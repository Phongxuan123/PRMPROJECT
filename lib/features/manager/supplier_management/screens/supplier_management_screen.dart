// Màn hình quản lý nhà cung cấp (UC21): CRUD danh sách nhà cung cấp.
// Nhà cung cấp được chọn khi tạo phiếu nhập hàng để ghi nguồn gốc hàng hóa.
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/utils/validators.dart';
import '../../../../models/supplier_model.dart';
import '../../../../providers/catalog_providers.dart';
import '../../../../providers/repository_providers.dart';
import '../../../../shared/dialogs/confirm_dialog.dart';
import '../../../../shared/widgets/app_snackbar.dart';
import '../../../../shared/widgets/empty_state_widget.dart';
import '../../../../shared/widgets/error_view.dart';
import '../../../../shared/widgets/loading_widget.dart';

/// Quản lý nhà cung cấp (UC21).
class SupplierManagementScreen extends ConsumerWidget {
  const SupplierManagementScreen({super.key});

  Future<void> _edit(
      BuildContext context, WidgetRef ref, Supplier? existing) async {
    final nameController = TextEditingController(text: existing?.name ?? '');
    final phoneController = TextEditingController(text: existing?.phone ?? '');
    final addressController =
        TextEditingController(text: existing?.address ?? '');
    final emailController = TextEditingController(text: existing?.email ?? '');
    final formKey = GlobalKey<FormState>();

    final saved = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(existing == null ? 'Thêm nhà cung cấp' : 'Sửa nhà cung cấp'),
        content: Form(
          key: formKey,
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextFormField(
                  controller: nameController,
                  decoration: const InputDecoration(labelText: 'Tên'),
                  validator: (v) => Validators.required(v, field: 'Tên'),
                ),
                TextFormField(
                  controller: phoneController,
                  decoration: const InputDecoration(labelText: 'Số điện thoại'),
                  keyboardType: TextInputType.phone,
                  validator: Validators.phone,
                ),
                TextFormField(
                  controller: addressController,
                  decoration: const InputDecoration(labelText: 'Địa chỉ'),
                  validator: (v) => Validators.required(v, field: 'Địa chỉ'),
                ),
                TextFormField(
                  controller: emailController,
                  decoration: const InputDecoration(labelText: 'Email'),
                  keyboardType: TextInputType.emailAddress,
                  validator: Validators.email,
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
    );

    if (saved == true) {
      final repo = ref.read(supplierRepositoryProvider);
      final supplier = Supplier(
        id: existing?.id ?? '',
        name: nameController.text.trim(),
        phone: phoneController.text.trim(),
        address: addressController.text.trim(),
        email: emailController.text.trim(),
      );
      try {
        if (existing == null) {
          await repo.addSupplier(supplier);
        } else {
          await repo.updateSupplier(supplier);
        }
        if (context.mounted) {
          AppSnackbar.showSuccess(context, 'Đã lưu nhà cung cấp.');
        }
      } catch (e) {
        if (context.mounted) AppSnackbar.showError(context, e.toString());
      }
    }
    nameController.dispose();
    phoneController.dispose();
    addressController.dispose();
    emailController.dispose();
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final suppliersAsync = ref.watch(suppliersProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Nhà cung cấp')),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _edit(context, ref, null),
        child: const Icon(Icons.add),
      ),
      body: suppliersAsync.when(
        loading: () => const LoadingWidget(),
        error: (e, _) => ErrorView(message: e.toString()),
        data: (suppliers) {
          if (suppliers.isEmpty) {
            return const EmptyStateWidget(message: 'Chưa có nhà cung cấp.');
          }
          return ListView.separated(
            itemCount: suppliers.length,
            separatorBuilder: (context, index) => const Divider(height: 1),
            itemBuilder: (context, index) {
              final supplier = suppliers[index];
              return ListTile(
                leading: const Icon(Icons.local_shipping_outlined),
                title: Text(supplier.name),
                subtitle: Text('${supplier.phone}\n${supplier.address}'),
                isThreeLine: true,
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    IconButton(
                      icon: const Icon(Icons.edit_outlined),
                      onPressed: () => _edit(context, ref, supplier),
                    ),
                    IconButton(
                      icon: const Icon(Icons.delete_outline),
                      onPressed: () async {
                        final confirm = await showConfirmDialog(
                          context,
                          title: 'Xóa nhà cung cấp',
                          message: 'Xóa "${supplier.name}"?',
                          isDestructive: true,
                        );
                        if (!confirm) return;
                        try {
                          await ref
                              .read(supplierRepositoryProvider)
                              .deleteSupplier(supplier.id);
                          if (context.mounted) {
                            AppSnackbar.showSuccess(context, 'Đã xóa.');
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
