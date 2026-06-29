import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../core/constants/user_role.dart';
import '../models/user_model.dart';
import 'auth_provider.dart';
import 'repository_providers.dart';

/// Địa chỉ giao hàng của người dùng đang đăng nhập (UC06).
final myAddressesProvider = StreamProvider<List<Address>>((ref) {
  final user = ref.watch(currentUserProvider).valueOrNull;
  if (user == null) return Stream.value(const []);
  return ref.watch(userRepositoryProvider).watchAddresses(user.uid);
});

/// Thông báo trong app của người dùng đang đăng nhập.
final myNotificationsProvider = StreamProvider<List<AppNotification>>((ref) {
  final user = ref.watch(currentUserProvider).valueOrNull;
  if (user == null) return Stream.value(const []);
  return ref.watch(userRepositoryProvider).watchNotifications(user.uid);
});

/// Số thông báo chưa đọc (để hiện badge).
final unreadNotificationCountProvider = Provider<int>((ref) {
  final list = ref.watch(myNotificationsProvider).valueOrNull ?? const [];
  return list.where((n) => !n.isRead).length;
});

/// Tất cả tài khoản (Admin - UC23).
final allUsersProvider = StreamProvider<List<AppUser>>((ref) {
  return ref.watch(userRepositoryProvider).watchAllUsers();
});

/// Nhân viên thuộc một chi nhánh (BranchManager - UC19).
final branchStaffProvider =
    StreamProvider.family<List<AppUser>, String>((ref, branchId) {
  return ref.watch(userRepositoryProvider).watchStaffByBranch(branchId);
});

/// Danh sách khách hàng (Staff xem - UC15).
final customersProvider = StreamProvider<List<AppUser>>((ref) {
  return ref
      .watch(userRepositoryProvider)
      .watchUsersByRole(UserRole.customer);
});
