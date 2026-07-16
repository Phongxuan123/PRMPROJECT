// Tiện ích định dạng tiền tệ Việt Nam Đồng (VND).
// Dùng thư viện intl để format theo locale vi_VN với ký hiệu 'd'.
import 'package:intl/intl.dart';

/// Tiện ích định dạng tiền tệ Việt Nam Đồng.
class CurrencyUtils {
  const CurrencyUtils._();

  static final NumberFormat _vndFormat = NumberFormat.currency(
    locale: 'vi_VN',
    symbol: 'd',
    decimalDigits: 0,
  );

  /// Định dạng số tiền thành chuỗi VND, ví dụ: 25000 -> "25.000 d".
  static String format(num amount) => _vndFormat.format(amount);

  /// Định dạng ngắn gọn, ví dụ: 1500000 -> "1.5tr", 25000 -> "25k".
  static String formatCompact(num amount) {
    if (amount >= 1000000) {
      return '${(amount / 1000000).toStringAsFixed(1)}tr';
    }
    if (amount >= 1000) {
      return '${(amount / 1000).toStringAsFixed(0)}k';
    }
    return amount.toStringAsFixed(0);
  }
}
