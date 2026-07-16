// Màn hình quản lý sản phẩm (UC13): Staff xem toàn bộ sản phẩm, tìm kiếm và điều hướng đến form.
// Dùng allProductsProvider để hiển thị cả sản phẩm đang ẩn (status == false).
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/utils/currency_utils.dart';
import '../../../../providers/product_provider.dart';
import '../../../../providers/repository_providers.dart';
import '../../../../shared/dialogs/confirm_dialog.dart';
import '../../../../shared/widgets/app_snackbar.dart';
import '../../../../shared/widgets/empty_state_widget.dart';
import '../../../../shared/widgets/error_view.dart';
import '../../../../shared/widgets/loading_widget.dart';
import 'product_form_screen.dart';

/// Quản lý sản phẩm cho nhân viên (UC13).
class ProductManagementScreen extends ConsumerWidget {
  const ProductManagementScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final productsAsync = ref.watch(allProductsProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Quản lý sản phẩm')),
      floatingActionButton: FloatingActionButton(
        onPressed: () => Navigator.of(context).push(
          MaterialPageRoute<void>(builder: (_) => const ProductFormScreen()),
        ),
        child: const Icon(Icons.add),
      ),
      body: productsAsync.when(
        loading: () => const LoadingWidget(),
        error: (e, _) => ErrorView(message: e.toString()),
        data: (products) {
          if (products.isEmpty) {
            return const EmptyStateWidget(message: 'Chưa có sản phẩm nào.');
          }
          return ListView.separated(
            itemCount: products.length,
            separatorBuilder: (context, index) => const Divider(height: 1),
            itemBuilder: (context, index) {
              final product = products[index];
              return ListTile(
                leading: CircleAvatar(
                  backgroundColor:
                      Theme.of(context).colorScheme.surfaceContainerHighest,
                  child: const Icon(Icons.inventory_2_outlined),
                ),
                title: Text(product.name),
                subtitle: Text(
                    '${CurrencyUtils.format(product.price)} - '
                    '${product.status ? "Đang bán" : "Ngừng bán"}'),
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    IconButton(
                      icon: const Icon(Icons.edit_outlined),
                      onPressed: () => Navigator.of(context).push(
                        MaterialPageRoute<void>(
                          builder: (_) => ProductFormScreen(product: product),
                        ),
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.delete_outline),
                      onPressed: () async {
                        final confirm = await showConfirmDialog(
                          context,
                          title: 'Xóa sản phẩm',
                          message: 'Bạn chắc chắn muốn xóa "${product.name}"?',
                          isDestructive: true,
                        );
                        if (!confirm) return;
                        try {
                          await ref
                              .read(productRepositoryProvider)
                              .deleteProduct(product.id);
                          if (context.mounted) {
                            AppSnackbar.showSuccess(context, 'Đã xóa sản phẩm.');
                          }
                        } catch (e) {
                          if (context.mounted) {
                            AppSnackbar.showError(context, e.toString());
                          }
                        }
                      },
                    ),
                  ],
                ),
              );
            },
          );
        },
      ),
    );
  }
}
