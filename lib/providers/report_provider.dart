import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../data/repositories/report_repository.dart';
import 'repository_providers.dart';

/// Báo cáo doanh thu theo chi nhánh (UC22). Truyền branchId = null cho Admin.
final revenueReportProvider =
    FutureProvider.family<RevenueReport, String?>((ref, branchId) {
  return ref
      .watch(reportRepositoryProvider)
      .buildRevenueReport(branchId: branchId);
});

/// Số liệu tổng quan toàn hệ thống (UC27).
final dashboardSummaryProvider = FutureProvider<DashboardSummary>((ref) {
  return ref.watch(reportRepositoryProvider).buildDashboardSummary();
});
