// Dashboard của BranchManager: lối vào nhanh các chức năng quản lý chi nhánh.
// Bao gồm: nhân viên, tồn kho, nhập hàng, báo cáo và quản lý nhà cung cấp.
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/routes/app_routes.dart';
import '../../../providers/auth_provider.dart';
import '../../../shared/widgets/dashboard_grid.dart';

/// Dashboard quản lý chi nhánh (Branch Manager).
class ManagerDashboardScreen extends ConsumerWidget {
  const ManagerDashboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(currentUserProvider).valueOrNull;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Quản lý chi nhánh'),
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
                  icon: Icons.warehouse,
                  label: 'Quản lý kho',
                  onTap: () => context.push(AppRoutes.managerInventory),
                ),
                DashboardItem(
                  icon: Icons.add_box,
                  label: 'Nhập hàng',
                  onTap: () => context.push(AppRoutes.managerImport),
                ),
                DashboardItem(
                  icon: Icons.badge,
                  label: 'Nhân viên',
                  onTap: () => context.push(AppRoutes.managerEmployees),
                ),
                DashboardItem(
                  icon: Icons.local_shipping,
                  label: 'Nhà cung cấp',
                  onTap: () => context.push(AppRoutes.managerSuppliers),
                ),
                DashboardItem(
                  icon: Icons.store,
                  label: 'Chi nhánh',
                  onTap: () => context.push(AppRoutes.managerBranches),
                ),
                DashboardItem(
                  icon: Icons.bar_chart,
                  label: 'Báo cáo',
                  onTap: () => context.push(AppRoutes.managerReports),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
