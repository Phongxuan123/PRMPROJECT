import 'package:cloud_firestore/cloud_firestore.dart';

import '../core/utils/firestore_utils.dart';

/// Hóa đơn, ánh xạ invoices/{invoiceId}.
class Invoice {
  const Invoice({
    required this.id,
    required this.orderId,
    required this.staffId,
    required this.invoiceDate,
    required this.totalAmount,
  });

  final String id;
  final String orderId;
  final String staffId;
  final DateTime invoiceDate;
  final double totalAmount;

  factory Invoice.fromMap(Map<String, dynamic> map, String id) {
    return Invoice(
      id: id,
      orderId: FirestoreUtils.asString(map['orderId']),
      staffId: FirestoreUtils.asString(map['staffId']),
      invoiceDate: FirestoreUtils.asDateTime(map['invoiceDate']),
      totalAmount: FirestoreUtils.asDouble(map['totalAmount']),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'orderId': orderId,
      'staffId': staffId,
      'invoiceDate': FieldValue.serverTimestamp(),
      'totalAmount': totalAmount,
    };
  }
}
