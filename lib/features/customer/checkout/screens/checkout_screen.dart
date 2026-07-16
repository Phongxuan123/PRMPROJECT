// Màn hình thanh toán (UC08): chọn địa chỉ, phương thức thanh toán, áp mã voucher và đặt hàng.
// Gọi OrderController.createOrder() để tạo đơn trong một Firestore Transaction.
// Sau khi đặt thành công, giỏ hàng được xóa và điều hướng đến lịch sử đơn hàng.
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/constants/order_status.dart';
import '../../../../core/routes/app_routes.dart';
import '../../../../core/utils/currency_utils.dart';
import '../../../../data/repositories/order_repository.dart';
import '../../../../models/branch_model.dart';
import '../../../../models/user_model.dart';
import '../../../../models/voucher_model.dart';
import '../../../../providers/auth_provider.dart';
import '../../../../providers/cart_provider.dart';
import '../../../../providers/catalog_providers.dart';
import '../../../../providers/order_provider.dart';
import '../../../../providers/repository_providers.dart';
import '../../../../providers/user_provider.dart';
import '../../../../shared/widgets/app_snackbar.dart';

/// Màn hình đặt hàng / checkout (UC08).
class CheckoutScreen extends ConsumerStatefulWidget {
  const CheckoutScreen({super.key});

  @override
  ConsumerState<CheckoutScreen> createState() => _CheckoutScreenState();
}

class _CheckoutScreenState extends ConsumerState<CheckoutScreen> {
  Address? _selectedAddress;
  Branch? _selectedBranch;
  PaymentMethod _paymentMethod = PaymentMethod.cod;
  Voucher? _appliedVoucher;
  final _voucherController = TextEditingController();

  @override
  void dispose() {
    _voucherController.dispose();
    super.dispose();
  }

  double get _discount => _appliedVoucher?.discountValue ?? 0;

  Future<void> _applyVoucher(double orderAmount) async {
    final code = _voucherController.text.trim();
    if (code.isEmpty) return;
    try {
      final voucher = await ref
          .read(voucherRepositoryProvider)
          .validateVoucher(code: code, orderAmount: orderAmount);
      setState(() => _appliedVoucher = voucher);
      if (mounted) AppSnackbar.showSuccess(context, 'Áp mã giảm giá thành công.');
    } catch (e) {
      setState(() => _appliedVoucher = null);
      if (mounted) AppSnackbar.showError(context, e.toString());
    }
  }

  Future<void> _placeOrder() async {
    final user = ref.read(currentUserProvider).valueOrNull;
    final items = ref.read(cartItemsProvider).valueOrNull ?? const [];

    if (user == null) return;
    if (_selectedAddress == null) {
      AppSnackbar.showError(context, 'Vui lòng chọn địa chỉ giao hàng.');
      return;
    }
    if (_selectedBranch == null) {
      AppSnackbar.showError(context, 'Vui lòng chọn chi nhánh.');
      return;
    }

    final params = CreateOrderParams(
      userId: user.uid,
      branchId: _selectedBranch!.id,
      items: items,
      shippingAddress: _selectedAddress!.addressDetail,
      phoneNumber: _selectedAddress!.phoneNumber,
      paymentMethod: _paymentMethod,
      voucherId: _appliedVoucher?.id,
      discountAmount: _discount,
    );

    final orderId =
        await ref.read(orderControllerProvider.notifier).createOrder(params);

    if (!mounted) return;
    if (orderId != null) {
      AppSnackbar.showSuccess(context, 'Đặt hàng thành công!');
      context.go(AppRoutes.customerHome);
    } else {
      final error = ref.read(orderControllerProvider).error;
      AppSnackbar.showError(context, error?.toString() ?? 'Đặt hàng thất bại.');
    }
  }

