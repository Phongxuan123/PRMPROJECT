// Dashboard của Staff: lối vào nhanh quản lý đơn hàng, sản phẩm, tồn kho và khách hàng.
// Hiển thị tên nhân viên và chi nhánh đang phụ trách lấy từ currentUserProvider.
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/routes/app_routes.dart';
import '../../../providers/auth_provider.dart';
import '../../../shared/widgets/dashboard_grid.dart';

/// Dashboard nhân viên (Staff).
class StaffDashboardScreen extends ConsumerWidget {
  const StaffDashboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(currentUserProvider).valueOrNull;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Trang nhân viên'),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            tooltip: 'Đăng xuất',
            onPressed: () => ref.read(authControllerProvider.notifier).signOut(),
          ),
        ],
      ),
      body: Column(
        children: [
          if (user != null)
            Padding(
              padding: const EdgeInsets.all(16),
              child: Align(
                alignment: Alignment.centerLeft,
                child: Text('Xin chào, ${user.fullName}',
                    style: Theme.of(context).textTheme.titleMedium),
              ),
            ),
          Expanded(
            child: DashboardGrid(
              items: [
                DashboardItem(
                  icon: Icons.receipt_long,
                  label: 'Xử lý đơn hàng',
                  onTap: () => context.push(AppRoutes.staffOrders),
                ),
                DashboardItem(
                  icon: Icons.inventory_2,
                  label: 'Quản lý sản phẩm',
                  onTap: () => context.push(AppRoutes.staffProducts),
                ),
                DashboardItem(
                  icon: Icons.warehouse,
                  label: 'Kiểm tra tồn kho',
                  onTap: () => context.push(AppRoutes.staffInventory),
                ),
                DashboardItem(
                  icon: Icons.people,
                  label: 'Khách hàng',
                  onTap: () => context.push(AppRoutes.staffCustomers),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
