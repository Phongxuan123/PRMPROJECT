/// Các exception nghiệp vụ (domain exception) của ứng dụng.
///
/// Repository bắt [FirebaseException] và ném lại dưới dạng các exception này
/// để tầng Provider/UI xử lý một cách có ý nghĩa, không lộ ra chi tiết Firebase.
abstract class AppException implements Exception {
  const AppException(this.message);

  /// Thông báo thân thiện có thể hiển thị cho người dùng.
  final String message;

  @override
  String toString() => message;
}

/// Lỗi xác thực (đăng nhập / đăng ký / phân quyền).
class AuthException extends AppException {
  const AuthException(super.message, {this.code});

  final String? code;
}

/// Lỗi chung khi thao tác Firestore thất bại.
class DataException extends AppException {
  const DataException(super.message, {this.code});

  final String? code;
}

/// Không tìm thấy document yêu cầu.
class NotFoundException extends AppException {
  const NotFoundException(super.message);
}

/// Giỏ hàng rỗng khi đặt hàng.
class EmptyCartException extends AppException {
  const EmptyCartException()
      : super('Giỏ hàng đang trống, không thể đặt hàng.');
}

/// Chưa chọn địa chỉ giao hàng.
class NoAddressSelectedException extends AppException {
  const NoAddressSelectedException()
      : super('Vui lòng chọn địa chỉ giao hàng.');
}

/// Tồn kho không đủ cho sản phẩm yêu cầu.
class InsufficientStockException extends AppException {
  const InsufficientStockException({required this.productName})
      : super('Sản phẩm "$productName" không đủ tồn kho.');

  final String productName;
}

/// Tạo đơn hàng thất bại (transaction Firestore lỗi).
class OrderCreationException extends AppException {
  const OrderCreationException([
    super.message = 'Tạo đơn hàng thất bại, vui lòng thử lại.',
  ]);
}

/// Không thể hủy đơn do trạng thái không cho phép.
class OrderNotCancellableException extends AppException {
  const OrderNotCancellableException()
      : super('Đơn hàng này không thể hủy ở trạng thái hiện tại.');
}

/// Voucher không hợp lệ (hết hạn / hết lượt / không đủ điều kiện).
class InvalidVoucherException extends AppException {
  const InvalidVoucherException(super.message);
}

/// Dữ liệu nhập không hợp lệ (validation thất bại).
class ValidationException extends AppException {
  const ValidationException(super.message);
}
