// Model chương trình khuyến mãi, ánh xạ collection promotions/{promotionId}.
// Mỗi khuyến mãi giảm theo % và chỉ áp dụng cho danh sách productIds cụ thể.
// Kiểm tra isActive trước khi hiển thị cho khách hàng.
import 'package:cloud_firestore/cloud_firestore.dart';

import '../core/utils/firestore_utils.dart';

/// Chương trình khuyến mãi, ánh xạ promotions/{promotionId}.
class Promotion {
  const Promotion({
    required this.id,
    required this.name,
    required this.discountPercent,
    required this.startDate,
    required this.endDate,
    this.status = true,
    this.productIds = const [],
  });

  final String id;
  final String name;
  final int discountPercent;
  final DateTime startDate;
  final DateTime endDate;
  final bool status;

  /// Danh sách productId được áp dụng khuyến mãi.
  final List<String> productIds;

  /// Khuyến mãi đang có hiệu lực (active và trong khoảng thời gian).
  bool get isActive {
    final now = DateTime.now();
    return status && now.isAfter(startDate) && now.isBefore(endDate);
  }

  factory Promotion.fromMap(Map<String, dynamic> map, String id) {
    return Promotion(
      id: id,
      name: FirestoreUtils.asString(map['name']),
      discountPercent: FirestoreUtils.asInt(map['discountPercent']),
      startDate: FirestoreUtils.asDateTime(map['startDate']),
      endDate: FirestoreUtils.asDateTime(map['endDate']),
      status: FirestoreUtils.asBool(map['status'], fallback: true),
      productIds: FirestoreUtils.asStringList(map['productIds']),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'discountPercent': discountPercent,
      'startDate': Timestamp.fromDate(startDate),
      'endDate': Timestamp.fromDate(endDate),
      'status': status,
      'productIds': productIds,
    };
  }

  Promotion copyWith({
    String? name,
    int? discountPercent,
    DateTime? startDate,
    DateTime? endDate,
    bool? status,
    List<String>? productIds,
  }) {
    return Promotion(
      id: id,
      name: name ?? this.name,
      discountPercent: discountPercent ?? this.discountPercent,
      startDate: startDate ?? this.startDate,
      endDate: endDate ?? this.endDate,
      status: status ?? this.status,
      productIds: productIds ?? this.productIds,
    );
  }
}
