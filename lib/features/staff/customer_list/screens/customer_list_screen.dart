import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../providers/user_provider.dart';
import '../../../../shared/widgets/empty_state_widget.dart';
import '../../../../shared/widgets/error_view.dart';
import '../../../../shared/widgets/loading_widget.dart';

/// Danh sách khách hàng (UC15).
class CustomerListScreen extends ConsumerWidget {
  const CustomerListScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final customersAsync = ref.watch(customersProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Khách hàng')),
      body: customersAsync.when(
        loading: () => const LoadingWidget(),
        error: (e, _) => ErrorView(message: e.toString()),
        data: (customers) {
          if (customers.isEmpty) {
            return const EmptyStateWidget(message: 'Chưa có khách hàng nào.');
          }
          return ListView.separated(
            itemCount: customers.length,
            separatorBuilder: (context, index) => const Divider(height: 1),
            itemBuilder: (context, index) {
              final customer = customers[index];
              return ListTile(
                leading: CircleAvatar(
                  child: Text(
                      customer.fullName.isEmpty ? '?' : customer.fullName[0]),
                ),
                title: Text(customer.fullName),
                subtitle: Text(
                    '${customer.email}\n${customer.phone ?? "Chưa có SĐT"}'),
                isThreeLine: true,
              );
            },
          );
        },
      ),
    );
  }
}
