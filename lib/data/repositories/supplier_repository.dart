import 'package:cloud_firestore/cloud_firestore.dart';

import '../../core/constants/firestore_paths.dart';
import '../../core/errors/app_exceptions.dart';
import '../../models/supplier_model.dart';

/// Quản lý nhà cung cấp (UC21).
class SupplierRepository {
  SupplierRepository({required FirebaseFirestore firestore})
      : _firestore = firestore;

  final FirebaseFirestore _firestore;

  Stream<List<Supplier>> watchSuppliers() {
    return _firestore
        .collection(FirestorePaths.suppliers)
        .snapshots()
        .map((snap) =>
            snap.docs.map((d) => Supplier.fromMap(d.data(), d.id)).toList());
  }

  Future<List<Supplier>> getSuppliers() async {
    try {
      final snap = await _firestore.collection(FirestorePaths.suppliers).get();
      return snap.docs.map((d) => Supplier.fromMap(d.data(), d.id)).toList();
    } on FirebaseException catch (e) {
      throw DataException('Không thể tải nhà cung cấp.', code: e.code);
    }
  }

  Future<void> addSupplier(Supplier supplier) async {
    try {
      await _firestore
          .collection(FirestorePaths.suppliers)
          .add(supplier.toMap());
    } on FirebaseException catch (e) {
      throw DataException('Thêm nhà cung cấp thất bại.', code: e.code);
    }
  }

  Future<void> updateSupplier(Supplier supplier) async {
    try {
      await _firestore
          .doc(FirestorePaths.supplier(supplier.id))
          .update(supplier.toMap());
    } on FirebaseException catch (e) {
      throw DataException('Cập nhật nhà cung cấp thất bại.', code: e.code);
    }
  }

  Future<void> deleteSupplier(String id) async {
    try {
      await _firestore.doc(FirestorePaths.supplier(id)).delete();
    } on FirebaseException catch (e) {
      throw DataException('Xóa nhà cung cấp thất bại.', code: e.code);
    }
  }
}
