// Màn hình chi tiết đơn hàng dành cho Staff (UC12): xem sản phẩm, địa chỉ và cập nhật trạng thái.
// Staff có thể chuyển trạng thái: confirmed → shipping → completed; không thể hủy đơn.
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/constants/order_status.dart';
import '../../../../core/utils/currency_utils.dart';
import '../../../../core/utils/date_utils.dart';
import '../../../../providers/auth_provider.dart';
import '../../../../providers/order_provider.dart';
import '../../../../shared/widgets/app_snackbar.dart';
import '../../../../shared/widgets/error_view.dart';
import '../../../../shared/widgets/loading_widget.dart';
import '../../../../shared/widgets/order_status_badge.dart';
import '../../invoice_detail/screens/invoice_detail_screen.dart';

/// Chi tiết đơn hàng cho nhân viên, cho phép cập nhật trạng thái (UC12).
class StaffOrderDetailScreen extends ConsumerWidget {
  const StaffOrderDetailScreen({super.key, required this.orderId});

  final String orderId;

  Future<void> _advanceStatus(BuildContext context, WidgetRef ref) async {
    final user = ref.read(currentUserProvider).valueOrNull;
    final order = ref.read(orderDetailProvider(orderId)).valueOrNull;
    if (user == null || order == null) return;

    final next = order.status.next;
    if (next == null) return;

    final success = await ref.read(orderControllerProvider.notifier).updateStatus(
          orderId: orderId,
          newStatus: next,
          staffId: user.uid,
        );

    if (!context.mounted) return;
    if (success) {
      ref.invalidate(orderDetailProvider(orderId));
      AppSnackbar.showSuccess(
          context, 'Đã cập nhật trạng thái: ${next.displayName}');
    } else {
      final error = ref.read(orderControllerProvider).error;
      AppSnackbar.showError(context, error?.toString() ?? 'Cập nhật thất bại.');
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final orderAsync = ref.watch(orderDetailProvider(orderId));

    return Scaffold(
      appBar: AppBar(title: const Text('Chi tiết đơn hàng')),
      body: orderAsync.when(
        loading: () => const LoadingWidget(),
        error: (e, _) => ErrorView(message: e.toString()),
        data: (order) {
          if (order == null) {
            return const ErrorView(message: 'Không tìm thấy đơn hàng.');
          }
          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('Don #${order.id.substring(0, 6).toUpperCase()}',
                      style: Theme.of(context).textTheme.titleMedium),
                  OrderStatusBadge(status: order.status),
                ],
              ),
              const SizedBox(height: 8),
              Text('Ngày đặt: ${AppDateUtils.formatDateTime(order.orderDate)}'),
              Text('Người nhận SĐT: ${order.phoneNumber}'),
              Text('Địa chỉ: ${order.shippingAddress}'),
              Text('Thanh toan: ${order.paymentMethod.displayName} '
                  '(${order.paymentStatus.displayName})'),
              const Divider(height: 24),
              Text('Sản phẩm', style: Theme.of(context).textTheme.titleMedium),
              ...order.details.map((d) => ListTile(
                    dense: true,
                    contentPadding: EdgeInsets.zero,
                    title: Text(d.productName),
                    subtitle: Text(
                        '${d.quantity} x ${CurrencyUtils.format(d.price)}'),
                    trailing: Text(CurrencyUtils.format(d.subtotal)),
                  )),
              const Divider(height: 24),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('Tổng cộng',
                      style: Theme.of(context).textTheme.titleMedium),
                  Text(CurrencyUtils.format(order.finalAmount),
                      style: Theme.of(context)
                          .textTheme
                          .titleMedium
                          ?.copyWith(fontWeight: FontWeight.bold)),
                ],
              ),
              if (order.status == OrderStatus.completed) ...[
                const SizedBox(height: 16),
                OutlinedButton.icon(
                  onPressed: () => Navigator.of(context).push(
                    MaterialPageRoute<void>(
                      builder: (_) => InvoiceDetailScreen(orderId: orderId),
                    ),
                  ),
                  icon: const Icon(Icons.receipt_long),
                  label: const Text('Xem hóa đơn'),
                ),
              ],
            ],
          );
        },
      ),
      bottomNavigationBar: orderAsync.maybeWhen(
        data: (order) {
          if (order == null) return null;
          final next = order.status.next;
          if (next == null) return null;
          return SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: FilledButton.icon(
                onPressed: () => _advanceStatus(context, ref),
                icon: const Icon(Icons.arrow_forward),
                label: Text('Chuyển sang: ${next.displayName}'),
              ),
            ),
          );
        },
        orElse: () => null,
      ),
    );
  }
}
