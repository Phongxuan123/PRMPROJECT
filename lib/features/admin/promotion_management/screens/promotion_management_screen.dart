import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/utils/currency_utils.dart';
import '../../../../core/utils/date_utils.dart';
import '../../../../core/utils/validators.dart';
import '../../../../models/promotion_model.dart';
import '../../../../models/voucher_model.dart';
import '../../../../providers/catalog_providers.dart';
import '../../../../providers/repository_providers.dart';
import '../../../../shared/dialogs/confirm_dialog.dart';
import '../../../../shared/widgets/app_snackbar.dart';
import '../../../../shared/widgets/empty_state_widget.dart';
import '../../../../shared/widgets/error_view.dart';
import '../../../../shared/widgets/loading_widget.dart';

/// Quản lý khuyến mãi và voucher (UC26).
class PromotionManagementScreen extends ConsumerWidget {
  const PromotionManagementScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Khuyến mãi & Voucher'),
          bottom: const TabBar(
            tabs: [
              Tab(text: 'Khuyến mãi'),
              Tab(text: 'Voucher'),
            ],
          ),
        ),
        body: const TabBarView(
          children: [
            _PromotionTab(),
            _VoucherTab(),
          ],
        ),
      ),
    );
  }
}

class _PromotionTab extends ConsumerWidget {
  const _PromotionTab();

  Future<void> _edit(
      BuildContext context, WidgetRef ref, Promotion? existing) async {
    final nameController = TextEditingController(text: existing?.name ?? '');
    final percentController = TextEditingController(
        text: existing == null ? '' : existing.discountPercent.toString());
    var start = existing?.startDate ?? DateTime.now();
    var end = existing?.endDate ?? DateTime.now().add(const Duration(days: 7));
    var status = existing?.status ?? true;
    final formKey = GlobalKey<FormState>();

    final saved = await showDialog<bool>(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          title: Text(existing == null ? 'Thêm khuyến mãi' : 'Sửa khuyến mãi'),
          content: Form(
            key: formKey,
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextFormField(
                    controller: nameController,
                    decoration: const InputDecoration(labelText: 'Tên chương trình'),
                    validator: (v) => Validators.required(v, field: 'Tên'),
                  ),
                  TextFormField(
                    controller: percentController,
                    decoration:
                        const InputDecoration(labelText: 'Phần trăm giảm (%)'),
                    keyboardType: TextInputType.number,
                    validator: (v) =>
                        Validators.positiveInt(v, field: 'Phần trăm'),
                  ),
                  ListTile(
                    contentPadding: EdgeInsets.zero,
                    title: Text('Bắt đầu: ${AppDateUtils.formatDate(start)}'),
                    trailing: const Icon(Icons.calendar_today, size: 18),
                    onTap: () async {
                      final picked = await showDatePicker(
                        context: context,
                        initialDate: start,
                        firstDate: DateTime(2020),
                        lastDate: DateTime(2100),
                      );
                      if (picked != null) setState(() => start = picked);
                    },
                  ),
                  ListTile(
                    contentPadding: EdgeInsets.zero,
                    title: Text('Kết thúc: ${AppDateUtils.formatDate(end)}'),
                    trailing: const Icon(Icons.calendar_today, size: 18),
                    onTap: () async {
                      final picked = await showDatePicker(
                        context: context,
                        initialDate: end,
                        firstDate: DateTime(2020),
                        lastDate: DateTime(2100),
                      );
                      if (picked != null) setState(() => end = picked);
                    },
                  ),
                  SwitchListTile(
                    value: status,
                    onChanged: (v) => setState(() => status = v),
                    title: const Text('Hoạt động'),
                    contentPadding: EdgeInsets.zero,
                  ),
                ],
              ),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text('Hủy'),
            ),
            FilledButton(
              onPressed: () {
                if (!formKey.currentState!.validate()) return;
                if (end.isBefore(start)) {
                  AppSnackbar.showError(
                      context, 'Ngày kết thúc phải sau ngày bắt đầu.');
                  return;
                }
                Navigator.pop(context, true);
              },
              child: const Text('Lưu'),
            ),
          ],
        ),
      ),
    );

    if (saved == true) {
      final repo = ref.read(promotionRepositoryProvider);
      final promotion = Promotion(
        id: existing?.id ?? '',
        name: nameController.text.trim(),
        discountPercent: int.parse(percentController.text.trim()),
        startDate: start,
        endDate: end,
        status: status,
        productIds: existing?.productIds ?? const [],
      );
      try {
        if (existing == null) {
          await repo.addPromotion(promotion);
        } else {
          await repo.updatePromotion(promotion);
        }
        if (context.mounted) AppSnackbar.showSuccess(context, 'Đã lưu khuyến mãi.');
      } catch (e) {
        if (context.mounted) AppSnackbar.showError(context, e.toString());
      }
    }
    nameController.dispose();
    percentController.dispose();
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final promotionsAsync = ref.watch(promotionsProvider);

    return Scaffold(
      floatingActionButton: FloatingActionButton(
        heroTag: 'promo',
        onPressed: () => _edit(context, ref, null),
        child: const Icon(Icons.add),
      ),
      body: promotionsAsync.when(
        loading: () => const LoadingWidget(),
        error: (e, _) => ErrorView(message: e.toString()),
        data: (promotions) {
          if (promotions.isEmpty) {
            return const EmptyStateWidget(message: 'Chưa có khuyến mãi nào.');
          }
          return ListView.separated(
            itemCount: promotions.length,
            separatorBuilder: (context, index) => const Divider(height: 1),
            itemBuilder: (context, index) {
              final p = promotions[index];
              return ListTile(
                leading: CircleAvatar(child: Text('-${p.discountPercent}%')),
                title: Text(p.name),
                subtitle: Text(
                    '${AppDateUtils.formatDate(p.startDate)} - '
                    '${AppDateUtils.formatDate(p.endDate)}'),
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    IconButton(
                      icon: const Icon(Icons.edit_outlined),
                      onPressed: () => _edit(context, ref, p),
                    ),
                    IconButton(
                      icon: const Icon(Icons.delete_outline),
                      onPressed: () async {
                        final confirm = await showConfirmDialog(
                          context,
                          title: 'Xóa khuyến mãi',
                          message: 'Xóa "${p.name}"?',
                          isDestructive: true,
                        );
                        if (!confirm) return;
                        try {
                          await ref
                              .read(promotionRepositoryProvider)
                              .deletePromotion(p.id);
                          if (context.mounted) {
                            AppSnackbar.showSuccess(context, 'Đã xóa khuyến mãi.');
                          }
                        } catch (e) {
                          if (context.mounted) {
                            AppSnackbar.showError(context, e.toString());
                          }
                        }
                      },
                    ),
                  ],
                ),
              );
            },
          );
        },
      ),
    );
  }
}

