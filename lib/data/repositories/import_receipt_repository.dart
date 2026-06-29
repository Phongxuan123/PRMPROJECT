import 'package:cloud_firestore/cloud_firestore.dart';

import '../../core/constants/firestore_paths.dart';
import '../../core/constants/order_status.dart';
import '../../core/errors/app_exceptions.dart';
import '../../models/import_receipt_model.dart';

/// Tham số tạo phiếu nhập hàng.
class CreateImportParams {
  const CreateImportParams({
    required this.supplierId,
    required this.branchId,
    required this.createdBy,
    required this.details,
  });

  final String supplierId;
  final String branchId;
  final String createdBy;
  final List<ImportDetail> details;

  double get totalAmount =>
      details.fold(0, (acc, d) => acc + d.subtotal);
}

/// Quản lý phiếu nhập hàng (UC18).
///
/// Tạo phiếu nhập và cộng tồn kho trong một Transaction (Mục 14.2).
class ImportReceiptRepository {
  ImportReceiptRepository({required FirebaseFirestore firestore})
      : _firestore = firestore;

  final FirebaseFirestore _firestore;

  Stream<List<ImportReceipt>> watchByBranch(String branchId) {
    return _firestore
        .collection(FirestorePaths.importReceipts)
        .where('branchId', isEqualTo: branchId)
        .orderBy('importDate', descending: true)
        .snapshots()
        .map((snap) => snap.docs
            .map((d) => ImportReceipt.fromMap(d.data(), d.id))
            .toList());
  }

  Future<ImportReceipt?> getWithDetails(String receiptId) async {
    final doc =
        await _firestore.doc(FirestorePaths.importReceipt(receiptId)).get();
    if (!doc.exists || doc.data() == null) return null;
    final detailSnap = await _firestore
        .collection(FirestorePaths.importReceiptDetails(receiptId))
        .get();
    final details = detailSnap.docs
        .map((d) => ImportDetail.fromMap(d.data(), d.id))
        .toList();
    return ImportReceipt.fromMap(doc.data()!, doc.id, details: details);
  }

  /// Tạo phiếu nhập và cập nhật tồn kho trong Transaction.
  Future<String> createImportReceipt(CreateImportParams params) async {
    if (params.details.isEmpty) {
      throw const ValidationException('Phiếu nhập phải có ít nhất 1 sản phẩm.');
    }

    final receiptRef =
        _firestore.collection(FirestorePaths.importReceipts).doc();

    try {
      await _firestore.runTransaction((transaction) async {
        // Đọc tồn kho hiện tại trước.
        final currentQty = <String, int>{};
        for (final detail in params.details) {
          final invId =
              FirestorePaths.inventoryId(params.branchId, detail.productId);
          final invRef = _firestore.doc(FirestorePaths.inventoryDoc(invId));
          final snap = await transaction.get(invRef);
          currentQty[detail.productId] =
              (snap.data()?['quantity'] as num?)?.toInt() ?? 0;
        }

        // Ghi phiếu nhập.
        transaction.set(receiptRef, {
          'supplierId': params.supplierId,
          'branchId': params.branchId,
          'createdBy': params.createdBy,
          'importDate': FieldValue.serverTimestamp(),
          'totalAmount': params.totalAmount,
        });

        for (final detail in params.details) {
          final detailRef = _firestore
              .collection(
                  FirestorePaths.importReceiptDetails(receiptRef.id))
              .doc();
          transaction.set(detailRef, detail.toMap());

          final invId =
              FirestorePaths.inventoryId(params.branchId, detail.productId);
          final invRef = _firestore.doc(FirestorePaths.inventoryDoc(invId));
          transaction.set(invRef, {
            'inventoryId': invId,
            'branchId': params.branchId,
            'productId': detail.productId,
            'quantity': currentQty[detail.productId]! + detail.quantity,
            'lastUpdated': FieldValue.serverTimestamp(),
          }, SetOptions(merge: true));

          final logRef =
              _firestore.collection(FirestorePaths.inventoryLogs(invId)).doc();
          transaction.set(logRef, {
            'changeType': InventoryChangeType.import.value,
            'quantityChanged': detail.quantity,
            'createdBy': params.createdBy,
            'createdAt': FieldValue.serverTimestamp(),
            'note': 'Nhập hàng ${receiptRef.id}',
          });
        }
      });
      return receiptRef.id;
    } on AppException {
      rethrow;
    } on FirebaseException catch (e) {
      throw DataException('Tạo phiếu nhập thất bại.', code: e.code);
    }
  }
}
