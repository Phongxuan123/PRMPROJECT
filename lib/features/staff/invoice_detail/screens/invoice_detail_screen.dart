import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/utils/currency_utils.dart';
import '../../../../core/utils/date_utils.dart';
import '../../../../providers/order_provider.dart';
import '../../../../shared/widgets/empty_state_widget.dart';
import '../../../../shared/widgets/error_view.dart';
import '../../../../shared/widgets/loading_widget.dart';

/// Xem hóa đơn của đơn hàng đã hoàn thành (UC16).
class InvoiceDetailScreen extends ConsumerWidget {
  const InvoiceDetailScreen({super.key, required this.orderId});

  final String orderId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final invoiceAsync = ref.watch(invoiceByOrderProvider(orderId));
    final orderAsync = ref.watch(orderDetailProvider(orderId));

    return Scaffold(
      appBar: AppBar(title: const Text('Hóa đơn')),
      body: invoiceAsync.when(
        loading: () => const LoadingWidget(),
        error: (e, _) => ErrorView(message: e.toString()),
        data: (invoice) {
          if (invoice == null) {
            return const EmptyStateWidget(
              message: 'Đơn hàng chưa có hóa đơn (chưa hoàn thành).',
              icon: Icons.receipt_outlined,
            );
          }
          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              Center(
                child: Text('HÓA ĐƠN',
                    style: Theme.of(context).textTheme.headlineSmall),
              ),
              const SizedBox(height: 16),
              Text('Mã hóa đơn: ${invoice.id.substring(0, 8).toUpperCase()}'),
              Text('Mã đơn hàng: ${orderId.substring(0, 6).toUpperCase()}'),
              Text('Ngay: ${AppDateUtils.formatDateTime(invoice.invoiceDate)}'),
              const Divider(height: 24),
              ...?orderAsync.valueOrNull?.details.map((d) => ListTile(
                    dense: true,
                    contentPadding: EdgeInsets.zero,
                    title: Text(d.productName),
                    subtitle: Text(
                        '${d.quantity} x ${CurrencyUtils.format(d.price)}'),
                    trailing: Text(CurrencyUtils.format(d.subtotal)),
                  )),
              const Divider(height: 24),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('Tổng thanh toán',
                      style: Theme.of(context).textTheme.titleMedium),
                  Text(CurrencyUtils.format(invoice.totalAmount),
                      style: Theme.of(context)
                          .textTheme
                          .titleMedium
                          ?.copyWith(fontWeight: FontWeight.bold)),
                ],
              ),
            ],
          );
        },
      ),
    );
  }
}
