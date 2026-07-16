// Repository đơn hàng: đặt hàng, cập nhật trạng thái, hủy đơn (UC08, UC09, UC10, UC12).
// Mọi thao tác ghi đều dùng Firestore Transaction để đảm bảo tính toàn vẹn dữ liệu.
// Khi đặt hàng: kiểm tra và trừ tồn kho, trừ lượt voucher trong cùng một Transaction.
// Ẩn `Order` của cloud_firestore để tránh trùng với model Order của app.
import 'package:cloud_firestore/cloud_firestore.dart' hide Order;

import '../../core/constants/firestore_paths.dart';
import '../../core/constants/order_status.dart';
import '../../core/errors/app_exceptions.dart';
import '../../models/cart_item_model.dart';
import '../../models/order_model.dart';

/// Tham số đặt hàng, gồm thông tin giao hàng và thanh toán.
class CreateOrderParams {
  const CreateOrderParams({
    required this.userId,
    required this.branchId,
    required this.items,
    required this.shippingAddress,
    required this.phoneNumber,
    required this.paymentMethod,
    this.voucherId,
    this.discountAmount = 0,
  });

  final String userId;
  final String branchId;
  final List<CartItem> items;
  final String shippingAddress;
  final String phoneNumber;
  final PaymentMethod paymentMethod;
  final String? voucherId;
  final double discountAmount;

  double get totalAmount =>
      items.fold(0, (acc, item) => acc + item.subtotal);
}

/// Quản lý toàn bộ luồng đơn hàng của khách hàng và nhân viên.
///
/// Sử dụng Firestore Transaction để đảm bảo tính atomic khi đặt / hủy đơn:
/// hoặc toàn bộ thành công, hoặc rollback hết.
class OrderRepository {
  OrderRepository({required FirebaseFirestore firestore})
      : _firestore = firestore;

  final FirebaseFirestore _firestore;

  // --- Truy vấn đơn hàng ---

  /// Lịch sử đơn hàng của một khách hàng (UC09).
  Stream<List<Order>> watchOrdersByUser(String userId) {
    return _firestore
        .collection(FirestorePaths.orders)
        .where('userId', isEqualTo: userId)
        .orderBy('orderDate', descending: true)
        .snapshots()
        .map((snap) =>
            snap.docs.map((d) => Order.fromMap(d.data(), d.id)).toList());
  }

  /// Đơn hàng theo chi nhánh và trạng thái (cho Staff - UC12).
  Stream<List<Order>> watchOrdersByBranch(
    String branchId, {
    OrderStatus? status,
  }) {
    Query<Map<String, dynamic>> query = _firestore
        .collection(FirestorePaths.orders)
        .where('branchId', isEqualTo: branchId);
    if (status != null) {
      query = query.where('status', isEqualTo: status.value);
    }
    return query.snapshots().map((snap) =>
        snap.docs.map((d) => Order.fromMap(d.data(), d.id)).toList());
  }

  /// Chi tiết đơn hàng kèm subcollection details.
  Future<Order?> getOrderWithDetails(String orderId) async {
    try {
      final doc = await _firestore.doc(FirestorePaths.order(orderId)).get();
      if (!doc.exists || doc.data() == null) return null;

      final detailSnap = await _firestore
          .collection(FirestorePaths.orderDetails(orderId))
          .get();
      final details = detailSnap.docs
          .map((d) => OrderDetail.fromMap(d.data(), d.id))
          .toList();

      return Order.fromMap(doc.data()!, doc.id, details: details);
    } on FirebaseException catch (e) {
      throw DataException('Không thể tải đơn hàng.', code: e.code);
    }
  }

  // --- Đặt hàng (UC08) ---

