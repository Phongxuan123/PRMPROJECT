// Dashboard Admin: lối vào nhanh tất cả chức năng quản trị toàn hệ thống.
// Bao gồm: tài khoản, sản phẩm, danh mục, chi nhánh, khuyến mãi, thống kê.
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/routes/app_routes.dart';
import '../../../providers/auth_provider.dart';
import '../../../shared/widgets/dashboard_grid.dart';

/// Dashboard quản trị viên (Admin).
class AdminDashboardScreen extends ConsumerWidget {
  const AdminDashboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(currentUserProvider).valueOrNull;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Quản trị hệ thống'),
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
                  icon: Icons.manage_accounts,
                  label: 'Tài khoản & Phân quyền',
                  onTap: () => context.push(AppRoutes.adminAccounts),
                ),
                DashboardItem(
                  icon: Icons.category,
                  label: 'Danh mục',
                  onTap: () => context.push(AppRoutes.adminCategories),
                ),
                DashboardItem(
                  icon: Icons.local_offer,
                  label: 'Khuyến mãi & Voucher',
                  onTap: () => context.push(AppRoutes.adminPromotions),
                ),
                DashboardItem(
                  icon: Icons.insights,
                  label: 'Thống kê tổng',
                  onTap: () => context.push(AppRoutes.adminStatistics),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
