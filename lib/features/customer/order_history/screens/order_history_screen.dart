// Màn hình lịch sử đơn hàng (UC09): danh sách đơn đã đặt sắp xếp từ mới nhất.
// Nhấn vào đơn để xem chi tiết và theo dõi trạng thái giao hàng.
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/routes/app_routes.dart';
import '../../../../core/utils/currency_utils.dart';
import '../../../../core/utils/date_utils.dart';
import '../../../../providers/order_provider.dart';
import '../../../../shared/widgets/empty_state_widget.dart';
import '../../../../shared/widgets/error_view.dart';
import '../../../../shared/widgets/loading_widget.dart';
import '../../../../shared/widgets/order_status_badge.dart';

/// Lịch sử đơn hàng của khách hàng (UC09).
class OrderHistoryScreen extends ConsumerWidget {
  const OrderHistoryScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final ordersAsync = ref.watch(myOrdersProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Đơn hàng của tôi')),
      body: ordersAsync.when(
        loading: () => const LoadingWidget(),
        error: (e, _) => ErrorView(message: e.toString()),
        data: (orders) {
          if (orders.isEmpty) {
            return const EmptyStateWidget(
              message: 'Bạn chưa có đơn hàng nào.',
              icon: Icons.receipt_long_outlined,
            );
          }
          return ListView.separated(
            padding: const EdgeInsets.all(12),
            itemCount: orders.length,
            separatorBuilder: (context, index) => const SizedBox(height: 8),
            itemBuilder: (context, index) {
              final order = orders[index];
              return Card(
                child: ListTile(
                  title: Text('Đơn #${order.id.substring(0, 6).toUpperCase()}'),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(AppDateUtils.formatDateTime(order.orderDate)),
                      const SizedBox(height: 4),
                      OrderStatusBadge(status: order.status),
                    ],
                  ),
                  trailing: Text(
                    CurrencyUtils.format(order.finalAmount),
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  isThreeLine: true,
                  onTap: () => context.push(
                    '${AppRoutes.orderDetail}/${order.id}',
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
