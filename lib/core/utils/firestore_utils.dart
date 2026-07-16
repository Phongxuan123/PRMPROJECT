// Tiện ích đọc dữ liệu từ Firestore an toàn với null safety.
// Firestore trả về Map<String, dynamic> nên cần ép kiểu cẩn thận để tránh lỗi runtime.
// Tất cả repository đều dùng các helper này thay vì cast trực tiếp.
import 'package:cloud_firestore/cloud_firestore.dart';

/// Tiện ích đọc dữ liệu Firestore an toàn với null safety.
///
/// Firestore trả về `Map<String, dynamic>` với giá trị dynamic, cần ép kiểu
/// cẩn thận để tránh runtime error.
class FirestoreUtils {
  const FirestoreUtils._();

  static String asString(dynamic value, {String fallback = ''}) {
    if (value is String) return value;
    return fallback;
  }

  static String? asStringOrNull(dynamic value) {
    if (value is String) return value;
    return null;
  }

  static int asInt(dynamic value, {int fallback = 0}) {
    if (value is int) return value;
    if (value is num) return value.toInt();
    return fallback;
  }

  static double asDouble(dynamic value, {double fallback = 0}) {
    if (value is num) return value.toDouble();
    return fallback;
  }

  static bool asBool(dynamic value, {bool fallback = false}) {
    if (value is bool) return value;
    return fallback;
  }

  /// Chuyển Timestamp Firestore thành DateTime, mặc định là thời điểm hiện tại.
  static DateTime asDateTime(dynamic value) {
    if (value is Timestamp) return value.toDate();
    if (value is DateTime) return value;
    return DateTime.now();
  }

  static DateTime? asDateTimeOrNull(dynamic value) {
    if (value is Timestamp) return value.toDate();
    if (value is DateTime) return value;
    return null;
  }

  /// Đọc một mảng chuỗi an toàn từ Firestore.
  static List<String> asStringList(dynamic value) {
    if (value is List) {
      return value.whereType<String>().toList();
    }
    return const [];
  }
}
