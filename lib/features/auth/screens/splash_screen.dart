import 'package:flutter/material.dart';

import '../../../core/constants/app_constants.dart';

/// Màn hình khởi động, hiển thị trong khi router xác định trạng thái đăng nhập.
class SplashScreen extends StatelessWidget {
  const SplashScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.storefront,
                size: 80, color: Theme.of(context).colorScheme.primary),
            const SizedBox(height: 16),
            Text(AppConstants.appName,
                style: Theme.of(context).textTheme.headlineSmall),
            const SizedBox(height: 24),
            const CircularProgressIndicator(),
          ],
        ),
      ),
    );
  }
}

/// Màn hình hiển thị khi người dùng không có quyền truy cập.
class UnauthorizedScreen extends StatelessWidget {
  const UnauthorizedScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Không có quyền')),
      body: const Center(
        child: Text('Bạn không có quyền truy cập chức năng này.'),
      ),
    );
  }
}
