/// Tập trung tên collection / đường dẫn Firestore.
///
/// Tránh rải magic string khắp repository. Khi đổi tên collection chỉ sửa ở đây.
class FirestorePaths {
  const FirestorePaths._();

  // Users
  static const String users = 'users';
  static String user(String uid) => 'users/$uid';
  static String userAddresses(String uid) => 'users/$uid/addresses';
  static String userNotifications(String uid) => 'users/$uid/notifications';

  // Categories
  static const String categories = 'categories';
  static String category(String id) => 'categories/$id';

  // Products
  static const String products = 'products';
  static String product(String id) => 'products/$id';
  static String productReviews(String productId) => 'products/$productId/reviews';

  // Branches
  static const String branches = 'branches';
  static String branch(String id) => 'branches/$id';

  // Suppliers
  static const String suppliers = 'suppliers';
  static String supplier(String id) => 'suppliers/$id';

  // Inventory
  static const String inventory = 'inventory';
  static String inventoryDoc(String id) => 'inventory/$id';
  static String inventoryLogs(String id) => 'inventory/$id/logs';

  /// Inventory id cố định dạng 'branchId_productId' để tránh trùng lặp.
  static String inventoryId(String branchId, String productId) =>
      '${branchId}_$productId';

  // Carts
  static const String carts = 'carts';
  static String cart(String userId) => 'carts/$userId';
  static String cartItems(String userId) => 'carts/$userId/items';

  // Orders
  static const String orders = 'orders';
  static String order(String id) => 'orders/$id';
  static String orderDetails(String orderId) => 'orders/$orderId/details';

  // Invoices
  static const String invoices = 'invoices';
  static String invoice(String id) => 'invoices/$id';

  // Returns
  static const String returns = 'returns';
  static String returnDoc(String id) => 'returns/$id';
  static String returnDetails(String returnId) => 'returns/$returnId/details';

  // Import receipts
  static const String importReceipts = 'importReceipts';
  static String importReceipt(String id) => 'importReceipts/$id';
  static String importReceiptDetails(String receiptId) =>
      'importReceipts/$receiptId/details';

  // Promotions
  static const String promotions = 'promotions';
  static String promotion(String id) => 'promotions/$id';

  // Vouchers
  static const String vouchers = 'vouchers';
  static String voucher(String id) => 'vouchers/$id';
}
