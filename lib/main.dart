import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart' show kDebugMode;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'core/constants/app_constants.dart';
import 'core/routes/app_router.dart';
import 'core/theme/app_theme.dart';
import 'data/firebase/fcm_service.dart';
import 'data/firebase/seed_service.dart';
import 'firebase_options.dart';

/// Xử lý thông báo FCM khi app ở background/terminated.
///
/// Phải là hàm top-level + `@pragma('vm:entry-point')` vì chạy trong isolate
/// riêng; cần khởi tạo lại Firebase trong isolate đó.
@pragma('vm:entry-point')
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  debugPrint('[FCM] Thông báo nền: ${message.notification?.title}');
}

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Khởi tạo Firebase. Nếu chưa cấu hình thật (chưa chạy flutterfire configure),
  // sẽ ném lỗi -> hiển thị màn hình hướng dẫn thay vì crash.
  Object? initError;
  try {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );

    // Khởi tạo FCM: đăng ký handler nền + xin quyền nhận thông báo. Bọc riêng
    // để lỗi FCM không chặn app khởi động.
    try {
      FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);
      await FcmService().requestPermission();
    } catch (e) {
      debugPrint('[main] Khởi tạo FCM thất bại: $e');
    }

    // Seed dữ liệu mẫu ở chế độ debug (tự bỏ qua nếu đã có dữ liệu).
    if (kDebugMode) {
      try {
        await SeedService().run();
      } catch (e) {
        debugPrint('[main] Seed dữ liệu thất bại: $e');
      }
    }
  } catch (e) {
    initError = e;
    debugPrint('[main] Khởi tạo Firebase thất bại: $e');
  }

  runApp(
    ProviderScope(
      child: initError == null
          ? const MiniMarketApp()
          : FirebaseConfigNeededApp(error: initError),
    ),
  );
}

/// Ứng dụng chính (khi Firebase đã khởi tạo thành công).
class MiniMarketApp extends ConsumerWidget {
  const MiniMarketApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final router = ref.watch(goRouterProvider);

    return MaterialApp.router(
      title: AppConstants.appName,
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light,
      routerConfig: router,
    );
  }
}

/// Màn hình hướng dẫn khi Firebase chưa được cấu hình.
class FirebaseConfigNeededApp extends StatelessWidget {
  const FirebaseConfigNeededApp({super.key, required this.error});

  final Object error;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: AppConstants.appName,
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light,
      home: Scaffold(
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.cloud_off, size: 64),
                const SizedBox(height: 16),
                Text('Firebase chưa được cấu hình',
                    style: Theme.of(context).textTheme.titleLarge),
                const SizedBox(height: 12),
                const Text(
                  'Vui lòng chạy "flutterfire configure" để tạo '
                  'firebase_options.dart thật, sau đó đặt google-services.json '
                  'vào android/app/. Xem chi tiết trong README.md.',
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
