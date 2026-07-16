// Repository danh mục sản phẩm (UC25): CRUD và stream realtime.
// Dùng cho cả khách hàng (lọc sản phẩm) và admin (quản lý danh mục).
import 'package:cloud_firestore/cloud_firestore.dart';

import '../../core/constants/firestore_paths.dart';
import '../../core/errors/app_exceptions.dart';
import '../../models/category_model.dart';

/// Quản lý danh mục sản phẩm (UC25).
class CategoryRepository {
  CategoryRepository({required FirebaseFirestore firestore})
      : _firestore = firestore;

  final FirebaseFirestore _firestore;

  Stream<List<Category>> watchCategories() {
    return _firestore
        .collection(FirestorePaths.categories)
        .snapshots()
        .map((snap) =>
            snap.docs.map((d) => Category.fromMap(d.data(), d.id)).toList());
  }

  Future<List<Category>> getCategories() async {
    try {
      final snap = await _firestore.collection(FirestorePaths.categories).get();
      return snap.docs.map((d) => Category.fromMap(d.data(), d.id)).toList();
    } on FirebaseException catch (e) {
      throw DataException('Không thể tải danh mục.', code: e.code);
    }
  }

  Future<void> addCategory(Category category) async {
    try {
      await _firestore
          .collection(FirestorePaths.categories)
          .add(category.toMap());
    } on FirebaseException catch (e) {
      throw DataException('Thêm danh mục thất bại.', code: e.code);
    }
  }

  Future<void> updateCategory(Category category) async {
    try {
      await _firestore
          .doc(FirestorePaths.category(category.id))
          .update(category.toMap());
    } on FirebaseException catch (e) {
      throw DataException('Cập nhật danh mục thất bại.', code: e.code);
    }
  }

  Future<void> deleteCategory(String id) async {
    try {
      await _firestore.doc(FirestorePaths.category(id)).delete();
    } on FirebaseException catch (e) {
      throw DataException('Xóa danh mục thất bại.', code: e.code);
    }
  }
}
