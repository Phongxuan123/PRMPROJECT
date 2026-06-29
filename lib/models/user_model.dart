import 'package:cloud_firestore/cloud_firestore.dart';

import '../core/constants/user_role.dart';
import '../core/utils/firestore_utils.dart';

/// Mô hình người dùng, ánh xạ document users/{uid}.
///
/// Đặt tên [AppUser] để tránh trùng với `User` của package firebase_auth.
class AppUser {
  const AppUser({
    required this.uid,
    required this.fullName,
    required this.email,
    required this.role,
    this.phone,
    this.avatarUrl,
    this.branchId,
    this.status = UserStatus.active,
    this.createdAt,
    this.updatedAt,
  });

  final String uid;
  final String fullName;
  final String email;
  final UserRole role;
  final String? phone;
  final String? avatarUrl;

  /// Null nếu là Admin hoặc Customer.
  final String? branchId;
  final UserStatus status;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  factory AppUser.fromMap(Map<String, dynamic> map, String uid) {
    return AppUser(
      uid: uid,
      fullName: FirestoreUtils.asString(map['fullName']),
      email: FirestoreUtils.asString(map['email']),
      role: UserRole.fromValue(FirestoreUtils.asStringOrNull(map['role'])),
      phone: FirestoreUtils.asStringOrNull(map['phone']),
      avatarUrl: FirestoreUtils.asStringOrNull(map['avatarUrl']),
      branchId: FirestoreUtils.asStringOrNull(map['branchId']),
      status:
          UserStatus.fromValue(FirestoreUtils.asStringOrNull(map['status'])),
      createdAt: FirestoreUtils.asDateTimeOrNull(map['createdAt']),
      updatedAt: FirestoreUtils.asDateTimeOrNull(map['updatedAt']),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'uid': uid,
      'fullName': fullName,
      'email': email,
      'role': role.value,
      'phone': phone,
      'avatarUrl': avatarUrl,
      'branchId': branchId,
      'status': status.value,
      'createdAt':
          createdAt == null ? FieldValue.serverTimestamp() : Timestamp.fromDate(createdAt!),
      'updatedAt': FieldValue.serverTimestamp(),
    };
  }

  AppUser copyWith({
    String? fullName,
    String? phone,
    String? avatarUrl,
    UserRole? role,
    String? branchId,
    UserStatus? status,
  }) {
    return AppUser(
      uid: uid,
      fullName: fullName ?? this.fullName,
      email: email,
      role: role ?? this.role,
      phone: phone ?? this.phone,
      avatarUrl: avatarUrl ?? this.avatarUrl,
      branchId: branchId ?? this.branchId,
      status: status ?? this.status,
      createdAt: createdAt,
      updatedAt: updatedAt,
    );
  }
}

/// Địa chỉ giao hàng, ánh xạ users/{uid}/addresses/{addressId}.
class Address {
  const Address({
    required this.id,
    required this.receiverName,
    required this.phoneNumber,
    required this.addressDetail,
    this.isDefault = false,
  });

  final String id;
  final String receiverName;
  final String phoneNumber;
  final String addressDetail;
  final bool isDefault;

  factory Address.fromMap(Map<String, dynamic> map, String id) {
    return Address(
      id: id,
      receiverName: FirestoreUtils.asString(map['receiverName']),
      phoneNumber: FirestoreUtils.asString(map['phoneNumber']),
      addressDetail: FirestoreUtils.asString(map['addressDetail']),
      isDefault: FirestoreUtils.asBool(map['isDefault']),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'receiverName': receiverName,
      'phoneNumber': phoneNumber,
      'addressDetail': addressDetail,
      'isDefault': isDefault,
    };
  }
}

/// Thông báo trong app, ánh xạ users/{uid}/notifications/{notificationId}.
class AppNotification {
  const AppNotification({
    required this.id,
    required this.title,
    required this.content,
    required this.isRead,
    required this.createdAt,
  });

  final String id;
  final String title;
  final String content;
  final bool isRead;
  final DateTime createdAt;

  factory AppNotification.fromMap(Map<String, dynamic> map, String id) {
    return AppNotification(
      id: id,
      title: FirestoreUtils.asString(map['title']),
      content: FirestoreUtils.asString(map['content']),
      isRead: FirestoreUtils.asBool(map['isRead']),
      createdAt: FirestoreUtils.asDateTime(map['createdAt']),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'title': title,
      'content': content,
      'isRead': isRead,
      'createdAt': Timestamp.fromDate(createdAt),
    };
  }
}
