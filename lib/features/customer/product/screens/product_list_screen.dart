import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/constants/app_constants.dart';
import '../../../../core/routes/app_routes.dart';
import '../../../../models/product_model.dart';
import '../../../../providers/auth_provider.dart';
import '../../../../providers/catalog_providers.dart';
import '../../../../providers/product_provider.dart';
import '../../../../providers/repository_providers.dart';
import '../../../../shared/widgets/app_snackbar.dart';
import '../../../../shared/widgets/empty_state_widget.dart';
import '../../../../shared/widgets/error_view.dart';
import '../../../../shared/widgets/loading_widget.dart';
import '../../../../shared/widgets/product_card.dart';

/// Danh sách sản phẩm kèm tìm kiếm và lọc danh mục (UC03).
class ProductListScreen extends ConsumerWidget {
  const ProductListScreen({super.key});

  Future<void> _addToCart(
      BuildContext context, WidgetRef ref, Product product) async {
    final user = ref.read(currentUserProvider).valueOrNull;
    if (user == null) return;
    try {
      await ref
          .read(cartRepositoryProvider)
          .addToCart(userId: user.uid, product: product);
      if (context.mounted) {
        AppSnackbar.showSuccess(context, 'Đã thêm vào giỏ hàng.');
      }
    } catch (e) {
      if (context.mounted) AppSnackbar.showError(context, e.toString());
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final productsAsync = ref.watch(filteredProductsProvider);
    final categoriesAsync = ref.watch(categoriesProvider);
    final selectedCategory = ref.watch(productCategoryFilterProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text(AppConstants.appName),
        actions: [
          IconButton(
            icon: const Icon(Icons.local_offer_outlined),
            tooltip: 'Khuyến mãi',
            onPressed: () => context.push(AppRoutes.promotions),
          ),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(12),
            child: TextField(
              decoration: const InputDecoration(
                hintText: 'Tìm sản phẩm...',
                prefixIcon: Icon(Icons.search),
              ),
              onChanged: (value) => ref
                  .read(productSearchQueryProvider.notifier)
                  .state = value,
            ),
          ),
          categoriesAsync.maybeWhen(
            data: (categories) => SizedBox(
              height: 44,
              child: ListView(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 12),
                children: [
                  _CategoryChip(
                    label: 'Tất cả',
                    selected: selectedCategory == null,
                    onTap: () => ref
                        .read(productCategoryFilterProvider.notifier)
                        .state = null,
                  ),
                  ...categories.map((c) => _CategoryChip(
                        label: c.name,
                        selected: selectedCategory == c.id,
                        onTap: () => ref
                            .read(productCategoryFilterProvider.notifier)
                            .state = c.id,
                      )),
                ],
              ),
            ),
            orElse: () => const SizedBox.shrink(),
          ),
          Expanded(
            child: productsAsync.when(
              loading: () => const LoadingWidget(),
              error: (e, _) => ErrorView(message: e.toString()),
              data: (products) {
                if (products.isEmpty) {
                  return const EmptyStateWidget(
                      message: 'Không tìm thấy sản phẩm.');
                }
                return GridView.builder(
                  padding: const EdgeInsets.all(12),
                  gridDelegate:
                      const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    childAspectRatio: 0.68,
                    crossAxisSpacing: 12,
                    mainAxisSpacing: 12,
                  ),
                  itemCount: products.length,
                  itemBuilder: (context, index) {
                    final product = products[index];
                    return ProductCard(
                      product: product,
                      onTap: () => context
                          .push('${AppRoutes.productDetail}/${product.id}'),
                      onAddToCart: () => _addToCart(context, ref, product),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _CategoryChip extends StatelessWidget {
  const _CategoryChip({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: ChoiceChip(
        label: Text(label),
        selected: selected,
        onSelected: (_) => onTap(),
      ),
    );
  }
}
