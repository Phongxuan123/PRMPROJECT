// Định nghĩa enum vai trò (UserRole) và trạng thái tài khoản (UserStatus).
// Giá trị string của enum được lưu vào Firestore để ánh xạ qua lại.
/// Vai trò người dùng trong hệ thống.
///
/// Giá trị [value] được lưu vào field `role` của document users/{uid}.
enum UserRole {
  admin('admin'),
  branchManager('branchManager'),
  staff('staff'),
  customer('customer');

  const UserRole(this.value);

  final String value;

  /// Chuyển chuỗi từ Firestore thành enum, mặc định là [customer] nếu không khớp.
  static UserRole fromValue(String? value) {
    return UserRole.values.firstWhere(
      (role) => role.value == value,
      orElse: () => UserRole.customer,
    );
  }

  /// Nhân viên trở lên (staff, branchManager, admin) có quyền quản trị dữ liệu.
  bool get isStaffOrAbove =>
      this == UserRole.staff ||
      this == UserRole.branchManager ||
      this == UserRole.admin;

  /// Tên hiển thị tiếng Việt cho UI.
  String get displayName {
    switch (this) {
      case UserRole.admin:
        return 'Quản trị viên';
      case UserRole.branchManager:
        return 'Quản lý chi nhánh';
      case UserRole.staff:
        return 'Nhân viên';
      case UserRole.customer:
        return 'Khách hàng';
    }
  }
}

/// Trạng thái tài khoản người dùng.
enum UserStatus {
  active('active'),
  inactive('inactive'),
  blocked('blocked');

  const UserStatus(this.value);

  final String value;

  static UserStatus fromValue(String? value) {
    return UserStatus.values.firstWhere(
      (status) => status.value == value,
      orElse: () => UserStatus.active,
    );
  }

  String get displayName {
    switch (this) {
      case UserStatus.active:
        return 'Hoạt động';
      case UserStatus.inactive:
        return 'Ngừng hoạt động';
      case UserStatus.blocked:
        return 'Bị khóa';
    }
  }
}
