import '../constants/app_constants.dart';

/// Tập hợp hàm validate dữ liệu nhập từ form.
///
/// Trả về `null` nếu hợp lệ, hoặc chuỗi thông báo lỗi nếu không hợp lệ
/// (phù hợp với `validator` của [TextFormField]).
class Validators {
  const Validators._();

  static final RegExp _emailRegExp =
      RegExp(r'^[\w.\-]+@([\w\-]+\.)+[\w\-]{2,}$');

  // Số điện thoại Việt Nam: 10 chữ số, bắt đầu bằng 0.
  static final RegExp _phoneRegExp = RegExp(r'^0\d{9}$');

  /// Email không được trống và phải đúng định dạng.
  static String? email(String? value) {
    final input = value?.trim() ?? '';
    if (input.isEmpty) return 'Vui lòng nhập email.';
    if (!_emailRegExp.hasMatch(input)) return 'Email không hợp lệ.';
    return null;
  }

  /// Mật khẩu tối thiểu [AppConstants.minPasswordLength] ký tự.
  static String? password(String? value) {
    final input = value ?? '';
    if (input.isEmpty) return 'Vui lòng nhập mật khẩu.';
    if (input.length < AppConstants.minPasswordLength) {
      return 'Mật khẩu tối thiểu ${AppConstants.minPasswordLength} ký tự.';
    }
    return null;
  }

  /// Xác nhận mật khẩu phải trùng với mật khẩu gốc.
  static String? confirmPassword(String? value, String original) {
    if ((value ?? '').isEmpty) return 'Vui lòng xác nhận mật khẩu.';
    if (value != original) return 'Mật khẩu xác nhận không khớp.';
    return null;
  }

  /// Số điện thoại Việt Nam (10 số, bắt đầu bằng 0).
  static String? phone(String? value) {
    final input = value?.trim() ?? '';
    if (input.isEmpty) return 'Vui lòng nhập số điện thoại.';
    if (!_phoneRegExp.hasMatch(input)) {
      return 'Số điện thoại không hợp lệ (10 số, bắt đầu bằng 0).';
    }
    return null;
  }

  /// Trường bắt buộc không được để trống.
  static String? required(String? value, {String field = 'Trường này'}) {
    if ((value ?? '').trim().isEmpty) return '$field không được để trống.';
    return null;
  }

  /// Giá trị số dương (> 0).
  static String? positiveNumber(String? value, {String field = 'Giá trị'}) {
    final input = value?.trim() ?? '';
    if (input.isEmpty) return '$field không được để trống.';
    final number = num.tryParse(input);
    if (number == null) return '$field phải là số.';
    if (number <= 0) return '$field phải lớn hơn 0.';
    return null;
  }

  /// Số nguyên không âm (>= 0).
  static String? nonNegativeInt(String? value, {String field = 'Giá trị'}) {
    final input = value?.trim() ?? '';
    if (input.isEmpty) return '$field không được để trống.';
    final number = int.tryParse(input);
    if (number == null) return '$field phải là số nguyên.';
    if (number < 0) return '$field không được âm.';
    return null;
  }

  /// Số nguyên dương (> 0). Dùng cho số lượng, phần trăm — tránh nhập số thập
  /// phân làm `int.parse` ném [FormatException] khi submit.
  static String? positiveInt(String? value, {String field = 'Giá trị'}) {
    final input = value?.trim() ?? '';
    if (input.isEmpty) return '$field không được để trống.';
    final number = int.tryParse(input);
    if (number == null) return '$field phải là số nguyên.';
    if (number <= 0) return '$field phải lớn hơn 0.';
    return null;
  }
}
