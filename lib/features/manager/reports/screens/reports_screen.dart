import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/constants/order_status.dart';
import '../../../../core/utils/currency_utils.dart';
import '../../../../providers/auth_provider.dart';
import '../../../../providers/inventory_provider.dart';
import '../../../../providers/product_provider.dart';
import '../../../../providers/report_provider.dart';
import '../../../../shared/widgets/empty_state_widget.dart';
import '../../../../shared/widgets/error_view.dart';
import '../../../../shared/widgets/loading_widget.dart';

/// Báo cáo doanh thu và tồn kho theo chi nhánh (UC22).
class ReportsScreen extends ConsumerWidget {
  const ReportsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final branchId = ref.watch(currentUserProvider).valueOrNull?.branchId;

    if (branchId == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Báo cáo')),
        body: const EmptyStateWidget(
            message: 'Tài khoản chưa được gán chi nhánh.'),
      );
    }

    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Báo cáo chi nhánh'),
          bottom: const TabBar(
            tabs: [
              Tab(text: 'Doanh thu'),
              Tab(text: 'Tồn kho'),
            ],
          ),
        ),
        body: TabBarView(
          children: [
            _RevenueTab(branchId: branchId),
            _StockTab(branchId: branchId),
          ],
        ),
      ),
    );
  }
}

class _RevenueTab extends ConsumerWidget {
  const _RevenueTab({required this.branchId});

  final String branchId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final reportAsync = ref.watch(revenueReportProvider(branchId));

    return reportAsync.when(
      loading: () => const LoadingWidget(),
      error: (e, _) => ErrorView(message: e.toString()),
      data: (report) => ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _StatCard(
            title: 'Tổng doanh thu',
            value: CurrencyUtils.format(report.totalRevenue),
            icon: Icons.attach_money,
          ),
          _StatCard(
            title: 'Tổng số đơn',
            value: '${report.totalOrders}',
            icon: Icons.receipt_long,
          ),
          const SizedBox(height: 8),
          Text('Đơn theo trạng thái',
              style: Theme.of(context).textTheme.titleMedium),
          ...OrderStatus.values.map((s) => ListTile(
                dense: true,
                title: Text(s.displayName),
                trailing: Text('${report.ordersByStatus[s] ?? 0}'),
              )),
          const SizedBox(height: 8),
          Text('Sản phẩm bán chạy',
              style: Theme.of(context).textTheme.titleMedium),
          if (report.topProducts.isEmpty)
            const Padding(
              padding: EdgeInsets.all(8),
              child: Text('Chưa có dữ liệu.'),
            )
          else
            ...report.topProducts.map((p) => ListTile(
                  dense: true,
                  title: Text(p.productName),
                  trailing: Text('Đã bán: ${p.soldQuantity}'),
                )),
        ],
      ),
    );
  }
}

class _StockTab extends ConsumerWidget {
  const _StockTab({required this.branchId});

  final String branchId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final inventoryAsync = ref.watch(branchInventoryProvider(branchId));
    final productsAsync = ref.watch(allProductsProvider);

    return inventoryAsync.when(
      loading: () => const LoadingWidget(),
      error: (e, _) => ErrorView(message: e.toString()),
      data: (inventories) {
        if (inventories.isEmpty) {
          return const EmptyStateWidget(message: 'Chưa có dữ liệu tồn kho.');
        }
        final names = {
          for (final p in productsAsync.valueOrNull ?? []) p.id: p.name,
        };
        return ListView.separated(
          itemCount: inventories.length,
          separatorBuilder: (context, index) => const Divider(height: 1),
          itemBuilder: (context, index) {
            final inv = inventories[index];
            return ListTile(
              title: Text(names[inv.productId] ?? inv.productId),
              trailing: Text('${inv.quantity}',
                  style: const TextStyle(fontWeight: FontWeight.bold)),
            );
          },
        );
      },
    );
  }
}

class _StatCard extends StatelessWidget {
  const _StatCard({
    required this.title,
    required this.value,
    required this.icon,
  });

  final String title;
  final String value;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: ListTile(
        leading: Icon(icon, color: Theme.of(context).colorScheme.primary),
        title: Text(title),
        trailing: Text(value,
            style: Theme.of(context)
                .textTheme
                .titleMedium
                ?.copyWith(fontWeight: FontWeight.bold)),
      ),
    );
  }
}
