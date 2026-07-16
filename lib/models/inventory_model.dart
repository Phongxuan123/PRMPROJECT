// Model tồn kho theo chi nhánh và nhật ký thay đổi.
// Inventory ánh xạ inventory/{branchId_productId} (id kết hợp để tra cứu nhanh).
// InventoryLog ánh xạ inventory/{id}/logs/{logId} để ghi lịch sử thay đổi.
import 'package:cloud_firestore/cloud_firestore.dart';

import '../core/constants/order_status.dart';
import '../core/utils/firestore_utils.dart';

/// Tồn kho theo chi nhánh, ánh xạ inventory/{branchId_productId}.
class Inventory {
  const Inventory({
    required this.id,
    required this.branchId,
    required this.productId,
    required this.quantity,
    this.lastUpdated,
  });

  final String id;
  final String branchId;
  final String productId;
  final int quantity;
  final DateTime? lastUpdated;

  factory Inventory.fromMap(Map<String, dynamic> map, String id) {
    return Inventory(
      id: id,
      branchId: FirestoreUtils.asString(map['branchId']),
      productId: FirestoreUtils.asString(map['productId']),
      quantity: FirestoreUtils.asInt(map['quantity']),
      lastUpdated: FirestoreUtils.asDateTimeOrNull(map['lastUpdated']),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'inventoryId': id,
      'branchId': branchId,
      'productId': productId,
      'quantity': quantity,
      'lastUpdated': FieldValue.serverTimestamp(),
    };
  }
}

/// Nhật ký thay đổi tồn kho, ánh xạ inventory/{id}/logs/{logId}.
class InventoryLog {
  const InventoryLog({
    required this.id,
    required this.changeType,
    required this.quantityChanged,
    required this.createdBy,
    required this.createdAt,
    this.note,
  });

  final String id;
  final InventoryChangeType changeType;

  /// Số dương = thêm, số âm = trừ.
  final int quantityChanged;
  final String createdBy;
  final DateTime createdAt;
  final String? note;

  factory InventoryLog.fromMap(Map<String, dynamic> map, String id) {
    return InventoryLog(
      id: id,
      changeType: InventoryChangeType.fromValue(
          FirestoreUtils.asStringOrNull(map['changeType'])),
      quantityChanged: FirestoreUtils.asInt(map['quantityChanged']),
      createdBy: FirestoreUtils.asString(map['createdBy']),
      createdAt: FirestoreUtils.asDateTime(map['createdAt']),
      note: FirestoreUtils.asStringOrNull(map['note']),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'changeType': changeType.value,
      'quantityChanged': quantityChanged,
      'createdBy': createdBy,
      'createdAt': FieldValue.serverTimestamp(),
      'note': note,
    };
  }
}