  @override
  Widget build(BuildContext context) {
    final addressesAsync = ref.watch(myAddressesProvider);
    final branchesAsync = ref.watch(branchesProvider);
    final total = ref.watch(cartTotalProvider);
    final isPlacing = ref.watch(orderControllerProvider).isLoading;
    final finalAmount = (total - _discount).clamp(0, double.infinity);

    return Scaffold(
      appBar: AppBar(title: const Text('Thanh toán')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _SectionTitle('Địa chỉ giao hàng'),
          addressesAsync.when(
            loading: () => const LinearProgressIndicator(),
            error: (e, _) => Text('Lỗi: $e'),
            data: (addresses) {
              if (addresses.isEmpty) {
                return ListTile(
                  leading: const Icon(Icons.add_location_alt_outlined),
                  title: const Text('Thêm địa chỉ giao hàng'),
                  onTap: () => context.push(AppRoutes.addresses),
                );
              }
              _selectedAddress ??= addresses.firstWhere(
                (a) => a.isDefault,
                orElse: () => addresses.first,
              );
              return RadioGroup<Address>(
                groupValue: _selectedAddress,
                onChanged: (v) => setState(() => _selectedAddress = v),
                child: Column(
                  children: addresses
                      .map((a) => RadioListTile<Address>(
                            value: a,
                            title: Text(a.receiverName),
                            subtitle:
                                Text('${a.phoneNumber}\n${a.addressDetail}'),
                            isThreeLine: true,
                          ))
                      .toList(),
                ),
              );
            },
          ),
          const Divider(),
          _SectionTitle('Chi nhánh'),
          branchesAsync.when(
            loading: () => const LinearProgressIndicator(),
            error: (e, _) => Text('Lỗi: $e'),
            data: (branches) {
              _selectedBranch ??=
                  branches.isNotEmpty ? branches.first : null;
              return DropdownButtonFormField<Branch>(
                initialValue: _selectedBranch,
                items: branches
                    .map((b) =>
                        DropdownMenuItem(value: b, child: Text(b.name)))
                    .toList(),
                onChanged: (v) => setState(() => _selectedBranch = v),
              );
            },
          ),
          const Divider(),
          _SectionTitle('Mã giảm giá'),
          Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _voucherController,
                  decoration: const InputDecoration(hintText: 'Nhập mã voucher'),
                ),
              ),
              const SizedBox(width: 8),
              OutlinedButton(
                onPressed: () => _applyVoucher(total),
                child: const Text('Áp dụng'),
              ),
            ],
          ),
          const Divider(),
          _SectionTitle('Phương thức thanh toán'),
          RadioGroup<PaymentMethod>(
            groupValue: _paymentMethod,
            onChanged: (v) => setState(() => _paymentMethod = v!),
            child: Column(
              children: PaymentMethod.values
                  .map((m) => RadioListTile<PaymentMethod>(
                        value: m,
                        title: Text(m.displayName),
                      ))
                  .toList(),
            ),
          ),
          const Divider(),
          _SummaryRow(label: 'Tạm tính', value: total),
          if (_discount > 0) _SummaryRow(label: 'Giảm giá', value: -_discount),
          _SummaryRow(label: 'Tổng cộng', value: finalAmount.toDouble(), bold: true),
        ],
      ),
      bottomNavigationBar: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: FilledButton(
            onPressed: isPlacing ? null : _placeOrder,
            child: isPlacing
                ? const SizedBox(
                    height: 20,
                    width: 20,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : Text('Đặt hàng - ${CurrencyUtils.format(finalAmount)}'),
          ),
        ),
      ),
    );
  }
}

class _SectionTitle extends StatelessWidget {
  const _SectionTitle(this.title);

  final String title;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Text(title, style: Theme.of(context).textTheme.titleMedium),
    );
  }
}

class _SummaryRow extends StatelessWidget {
  const _SummaryRow({required this.label, required this.value, this.bold = false});

  final String label;
  final double value;
  final bool bold;

  @override
  Widget build(BuildContext context) {
    final style = bold
        ? Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)
        : Theme.of(context).textTheme.bodyMedium;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: style),
          Text(CurrencyUtils.format(value), style: style),
        ],
      ),
    );
  }
}
