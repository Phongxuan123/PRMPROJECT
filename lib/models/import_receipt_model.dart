// Model phiếu nhập hàng từ nhà cung cấp.
// ImportReceipt ánh xạ importReceipts/{receiptId}, ImportDetail là subcollection details.
// Khi tạo phiếu nhập, tồn kho sẽ được cộng thêm trong một Firestore Transaction.
import 'package:cloud_firestore/cloud_firestore.dart';

import '../core/utils/firestore_utils.dart';

/// Phiếu nhập hàng, ánh xạ importReceipts/{receiptId}.
class ImportReceipt {
  const ImportReceipt({
    required this.id,
    required this.supplierId,
    required this.branchId,
    required this.createdBy,
    required this.importDate,
    required this.totalAmount,
    this.details = const [],
  });

  final String id;
  final String supplierId;
  final String branchId;
  final String createdBy;
  final DateTime importDate;
  final double totalAmount;
  final List<ImportDetail> details;

  factory ImportReceipt.fromMap(Map<String, dynamic> map, String id,
      {List<ImportDetail> details = const []}) {
    return ImportReceipt(
      id: id,
      supplierId: FirestoreUtils.asString(map['supplierId']),
      branchId: FirestoreUtils.asString(map['branchId']),
      createdBy: FirestoreUtils.asString(map['createdBy']),
      importDate: FirestoreUtils.asDateTime(map['importDate']),
      totalAmount: FirestoreUtils.asDouble(map['totalAmount']),
      details: details,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'supplierId': supplierId,
      'branchId': branchId,
      'createdBy': createdBy,
      'importDate': FieldValue.serverTimestamp(),
      'totalAmount': totalAmount,
    };
  }
}

/// Chi tiết phiếu nhập, ánh xạ importReceipts/{receiptId}/details/{detailId}.
class ImportDetail {
  const ImportDetail({
    required this.id,
    required this.productId,
    required this.productName,
    required this.quantity,
    required this.importPrice,
  });

  final String id;
  final String productId;
  final String productName;
  final int quantity;
  final double importPrice;

  double get subtotal => importPrice * quantity;

  factory ImportDetail.fromMap(Map<String, dynamic> map, String id) {
    return ImportDetail(
      id: id,
      productId: FirestoreUtils.asString(map['productId']),
      productName: FirestoreUtils.asString(map['productName']),
      quantity: FirestoreUtils.asInt(map['quantity']),
      importPrice: FirestoreUtils.asDouble(map['importPrice']),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'productId': productId,
      'productName': productName,
      'quantity': quantity,
      'importPrice': importPrice,
    };
  }
}
