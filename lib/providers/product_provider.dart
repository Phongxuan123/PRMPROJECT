import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/product_model.dart';
import 'repository_providers.dart';

/// Sản phẩm đang bán (status == true) cho khách hàng (UC03).
final activeProductsProvider = StreamProvider<List<Product>>((ref) {
  return ref.watch(productRepositoryProvider).watchActiveProducts();
});

/// Tất cả sản phẩm cho Staff/Admin quản lý (UC13).
final allProductsProvider = StreamProvider<List<Product>>((ref) {
  return ref.watch(productRepositoryProvider).watchAllProducts();
});

/// Từ khóa tìm kiếm sản phẩm hiện tại.
final productSearchQueryProvider = StateProvider<String>((ref) => '');

/// Danh mục đang lọc (null = tất cả).
final productCategoryFilterProvider = StateProvider<String?>((ref) => null);

/// Danh sách sản phẩm sau khi áp tìm kiếm + lọc danh mục (UC03).
final filteredProductsProvider = Provider<AsyncValue<List<Product>>>((ref) {
  final productsAsync = ref.watch(activeProductsProvider);
  final query = ref.watch(productSearchQueryProvider).trim().toLowerCase();
  final categoryId = ref.watch(productCategoryFilterProvider);

  return productsAsync.whenData((products) {
    return products.where((p) {
      final matchesQuery = query.isEmpty ||
          p.name.toLowerCase().contains(query) ||
          p.barcode.toLowerCase().contains(query);
      final matchesCategory =
          categoryId == null || p.categoryId == categoryId;
      return matchesQuery && matchesCategory;
    }).toList();
  });
});

/// Chi tiết một sản phẩm theo id.
final productByIdProvider =
    FutureProvider.family<Product?, String>((ref, productId) {
  return ref.watch(productRepositoryProvider).getProduct(productId);
});

/// Đánh giá của một sản phẩm (UC11).
final productReviewsProvider =
    StreamProvider.family<List<Review>, String>((ref, productId) {
  return ref.watch(productRepositoryProvider).watchReviews(productId);
});
