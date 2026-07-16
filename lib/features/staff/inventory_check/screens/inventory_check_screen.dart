// Màn hình kiểm kho (UC14): Staff xem tồn kho chi nhánh và điều chỉnh số lượng thực tế.
// Điều chỉnh được ghi vào Firestore Transaction kèm log lý do thay đổi.
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/constants/app_constants.dart';
import '../../../../core/utils/validators.dart';
import '../../../../providers/auth_provider.dart';
import '../../../../providers/inventory_provider.dart';
import '../../../../providers/product_provider.dart';
import '../../../../providers/repository_providers.dart';
import '../../../../shared/widgets/app_snackbar.dart';
import '../../../../shared/widgets/empty_state_widget.dart';
import '../../../../shared/widgets/error_view.dart';
import '../../../../shared/widgets/loading_widget.dart';

/// Kiểm tra và cập nhật tồn kho (UC14).
class InventoryCheckScreen extends ConsumerWidget {
  const InventoryCheckScreen({super.key});

  Future<void> _adjust(
    BuildContext context,
    WidgetRef ref, {
    required String branchId,
    required String productId,
    required String productName,
    required int currentQuantity,
    required String userId,
  }) async {
    final controller =
        TextEditingController(text: currentQuantity.toString());
    final formKey = GlobalKey<FormState>();

    final saved = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Cập nhật tồn kho: $productName'),
        content: Form(
          key: formKey,
          child: TextFormField(
            controller: controller,
            keyboardType: TextInputType.number,
            decoration: const InputDecoration(labelText: 'Số lượng mới'),
            validator: (v) => Validators.nonNegativeInt(v, field: 'Số lượng'),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Hủy'),
          ),
          FilledButton(
            onPressed: () {
              if (formKey.currentState!.validate()) {
                Navigator.pop(context, true);
              }
            },
            child: const Text('Lưu'),
          ),
        ],
      ),
    );

    if (saved == true) {
      try {
        await ref.read(inventoryRepositoryProvider).adjustQuantity(
              branchId: branchId,
              productId: productId,
              newQuantity: int.parse(controller.text.trim()),
              userId: userId,
              note: 'Điều chỉnh thủ công',
            );
        if (context.mounted) {
          AppSnackbar.showSuccess(context, 'Đã cập nhật tồn kho.');
        }
      } catch (e) {
        if (context.mounted) AppSnackbar.showError(context, e.toString());
      }
    }
    controller.dispose();
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(currentUserProvider).valueOrNull;
    final branchId = user?.branchId;

    if (branchId == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Kiểm tra tồn kho')),
        body: const EmptyStateWidget(
            message: 'Tài khoản chưa được gán chi nhánh.'),
      );
    }

    final inventoryAsync = ref.watch(branchInventoryProvider(branchId));
    final productsAsync = ref.watch(allProductsProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Kiểm tra tồn kho')),
      body: inventoryAsync.when(
        loading: () => const LoadingWidget(),
        error: (e, _) => ErrorView(message: e.toString()),
        data: (inventories) {
          if (inventories.isEmpty) {
            return const EmptyStateWidget(message: 'Chưa có dữ liệu tồn kho.');
          }
          final productNames = {
            for (final p in productsAsync.valueOrNull ?? []) p.id: p.name,
          };
          return ListView.separated(
            itemCount: inventories.length,
            separatorBuilder: (context, index) => const Divider(height: 1),
            itemBuilder: (context, index) {
              final inv = inventories[index];
              final name = productNames[inv.productId] ?? inv.productId;
              final isLow = inv.quantity < AppConstants.lowStockThreshold;
              return ListTile(
                title: Text(name),
                subtitle: Text('Tồn kho: ${inv.quantity}'),
                leading: Icon(
                  isLow ? Icons.warning_amber : Icons.check_circle_outline,
                  color: isLow ? Colors.orange : Colors.green,
                ),
                trailing: IconButton(
                  icon: const Icon(Icons.edit_outlined),
                  onPressed: () => _adjust(
                    context,
                    ref,
                    branchId: branchId,
                    productId: inv.productId,
                    productName: name,
                    currentQuantity: inv.quantity,
                    userId: user!.uid,
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
