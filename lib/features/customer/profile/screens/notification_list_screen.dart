import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/utils/date_utils.dart';
import '../../../../providers/auth_provider.dart';
import '../../../../providers/repository_providers.dart';
import '../../../../providers/user_provider.dart';
import '../../../../shared/widgets/empty_state_widget.dart';
import '../../../../shared/widgets/error_view.dart';
import '../../../../shared/widgets/loading_widget.dart';

/// Danh sách thông báo trong app (UC "Nhận thông báo" - FCM).
class NotificationListScreen extends ConsumerWidget {
  const NotificationListScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final notificationsAsync = ref.watch(myNotificationsProvider);
    final user = ref.watch(currentUserProvider).valueOrNull;

    return Scaffold(
      appBar: AppBar(title: const Text('Thông báo')),
      body: notificationsAsync.when(
        loading: () => const LoadingWidget(),
        error: (e, _) => ErrorView(message: e.toString()),
        data: (notifications) {
          if (notifications.isEmpty) {
            return const EmptyStateWidget(
              message: 'Chưa có thông báo nào.',
              icon: Icons.notifications_off_outlined,
            );
          }
          return ListView.separated(
            itemCount: notifications.length,
            separatorBuilder: (context, index) => const Divider(height: 1),
            itemBuilder: (context, index) {
              final n = notifications[index];
              return ListTile(
                leading: Icon(
                  n.isRead
                      ? Icons.notifications_none
                      : Icons.notifications_active,
                  color: n.isRead
                      ? null
                      : Theme.of(context).colorScheme.primary,
                ),
                title: Text(n.title),
                subtitle: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(n.content),
                    Text(AppDateUtils.timeAgo(n.createdAt),
                        style: Theme.of(context).textTheme.bodySmall),
                  ],
                ),
                isThreeLine: true,
                onTap: n.isRead || user == null
                    ? null
                    : () => ref
                        .read(userRepositoryProvider)
                        .markNotificationRead(user.uid, n.id),
              );
            },
          );
        },
      ),
    );
  }
}