  /// Tạo đơn hàng mới từ giỏ hàng trong một Firestore Transaction.
  ///
  /// Quy trình atomic: kiểm tra tồn kho -> tạo order + details -> trừ kho
  /// -> ghi inventory log -> giảm lượt voucher. Nếu tồn kho không đủ,
  /// toàn bộ bị rollback.
  ///
  /// Throws [InsufficientStockException] nếu tồn kho không đủ.
  /// Throws [OrderCreationException] nếu transaction thất bại.
  Future<String> createOrder(CreateOrderParams params) async {
    if (params.items.isEmpty) throw const EmptyCartException();
    if (params.shippingAddress.trim().isEmpty) {
      throw const NoAddressSelectedException();
    }

    final orderRef = _firestore.collection(FirestorePaths.orders).doc();

    try {
      await _firestore.runTransaction((transaction) async {
        // --- Giai đoạn đọc: đọc toàn bộ inventory trước khi ghi ---
        final inventoryRefs = <String, DocumentReference<Map<String, dynamic>>>{};
        final currentQuantities = <String, int>{};

        for (final item in params.items) {
          final invId =
              FirestorePaths.inventoryId(params.branchId, item.productId);
          final invRef = _firestore.doc(FirestorePaths.inventoryDoc(invId));
          final invSnap = await transaction.get(invRef);
          final available =
              (invSnap.data()?['quantity'] as num?)?.toInt() ?? 0;

          if (available < item.quantity) {
            throw InsufficientStockException(productName: item.productName);
          }
          inventoryRefs[item.productId] = invRef;
          currentQuantities[item.productId] = available;
        }

        DocumentReference<Map<String, dynamic>>? voucherRef;
        // Số tiền giảm do server tính lại từ dữ liệu voucher, KHÔNG tin
        // params.discountAmount do client gửi lên (tránh gian lận / dữ liệu cũ).
        var discountAmount = 0.0;
        if (params.voucherId != null) {
          voucherRef = _firestore.doc(FirestorePaths.voucher(params.voucherId!));
          final voucherSnap = await transaction.get(voucherRef);
          final vData = voucherSnap.data();
          if (vData == null) {
            throw const InvalidVoucherException('Voucher không tồn tại.');
          }
          final remaining = (vData['quantity'] as num?)?.toInt() ?? 0;
          final active = vData['status'] as bool? ?? false;
          final expired = (vData['expiredDate'] as Timestamp?)?.toDate();
          final minOrder = (vData['minOrderAmount'] as num?)?.toDouble() ?? 0;

          if (remaining <= 0) {
            throw const InvalidVoucherException('Voucher đã hết lượt sử dụng.');
          }
          if (!active) {
            throw const InvalidVoucherException('Voucher không còn hiệu lực.');
          }
          if (expired != null && expired.isBefore(DateTime.now())) {
            throw const InvalidVoucherException('Voucher đã hết hạn.');
          }
          if (params.totalAmount < minOrder) {
            throw const InvalidVoucherException(
                'Đơn hàng chưa đạt giá trị tối thiểu để áp mã.');
          }
          final value = (vData['discountValue'] as num?)?.toDouble() ?? 0;
          // Không cho giảm quá tổng tiền đơn.
          discountAmount =
              value > params.totalAmount ? params.totalAmount : value;
        }

        // --- Giai đoạn ghi ---
        final order = Order(
          id: orderRef.id,
          userId: params.userId,
          branchId: params.branchId,
          orderDate: DateTime.now(),
          totalAmount: params.totalAmount,
          discountAmount: discountAmount,
          voucherId: params.voucherId,
          status: OrderStatus.pending,
          shippingAddress: params.shippingAddress,
          phoneNumber: params.phoneNumber,
          paymentMethod: params.paymentMethod,
          paymentStatus: PaymentStatus.unpaid,
          deliveryTracking: [
            DeliveryTracking(
              status: OrderStatus.pending.value,
              updatedAt: DateTime.now(),
            ),
          ],
        );
        transaction.set(orderRef, order.toMap());

        for (final item in params.items) {
          final detailRef = _firestore
              .collection(FirestorePaths.orderDetails(orderRef.id))
              .doc();
          final detail = OrderDetail(
            id: detailRef.id,
            productId: item.productId,
            productName: item.productName,
            quantity: item.quantity,
            price: item.productPrice,
          );
          transaction.set(detailRef, detail.toMap());

          // Trừ tồn kho + ghi log.
          final invRef = inventoryRefs[item.productId]!;
          final newQty =
              currentQuantities[item.productId]! - item.quantity;
          transaction.update(invRef, {
            'quantity': newQty,
            'lastUpdated': FieldValue.serverTimestamp(),
          });

          final invId =
              FirestorePaths.inventoryId(params.branchId, item.productId);
          final logRef =
              _firestore.collection(FirestorePaths.inventoryLogs(invId)).doc();
          transaction.set(logRef, {
            'changeType': InventoryChangeType.sale.value,
            'quantityChanged': -item.quantity,
            'createdBy': params.userId,
            'createdAt': FieldValue.serverTimestamp(),
            'note': 'Đặt hàng ${orderRef.id}',
          });
        }

        if (voucherRef != null) {
          transaction.update(voucherRef, {
            'quantity': FieldValue.increment(-1),
          });
        }
      });

      return orderRef.id;
    } on AppException {
      rethrow;
    } on FirebaseException catch (e) {
      throw OrderCreationException('Tạo đơn hàng thất bại: ${e.code}');
    }
  }

  // --- Xử lý đơn hàng (Staff - UC12) ---

