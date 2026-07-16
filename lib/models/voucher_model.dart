// Model mã giảm giá, ánh xạ collection vouchers/{voucherId}.
// Khách hàng nhập code khi checkout; server kiểm tra isUsable và trừ lượt trong Transaction.
import 'package:cloud_firestore/cloud_firestore.dart';

import '../core/utils/firestore_utils.dart';

/// Mã giảm giá, ánh xạ vouchers/{voucherId}.
class Voucher {
  const Voucher({
    required this.id,
    required this.code,
    required this.discountValue,
    required this.minOrderAmount,
    required this.expiredDate,
    required this.quantity,
    this.status = true,
  });

  final String id;
  final String code;

  /// Số tiền giảm trực tiếp.
  final double discountValue;
  final double minOrderAmount;
  final DateTime expiredDate;
  final int quantity;
  final bool status;

  /// Voucher còn dùng được: active, còn lượt, chưa hết hạn.
  bool get isUsable {
    return status && quantity > 0 && DateTime.now().isBefore(expiredDate);
  }

  factory Voucher.fromMap(Map<String, dynamic> map, String id) {
    return Voucher(
      id: id,
      code: FirestoreUtils.asString(map['code']),
      discountValue: FirestoreUtils.asDouble(map['discountValue']),
      minOrderAmount: FirestoreUtils.asDouble(map['minOrderAmount']),
      expiredDate: FirestoreUtils.asDateTime(map['expiredDate']),
      quantity: FirestoreUtils.asInt(map['quantity']),
      status: FirestoreUtils.asBool(map['status'], fallback: true),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'code': code,
      'discountValue': discountValue,
      'minOrderAmount': minOrderAmount,
      'expiredDate': Timestamp.fromDate(expiredDate),
      'quantity': quantity,
      'status': status,
    };
  }

  Voucher copyWith({
    String? code,
    double? discountValue,
    double? minOrderAmount,
    DateTime? expiredDate,
    int? quantity,
    bool? status,
  }) {
    return Voucher(
      id: id,
      code: code ?? this.code,
      discountValue: discountValue ?? this.discountValue,
      minOrderAmount: minOrderAmount ?? this.minOrderAmount,
      expiredDate: expiredDate ?? this.expiredDate,
      quantity: quantity ?? this.quantity,
      status: status ?? this.status,
    );
  }
}
