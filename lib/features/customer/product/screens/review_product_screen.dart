// Màn hình viết đánh giá sản phẩm (UC11): chọn số sao và nhập nhận xét.
// Chỉ hiển thị cho khách hàng đã mua và nhận hàng thành công.
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/constants/app_constants.dart';
import '../../../../models/product_model.dart';
import '../../../../providers/auth_provider.dart';
import '../../../../providers/product_provider.dart';
import '../../../../providers/repository_providers.dart';
import '../../../../shared/widgets/app_snackbar.dart';

/// Màn hình đánh giá sản phẩm đã mua (UC11).
class ReviewProductScreen extends ConsumerStatefulWidget {
  const ReviewProductScreen({super.key, required this.productId});

  final String productId;

  @override
  ConsumerState<ReviewProductScreen> createState() =>
      _ReviewProductScreenState();
}

class _ReviewProductScreenState extends ConsumerState<ReviewProductScreen> {
  int _rating = 5;
  final _commentController = TextEditingController();
  bool _submitting = false;

  @override
  void dispose() {
    _commentController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    final user = ref.read(currentUserProvider).valueOrNull;
    if (user == null) return;

    if (_commentController.text.trim().isEmpty) {
      AppSnackbar.showError(context, 'Vui lòng nhập nhận xét.');
      return;
    }

    setState(() => _submitting = true);
    try {
      final review = Review(
        id: '',
        userId: user.uid,
        userName: user.fullName,
        rating: _rating,
        comment: _commentController.text.trim(),
        createdAt: DateTime.now(),
      );
      await ref
          .read(productRepositoryProvider)
          .addReview(widget.productId, review);
      ref.invalidate(productReviewsProvider(widget.productId));
      if (mounted) {
        AppSnackbar.showSuccess(context, 'Cảm ơn bạn đã đánh giá!');
        context.pop();
      }
    } catch (e) {
      if (mounted) AppSnackbar.showError(context, e.toString());
    } finally {
      if (mounted) setState(() => _submitting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Đánh giá sản phẩm')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Đánh giá của bạn'),
            const SizedBox(height: 8),
            Row(
              children: List.generate(
                AppConstants.maxRating,
                (i) => IconButton(
                  icon: Icon(
                    i < _rating ? Icons.star : Icons.star_border,
                    color: Colors.amber,
                    size: 36,
                  ),
                  onPressed: () => setState(() => _rating = i + 1),
                ),
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _commentController,
              maxLines: 4,
              decoration: const InputDecoration(
                labelText: 'Nhận xét',
                alignLabelWithHint: true,
              ),
            ),
            const SizedBox(height: 24),
            FilledButton(
              onPressed: _submitting ? null : _submit,
              child: _submitting
                  ? const SizedBox(
                      height: 20,
                      width: 20,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Text('Gửi đánh giá'),
            ),
          ],
        ),
      ),
    );
  }
}
