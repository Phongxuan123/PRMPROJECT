import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/utils/date_utils.dart';
import '../../../../providers/catalog_providers.dart';
import '../../../../shared/widgets/empty_state_widget.dart';
import '../../../../shared/widgets/error_view.dart';
import '../../../../shared/widgets/loading_widget.dart';

/// Danh sách khuyến mãi đang hoạt động (UC04).
class PromotionScreen extends ConsumerWidget {
  const PromotionScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final promotionsAsync = ref.watch(activePromotionsProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Khuyến mãi')),
      body: promotionsAsync.when(
        loading: () => const LoadingWidget(),
        error: (e, _) => ErrorView(message: e.toString()),
        data: (promotions) {
          if (promotions.isEmpty) {
            return const EmptyStateWidget(
              message: 'Hiện chưa có khuyến mãi nào.',
              icon: Icons.local_offer_outlined,
            );
          }
          return ListView.separated(
            padding: const EdgeInsets.all(12),
            itemCount: promotions.length,
            separatorBuilder: (context, index) => const SizedBox(height: 8),
            itemBuilder: (context, index) {
              final p = promotions[index];
              return Card(
                child: ListTile(
                  leading: CircleAvatar(
                    backgroundColor:
                        Theme.of(context).colorScheme.primaryContainer,
                    child: Text('-${p.discountPercent}%'),
                  ),
                  title: Text(p.name),
                  subtitle: Text(
                    'Từ ${AppDateUtils.formatDate(p.startDate)} '
                    'đến ${AppDateUtils.formatDate(p.endDate)}',
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
