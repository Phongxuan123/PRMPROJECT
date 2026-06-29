import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/utils/currency_utils.dart';
import '../../../../providers/report_provider.dart';
import '../../../../shared/widgets/error_view.dart';
import '../../../../shared/widgets/loading_widget.dart';

/// Thống kê tổng quan toàn hệ thống (UC27).
class StatisticsScreen extends ConsumerWidget {
  const StatisticsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final summaryAsync = ref.watch(dashboardSummaryProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Thống kê tổng'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () => ref.invalidate(dashboardSummaryProvider),
          ),
        ],
      ),
      body: summaryAsync.when(
        loading: () => const LoadingWidget(),
        error: (e, _) => ErrorView(message: e.toString()),
        data: (summary) => GridView.count(
          crossAxisCount: 2,
          padding: const EdgeInsets.all(16),
          mainAxisSpacing: 12,
          crossAxisSpacing: 12,
          childAspectRatio: 1.2,
          children: [
            _StatTile(
              icon: Icons.attach_money,
              label: 'Tổng doanh thu',
              value: CurrencyUtils.formatCompact(summary.totalRevenue),
            ),
            _StatTile(
              icon: Icons.receipt_long,
              label: 'Tổng đơn hàng',
              value: '${summary.totalOrders}',
            ),
            _StatTile(
              icon: Icons.people,
              label: 'Khách hàng',
              value: '${summary.totalCustomers}',
            ),
            _StatTile(
              icon: Icons.inventory_2,
              label: 'Sản phẩm đang bán',
              value: '${summary.totalProducts}',
            ),
          ],
        ),
      ),
    );
  }
}

class _StatTile extends StatelessWidget {
  const _StatTile({
    required this.icon,
    required this.label,
    required this.value,
  });

  final IconData icon;
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 36, color: scheme.primary),
            const SizedBox(height: 12),
            Text(value,
                style: Theme.of(context)
                    .textTheme
                    .headlineSmall
                    ?.copyWith(fontWeight: FontWeight.bold)),
            const SizedBox(height: 4),
            Text(label, textAlign: TextAlign.center),
          ],
        ),
      ),
    );
  }
}
