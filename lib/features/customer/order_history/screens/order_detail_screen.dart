import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/utils/currency_utils.dart';
import '../../../../core/utils/date_utils.dart';
import '../../../../models/order_model.dart';
import '../../../../providers/auth_provider.dart';
import '../../../../providers/order_provider.dart';
import '../../../../shared/dialogs/confirm_dialog.dart';
import '../../../../shared/widgets/app_snackbar.dart';
import '../../../../shared/widgets/error_view.dart';
import '../../../../shared/widgets/loading_widget.dart';
import '../../../../shared/widgets/order_status_badge.dart';

/// Chi tiết đơn hàng kèm theo dõi giao hàng và hủy đơn (UC09, UC10).
class OrderDetailScreen extends ConsumerWidget {
  const OrderDetailScreen({super.key, required this.orderId});

  final String orderId;

  Future<void> _cancel(BuildContext context, WidgetRef ref) async {
    final user = ref.read(currentUserProvider).valueOrNull;
    if (user == null) return;

    final confirm = await showConfirmDialog(
      context,
      title: 'Hủy đơn hàng',
      message: 'Bạn chắc chắn muốn hủy đơn hàng này?',
      confirmLabel: 'Hủy đơn',
      isDestructive: true,
    );
    if (!confirm) return;

    final success = await ref
        .read(orderControllerProvider.notifier)
        .cancelOrder(orderId: orderId, userId: user.uid);

    if (!context.mounted) return;
    if (success) {
      ref.invalidate(orderDetailProvider(orderId));
      AppSnackbar.showSuccess(context, 'Đã hủy đơn hàng.');
    } else {
      final error = ref.read(orderControllerProvider).error;
      AppSnackbar.showError(context, error?.toString() ?? 'Hủy đơn thất bại.');
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
                  Text('Đơn #${order.id.substring(0, 6).toUpperCase()}',
                      style: Theme.of(context).textTheme.titleMedium),
                  OrderStatusBadge(status: order.status),
                ],
              ),
              const SizedBox(height: 8),
              Text('Ngày đặt: ${AppDateUtils.formatDateTime(order.orderDate)}'),
              Text('Địa chỉ: ${order.shippingAddress}'),
              Text('SĐT: ${order.phoneNumber}'),
              Text('Thanh toán: ${order.paymentMethod.displayName}'),
              Text('Trạng thái TT: ${order.paymentStatus.displayName}'),
              const Divider(height: 24),
              Text('Sản phẩm', style: Theme.of(context).textTheme.titleMedium),
              ...order.details.map((d) => _DetailRow(detail: d)),
              const Divider(height: 24),
              _amountRow(context, 'Tạm tính', order.totalAmount),
              if (order.discountAmount > 0)
                _amountRow(context, 'Giảm giá', -order.discountAmount),
              _amountRow(context, 'Tổng cộng', order.finalAmount, bold: true),
              const Divider(height: 24),
              Text('Theo dõi giao hàng',
                  style: Theme.of(context).textTheme.titleMedium),
              const SizedBox(height: 8),
              ...order.deliveryTracking.map((t) => ListTile(
                    dense: true,
                    leading: const Icon(Icons.local_shipping_outlined),
                    title: Text(t.status),
                    subtitle: Text(AppDateUtils.formatDateTime(t.updatedAt)),
                  )),
              const SizedBox(height: 16),
              if (order.status.isCancellable)
                OutlinedButton.icon(
                  style: OutlinedButton.styleFrom(
                    foregroundColor: Theme.of(context).colorScheme.error,
                  ),
                  onPressed: () => _cancel(context, ref),
                  icon: const Icon(Icons.cancel_outlined),
                  label: const Text('Hủy đơn hàng'),
                ),
            ],
          );
        },
      ),
    );
  }

  Widget _amountRow(BuildContext context, String label, double value,
      {bool bold = false}) {
    final style = bold
        ? Theme.of(context)
            .textTheme
            .titleMedium
            ?.copyWith(fontWeight: FontWeight.bold)
        : Theme.of(context).textTheme.bodyMedium;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: style),
          Text(CurrencyUtils.format(value), style: style),
        ],
      ),
    );
  }
}

class _DetailRow extends StatelessWidget {
  const _DetailRow({required this.detail});

  final OrderDetail detail;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      dense: true,
      contentPadding: EdgeInsets.zero,
      title: Text(detail.productName),
      subtitle: Text(
          '${detail.quantity} x ${CurrencyUtils.format(detail.price)}'),
      trailing: Text(CurrencyUtils.format(detail.subtotal)),
    );
  }
}
