import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/inventory_model.dart';
import 'repository_providers.dart';

/// Tồn kho theo chi nhánh (UC17).
final branchInventoryProvider =
    StreamProvider.family<List<Inventory>, String>((ref, branchId) {
  return ref.watch(inventoryRepositoryProvider).watchByBranch(branchId);
});

/// Tồn kho thấp theo chi nhánh (báo cáo tồn kho thấp).
final lowStockProvider =
    StreamProvider.family<List<Inventory>, String>((ref, branchId) {
  return ref.watch(inventoryRepositoryProvider).watchLowStock(branchId);
});
