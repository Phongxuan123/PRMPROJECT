// Tập trung tất cả đường dẫn (path constant) của route trong ứng dụng.
// Khi đổi đường dẫn chỉ cần sửa ở đây, không cần tìm kiếm toàn bộ codebase.
/// Tập trung đường dẫn (path) của tất cả route trong ứng dụng.
class AppRoutes {
  const AppRoutes._();

  static const String splash = '/';
  static const String login = '/login';
  static const String register = '/register';
  static const String unauthorized = '/unauthorized';

  // Customer
  static const String customerHome = '/home';
  static const String productDetail = '/product'; // /product/:id
  static const String cart = '/cart';
  static const String checkout = '/checkout';
  static const String orderHistory = '/orders';
  static const String orderDetail = '/orders/detail'; // truyền order qua extra
  static const String profile = '/profile';
  static const String addresses = '/addresses';
  static const String notifications = '/notifications';
  static const String promotions = '/promotions';
  static const String reviewProduct = '/review'; // /review/:id

  // Staff
  static const String staffDashboard = '/staff';
  static const String staffOrders = '/staff/orders';
  static const String staffProducts = '/staff/products';
  static const String staffInventory = '/staff/inventory';
  static const String staffCustomers = '/staff/customers';

  // Manager
  static const String managerDashboard = '/manager';
  static const String managerInventory = '/manager/inventory';
  static const String managerImport = '/manager/import';
  static const String managerEmployees = '/manager/employees';
  static const String managerSuppliers = '/manager/suppliers';
  static const String managerBranches = '/manager/branches';
  static const String managerReports = '/manager/reports';

  // Admin
  static const String adminDashboard = '/admin';
  static const String adminAccounts = '/admin/accounts';
  static const String adminCategories = '/admin/categories';
  static const String adminPromotions = '/admin/promotions';
  static const String adminStatistics = '/admin/statistics';
}
