// Service bao bọc Firebase Cloud Messaging (FCM).
// Xin quyền thông báo, lấy device token và lắng nghe thông báo foreground.
// Handler background được đăng ký ở main.dart (phải là top-level function).
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';

/// Bao bọc Firebase Cloud Messaging (FCM).
///
/// Xin quyền thông báo, lấy device token và lắng nghe thông báo đến.
/// Việc hiển thị danh sách thông báo trong app dùng subcollection
/// users/{uid}/notifications (xem [UserRepository]).
class FcmService {
  FcmService({FirebaseMessaging? messaging})
      : _messaging = messaging ?? FirebaseMessaging.instance;

  final FirebaseMessaging _messaging;

  /// Xin quyền nhận thông báo từ người dùng.
  Future<void> requestPermission() async {
    await _messaging.requestPermission(
      alert: true,
      badge: true,
      sound: true,
    );
  }

  /// Lấy device token để gửi thông báo trực tiếp đến thiết bị.
  Future<String?> getToken() => _messaging.getToken();

  /// Lắng nghe thông báo khi app đang mở (foreground).
  void listenForegroundMessages(void Function(RemoteMessage) onMessage) {
    FirebaseMessaging.onMessage.listen((message) {
      debugPrint('[FCM] Nhận thông báo: ${message.notification?.title}');
      onMessage(message);
    });
  }

  /// Stream phát ra khi token thay đổi (cần cập nhật lên server).
  Stream<String> get onTokenRefresh => _messaging.onTokenRefresh;
}
