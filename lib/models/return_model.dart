import 'package:cloud_firestore/cloud_firestore.dart';

import '../core/constants/order_status.dart';
import '../core/utils/firestore_utils.dart';

/// Yêu cầu hoàn trả hàng, ánh xạ returns/{returnId}.
///
/// Optional - thiết kế sẵn, triển khai ở phase sau (xem Mục 20 tài liệu).
class ReturnRequest {
  const ReturnRequest({
    required this.id,
    required this.orderId,
    required this.userId,
    required this.reason,
    required this.status,
    required this.createdAt,
    this.details = const [],
  });

  final String id;
  final String orderId;
  final String userId;
  final String reason;
  final ReturnStatus status;
  final DateTime createdAt;
  final List<ReturnDetail> details;

  factory ReturnRequest.fromMap(Map<String, dynamic> map, String id,
      {List<ReturnDetail> details = const []}) {
    return ReturnRequest(
      id: id,
      orderId: FirestoreUtils.asString(map['orderId']),
      userId: FirestoreUtils.asString(map['userId']),
      reason: FirestoreUtils.asString(map['reason']),
      status:
          ReturnStatus.fromValue(FirestoreUtils.asStringOrNull(map['status'])),
      createdAt: FirestoreUtils.asDateTime(map['createdAt']),
      details: details,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'orderId': orderId,
      'userId': userId,
      'reason': reason,
      'status': status.value,
      'createdAt': FieldValue.serverTimestamp(),
    };
  }
}

/// Chi tiết hoàn trả, ánh xạ returns/{returnId}/details/{detailId}.
class ReturnDetail {
  const ReturnDetail({
    required this.id,
    required this.productId,
    required this.quantity,
  });

  final String id;
  final String productId;
  final int quantity;

  factory ReturnDetail.fromMap(Map<String, dynamic> map, String id) {
    return ReturnDetail(
      id: id,
      productId: FirestoreUtils.asString(map['productId']),
      quantity: FirestoreUtils.asInt(map['quantity']),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'productId': productId,
      'quantity': quantity,
    };
  }
}
