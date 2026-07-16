// Tiện ích định dạng ngày giờ theo kiểu Việt Nam (dd/MM/yyyy HH:mm).
// Cũng cung cấp hàm timeAgo() để hiển thị khoảng thời gian tương đối.
import 'package:intl/intl.dart';

/// Tiện ích định dạng ngày giờ.
class AppDateUtils {
  const AppDateUtils._();

  static final DateFormat _dateFormat = DateFormat('dd/MM/yyyy');
  static final DateFormat _dateTimeFormat = DateFormat('dd/MM/yyyy HH:mm');

  /// Định dạng ngày: 24/06/2026.
  static String formatDate(DateTime date) => _dateFormat.format(date);

  /// Định dạng ngày giờ: 24/06/2026 21:30.
  static String formatDateTime(DateTime date) => _dateTimeFormat.format(date);

  /// Mô tả khoảng thời gian tương đối, ví dụ "5 phút trước".
  static String timeAgo(DateTime date) {
    final diff = DateTime.now().difference(date);
    if (diff.inDays >= 1) return '${diff.inDays} ngày trước';
    if (diff.inHours >= 1) return '${diff.inHours} giờ trước';
    if (diff.inMinutes >= 1) return '${diff.inMinutes} phút trước';
    return 'Vừa xong';
  }
}