class _VoucherTab extends ConsumerWidget {
  const _VoucherTab();

  Future<void> _edit(
      BuildContext context, WidgetRef ref, Voucher? existing) async {
    final codeController = TextEditingController(text: existing?.code ?? '');
    final valueController = TextEditingController(
        text: existing == null ? '' : existing.discountValue.toStringAsFixed(0));
    final minController = TextEditingController(
        text: existing == null ? '' : existing.minOrderAmount.toStringAsFixed(0));
    final quantityController = TextEditingController(
        text: existing == null ? '' : existing.quantity.toString());
    var expired =
        existing?.expiredDate ?? DateTime.now().add(const Duration(days: 30));
    var status = existing?.status ?? true;
    final formKey = GlobalKey<FormState>();

    final saved = await showDialog<bool>(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          title: Text(existing == null ? 'Thêm voucher' : 'Sửa voucher'),
          content: Form(
            key: formKey,
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextFormField(
                    controller: codeController,
                    decoration: const InputDecoration(labelText: 'Mã voucher'),
                    validator: (v) => Validators.required(v, field: 'Mã'),
                  ),
                  TextFormField(
                    controller: valueController,
                    decoration:
                        const InputDecoration(labelText: 'Giá trị giảm (VND)'),
                    keyboardType: TextInputType.number,
                    validator: (v) =>
                        Validators.positiveNumber(v, field: 'Giá trị'),
                  ),
                  TextFormField(
                    controller: minController,
                    decoration: const InputDecoration(
                        labelText: 'Giá trị đơn tối thiểu (VND)'),
                    keyboardType: TextInputType.number,
                    validator: (v) =>
                        Validators.nonNegativeInt(v, field: 'Giá trị tối thiểu'),
                  ),
                  TextFormField(
                    controller: quantityController,
                    decoration: const InputDecoration(labelText: 'Số lượng'),
                    keyboardType: TextInputType.number,
                    validator: (v) =>
                        Validators.nonNegativeInt(v, field: 'Số lượng'),
                  ),
                  ListTile(
                    contentPadding: EdgeInsets.zero,
                    title: Text('Hết hạn: ${AppDateUtils.formatDate(expired)}'),
                    trailing: const Icon(Icons.calendar_today, size: 18),
                    onTap: () async {
                      final picked = await showDatePicker(
                        context: context,
                        initialDate: expired,
                        firstDate: DateTime(2020),
                        lastDate: DateTime(2100),
                      );
                      if (picked != null) setState(() => expired = picked);
                    },
                  ),
                  SwitchListTile(
                    value: status,
                    onChanged: (v) => setState(() => status = v),
                    title: const Text('Hoạt động'),
                    contentPadding: EdgeInsets.zero,
                  ),
                ],
              ),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text('Hủy'),
            ),
            FilledButton(
              onPressed: () {
                if (formKey.currentState!.validate()) {
                  Navigator.pop(context, true);
                }
              },
              child: const Text('Lưu'),
            ),
          ],
        ),
      ),
    );

    if (saved == true) {
      final repo = ref.read(voucherRepositoryProvider);
      final voucher = Voucher(
        id: existing?.id ?? '',
        code: codeController.text.trim(),
        discountValue: double.parse(valueController.text.trim()),
        minOrderAmount: double.parse(minController.text.trim()),
        expiredDate: expired,
        quantity: int.parse(quantityController.text.trim()),
        status: status,
      );
      try {
        if (existing == null) {
          await repo.addVoucher(voucher);
        } else {
          await repo.updateVoucher(voucher);
        }
        if (context.mounted) AppSnackbar.showSuccess(context, 'Đã lưu voucher.');
      } catch (e) {
        if (context.mounted) AppSnackbar.showError(context, e.toString());
      }
    }
    codeController.dispose();
    valueController.dispose();
    minController.dispose();
    quantityController.dispose();
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final vouchersAsync = ref.watch(vouchersProvider);

    return Scaffold(
      floatingActionButton: FloatingActionButton(
        heroTag: 'voucher',
        onPressed: () => _edit(context, ref, null),
        child: const Icon(Icons.add),
      ),
      body: vouchersAsync.when(
        loading: () => const LoadingWidget(),
        error: (e, _) => ErrorView(message: e.toString()),
        data: (vouchers) {
          if (vouchers.isEmpty) {
            return const EmptyStateWidget(message: 'Chưa có voucher nào.');
          }
          return ListView.separated(
            itemCount: vouchers.length,
            separatorBuilder: (context, index) => const Divider(height: 1),
            itemBuilder: (context, index) {
              final v = vouchers[index];
              return ListTile(
                leading: const Icon(Icons.confirmation_number_outlined),
                title: Text(v.code),
                subtitle: Text(
                    'Giảm ${CurrencyUtils.format(v.discountValue)} - '
                    'Còn ${v.quantity} lượt'),
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    IconButton(
                      icon: const Icon(Icons.edit_outlined),
                      onPressed: () => _edit(context, ref, v),
                    ),
                    IconButton(
                      icon: const Icon(Icons.delete_outline),
                      onPressed: () async {
                        final confirm = await showConfirmDialog(
                          context,
                          title: 'Xóa voucher',
                          message: 'Xóa "${v.code}"?',
                          isDestructive: true,
                        );
                        if (!confirm) return;
                        try {
                          await ref
                              .read(voucherRepositoryProvider)
                              .deleteVoucher(v.id);
                          if (context.mounted) {
                            AppSnackbar.showSuccess(context, 'Đã xóa voucher.');
                          }
                        } catch (e) {
                          if (context.mounted) {
                            AppSnackbar.showError(context, e.toString());
                          }
                        }
                      },
                    ),
                  ],
                ),
              );
            },
          );
        },
      ),
    );
  }
}
