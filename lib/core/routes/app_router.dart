import 'package:flutter/foundation.dart' show ValueNotifier;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../features/admin/account_management/screens/account_management_screen.dart';
import '../../features/admin/category_management/screens/category_management_screen.dart';
import '../../features/admin/dashboard/admin_dashboard_screen.dart';
import '../../features/admin/promotion_management/screens/promotion_management_screen.dart';
import '../../features/admin/statistics/screens/statistics_screen.dart';
import '../../features/auth/screens/login_screen.dart';
import '../../features/auth/screens/register_screen.dart';
import '../../features/auth/screens/splash_screen.dart';
import '../../features/customer/checkout/screens/checkout_screen.dart';
import '../../features/customer/home/customer_home_screen.dart';
import '../../features/customer/order_history/screens/order_detail_screen.dart';
import '../../features/customer/product/screens/product_detail_screen.dart';
import '../../features/customer/product/screens/review_product_screen.dart';
import '../../features/customer/profile/screens/address_management_screen.dart';
import '../../features/customer/profile/screens/notification_list_screen.dart';
import '../../features/customer/promotion/screens/promotion_screen.dart';
import '../../features/manager/branch_management/screens/branch_management_screen.dart';
import '../../features/manager/dashboard/manager_dashboard_screen.dart';
import '../../features/manager/employee_management/screens/employee_management_screen.dart';
import '../../features/manager/import_receipt/screens/import_receipt_screen.dart';
import '../../features/manager/inventory_management/screens/inventory_management_screen.dart';
import '../../features/manager/reports/screens/reports_screen.dart';
import '../../features/manager/supplier_management/screens/supplier_management_screen.dart';
import '../../features/staff/customer_list/screens/customer_list_screen.dart';
import '../../features/staff/dashboard/staff_dashboard_screen.dart';
import '../../features/staff/inventory_check/screens/inventory_check_screen.dart';
import '../../features/staff/order_management/screens/staff_order_management_screen.dart';
import '../../features/staff/product_management/screens/product_management_screen.dart';
import '../../providers/auth_provider.dart';
import '../constants/user_role.dart';
import 'app_routes.dart';

/// Trả về đường dẫn trang chủ tương ứng với vai trò người dùng.
String homePathForRole(UserRole role) {
  switch (role) {
    case UserRole.admin:
      return AppRoutes.adminDashboard;
    case UserRole.branchManager:
      return AppRoutes.managerDashboard;
    case UserRole.staff:
      return AppRoutes.staffDashboard;
    case UserRole.customer:
      return AppRoutes.customerHome;
  }
}

