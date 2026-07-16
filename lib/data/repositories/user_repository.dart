// Repository người dùng: quản lý hồ sơ, địa chỉ giao hàng và thông báo in-app.
// watchUser() cung cấp stream realtime cho router và auth provider.
// Quản lý role/status dành riêng cho Admin (UC23, UC24).
import 'package:cloud_firestore/cloud_firestore.dart';

import '../../core/constants/firestore_paths.dart';
import '../../core/constants/user_role.dart';
import '../../core/errors/app_exceptions.dart';
import '../../models/user_model.dart';

/// Quản lý hồ sơ người dùng, địa chỉ giao hàng và thông báo trong app.
class UserRepository {
  UserRepository({required FirebaseFirestore firestore})
      : _firestore = firestore;

  final FirebaseFirestore _firestore;

  /// Stream hồ sơ người dùng để tự động cập nhật khi có thay đổi.
  Stream<AppUser?> watchUser(String uid) {
    return _firestore.doc(FirestorePaths.user(uid)).snapshots().map((doc) {
      if (!doc.exists || doc.data() == null) return null;
      return AppUser.fromMap(doc.data()!, doc.id);
    });
  }

  Future<AppUser?> getUser(String uid) async {
    try {
      final doc = await _firestore.doc(FirestorePaths.user(uid)).get();
      if (!doc.exists || doc.data() == null) return null;
      return AppUser.fromMap(doc.data()!, doc.id);
    } on FirebaseException catch (e) {
      throw DataException('Không thể đọc người dùng.', code: e.code);
    }
  }

  /// Cập nhật thông tin hồ sơ (UC05).
  Future<void> updateProfile({
    required String uid,
    String? fullName,
    String? phone,
    String? avatarUrl,
  }) async {
    try {
      final data = <String, dynamic>{'updatedAt': FieldValue.serverTimestamp()};
      if (fullName != null) data['fullName'] = fullName.trim();
      if (phone != null) data['phone'] = phone.trim();
      if (avatarUrl != null) data['avatarUrl'] = avatarUrl;

      await _firestore.doc(FirestorePaths.user(uid)).update(data);
    } on FirebaseException catch (e) {
      throw DataException('Cập nhật hồ sơ thất bại.', code: e.code);
    }
  }

  // --- Quản lý tài khoản (Admin) ---

  Stream<List<AppUser>> watchAllUsers() {
    return _firestore
        .collection(FirestorePaths.users)
        .snapshots()
        .map((snap) =>
            snap.docs.map((d) => AppUser.fromMap(d.data(), d.id)).toList());
  }

  Stream<List<AppUser>> watchUsersByRole(UserRole role) {
    return _firestore
        .collection(FirestorePaths.users)
        .where('role', isEqualTo: role.value)
        .snapshots()
        .map((snap) =>
            snap.docs.map((d) => AppUser.fromMap(d.data(), d.id)).toList());
  }

  /// Nhân viên thuộc một chi nhánh (BranchManager quản lý nhân viên - UC19).
  Stream<List<AppUser>> watchStaffByBranch(String branchId) {
    return _firestore
        .collection(FirestorePaths.users)
        .where('branchId', isEqualTo: branchId)
        .where('role', isEqualTo: UserRole.staff.value)
        .snapshots()
        .map((snap) =>
            snap.docs.map((d) => AppUser.fromMap(d.data(), d.id)).toList());
  }

  /// Gán role cho người dùng (UC24 - phân quyền).
  Future<void> updateRole({
    required String uid,
    required UserRole role,
    String? branchId,
  }) async {
    try {
      await _firestore.doc(FirestorePaths.user(uid)).update({
        'role': role.value,
        'branchId': branchId,
        'updatedAt': FieldValue.serverTimestamp(),
      });
    } on FirebaseException catch (e) {
      throw DataException('Cập nhật quyền thất bại.', code: e.code);
    }
  }

  /// Cập nhật trạng thái tài khoản (active / inactive / blocked).
  Future<void> updateStatus({
    required String uid,
    required UserStatus status,
  }) async {
    try {
      await _firestore.doc(FirestorePaths.user(uid)).update({
        'status': status.value,
        'updatedAt': FieldValue.serverTimestamp(),
      });
    } on FirebaseException catch (e) {
      throw DataException('Cập nhật trạng thái thất bại.', code: e.code);
    }
  }

  // --- Địa chỉ giao hàng (UC06) ---

  Stream<List<Address>> watchAddresses(String uid) {
    return _firestore
        .collection(FirestorePaths.userAddresses(uid))
        .snapshots()
        .map((snap) =>
            snap.docs.map((d) => Address.fromMap(d.data(), d.id)).toList());
  }

  Future<void> addAddress(String uid, Address address) async {
    try {
      await _firestore
          .collection(FirestorePaths.userAddresses(uid))
          .add(address.toMap());
    } on FirebaseException catch (e) {
      throw DataException('Thêm địa chỉ thất bại.', code: e.code);
    }
  }

  Future<void> updateAddress(String uid, Address address) async {
    try {
      await _firestore
          .collection(FirestorePaths.userAddresses(uid))
          .doc(address.id)
          .update(address.toMap());
    } on FirebaseException catch (e) {
      throw DataException('Cập nhật địa chỉ thất bại.', code: e.code);
    }
  }

  Future<void> deleteAddress(String uid, String addressId) async {
    try {
      await _firestore
          .collection(FirestorePaths.userAddresses(uid))
          .doc(addressId)
          .delete();
    } on FirebaseException catch (e) {
      throw DataException('Xóa địa chỉ thất bại.', code: e.code);
    }
  }

  // --- Thông báo trong app (UC "Nhận thông báo") ---

  Stream<List<AppNotification>> watchNotifications(String uid) {
    return _firestore
        .collection(FirestorePaths.userNotifications(uid))
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snap) => snap.docs
            .map((d) => AppNotification.fromMap(d.data(), d.id))
            .toList());
  }

  Future<void> markNotificationRead(String uid, String notificationId) async {
    try {
      await _firestore
          .collection(FirestorePaths.userNotifications(uid))
          .doc(notificationId)
          .update({'isRead': true});
    } on FirebaseException catch (e) {
      throw DataException('Cập nhật thông báo thất bại.', code: e.code);
    }
  }

  /// Tạo thông báo trong app cho người dùng (dùng khi đơn hàng đổi trạng thái).
  Future<void> pushNotification({
    required String uid,
    required String title,
    required String content,
  }) async {
    try {
      await _firestore.collection(FirestorePaths.userNotifications(uid)).add({
        'title': title,
        'content': content,
        'isRead': false,
        'createdAt': FieldValue.serverTimestamp(),
      });
    } on FirebaseException catch (e) {
      throw DataException('Gửi thông báo thất bại.', code: e.code);
    }
  }
}
