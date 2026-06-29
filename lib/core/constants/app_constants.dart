/// Hằng số dùng chung toàn ứng dụng.
///
/// Tập trung magic number / magic string tại một nơi để tránh lặp và dễ bảo trì.
class AppConstants {
  const AppConstants._();

  /// Ngưỡng cảnh báo tồn kho thấp.
  static const int lowStockThreshold = 5;

  /// Số lượng ảnh tối đa cho mỗi sản phẩm.
  static const int maxImagesPerProduct = 5;

  /// Thời gian timeout mặc định cho một request.
  static const Duration requestTimeout = Duration(seconds: 30);

  /// Số phần tử mặc định cho mỗi trang khi phân trang.
  static const int defaultPageSize = 20;

  /// Độ dài tối thiểu của mật khẩu (theo Firebase Auth).
  static const int minPasswordLength = 6;

  /// Số sao tối đa khi đánh giá sản phẩm.
  static const int maxRating = 5;

  /// Tên ứng dụng hiển thị trên UI.
  static const String appName = 'Mini Market';
}