/// Cấu hình GoRouter với redirect theo trạng thái đăng nhập và phân quyền.
final goRouterProvider = Provider<GoRouter>((ref) {
  // Bump notifier mỗi khi auth hoặc hồ sơ người dùng thay đổi để router refresh.
  final refresh = ValueNotifier<int>(0);
  ref.listen(authStateProvider, (previous, next) => refresh.value++);
  ref.listen(currentUserProvider, (previous, next) => refresh.value++);
  ref.onDispose(refresh.dispose);

  return GoRouter(
    initialLocation: AppRoutes.splash,
    refreshListenable: refresh,
    redirect: (context, state) {
      final authState = ref.read(authStateProvider);
      // Đang xác định trạng thái đăng nhập -> giữ nguyên màn hình splash.
      if (authState.isLoading) return null;

      final firebaseUser = authState.valueOrNull;
      final location = state.matchedLocation;
      final isAuthPage = location == AppRoutes.login ||
          location == AppRoutes.register;
      final isSplash = location == AppRoutes.splash;

      // Chưa đăng nhập.
      if (firebaseUser == null) {
        return isAuthPage ? null : AppRoutes.login;
      }

      // Đã đăng nhập nhưng đang nạp hồ sơ -> chờ.
      final userState = ref.read(currentUserProvider);
      if (userState.isLoading) return null;

      final appUser = userState.valueOrNull;
      // Đã đăng nhập Firebase nhưng không có hồ sơ Firestore (doc chưa tạo xong,
      // bị xóa, hoặc lỗi đọc). Tránh kẹt vĩnh viễn ở splash: nếu đang ở trang
      // auth thì chờ hồ sơ load, ngược lại đưa về login.
      if (appUser == null) {
        return isAuthPage ? null : AppRoutes.login;
      }

      // Tài khoản bị khóa / ngừng hoạt động (kể cả khi bị khóa lúc đang đăng
      // nhập) -> không cho truy cập, đưa về login.
      if (appUser.status != UserStatus.active) {
        return isAuthPage ? null : AppRoutes.login;
      }

      final home = homePathForRole(appUser.role);

      // Đang ở splash/auth -> chuyển về trang chủ theo role.
      if (isSplash || isAuthPage) return home;

      // Guard phân quyền theo prefix đường dẫn.
      if (location.startsWith('/admin') && appUser.role != UserRole.admin) {
        return AppRoutes.unauthorized;
      }
      if (location.startsWith('/manager') &&
          appUser.role != UserRole.branchManager) {
        return AppRoutes.unauthorized;
      }
      if (location.startsWith('/staff') && !appUser.role.isStaffOrAbove) {
        return AppRoutes.unauthorized;
      }
      return null;
    },
    routes: [
      GoRoute(
        path: AppRoutes.splash,
        builder: (context, state) => const SplashScreen(),
      ),
      GoRoute(
        path: AppRoutes.login,
        builder: (context, state) => const LoginScreen(),
      ),
      GoRoute(
        path: AppRoutes.register,
        builder: (context, state) => const RegisterScreen(),
      ),
      GoRoute(
        path: AppRoutes.unauthorized,
        builder: (context, state) => const UnauthorizedScreen(),
      ),

      // --- Customer ---
      GoRoute(
        path: AppRoutes.customerHome,
        builder: (context, state) => const CustomerHomeScreen(),
      ),
      GoRoute(
        path: '${AppRoutes.productDetail}/:id',
        builder: (context, state) =>
            ProductDetailScreen(productId: state.pathParameters['id']!),
      ),
      GoRoute(
        path: AppRoutes.checkout,
        builder: (context, state) => const CheckoutScreen(),
      ),
      GoRoute(
        path: '${AppRoutes.orderDetail}/:id',
        builder: (context, state) =>
            OrderDetailScreen(orderId: state.pathParameters['id']!),
      ),
      GoRoute(
        path: AppRoutes.addresses,
        builder: (context, state) => const AddressManagementScreen(),
      ),
      GoRoute(
        path: AppRoutes.notifications,
        builder: (context, state) => const NotificationListScreen(),
      ),
      GoRoute(
        path: AppRoutes.promotions,
        builder: (context, state) => const PromotionScreen(),
      ),
      GoRoute(
        path: '${AppRoutes.reviewProduct}/:id',
        builder: (context, state) =>
            ReviewProductScreen(productId: state.pathParameters['id']!),
      ),

      // --- Staff ---
      GoRoute(
        path: AppRoutes.staffDashboard,
        builder: (context, state) => const StaffDashboardScreen(),
      ),
      GoRoute(
        path: AppRoutes.staffOrders,
        builder: (context, state) => const StaffOrderManagementScreen(),
      ),
      GoRoute(
        path: AppRoutes.staffProducts,
        builder: (context, state) => const ProductManagementScreen(),
      ),
      GoRoute(
        path: AppRoutes.staffInventory,
        builder: (context, state) => const InventoryCheckScreen(),
      ),
      GoRoute(
        path: AppRoutes.staffCustomers,
        builder: (context, state) => const CustomerListScreen(),
      ),

      // --- Manager ---
      GoRoute(
        path: AppRoutes.managerDashboard,
        builder: (context, state) => const ManagerDashboardScreen(),
      ),
      GoRoute(
        path: AppRoutes.managerInventory,
        builder: (context, state) => const InventoryManagementScreen(),
      ),
      GoRoute(
        path: AppRoutes.managerImport,
        builder: (context, state) => const ImportReceiptScreen(),
      ),
      GoRoute(
        path: AppRoutes.managerEmployees,
        builder: (context, state) => const EmployeeManagementScreen(),
      ),
      GoRoute(
        path: AppRoutes.managerSuppliers,
        builder: (context, state) => const SupplierManagementScreen(),
      ),
      GoRoute(
        path: AppRoutes.managerBranches,
        builder: (context, state) => const BranchManagementScreen(),
      ),
      GoRoute(
        path: AppRoutes.managerReports,
        builder: (context, state) => const ReportsScreen(),
      ),

      // --- Admin ---
      GoRoute(
        path: AppRoutes.adminDashboard,
        builder: (context, state) => const AdminDashboardScreen(),
      ),
      GoRoute(
        path: AppRoutes.adminAccounts,
        builder: (context, state) => const AccountManagementScreen(),
      ),
      GoRoute(
        path: AppRoutes.adminCategories,
        builder: (context, state) => const CategoryManagementScreen(),
      ),
      GoRoute(
        path: AppRoutes.adminPromotions,
        builder: (context, state) => const PromotionManagementScreen(),
      ),
      GoRoute(
        path: AppRoutes.adminStatistics,
        builder: (context, state) => const StatisticsScreen(),
      ),
    ],
  );
});
