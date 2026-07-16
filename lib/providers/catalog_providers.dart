// Provider cho các danh mục dữ liệu dùng chung (master data).
// Bao gồm: danh mục sản phẩm, chi nhánh, nhà cung cấp, voucher, khuyến mãi.
// Các provider này được nhiều màn hình khác nhau watch đồng thời.
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/branch_model.dart';
import '../models/category_model.dart';
import '../models/promotion_model.dart';
import '../models/supplier_model.dart';
import '../models/voucher_model.dart';
import 'repository_providers.dart';

/// Stream provider cho các danh mục dữ liệu dùng chung (master data).

final categoriesProvider = StreamProvider<List<Category>>((ref) {
  return ref.watch(categoryRepositoryProvider).watchCategories();
});

final branchesProvider = StreamProvider<List<Branch>>((ref) {
  return ref.watch(branchRepositoryProvider).watchBranches();
});

final suppliersProvider = StreamProvider<List<Supplier>>((ref) {
  return ref.watch(supplierRepositoryProvider).watchSuppliers();
});

final vouchersProvider = StreamProvider<List<Voucher>>((ref) {
  return ref.watch(voucherRepositoryProvider).watchVouchers();
});

/// Tất cả khuyến mãi (cho Admin quản lý).
final promotionsProvider = StreamProvider<List<Promotion>>((ref) {
  return ref.watch(promotionRepositoryProvider).watchPromotions();
});

/// Khuyến mãi đang hoạt động (cho Guest/Customer xem - UC04).
final activePromotionsProvider = StreamProvider<List<Promotion>>((ref) {
  return ref.watch(promotionRepositoryProvider).watchActivePromotions();
});
