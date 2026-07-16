// Provider đơn hàng: stream lịch sử đặt hàng, chi tiết đơn và controller xử lý.
// OrderController bọc createOrder (có xóa giỏ sau khi tạo), cancelOrder và updateStatus.
// Dùng select() để tránh restart stream không cần thiết khi token Firebase refresh.
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../core/constants/order_status.dart';
import '../data/repositories/order_repository.dart';
import '../models/invoice_model.dart';
import '../models/order_model.dart';
import 'auth_provider.dart';
import 'repository_providers.dart';

/// Lịch sử đơn hàng của người dùng đang đăng nhập (UC09).
final myOrdersProvider = StreamProvider<List<Order>>((ref) {
  final user = ref.watch(currentUserProvider).valueOrNull;
  if (user == null) return Stream.value(const []);
  return ref.watch(orderRepositoryProvider).watchOrdersByUser(user.uid);
});

/// Đơn hàng theo chi nhánh và trạng thái (Staff - UC12).
final branchOrdersProvider = StreamProvider.family<List<Order>,
    ({String branchId, OrderStatus? status})>((ref, params) {
  return ref
      .watch(orderRepositoryProvider)
      .watchOrdersByBranch(params.branchId, status: params.status);
});

/// Chi tiết một đơn hàng kèm subcollection details.
final orderDetailProvider =
    FutureProvider.family<Order?, String>((ref, orderId) {
  return ref.watch(orderRepositoryProvider).getOrderWithDetails(orderId);
});

/// Hóa đơn ứng với một đơn hàng (UC16, null nếu chưa hoàn thành).
final invoiceByOrderProvider =
    FutureProvider.family<Invoice?, String>((ref, orderId) {
  return ref.watch(invoiceRepositoryProvider).getByOrder(orderId);
});

/// Controller xử lý các thao tác đơn hàng (đặt / hủy / cập nhật trạng thái).
class OrderController extends AsyncNotifier<void> {
  @override
  Future<void> build() async {}

  /// Đặt hàng, trả về orderId nếu thành công (null nếu lỗi).
  Future<String?> createOrder(CreateOrderParams params) async {
    state = const AsyncLoading();
    final result = await AsyncValue.guard(
      () => ref.read(orderRepositoryProvider).createOrder(params),
    );
    if (result.hasError) {
      state = AsyncError(result.error!, result.stackTrace ?? StackTrace.current);
      return null;
    }

    // Đơn đã tạo thành công (transaction atomic). Việc xóa giỏ hàng KHÔNG
    // được phép làm hỏng kết quả: nếu clearCart lỗi (mạng chập chờn), người
    // dùng vẫn được báo đặt hàng thành công, tránh đặt trùng đơn. Giỏ sẽ tự
    // đồng bộ ở lần load sau.
    try {
      await ref.read(cartRepositoryProvider).clearCart(params.userId);
    } catch (_) {
      // Bỏ qua: đơn đã tạo, giỏ sẽ được xóa/đồng bộ sau.
    }
    state = const AsyncData(null);
    return result.value;
  }

  Future<bool> cancelOrder({
    required String orderId,
    required String userId,
  }) async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() async {
      await ref
          .read(orderRepositoryProvider)
          .cancelOrder(orderId: orderId, userId: userId);
    });
    return !state.hasError;
  }

  Future<bool> updateStatus({
    required String orderId,
    required OrderStatus newStatus,
    required String staffId,
  }) async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() async {
      await ref.read(orderRepositoryProvider).updateStatus(
            orderId: orderId,
            newStatus: newStatus,
            staffId: staffId,
          );
    });
    return !state.hasError;
  }
}

final orderControllerProvider =
    AsyncNotifierProvider<OrderController, void>(OrderController.new);
