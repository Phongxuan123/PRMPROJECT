// Màn hình chi tiết sản phẩm (UC03): xem ảnh, mô tả, giá, đánh giá và thêm vào giỏ.
// Hiển thị ảnh gallery dạng carousel; nút thêm vào giỏ gọi CartRepository.addToCart().
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/routes/app_routes.dart';
import '../../../../core/utils/currency_utils.dart';
import '../../../../core/utils/date_utils.dart';
import '../../../../models/product_model.dart';
import '../../../../providers/auth_provider.dart';
import '../../../../providers/product_provider.dart';
import '../../../../providers/repository_providers.dart';
import '../../../../shared/widgets/app_snackbar.dart';
import '../../../../shared/widgets/error_view.dart';
import '../../../../shared/widgets/loading_widget.dart';

/// Chi tiết sản phẩm, đánh giá và thêm vào giỏ (UC03, UC11).
class ProductDetailScreen extends ConsumerWidget {
  const ProductDetailScreen({super.key, required this.productId});

  final String productId;

  Future<void> _addToCart(
      BuildContext context, WidgetRef ref, Product product) async {
    final firebaseUser = ref.read(authStateProvider).valueOrNull;
    if (firebaseUser == null) return;
    try {
      await ref
          .read(cartRepositoryProvider)
          .addToCart(userId: firebaseUser.uid, product: product);
      if (context.mounted) {
        AppSnackbar.showSuccess(context, 'Đã thêm vào giỏ hàng.');
      }
    } catch (e) {
      if (context.mounted) AppSnackbar.showError(context, e.toString());
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final productAsync = ref.watch(productByIdProvider(productId));
    final reviewsAsync = ref.watch(productReviewsProvider(productId));

    return Scaffold(
      appBar: AppBar(title: const Text('Chi tiết sản phẩm')),
      body: productAsync.when(
        loading: () => const LoadingWidget(),
        error: (e, _) => ErrorView(message: e.toString()),
        data: (product) {
          if (product == null) {
            return const ErrorView(message: 'Không tìm thấy sản phẩm.');
          }
          return ListView(
            children: [
              _ImageGallery(images: product.images),
              Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(product.name,
                        style: Theme.of(context).textTheme.titleLarge),
                    const SizedBox(height: 8),
                    Text(
                      CurrencyUtils.format(product.price),
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                            color: Theme.of(context).colorScheme.primary,
                            fontWeight: FontWeight.bold,
                          ),
                    ),
                    const SizedBox(height: 4),
                    Text('Đơn vị: ${product.unit}'),
                    const SizedBox(height: 16),
                    if (product.description != null) ...[
                      Text('Mô tả',
                          style: Theme.of(context).textTheme.titleMedium),
                      const SizedBox(height: 4),
                      Text(product.description!),
                      const SizedBox(height: 16),
                    ],
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text('Đánh giá',
                            style: Theme.of(context).textTheme.titleMedium),
                        TextButton.icon(
                          onPressed: () => context
                              .push('${AppRoutes.reviewProduct}/$productId'),
                          icon: const Icon(Icons.rate_review_outlined),
                          label: const Text('Viết đánh giá'),
                        ),
                      ],
                    ),
                    reviewsAsync.when(
                      loading: () => const Padding(
                        padding: EdgeInsets.all(8),
                        child: LinearProgressIndicator(),
                      ),
                      error: (e, _) => Text('Lỗi tải đánh giá: $e'),
                      data: (reviews) {
                        if (reviews.isEmpty) {
                          return const Padding(
                            padding: EdgeInsets.symmetric(vertical: 8),
                            child: Text('Chưa có đánh giá nào.'),
                          );
                        }
                        return Column(
                          children:
                              reviews.map((r) => _ReviewTile(review: r)).toList(),
                        );
                      },
                    ),
                  ],
                ),
              ),
            ],
          );
        },
      ),
      bottomNavigationBar: productAsync.maybeWhen(
        data: (product) => product == null
            ? null
            : SafeArea(
                child: Padding(
                  padding: const EdgeInsets.all(12),
                  child: FilledButton.icon(
                    onPressed: () => _addToCart(context, ref, product),
                    icon: const Icon(Icons.add_shopping_cart),
                    label: const Text('Thêm vào giỏ hàng'),
                  ),
                ),
              ),
        orElse: () => null,
      ),
    );
  }
}

class _ImageGallery extends StatelessWidget {
  const _ImageGallery({required this.images});

  final List<String> images;

  @override
  Widget build(BuildContext context) {
    if (images.isEmpty) {
      return Container(
        height: 240,
        color: Theme.of(context).colorScheme.surfaceContainerHighest,
        child: const Icon(Icons.image_outlined, size: 64),
      );
    }
    return SizedBox(
      height: 240,
      child: PageView(
        children: images
            .map((url) => CachedNetworkImage(imageUrl: url, fit: BoxFit.cover))
            .toList(),
      ),
    );
  }
}

class _ReviewTile extends StatelessWidget {
  const _ReviewTile({required this.review});

  final Review review;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      contentPadding: EdgeInsets.zero,
      leading: CircleAvatar(
        child: Text(review.userName.isEmpty ? '?' : review.userName[0]),
      ),
      title: Row(
        children: [
          Text(review.userName),
          const Spacer(),
          ...List.generate(
            5,
            (i) => Icon(
              i < review.rating ? Icons.star : Icons.star_border,
              size: 16,
              color: Colors.amber,
            ),
          ),
        ],
      ),
      subtitle: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(review.comment),
          Text(AppDateUtils.timeAgo(review.createdAt),
              style: Theme.of(context).textTheme.bodySmall),
        ],
      ),
    );
  }
}
