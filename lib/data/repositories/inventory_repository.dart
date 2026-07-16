// Repository quản lý tồn kho (UC14, UC17): xem theo chi nhánh, điều chỉnh thủ công, xem log.
// adjustQuantity() dùng Transaction để ghi đồng thời inventory doc và log trong một lần atomic.
// watchLowStock() lọc sản phẩm dưới ngưỡng AppConstants.lowStockThreshold.
import 'package:cloud_firestore/cloud_firestore.dart';

import '../../core/constants/app_constants.dart';
import '../../core/constants/firestore_paths.dart';
import '../../core/constants/order_status.dart';
import '../../core/errors/app_exceptions.dart';
import '../../models/inventory_model.dart';

/// Quản lý tồn kho theo chi nhánh và nhật ký thay đổi (UC14, UC17).
class InventoryRepository {
  InventoryRepository({required FirebaseFirestore firestore})
      : _firestore = firestore;

  final FirebaseFirestore _firestore;

  /// Stream tồn kho của một chi nhánh.
  Stream<List<Inventory>> watchByBranch(String branchId) {
    return _firestore
        .collection(FirestorePaths.inventory)
        .where('branchId', isEqualTo: branchId)
        .snapshots()
        .map((snap) =>
            snap.docs.map((d) => Inventory.fromMap(d.data(), d.id)).toList());
  }

  /// Tồn kho thấp hơn ngưỡng cảnh báo (báo cáo tồn kho thấp - Mục 17.3).
  Stream<List<Inventory>> watchLowStock(String branchId) {
    return _firestore
        .collection(FirestorePaths.inventory)
        .where('branchId', isEqualTo: branchId)
        .where('quantity', isLessThan: AppConstants.lowStockThreshold)
        .snapshots()
        .map((snap) =>
            snap.docs.map((d) => Inventory.fromMap(d.data(), d.id)).toList());
  }

  Future<Inventory?> getInventory({
    required String branchId,
    required String productId,
  }) async {
    final id = FirestorePaths.inventoryId(branchId, productId);
    final doc = await _firestore.doc(FirestorePaths.inventoryDoc(id)).get();
    if (!doc.exists || doc.data() == null) return null;
    return Inventory.fromMap(doc.data()!, doc.id);
  }

  /// Điều chỉnh tồn kho thủ công (UC14) - ghi kèm log.
  Future<void> adjustQuantity({
    required String branchId,
    required String productId,
    required int newQuantity,
    required String userId,
    String? note,
  }) async {
    if (newQuantity < 0) {
      throw const ValidationException('Số lượng tồn kho không được âm.');
    }
    final id = FirestorePaths.inventoryId(branchId, productId);
    final invRef = _firestore.doc(FirestorePaths.inventoryDoc(id));

    try {
      await _firestore.runTransaction((transaction) async {
        final snap = await transaction.get(invRef);
        final oldQuantity =
            (snap.data()?['quantity'] as num?)?.toInt() ?? 0;

        transaction.set(invRef, {
          'inventoryId': id,
          'branchId': branchId,
          'productId': productId,
          'quantity': newQuantity,
          'lastUpdated': FieldValue.serverTimestamp(),
        });

        final logRef =
            _firestore.collection(FirestorePaths.inventoryLogs(id)).doc();
        transaction.set(logRef, {
          'changeType': InventoryChangeType.adjustment.value,
          'quantityChanged': newQuantity - oldQuantity,
          'createdBy': userId,
          'createdAt': FieldValue.serverTimestamp(),
          'note': note,
        });
      });
    } on FirebaseException catch (e) {
      throw DataException('Cập nhật tồn kho thất bại.', code: e.code);
    }
  }

  Stream<List<InventoryLog>> watchLogs({
    required String branchId,
    required String productId,
  }) {
    final id = FirestorePaths.inventoryId(branchId, productId);
    return _firestore
        .collection(FirestorePaths.inventoryLogs(id))
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snap) => snap.docs
            .map((d) => InventoryLog.fromMap(d.data(), d.id))
            .toList());
  }
}
