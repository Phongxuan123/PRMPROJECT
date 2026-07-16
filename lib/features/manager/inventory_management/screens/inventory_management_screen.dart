// Màn hình quản lý tồn kho (UC14, UC17): xem tồn kho, điều chỉnh thủ công và xem cảnh báo thấp.
// Hiển thị tab "Tất cả" và "Thấp" để dễ lọc sản phẩm cần nhập thêm.
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/constants/app_constants.dart';
import '../../../../providers/auth_provider.dart';
import '../../../../providers/inventory_provider.dart';
import '../../../../providers/product_provider.dart';
import '../../../../shared/widgets/empty_state_widget.dart';
import '../../../../shared/widgets/error_view.dart';
import '../../../../shared/widgets/loading_widget.dart';

/// Quản lý kho theo chi nhánh, theo dõi tồn kho thấp (UC17).
class InventoryManagementScreen extends ConsumerWidget {
  const InventoryManagementScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(currentUserProvider).valueOrNull;
    final branchId = user?.branchId;

    if (branchId == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Quản lý kho')),
        body: const EmptyStateWidget(
            message: 'Tài khoản chưa được gán chi nhánh.'),
      );
    }

    final inventoryAsync = ref.watch(branchInventoryProvider(branchId));
    final productsAsync = ref.watch(allProductsProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Quản lý kho')),
      body: inventoryAsync.when(
        loading: () => const LoadingWidget(),
        error: (e, _) => ErrorView(message: e.toString()),
        data: (inventories) {
          if (inventories.isEmpty) {
            return const EmptyStateWidget(message: 'Chưa có dữ liệu tồn kho.');
          }
          final productNames = {
            for (final p in productsAsync.valueOrNull ?? []) p.id: p.name,
          };
          final lowCount = inventories
              .where((i) => i.quantity < AppConstants.lowStockThreshold)
              .length;

          return Column(
            children: [
              if (lowCount > 0)
                Container(
                  width: double.infinity,
                  color: Colors.orange.withValues(alpha: 0.15),
                  padding: const EdgeInsets.all(12),
                  child: Text('Có $lowCount sản phẩm tồn kho thấp.',
                      style: const TextStyle(fontWeight: FontWeight.w600)),
                ),
              Expanded(
                child: ListView.separated(
                  itemCount: inventories.length,
                  separatorBuilder: (context, index) =>
                      const Divider(height: 1),
                  itemBuilder: (context, index) {
                    final inv = inventories[index];
                    final name = productNames[inv.productId] ?? inv.productId;
                    final isLow =
                        inv.quantity < AppConstants.lowStockThreshold;
                    return ListTile(
                      title: Text(name),
                      trailing: Text(
                        '${inv.quantity}',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: isLow ? Colors.orange : null,
                        ),
                      ),
                    );
                  },
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}
