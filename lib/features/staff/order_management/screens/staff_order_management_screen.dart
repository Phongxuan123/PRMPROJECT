import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/constants/order_status.dart';
import '../../../../core/utils/currency_utils.dart';
import '../../../../core/utils/date_utils.dart';
import '../../../../providers/auth_provider.dart';
import '../../../../providers/order_provider.dart';
import '../../../../shared/widgets/empty_state_widget.dart';
import '../../../../shared/widgets/error_view.dart';
import '../../../../shared/widgets/loading_widget.dart';
import 'staff_order_detail_screen.dart';

/// Quản lý đơn hàng theo chi nhánh, phân loại theo trạng thái (UC12).
class StaffOrderManagementScreen extends ConsumerWidget {
  const StaffOrderManagementScreen({super.key});

  static const _statusTabs = [
    OrderStatus.pending,
    OrderStatus.confirmed,
    OrderStatus.shipping,
    OrderStatus.completed,
    OrderStatus.cancelled,
  ];

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(currentUserProvider).valueOrNull;
    final branchId = user?.branchId;

    if (branchId == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Xử lý đơn hàng')),
        body: const EmptyStateWidget(
          message: 'Tài khoản chưa được gán chi nhánh.',
        ),
      );
    }

    return DefaultTabController(
      length: _statusTabs.length,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Xử lý đơn hàng'),
          bottom: TabBar(
            isScrollable: true,
            tabs: _statusTabs
                .map((s) => Tab(text: s.displayName))
                .toList(),
          ),
        ),
        body: TabBarView(
          children: _statusTabs
              .map((status) => _OrderList(branchId: branchId, status: status))
              .toList(),
        ),
      ),
    );
  }
}

class _OrderList extends ConsumerWidget {
  const _OrderList({required this.branchId, required this.status});

  final String branchId;
  final OrderStatus status;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final ordersAsync = ref.watch(
      branchOrdersProvider((branchId: branchId, status: status)),
    );

    return ordersAsync.when(
      loading: () => const LoadingWidget(),
      error: (e, _) => ErrorView(message: e.toString()),
      data: (orders) {
        if (orders.isEmpty) {
          return const EmptyStateWidget(message: 'Không có đơn hàng.');
        }
        return ListView.separated(
          padding: const EdgeInsets.all(12),
          itemCount: orders.length,
          separatorBuilder: (context, index) => const SizedBox(height: 8),
          itemBuilder: (context, index) {
            final order = orders[index];
            return Card(
              child: ListTile(
                title:
                    Text('Don #${order.id.substring(0, 6).toUpperCase()}'),
                subtitle: Text(
                    '${AppDateUtils.formatDateTime(order.orderDate)}\n'
                    '${order.shippingAddress}'),
                isThreeLine: true,
                trailing: Text(
                  CurrencyUtils.format(order.finalAmount),
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                onTap: () => Navigator.of(context).push(
                  MaterialPageRoute<void>(
                    builder: (_) =>
                        StaffOrderDetailScreen(orderId: order.id),
                  ),
                ),
              ),
            );
          },
        );
      },
    );
  }
}
