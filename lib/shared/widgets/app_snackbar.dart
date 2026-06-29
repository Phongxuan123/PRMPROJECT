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
