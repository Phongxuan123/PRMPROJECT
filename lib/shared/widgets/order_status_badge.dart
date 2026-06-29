import 'package:flutter/material.dart';

import '../../core/constants/order_status.dart';

/// Hiển thị trạng thái đơn hàng dưới dạng chip màu.
class OrderStatusBadge extends StatelessWidget {
  const OrderStatusBadge({super.key, required this.status});

  final OrderStatus status;

  Color _color(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    switch (status) {
      case OrderStatus.pending:
        return Colors.orange;
      case OrderStatus.confirmed:
        return Colors.blue;
      case OrderStatus.shipping:
        return Colors.purple;
      case OrderStatus.completed:
        return scheme.primary;
      case OrderStatus.cancelled:
        return scheme.error;
    }
  }

  @override
  Widget build(BuildContext context) {
    final color = _color(context);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        status.displayName,
        style: TextStyle(color: color, fontWeight: FontWeight.w600, fontSize: 12),
      ),
    );
  }
}
