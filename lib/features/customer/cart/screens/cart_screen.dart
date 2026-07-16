// Màn hình giỏ hàng (UC07): xem, chỉnh số lượng, xóa sản phẩm và chuyển sang thanh toán.
// Hiển thị badge tổng số lượng và tổng tiền ở thanh dưới cùng.
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
          // Tổng tiền + nút thanh toán đặt trong body (không dùng
          // Scaffold.bottomNavigationBar) vì CartScreen nằm trong IndexedStack
          // của CustomerHomeScreen — bottomNavigationBar lồng nhau không hiển thị.
          return Column(
            children: [
              Expanded(
                child: ListView.separated(
                  padding: const EdgeInsets.all(12),
                  itemCount: items.length,
                  separatorBuilder: (context, index) =>
                      const Divider(height: 1),
                  itemBuilder: (context, index) {
                    final item = items[index];
                    return _CartItemTile(item: item, userId: user?.uid);
                  },
                ),
              ),
              _CartSummaryBar(total: total),
            ],
          );
        },
      ),
    );
  }
}

/// Thanh tổng tiền + nút thanh toán ghim ở đáy giỏ hàng.
class _CartSummaryBar extends StatelessWidget {
  const _CartSummaryBar({required this.total});

  final double total;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        border: Border(
          top: BorderSide(color: theme.dividerColor),
        ),
      ),
      child: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Row(
            children: [
              // Expanded để phần tổng tiền chiếm hết chỗ còn lại; nút thanh toán
              // co theo nội dung. KHÔNG để nút dùng minimumSize mặc định của theme
              // (Size.fromHeight = width vô hạn) vì trong Row nó sẽ ép cột text về
              // 0 và làm sập layout ở bản release.
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Text(
                      'Tổng cộng',
                      maxLines: 1,
                      softWrap: false,
                      overflow: TextOverflow.ellipsis,
                    ),
                    Text(
                      CurrencyUtils.format(total),
                      maxLines: 1,
                      softWrap: false,
                      overflow: TextOverflow.ellipsis,
                      style: Theme.of(context)
                          .textTheme
                          .titleLarge
                          ?.copyWith(fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 12),
              FilledButton(
                style: FilledButton.styleFrom(
                  minimumSize: const Size(0, 48),
                ),
                onPressed: () => context.push(AppRoutes.checkout),
                child: const Text('Thanh toán'),
              ),
            ],
          ),
        ),
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
    // Custom layout thay vì ListTile để tránh lỗi "no size" khi trailing Row
    // (2 IconButton + Text) bị ListTile cấp phát constraint width = 0.
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          SizedBox(
            width: 56,
            height: 56,
            child: item.imageUrl.isEmpty
                ? const Icon(Icons.image_outlined)
                : CachedNetworkImage(
                    imageUrl: item.imageUrl,
                    fit: BoxFit.cover,
                    placeholder: (_, _) => const Icon(Icons.image_outlined),
                    errorWidget: (_, _, _) =>
                        const Icon(Icons.broken_image_outlined),
                  ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  item.productName,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 4),
                Text(CurrencyUtils.format(item.productPrice)),
              ],
            ),
          ),
          Row(
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
        ],
      ),
    );
  }
}
