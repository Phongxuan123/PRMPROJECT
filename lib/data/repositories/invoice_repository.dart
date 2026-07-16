// Repository tra cứu hóa đơn (UC16).
// Hóa đơn được tạo tự động bởi OrderRepository khi đơn hàng chuyển sang completed.
// Repository này chỉ có chức năng đọc (không tạo/sửa/xóa hóa đơn trực tiếp).
import 'package:cloud_firestore/cloud_firestore.dart';

import '../../core/constants/firestore_paths.dart';
import '../../core/errors/app_exceptions.dart';
import '../../models/invoice_model.dart';

/// Truy vấn hóa đơn (UC16). Hóa đơn được tạo bởi [OrderRepository] khi
/// đơn hàng hoàn thành.
class InvoiceRepository {
  InvoiceRepository({required FirebaseFirestore firestore})
      : _firestore = firestore;

  final FirebaseFirestore _firestore;

  /// Hóa đơn ứng với một đơn hàng (null nếu đơn chưa hoàn thành).
  Future<Invoice?> getByOrder(String orderId) async {
    try {
      final snap = await _firestore
          .collection(FirestorePaths.invoices)
          .where('orderId', isEqualTo: orderId)
          .limit(1)
          .get();
      if (snap.docs.isEmpty) return null;
      return Invoice.fromMap(snap.docs.first.data(), snap.docs.first.id);
    } on FirebaseException catch (e) {
      throw DataException('Không thể tải hóa đơn.', code: e.code);
    }
  }
}
