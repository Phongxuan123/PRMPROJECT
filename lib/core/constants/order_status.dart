/// Trạng thái đơn hàng.
enum OrderStatus {
  pending('pending'),
  confirmed('confirmed'),
  shipping('shipping'),
  completed('completed'),
  cancelled('cancelled');

  const OrderStatus(this.value);

  final String value;

  static OrderStatus fromValue(String? value) {
    return OrderStatus.values.firstWhere(
      (status) => status.value == value,
      orElse: () => OrderStatus.pending,
    );
  }

  /// Chỉ cho phép hủy đơn khi đang ở trạng thái pending hoặc confirmed.
  bool get isCancellable =>
      this == OrderStatus.pending || this == OrderStatus.confirmed;

  String get displayName {
    switch (this) {
      case OrderStatus.pending:
        return 'Chờ xử lý';
      case OrderStatus.confirmed:
        return 'Đã xác nhận';
      case OrderStatus.shipping:
        return 'Đang giao';
      case OrderStatus.completed:
        return 'Hoàn thành';
      case OrderStatus.cancelled:
        return 'Đã hủy';
    }
  }

  /// Trạng thái kế tiếp trong quy trình xử lý đơn (null nếu đã ở trạng thái cuối).
  OrderStatus? get next {
    switch (this) {
      case OrderStatus.pending:
        return OrderStatus.confirmed;
      case OrderStatus.confirmed:
        return OrderStatus.shipping;
      case OrderStatus.shipping:
        return OrderStatus.completed;
      case OrderStatus.completed:
      case OrderStatus.cancelled:
        return null;
    }
  }
}

/// Trạng thái thanh toán (mock - không tích hợp cổng thanh toán thật).
enum PaymentStatus {
  unpaid('unpaid'),
  paid('paid'),
  failed('failed'),
  refunded('refunded');

  const PaymentStatus(this.value);

  final String value;

  static PaymentStatus fromValue(String? value) {
    return PaymentStatus.values.firstWhere(
      (status) => status.value == value,
      orElse: () => PaymentStatus.unpaid,
    );
  }

  String get displayName {
    switch (this) {
      case PaymentStatus.unpaid:
        return 'Chưa thanh toán';
      case PaymentStatus.paid:
        return 'Đã thanh toán';
      case PaymentStatus.failed:
        return 'Thanh toán thất bại';
      case PaymentStatus.refunded:
        return 'Đã hoàn tiền';
    }
  }
}

/// Phương thức thanh toán hỗ trợ.
enum PaymentMethod {
  cod('cod'),
  mockTransfer('mock_transfer');

  const PaymentMethod(this.value);

  final String value;

  static PaymentMethod fromValue(String? value) {
    return PaymentMethod.values.firstWhere(
      (method) => method.value == value,
      orElse: () => PaymentMethod.cod,
    );
  }

  String get displayName {
    switch (this) {
      case PaymentMethod.cod:
        return 'Thanh toán khi nhận hàng (COD)';
      case PaymentMethod.mockTransfer:
        return 'Chuyển khoản (mô phỏng)';
    }
  }
}

/// Trạng thái yêu cầu hoàn trả.
enum ReturnStatus {
  requested('requested'),
  approved('approved'),
  rejected('rejected'),
  completed('completed');

  const ReturnStatus(this.value);

  final String value;

  static ReturnStatus fromValue(String? value) {
    return ReturnStatus.values.firstWhere(
      (status) => status.value == value,
      orElse: () => ReturnStatus.requested,
    );
  }
}

/// Loại thay đổi tồn kho, dùng trong inventory logs.
enum InventoryChangeType {
  import('import'),
  sale('sale'),
  returnItem('return'),
  adjustment('adjustment');

  const InventoryChangeType(this.value);

  final String value;

  static InventoryChangeType fromValue(String? value) {
    return InventoryChangeType.values.firstWhere(
      (type) => type.value == value,
      orElse: () => InventoryChangeType.adjustment,
    );
  }
}
