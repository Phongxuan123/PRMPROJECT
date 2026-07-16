// Màn hình phiếu nhập hàng (UC18): tạo phiếu nhập từ nhà cung cấp và cập nhật tồn kho.
// Mỗi dòng nhập gồm sản phẩm + số lượng + giá nhập; tạo xong là Transaction Firestore.
// Tồn kho được cộng ngay và ghi log để theo dõi lịch sử nhập kho.
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/utils/currency_utils.dart';
import '../../../../core/utils/validators.dart';
import '../../../../data/repositories/import_receipt_repository.dart';
import '../../../../models/import_receipt_model.dart';
import '../../../../models/product_model.dart';
import '../../../../providers/auth_provider.dart';
import '../../../../providers/catalog_providers.dart';
import '../../../../providers/product_provider.dart';
import '../../../../providers/repository_providers.dart';
import '../../../../shared/widgets/app_snackbar.dart';

/// Tạo phiếu nhập hàng từ nhà cung cấp (UC18).
class ImportReceiptScreen extends ConsumerStatefulWidget {
  const ImportReceiptScreen({super.key});

  @override
  ConsumerState<ImportReceiptScreen> createState() =>
      _ImportReceiptScreenState();
}

class _ImportReceiptScreenState extends ConsumerState<ImportReceiptScreen> {
  String? _supplierId;
  final List<ImportDetail> _lines = [];
  bool _submitting = false;

  double get _total => _lines.fold(0, (acc, l) => acc + l.subtotal);

  Future<void> _addLine() async {
    final products = ref.read(allProductsProvider).valueOrNull ?? const [];
    if (products.isEmpty) {
      AppSnackbar.showError(context, 'Chưa có sản phẩm để nhập.');
      return;
    }

    Product? selectedProduct = products.first;
    final qtyController = TextEditingController(text: '1');
    final priceController = TextEditingController();
    final formKey = GlobalKey<FormState>();

    final added = await showDialog<bool>(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          title: const Text('Thêm sản phẩm nhập'),
          content: Form(
            key: formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                DropdownButtonFormField<Product>(
                  initialValue: selectedProduct,
                  decoration: const InputDecoration(labelText: 'Sản phẩm'),
                  items: products
                      .map((p) =>
                          DropdownMenuItem(value: p, child: Text(p.name)))
                      .toList(),
                  onChanged: (v) => setState(() => selectedProduct = v),
                ),
                TextFormField(
                  controller: qtyController,
                  decoration: const InputDecoration(labelText: 'Số lượng'),
                  keyboardType: TextInputType.number,
                  validator: (v) =>
                      Validators.positiveInt(v, field: 'Số lượng'),
                ),
                TextFormField(
                  controller: priceController,
                  decoration: const InputDecoration(labelText: 'Giá nhập'),
                  keyboardType: TextInputType.number,
                  validator: (v) =>
                      Validators.positiveNumber(v, field: 'Giá nhập'),
                ),
              ],
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
              child: const Text('Thêm'),
            ),
          ],
        ),
      ),
    );

    if (added == true && selectedProduct != null) {
      setState(() {
        _lines.add(ImportDetail(
          id: '',
          productId: selectedProduct!.id,
          productName: selectedProduct!.name,
          quantity: int.parse(qtyController.text.trim()),
          importPrice: double.parse(priceController.text.trim()),
        ));
      });
    }
    qtyController.dispose();
    priceController.dispose();
  }

  Future<void> _submit() async {
    final user = ref.read(currentUserProvider).valueOrNull;
    final branchId = user?.branchId;

    if (_supplierId == null) {
      AppSnackbar.showError(context, 'Vui lòng chọn nhà cung cấp.');
      return;
    }
    if (branchId == null) {
      AppSnackbar.showError(context, 'Tài khoản chưa được gán chi nhánh.');
      return;
    }
    if (_lines.isEmpty) {
      AppSnackbar.showError(context, 'Vui lòng thêm sản phẩm nhập.');
      return;
    }

    setState(() => _submitting = true);
    try {
      await ref.read(importReceiptRepositoryProvider).createImportReceipt(
            CreateImportParams(
              supplierId: _supplierId!,
              branchId: branchId,
              createdBy: user!.uid,
              details: _lines,
            ),
          );
      if (mounted) {
        AppSnackbar.showSuccess(context, 'Tạo phiếu nhập thành công.');
        Navigator.of(context).pop();
      }
    } catch (e) {
      if (mounted) AppSnackbar.showError(context, e.toString());
    } finally {
      if (mounted) setState(() => _submitting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final suppliersAsync = ref.watch(suppliersProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Tạo phiếu nhập hàng')),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: suppliersAsync.maybeWhen(
              data: (suppliers) => DropdownButtonFormField<String>(
                initialValue: _supplierId,
                decoration: const InputDecoration(labelText: 'Nhà cung cấp'),
                items: suppliers
                    .map((s) =>
                        DropdownMenuItem(value: s.id, child: Text(s.name)))
                    .toList(),
                onChanged: (v) => setState(() => _supplierId = v),
              ),
              orElse: () => const LinearProgressIndicator(),
            ),
          ),
          Expanded(
            child: _lines.isEmpty
                ? const Center(child: Text('Chưa có sản phẩm nhập.'))
                : ListView.separated(
                    itemCount: _lines.length,
                    separatorBuilder: (context, index) =>
                        const Divider(height: 1),
                    itemBuilder: (context, index) {
                      final line = _lines[index];
                      return ListTile(
                        title: Text(line.productName),
                        subtitle: Text(
                            '${line.quantity} x ${CurrencyUtils.format(line.importPrice)}'),
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(CurrencyUtils.format(line.subtotal)),
                            IconButton(
                              icon: const Icon(Icons.delete_outline),
                              onPressed: () =>
                                  setState(() => _lines.removeAt(index)),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _addLine,
        icon: const Icon(Icons.add),
        label: const Text('Thêm SP'),
      ),
      bottomNavigationBar: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: FilledButton(
            onPressed: _submitting ? null : _submit,
            child: _submitting
                ? const SizedBox(
                    height: 20,
                    width: 20,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : Text('Tạo phiếu nhập - ${CurrencyUtils.format(_total)}'),
          ),
        ),
      ),
    );
  }
}
