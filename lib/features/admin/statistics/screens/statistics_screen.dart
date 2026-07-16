// Màn hình Thống kê Tổng quan (UC27).
// Hiển thị 4 chỉ số quan trọng của toàn hệ thống dưới dạng lưới 2x2:
// tổng doanh thu, tổng đơn hàng, số khách hàng và số sản phẩm đang bán.
// Dữ liệu được tính toán tổng hợp từ Firestore thông qua dashboardSummaryProvider.

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/utils/currency_utils.dart';
import '../../../../providers/report_provider.dart';
import '../../../../shared/widgets/error_view.dart';
import '../../../../shared/widgets/loading_widget.dart';

/// Thống kê tổng quan toàn hệ thống (UC27).
class StatisticsScreen extends ConsumerWidget {
  const StatisticsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Lắng nghe provider tổng hợp số liệu từ Firestore.
    // Provider này truy vấn nhiều collection (orders, users, products)
    // rồi tính toán ra các con số tổng hợp.
    final summaryAsync = ref.watch(dashboardSummaryProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Thống kê tổng'),
        actions: [
          // Nút làm mới — buộc provider tính lại dữ liệu từ Firestore.
          // invalidate xoá cache hiện tại, provider sẽ tự fetch lại.
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () => ref.invalidate(dashboardSummaryProvider),
          ),
        ],
      ),
      // Xử lý 3 trạng thái bất đồng bộ: đang tải, lỗi, có dữ liệu.
      body: summaryAsync.when(
        loading: () => const LoadingWidget(),
        error: (e, _) => ErrorView(message: e.toString()),
        // Hiển thị 4 ô thống kê trong lưới 2 cột khi có dữ liệu.
        data: (summary) => GridView.count(
          crossAxisCount: 2,
          padding: const EdgeInsets.all(16),
          mainAxisSpacing: 12,
          crossAxisSpacing: 12,
          // childAspectRatio điều chỉnh tỉ lệ chiều rộng/chiều cao của mỗi ô.
          childAspectRatio: 1.2,
          children: [
            // Ô 1: Tổng doanh thu — dùng formatCompact để rút gọn (vd: 1.2 tỷ).
            _StatTile(
              icon: Icons.attach_money,
              label: 'Tổng doanh thu',
              value: CurrencyUtils.formatCompact(summary.totalRevenue),
            ),
            // Ô 2: Tổng số đơn hàng đã được tạo trong hệ thống.
            _StatTile(
              icon: Icons.receipt_long,
              label: 'Tổng đơn hàng',
              value: '${summary.totalOrders}',
            ),
            // Ô 3: Số tài khoản có vai trò khách hàng.
            _StatTile(
              icon: Icons.people,
              label: 'Khách hàng',
              value: '${summary.totalCustomers}',
            ),
            // Ô 4: Số sản phẩm đang ở trạng thái hoạt động (đang bán).
            _StatTile(
              icon: Icons.inventory_2,
              label: 'Sản phẩm đang bán',
              value: '${summary.totalProducts}',
            ),
          ],
        ),
      ),
    );
  }
}

// Widget hiển thị một ô thống kê gồm icon, con số và nhãn mô tả.
// Là StatelessWidget thuần UI — nhận dữ liệu qua constructor, không cần Riverpod.
class _StatTile extends StatelessWidget {
  const _StatTile({
    required this.icon,
    required this.label,
    required this.value,
  });

  final IconData icon;
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    // Lấy màu chủ đạo từ theme để icon đồng bộ với toàn bộ giao diện ứng dụng.
    final scheme = Theme.of(context).colorScheme;
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Icon đại diện cho loại chỉ số.
            Icon(icon, size: 36, color: scheme.primary),
            const SizedBox(height: 12),
            // Con số thống kê — hiển thị to và đậm để nổi bật.
            Text(value,
                style: Theme.of(context)
                    .textTheme
                    .headlineSmall
                    ?.copyWith(fontWeight: FontWeight.bold)),
            const SizedBox(height: 4),
            // Nhãn mô tả ý nghĩa của con số, căn giữa nếu xuống dòng.
            Text(label, textAlign: TextAlign.center),
          ],
        ),
      ),
    );
  }
}
