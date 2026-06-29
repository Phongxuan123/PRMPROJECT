import 'package:cloud_firestore/cloud_firestore.dart';

import '../core/constants/order_status.dart';
import '../core/utils/firestore_utils.dart';

/// Một bước tracking giao hàng, nhúng trong document orders.
class DeliveryTracking {
  const DeliveryTracking({
    required this.status,
    required this.updatedAt,
    this.location,
  });

  final String status;
  final DateTime updatedAt;
  final String? location;

  factory DeliveryTracking.fromMap(Map<String, dynamic> map) {
    return DeliveryTracking(
      status: FirestoreUtils.asString(map['status']),
      updatedAt: FirestoreUtils.asDateTime(map['updatedAt']),
      location: FirestoreUtils.asStringOrNull(map['location']),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'status': status,
      'updatedAt': Timestamp.fromDate(updatedAt),
      'location': location,
    };
  }
}

/// Đơn hàng, ánh xạ orders/{orderId}.
class Order {
  const Order({
    required this.id,
    required this.userId,
    required this.branchId,
    required this.orderDate,
    required this.totalAmount,
    required this.status,
    required this.shippingAddress,
    required this.phoneNumber,
    required this.paymentMethod,
    required this.paymentStatus,
    this.discountAmount = 0,
    this.voucherId,
    this.deliveryTracking = const [],
    this.details = const [],
  });

  final String id;
  final String userId;
  final String branchId;
  final DateTime orderDate;
  final double totalAmount;
  final double discountAmount;
  final String? voucherId;
  final OrderStatus status;
  final String shippingAddress;
  final String phoneNumber;
  final PaymentMethod paymentMethod;
  final PaymentStatus paymentStatus;
  final List<DeliveryTracking> deliveryTracking;

  /// Chi tiết đơn (subcollection details), nạp riêng khi cần.
  final List<OrderDetail> details;

  /// Số tiền thực trả sau khi trừ giảm giá.
  double get finalAmount => totalAmount - discountAmount;

  factory Order.fromMap(Map<String, dynamic> map, String id,
      {List<OrderDetail> details = const []}) {
    final trackingRaw = map['deliveryTracking'];
    final tracking = trackingRaw is List
        ? trackingRaw
            .whereType<Map<String, dynamic>>()
            .map(DeliveryTracking.fromMap)
            .toList()
        : <DeliveryTracking>[];

    return Order(
      id: id,
      userId: FirestoreUtils.asString(map['userId']),
      branchId: FirestoreUtils.asString(map['branchId']),
      orderDate: FirestoreUtils.asDateTime(map['orderDate']),
      totalAmount: FirestoreUtils.asDouble(map['totalAmount']),
      discountAmount: FirestoreUtils.asDouble(map['discountAmount']),
      voucherId: FirestoreUtils.asStringOrNull(map['voucherId']),
      status:
          OrderStatus.fromValue(FirestoreUtils.asStringOrNull(map['status'])),
      shippingAddress: FirestoreUtils.asString(map['shippingAddress']),
      phoneNumber: FirestoreUtils.asString(map['phoneNumber']),
      paymentMethod: PaymentMethod.fromValue(
          FirestoreUtils.asStringOrNull(map['paymentMethod'])),
      paymentStatus: PaymentStatus.fromValue(
          FirestoreUtils.asStringOrNull(map['paymentStatus'])),
      deliveryTracking: tracking,
      details: details,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'userId': userId,
      'branchId': branchId,
      'orderDate': Timestamp.fromDate(orderDate),
      'totalAmount': totalAmount,
      'discountAmount': discountAmount,
      'voucherId': voucherId,
      'status': status.value,
      'shippingAddress': shippingAddress,
      'phoneNumber': phoneNumber,
      'paymentMethod': paymentMethod.value,
      'paymentStatus': paymentStatus.value,
      'deliveryTracking': deliveryTracking.map((t) => t.toMap()).toList(),
    };
  }
}

/// Chi tiết đơn hàng, ánh xạ orders/{orderId}/details/{detailId}.
///
/// productName và price là snapshot tại thời điểm đặt hàng, không đổi dù sau này
/// giá sản phẩm thay đổi.
class OrderDetail {
  const OrderDetail({
    required this.id,
    required this.productId,
    required this.productName,
    required this.quantity,
    required this.price,
  });

  final String id;
  final String productId;
  final String productName;
  final int quantity;
  final double price;

  double get subtotal => price * quantity;

  factory OrderDetail.fromMap(Map<String, dynamic> map, String id) {
    return OrderDetail(
      id: id,
      productId: FirestoreUtils.asString(map['productId']),
      productName: FirestoreUtils.asString(map['productName']),
      quantity: FirestoreUtils.asInt(map['quantity']),
      price: FirestoreUtils.asDouble(map['price']),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'productId': productId,
      'productName': productName,
      'quantity': quantity,
      'price': price,
    };
  }
}
