// Provider tồn kho: stream realtime theo chi nhánh và cảnh báo tồn kho thấp.
// branchInventoryProvider: xem toàn bộ tồn kho của một chi nhánh.
// lowStockProvider: lọc những sản phẩm dưới ngưỡng AppConstants.lowStockThreshold.
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
