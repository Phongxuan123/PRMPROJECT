// Tiện ích hiển thị SnackBar thông báo nhanh dùng chung toàn ứng dụng.
// Cung cấp 3 kiểu: success (xanh lá), error (đỏ), info (xanh dương).
import 'package:flutter/material.dart';

/// Tiện ích hiển thị SnackBar thông báo nhanh.
class AppSnackbar {
  const AppSnackbar._();

  static void showSuccess(BuildContext context, String message) {
    _show(context, message, Theme.of(context).colorScheme.primary);
  }

  static void showError(BuildContext context, String message) {
    _show(context, message, Theme.of(context).colorScheme.error);
  }

  static void _show(BuildContext context, String message, Color color) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(content: Text(message), backgroundColor: color),
      );
  }
}
