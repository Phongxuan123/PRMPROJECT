// Repository khuyến mãi (UC04, UC26): CRUD và stream riêng cho Admin và khách hàng.
// watchActivePromotions() lọc thêm ở client-side theo isActive (kết hợp status + thời gian).
import 'package:cloud_firestore/cloud_firestore.dart';

import '../../core/constants/firestore_paths.dart';
import '../../core/errors/app_exceptions.dart';
import '../../models/promotion_model.dart';

/// Quản lý chương trình khuyến mãi (UC04, UC26).
class PromotionRepository {
  PromotionRepository({required FirebaseFirestore firestore})
      : _firestore = firestore;

  final FirebaseFirestore _firestore;

  Stream<List<Promotion>> watchPromotions() {
    return _firestore
        .collection(FirestorePaths.promotions)
        .snapshots()
        .map((snap) =>
            snap.docs.map((d) => Promotion.fromMap(d.data(), d.id)).toList());
  }

  /// Khuyến mãi đang hoạt động (status == true) cho Guest/Customer xem.
  Stream<List<Promotion>> watchActivePromotions() {
    return _firestore
        .collection(FirestorePaths.promotions)
        .where('status', isEqualTo: true)
        .snapshots()
        .map((snap) => snap.docs
            .map((d) => Promotion.fromMap(d.data(), d.id))
            .where((p) => p.isActive)
            .toList());
  }

  Future<void> addPromotion(Promotion promotion) async {
    try {
      await _firestore
          .collection(FirestorePaths.promotions)
          .add(promotion.toMap());
    } on FirebaseException catch (e) {
      throw DataException('Thêm khuyến mãi thất bại.', code: e.code);
    }
  }

  Future<void> updatePromotion(Promotion promotion) async {
    try {
      await _firestore
          .doc(FirestorePaths.promotion(promotion.id))
          .update(promotion.toMap());
    } on FirebaseException catch (e) {
      throw DataException('Cập nhật khuyến mãi thất bại.', code: e.code);
    }
  }

  Future<void> deletePromotion(String id) async {
    try {
      await _firestore.doc(FirestorePaths.promotion(id)).delete();
    } on FirebaseException catch (e) {
      throw DataException('Xóa khuyến mãi thất bại.', code: e.code);
    }
  }
}
