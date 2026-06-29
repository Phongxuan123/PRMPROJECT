import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../data/repositories/auth_repository.dart';
import '../data/repositories/branch_repository.dart';
import '../data/repositories/cart_repository.dart';
import '../data/repositories/category_repository.dart';
import '../data/repositories/import_receipt_repository.dart';
import '../data/repositories/inventory_repository.dart';
import '../data/repositories/invoice_repository.dart';
import '../data/repositories/order_repository.dart';
import '../data/repositories/product_repository.dart';
import '../data/repositories/promotion_repository.dart';
import '../data/repositories/report_repository.dart';
import '../data/repositories/supplier_repository.dart';
import '../data/repositories/user_repository.dart';
import '../data/repositories/voucher_repository.dart';
import 'firebase_providers.dart';

/// Cung cấp các repository, mỗi domain một provider (Repository Pattern).

final authRepositoryProvider = Provider<AuthRepository>((ref) {
  return AuthRepository(
    authService: ref.watch(firebaseAuthServiceProvider),
    firestore: ref.watch(firestoreProvider),
  );
});

final userRepositoryProvider = Provider<UserRepository>((ref) {
  return UserRepository(firestore: ref.watch(firestoreProvider));
});

final productRepositoryProvider = Provider<ProductRepository>((ref) {
  return ProductRepository(
    firestore: ref.watch(firestoreProvider),
    storageService: ref.watch(firebaseStorageServiceProvider),
  );
});

final categoryRepositoryProvider = Provider<CategoryRepository>((ref) {
  return CategoryRepository(firestore: ref.watch(firestoreProvider));
});

final branchRepositoryProvider = Provider<BranchRepository>((ref) {
  return BranchRepository(firestore: ref.watch(firestoreProvider));
});

final supplierRepositoryProvider = Provider<SupplierRepository>((ref) {
  return SupplierRepository(firestore: ref.watch(firestoreProvider));
});

final cartRepositoryProvider = Provider<CartRepository>((ref) {
  return CartRepository(firestore: ref.watch(firestoreProvider));
});

final inventoryRepositoryProvider = Provider<InventoryRepository>((ref) {
  return InventoryRepository(firestore: ref.watch(firestoreProvider));
});

final orderRepositoryProvider = Provider<OrderRepository>((ref) {
  return OrderRepository(firestore: ref.watch(firestoreProvider));
});

final importReceiptRepositoryProvider =
    Provider<ImportReceiptRepository>((ref) {
  return ImportReceiptRepository(firestore: ref.watch(firestoreProvider));
});

final invoiceRepositoryProvider = Provider<InvoiceRepository>((ref) {
  return InvoiceRepository(firestore: ref.watch(firestoreProvider));
});

final promotionRepositoryProvider = Provider<PromotionRepository>((ref) {
  return PromotionRepository(firestore: ref.watch(firestoreProvider));
});

final voucherRepositoryProvider = Provider<VoucherRepository>((ref) {
  return VoucherRepository(firestore: ref.watch(firestoreProvider));
});

final reportRepositoryProvider = Provider<ReportRepository>((ref) {
  return ReportRepository(firestore: ref.watch(firestoreProvider));
});