  /// Cập nhật trạng thái đơn hàng và thêm bước tracking.
  ///
  /// Khi chuyển sang [OrderStatus.completed] sẽ tạo hóa đơn (UC16).
  Future<void> updateStatus({
    required String orderId,
    required OrderStatus newStatus,
    required String staffId,
    String? location,
  }) async {
    final orderRef = _firestore.doc(FirestorePaths.order(orderId));
    try {
      await _firestore.runTransaction((transaction) async {
        final snap = await transaction.get(orderRef);
        if (!snap.exists) throw const NotFoundException('Không tìm thấy đơn.');

        final tracking = List<Map<String, dynamic>>.from(
          (snap.data()?['deliveryTracking'] as List?) ?? const [],
        );
        tracking.add({
          'status': newStatus.value,
          'updatedAt': Timestamp.fromDate(DateTime.now()),
          'location': location,
        });

        final updates = <String, dynamic>{
          'status': newStatus.value,
          'deliveryTracking': tracking,
        };
        if (newStatus == OrderStatus.completed) {
          updates['paymentStatus'] = PaymentStatus.paid.value;
        }
        transaction.update(orderRef, updates);

        // Tạo hóa đơn khi đơn hoàn thành.
        if (newStatus == OrderStatus.completed) {
          final total = (snap.data()?['totalAmount'] as num?)?.toDouble() ?? 0;
          final discount =
              (snap.data()?['discountAmount'] as num?)?.toDouble() ?? 0;
          final invoiceRef =
              _firestore.collection(FirestorePaths.invoices).doc();
          transaction.set(invoiceRef, {
            'orderId': orderId,
            'staffId': staffId,
            'invoiceDate': FieldValue.serverTimestamp(),
            'totalAmount': total - discount,
          });
        }
      });
    } on AppException {
      rethrow;
    } on FirebaseException catch (e) {
      throw DataException('Cập nhật trạng thái thất bại.', code: e.code);
    }
  }

  // --- Hủy đơn (UC10) ---

  /// Hủy đơn hàng và hoàn trả tồn kho trong một transaction (Mục 14.3).
  ///
  /// Chỉ cho phép hủy khi đơn đang pending hoặc confirmed.
  Future<void> cancelOrder({
    required String orderId,
    required String userId,
  }) async {
    final orderRef = _firestore.doc(FirestorePaths.order(orderId));

    try {
      await _firestore.runTransaction((transaction) async {
        final orderSnap = await transaction.get(orderRef);
        if (!orderSnap.exists) {
          throw const NotFoundException('Không tìm thấy đơn hàng.');
        }

        final data = orderSnap.data()!;
        final status = OrderStatus.fromValue(data['status'] as String?);
        if (!status.isCancellable) {
          throw const OrderNotCancellableException();
        }

        final branchId = data['branchId'] as String? ?? '';
        final voucherId = data['voucherId'] as String?;
        final paymentStatus =
            PaymentStatus.fromValue(data['paymentStatus'] as String?);

        // Đọc chi tiết đơn để biết số lượng cần hoàn kho.
        final detailSnap = await _firestore
            .collection(FirestorePaths.orderDetails(orderId))
            .get();

        // Đọc tồn kho hiện tại cho từng sản phẩm (trước khi ghi).
        final invData = <String, ({DocumentReference<Map<String, dynamic>> ref, int qty, int restore, String productId})>{};
        for (final detail in detailSnap.docs) {
          final productId = detail.data()['productId'] as String? ?? '';
          final quantity =
              (detail.data()['quantity'] as num?)?.toInt() ?? 0;
          final invId = FirestorePaths.inventoryId(branchId, productId);
          final invRef = _firestore.doc(FirestorePaths.inventoryDoc(invId));
          final invSnap = await transaction.get(invRef);
          final current = (invSnap.data()?['quantity'] as num?)?.toInt() ?? 0;
          invData[invId] = (
            ref: invRef,
            qty: current,
            restore: quantity,
            productId: productId,
          );
        }

        DocumentReference<Map<String, dynamic>>? voucherRef;
        if (voucherId != null) {
          voucherRef = _firestore.doc(FirestorePaths.voucher(voucherId));
          await transaction.get(voucherRef);
        }

        // --- Ghi ---
        final updates = <String, dynamic>{
          'status': OrderStatus.cancelled.value,
        };
        if (paymentStatus == PaymentStatus.paid) {
          updates['paymentStatus'] = PaymentStatus.refunded.value;
        }
        transaction.update(orderRef, updates);

        invData.forEach((invId, entry) {
          transaction.update(entry.ref, {
            'quantity': entry.qty + entry.restore,
            'lastUpdated': FieldValue.serverTimestamp(),
          });
          final logRef =
              _firestore.collection(FirestorePaths.inventoryLogs(invId)).doc();
          transaction.set(logRef, {
            'changeType': InventoryChangeType.returnItem.value,
            'quantityChanged': entry.restore,
            'createdBy': userId,
            'createdAt': FieldValue.serverTimestamp(),
            'note': 'Hủy đơn $orderId',
          });
        });

        if (voucherRef != null) {
          transaction.update(voucherRef, {
            'quantity': FieldValue.increment(1),
          });
        }
      });
    } on AppException {
      rethrow;
    } on FirebaseException catch (e) {
      throw DataException('Hủy đơn thất bại.', code: e.code);
    }
  }
}
