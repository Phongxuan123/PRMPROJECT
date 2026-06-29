import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';

import '../../core/constants/firestore_paths.dart';
import '../../core/errors/app_exceptions.dart';
import '../../models/product_model.dart';
import '../firebase/firebase_storage_service.dart';

/// Quản lý sản phẩm, đánh giá và ảnh sản phẩm (UC03, UC11, UC13).
class ProductRepository {
  ProductRepository({
    required FirebaseFirestore firestore,
    required FirebaseStorageService storageService,
  })  : _firestore = firestore,
        _storage = storageService;

  final FirebaseFirestore _firestore;
  final FirebaseStorageService _storage;

  /// Stream sản phẩm đang bán (status == true) cho khách hàng.
  Stream<List<Product>> watchActiveProducts() {
    return _firestore
        .collection(FirestorePaths.products)
        .where('status', isEqualTo: true)
        .snapshots()
        .map((snap) =>
            snap.docs.map((d) => Product.fromMap(d.data(), d.id)).toList());
  }

  /// Stream tất cả sản phẩm (cho Staff/Admin quản lý).
  Stream<List<Product>> watchAllProducts() {
    return _firestore
        .collection(FirestorePaths.products)
        .snapshots()
        .map((snap) =>
            snap.docs.map((d) => Product.fromMap(d.data(), d.id)).toList());
  }

  Future<Product?> getProduct(String id) async {
    try {
      final doc = await _firestore.doc(FirestorePaths.product(id)).get();
      if (!doc.exists || doc.data() == null) return null;
      return Product.fromMap(doc.data()!, doc.id);
    } on FirebaseException catch (e) {
      throw DataException('Không thể tải sản phẩm.', code: e.code);
    }
  }

  /// Kiểm tra barcode đã tồn tại chưa (validation trước khi thêm - Mục 15.2).
  Future<bool> isBarcodeTaken(String barcode, {String? excludeId}) async {
    final snap = await _firestore
        .collection(FirestorePaths.products)
        .where('barcode', isEqualTo: barcode)
        .limit(2)
        .get();
    return snap.docs.any((d) => d.id != excludeId);
  }

  /// Thêm sản phẩm mới, trả về productId vừa tạo.
  Future<String> addProduct(Product product) async {
    try {
      if (await isBarcodeTaken(product.barcode)) {
        throw const ValidationException('Barcode đã tồn tại.');
      }
      final ref = await _firestore
          .collection(FirestorePaths.products)
          .add(product.toMap());
      return ref.id;
    } on FirebaseException catch (e) {
      throw DataException('Thêm sản phẩm thất bại.', code: e.code);
    }
  }

  Future<void> updateProduct(Product product) async {
    try {
      if (await isBarcodeTaken(product.barcode, excludeId: product.id)) {
        throw const ValidationException('Barcode đã tồn tại.');
      }
      // Không ghi đè createdAt khi cập nhật (toMap đặt serverTimestamp khi
      // createdAt == null sẽ làm mất ngày tạo gốc).
      final data = product.toMap()..remove('createdAt');
      await _firestore.doc(FirestorePaths.product(product.id)).update(data);
    } on FirebaseException catch (e) {
      throw DataException('Cập nhật sản phẩm thất bại.', code: e.code);
    }
  }

  Future<void> deleteProduct(String id) async {
    try {
      await _firestore.doc(FirestorePaths.product(id)).delete();
    } on FirebaseException catch (e) {
      throw DataException('Xóa sản phẩm thất bại.', code: e.code);
    }
  }

  /// Upload ảnh sản phẩm lên Storage, trả về URL tải xuống.
  Future<String> uploadImage({
    required File imageFile,
    required String productId,
    required int timestampMs,
  }) {
    return _storage.uploadProductImage(
      imageFile: imageFile,
      productId: productId,
      timestampMs: timestampMs,
    );
  }

  // --- Đánh giá sản phẩm (UC11) ---

  Stream<List<Review>> watchReviews(String productId) {
    return _firestore
        .collection(FirestorePaths.productReviews(productId))
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snap) =>
            snap.docs.map((d) => Review.fromMap(d.data(), d.id)).toList());
  }

  Future<void> addReview(String productId, Review review) async {
    try {
      await _firestore
          .collection(FirestorePaths.productReviews(productId))
          .add(review.toMap());
    } on FirebaseException catch (e) {
      throw DataException('Gửi đánh giá thất bại.', code: e.code);
    }
  }
}
