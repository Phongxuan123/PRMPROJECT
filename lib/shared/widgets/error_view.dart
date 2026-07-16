// Widget hiển thị lỗi dùng chung kèm nút "Thử lại" để trigger rebuild provider.
// Đặt tên ErrorView thay vì ErrorWidget để tránh xung đột với widget nội bộ của Flutter.
import 'package:flutter/material.dart';

/// Hiển thị lỗi dùng chung kèm nút thử lại.
///
/// Đặt tên [ErrorView] để tránh trùng với `ErrorWidget` của Flutter.
class ErrorView extends StatelessWidget {
  const ErrorView({super.key, required this.message, this.onRetry});

  final String message;
  final VoidCallback? onRetry;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.error_outline,
                size: 48, color: Theme.of(context).colorScheme.error),
            const SizedBox(height: 16),
            Text(message, textAlign: TextAlign.center),
            if (onRetry != null) ...[
              const SizedBox(height: 16),
              OutlinedButton.icon(
                onPressed: onRetry,
                icon: const Icon(Icons.refresh),
                label: const Text('Thử lại'),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
