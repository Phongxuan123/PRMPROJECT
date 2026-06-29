import 'package:cloud_firestore/cloud_firestore.dart';

import '../../core/constants/firestore_paths.dart';
import '../../core/constants/order_status.dart';
import '../../core/constants/user_role.dart';
import '../../core/errors/app_exceptions.dart';

/// Tổng hợp số liệu báo cáo doanh thu và đơn hàng.
class RevenueReport {
  const RevenueReport({
    required this.totalRevenue,
    required this.totalOrders,
    required this.ordersByStatus,
    required this.topProducts,
  });

  final double totalRevenue;
  final int totalOrders;
  final Map<OrderStatus, int> ordersByStatus;

  /// Danh sách sản phẩm bán chạy: (tên sản phẩm, số lượng đã bán).
  final List<({String productName, int soldQuantity})> topProducts;
}

/// Tổng hợp số liệu dashboard toàn hệ thống (Admin - UC27).
class DashboardSummary {
  const DashboardSummary({
    required this.totalRevenue,
    required this.totalOrders,
    required this.totalCustomers,
    required this.totalProducts,
  });

  final double totalRevenue;
  final int totalOrders;
  final int totalCustomers;
  final int totalProducts;
}

/// Tạo báo cáo thống kê (UC22, UC27).
///
/// Firestore không có GROUP BY/SUM như SQL nên kết hợp AggregateQuery
/// (count/sum) và tính client-side cho báo cáo phức tạp (Mục 17).
class ReportRepository {
  ReportRepository({required FirebaseFirestore firestore})
      : _firestore = firestore;

  final FirebaseFirestore _firestore;

  /// Báo cáo doanh thu theo chi nhánh và khoảng thời gian (UC22).
  ///
  /// Truyền [branchId] = null để tính toán toàn hệ thống (Admin).
  Future<RevenueReport> buildRevenueReport({
    String? branchId,
    DateTime? startDate,
    DateTime? endDate,
  }) async {
    try {
      Query<Map<String, dynamic>> query =
          _firestore.collection(FirestorePaths.orders);
      if (branchId != null) {
        query = query.where('branchId', isEqualTo: branchId);
      }
      if (startDate != null) {
        query = query.where('orderDate',
            isGreaterThanOrEqualTo: Timestamp.fromDate(startDate));
      }
      if (endDate != null) {
        query = query.where('orderDate',
            isLessThanOrEqualTo: Timestamp.fromDate(endDate));
      }

      final snap = await query.get();

      var totalRevenue = 0.0;
      final ordersByStatus = <OrderStatus, int>{
        for (final s in OrderStatus.values) s: 0,
      };

      for (final doc in snap.docs) {
        final data = doc.data();
        final status = OrderStatus.fromValue(data['status'] as String?);
        ordersByStatus[status] = (ordersByStatus[status] ?? 0) + 1;

        if (status == OrderStatus.completed) {
          final total = (data['totalAmount'] as num?)?.toDouble() ?? 0;
          final discount = (data['discountAmount'] as num?)?.toDouble() ?? 0;
          totalRevenue += total - discount;
        }
      }

      final topProducts = await _computeTopProducts(snap.docs);

      return RevenueReport(
        totalRevenue: totalRevenue,
        totalOrders: snap.docs.length,
        ordersByStatus: ordersByStatus,
        topProducts: topProducts,
      );
    } on FirebaseException catch (e) {
      throw DataException('Không thể tạo báo cáo.', code: e.code);
    }
  }

  /// Tính sản phẩm bán chạy từ order details của các đơn hoàn thành.
  Future<List<({String productName, int soldQuantity})>> _computeTopProducts(
    List<QueryDocumentSnapshot<Map<String, dynamic>>> orderDocs,
  ) async {
    // Gom nhóm theo productId (không theo tên) để tránh gộp nhầm 2 sản phẩm
    // trùng tên, hoặc tách 1 sản phẩm bị đổi tên thành 2 dòng.
    final soldByProduct = <String, ({String name, int qty})>{};

    for (final order in orderDocs) {
      final status = OrderStatus.fromValue(order.data()['status'] as String?);
      if (status != OrderStatus.completed) continue;

      final detailSnap = await _firestore
          .collection(FirestorePaths.orderDetails(order.id))
          .get();
      for (final detail in detailSnap.docs) {
        final productId = detail.data()['productId'] as String? ?? '';
        if (productId.isEmpty) continue;
        final name = detail.data()['productName'] as String? ?? '';
        final qty = (detail.data()['quantity'] as num?)?.toInt() ?? 0;
        final prev = soldByProduct[productId];
        soldByProduct[productId] = (name: name, qty: (prev?.qty ?? 0) + qty);
      }
    }

    final entries = soldByProduct.values.toList()
      ..sort((a, b) => b.qty.compareTo(a.qty));
    return entries
        .take(5)
        .map((e) => (productName: e.name, soldQuantity: e.qty))
        .toList();
  }

  /// Số liệu tổng quan toàn hệ thống (UC27).
  Future<DashboardSummary> buildDashboardSummary() async {
    try {
      final report = await buildRevenueReport();

      final customerCount = await _firestore
          .collection(FirestorePaths.users)
          .where('role', isEqualTo: UserRole.customer.value)
          .count()
          .get();

      final productCount = await _firestore
          .collection(FirestorePaths.products)
          .where('status', isEqualTo: true)
          .count()
          .get();

      return DashboardSummary(
        totalRevenue: report.totalRevenue,
        totalOrders: report.totalOrders,
        totalCustomers: customerCount.count ?? 0,
        totalProducts: productCount.count ?? 0,
      );
    } on FirebaseException catch (e) {
      throw DataException('Không thể tạo dashboard.', code: e.code);
    }
  }
}
