// Màn hình Dashboard chính của Admin.
// Hiển thị lời chào và 4 ô chức năng để điều hướng tới các màn hình quản lý:
// Tài khoản, Danh mục, Khuyến mãi và Thống kê.

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
    // Lắng nghe thông tin người dùng đang đăng nhập.
    // valueOrNull tránh lỗi khi dữ liệu chưa tải xong.
    final user = ref.watch(currentUserProvider).valueOrNull;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Quản trị hệ thống'),
        actions: [
          // Nút đăng xuất ở góc phải thanh tiêu đề.
          IconButton(
            icon: const Icon(Icons.logout),
            tooltip: 'Đăng xuất',
            // Gọi hàm đăng xuất thông qua authController.
            onPressed: () => ref.read(authControllerProvider.notifier).signOut(),
          ),
        ],
      ),
      body: Column(
        children: [
          // Hiển thị lời chào cá nhân hoá nếu đã có thông tin người dùng.
          if (user != null)
            Padding(
              padding: const EdgeInsets.all(16),
              child: Align(
                alignment: Alignment.centerLeft,
                child: Text('Xin chào, ${user.fullName}',
                    style: Theme.of(context).textTheme.titleMedium),
              ),
            ),

          // Phần lưới chức năng chính, chiếm toàn bộ không gian còn lại.
          // DashboardGrid là widget dùng chung, tái sử dụng ở cả Manager và Staff.
          Expanded(
            child: DashboardGrid(
              items: [
                // Ô 1: Điều hướng sang màn hình quản lý tài khoản và phân quyền.
                DashboardItem(
                  icon: Icons.manage_accounts,
                  label: 'Tài khoản & Phân quyền',
                  onTap: () => context.push(AppRoutes.adminAccounts),
                ),
                // Ô 2: Điều hướng sang màn hình quản lý danh mục sản phẩm.
                DashboardItem(
                  icon: Icons.category,
                  label: 'Danh mục',
                  onTap: () => context.push(AppRoutes.adminCategories),
                ),
                // Ô 3: Điều hướng sang màn hình quản lý khuyến mãi và voucher.
                DashboardItem(
                  icon: Icons.local_offer,
                  label: 'Khuyến mãi & Voucher',
                  onTap: () => context.push(AppRoutes.adminPromotions),
                ),
                // Ô 4: Điều hướng sang màn hình thống kê tổng hợp toàn hệ thống.
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
