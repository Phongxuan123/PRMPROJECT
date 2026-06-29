import 'package:cloud_firestore/cloud_firestore.dart';

import '../../core/constants/firestore_paths.dart';
import '../../core/errors/app_exceptions.dart';
import '../../models/voucher_model.dart';

/// Quản lý mã giảm giá (UC08 - áp voucher, UC26 - quản lý).
class VoucherRepository {
  VoucherRepository({required FirebaseFirestore firestore})
      : _firestore = firestore;

  final FirebaseFirestore _firestore;

  Stream<List<Voucher>> watchVouchers() {
    return _firestore
        .collection(FirestorePaths.vouchers)
        .snapshots()
        .map((snap) =>
            snap.docs.map((d) => Voucher.fromMap(d.data(), d.id)).toList());
  }

  /// Tìm voucher theo mã và kiểm tra điều kiện áp dụng (Mục 15.3).
  ///
  /// Throws [InvalidVoucherException] nếu không hợp lệ.
  Future<Voucher> validateVoucher({
    required String code,
    required double orderAmount,
  }) async {
    final snap = await _firestore
        .collection(FirestorePaths.vouchers)
        .where('code', isEqualTo: code.trim())
        .limit(1)
        .get();

    if (snap.docs.isEmpty) {
      throw const InvalidVoucherException('Mã giảm giá không tồn tại.');
    }

    final voucher = Voucher.fromMap(snap.docs.first.data(), snap.docs.first.id);

    if (!voucher.isUsable) {
      throw const InvalidVoucherException(
          'Mã giảm giá đã hết hạn hoặc hết lượt.');
    }
    if (orderAmount < voucher.minOrderAmount) {
      throw const InvalidVoucherException(
          'Đơn hàng chưa đạt giá trị tối thiểu để áp mã.');
    }
    return voucher;
  }

  Future<void> addVoucher(Voucher voucher) async {
    try {
      await _firestore.collection(FirestorePaths.vouchers).add(voucher.toMap());
    } on FirebaseException catch (e) {
      throw DataException('Thêm voucher thất bại.', code: e.code);
    }
  }

  Future<void> updateVoucher(Voucher voucher) async {
    try {
      await _firestore
          .doc(FirestorePaths.voucher(voucher.id))
          .update(voucher.toMap());
    } on FirebaseException catch (e) {
      throw DataException('Cập nhật voucher thất bại.', code: e.code);
    }
  }

  Future<void> deleteVoucher(String id) async {
    try {
      await _firestore.doc(FirestorePaths.voucher(id)).delete();
    } on FirebaseException catch (e) {
      throw DataException('Xóa voucher thất bại.', code: e.code);
    }
  }
}
