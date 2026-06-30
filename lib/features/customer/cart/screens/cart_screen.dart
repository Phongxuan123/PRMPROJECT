import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/routes/app_routes.dart';
import '../../../../core/utils/currency_utils.dart';
import '../../../../models/cart_item_model.dart';
import '../../../../providers/auth_provider.dart';
import '../../../../providers/cart_provider.dart';
import '../../../../providers/repository_providers.dart';
import '../../../../shared/widgets/empty_state_widget.dart';
import '../../../../shared/widgets/error_view.dart';
import '../../../../shared/widgets/loading_widget.dart';

/// Giỏ hàng của khách hàng (UC07).
class CartScreen extends ConsumerWidget {
  const CartScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final cartAsync = ref.watch(cartItemsProvider);
    final total = ref.watch(cartTotalProvider);
    final user = ref.watch(authStateProvider).valueOrNull;

    return Scaffold(
      appBar: AppBar(title: const Text('Giỏ hàng')),
      body: cartAsync.when(
        skipLoadingOnReload: true,
        loading: () => const LoadingWidget(),
        error: (e, _) => ErrorView(message: e.toString()),
        data: (items) {
          if (items.isEmpty) {
            return const EmptyStateWidget(
              message: 'Giỏ hàng đang trống.',
              icon: Icons.shopping_cart_outlined,
            );
          }
          return ListView.separated(
            padding: const EdgeInsets.all(12),
            itemCount: items.length,
            separatorBuilder: (context, index) => const Divider(height: 1),
            itemBuilder: (context, index) {
              final item = items[index];
              return _CartItemTile(item: item, userId: user?.uid);
            },
          );
        },
      ),
      bottomNavigationBar: cartAsync.maybeWhen(
        data: (items) => items.isEmpty
            ? null
            : SafeArea(
                child: Padding(
                  padding: const EdgeInsets.all(12),
                  child: Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Text('Tổng cộng'),
                            Text(
                              CurrencyUtils.format(total),
                              style: Theme.of(context)
                                  .textTheme
                                  .titleLarge
                                  ?.copyWith(fontWeight: FontWeight.bold),
                            ),
                          ],
                        ),
                      ),
                      FilledButton(
                        onPressed: () => context.push(AppRoutes.checkout),
                        child: const Text('Thanh toán'),
                      ),
                    ],
                  ),
                ),
              ),
        orElse: () => null,
      ),
    );
  }
}

class _CartItemTile extends ConsumerWidget {
  const _CartItemTile({required this.item, required this.userId});

  final CartItem item;
  final String? userId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final repo = ref.read(cartRepositoryProvider);
    return ListTile(
      contentPadding: const EdgeInsets.symmetric(vertical: 8),
      leading: SizedBox(
        width: 56,
        height: 56,
        child: item.imageUrl.isEmpty
            ? const Icon(Icons.image_outlined)
            : CachedNetworkImage(
            imageUrl: item.imageUrl,
            fit: BoxFit.cover,
            placeholder: (_, _) => const Icon(Icons.image_outlined),
            errorWidget: (_, _, _) => const Icon(Icons.broken_image_outlined),
          ),
      ),
      title: Text(item.productName, maxLines: 2, overflow: TextOverflow.ellipsis),
      subtitle: Text(CurrencyUtils.format(item.productPrice)),
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          IconButton(
            icon: const Icon(Icons.remove_circle_outline),
            onPressed: userId == null
                ? null
                : () => repo.updateQuantity(
                      userId: userId!,
                      itemId: item.id,
                      quantity: item.quantity - 1,
                    ),
          ),
          Text('${item.quantity}'),
          IconButton(
            icon: const Icon(Icons.add_circle_outline),
            onPressed: userId == null
                ? null
                : () => repo.updateQuantity(
                      userId: userId!,
                      itemId: item.id,
                      quantity: item.quantity + 1,
                    ),
          ),
        ],
      ),
    );
  }
}
