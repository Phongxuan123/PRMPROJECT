// Repository quản lý chi nhánh siêu thị (UC20).
// Cung cấp CRUD và stream realtime danh sách chi nhánh cho Admin và Manager.
import 'package:cloud_firestore/cloud_firestore.dart';

import '../../core/constants/firestore_paths.dart';
import '../../core/errors/app_exceptions.dart';
import '../../models/branch_model.dart';

/// Quản lý chi nhánh (UC20).
class BranchRepository {
  BranchRepository({required FirebaseFirestore firestore})
      : _firestore = firestore;

  final FirebaseFirestore _firestore;

  Stream<List<Branch>> watchBranches() {
    return _firestore
        .collection(FirestorePaths.branches)
        .snapshots()
        .map((snap) =>
            snap.docs.map((d) => Branch.fromMap(d.data(), d.id)).toList());
  }

  Future<List<Branch>> getBranches() async {
    try {
      final snap = await _firestore.collection(FirestorePaths.branches).get();
      return snap.docs.map((d) => Branch.fromMap(d.data(), d.id)).toList();
    } on FirebaseException catch (e) {
      throw DataException('Không thể tải chi nhánh.', code: e.code);
    }
  }

  Future<Branch?> getBranch(String id) async {
    try {
      final doc = await _firestore.doc(FirestorePaths.branch(id)).get();
      if (!doc.exists || doc.data() == null) return null;
      return Branch.fromMap(doc.data()!, doc.id);
    } on FirebaseException catch (e) {
      throw DataException('Không thể tải chi nhánh.', code: e.code);
    }
  }

  Future<void> addBranch(Branch branch) async {
    try {
      await _firestore.collection(FirestorePaths.branches).add(branch.toMap());
    } on FirebaseException catch (e) {
      throw DataException('Thêm chi nhánh thất bại.', code: e.code);
    }
  }

  Future<void> updateBranch(Branch branch) async {
    try {
      await _firestore
          .doc(FirestorePaths.branch(branch.id))
          .update(branch.toMap());
    } on FirebaseException catch (e) {
      throw DataException('Cập nhật chi nhánh thất bại.', code: e.code);
    }
  }

  Future<void> deleteBranch(String id) async {
    try {
      await _firestore.doc(FirestorePaths.branch(id)).delete();
    } on FirebaseException catch (e) {
      throw DataException('Xóa chi nhánh thất bại.', code: e.code);
    }
  }
}
