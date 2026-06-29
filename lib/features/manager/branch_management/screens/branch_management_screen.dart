import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/utils/validators.dart';
import '../../../../models/branch_model.dart';
import '../../../../providers/catalog_providers.dart';
import '../../../../providers/repository_providers.dart';
import '../../../../shared/widgets/app_snackbar.dart';
import '../../../../shared/widgets/empty_state_widget.dart';
import '../../../../shared/widgets/error_view.dart';
import '../../../../shared/widgets/loading_widget.dart';

/// Quản lý thông tin chi nhánh (UC20).
class BranchManagementScreen extends ConsumerWidget {
  const BranchManagementScreen({super.key});

  Future<void> _edit(
      BuildContext context, WidgetRef ref, Branch? existing) async {
    final nameController = TextEditingController(text: existing?.name ?? '');
    final addressController =
        TextEditingController(text: existing?.address ?? '');
    final phoneController = TextEditingController(text: existing?.phone ?? '');
    final formKey = GlobalKey<FormState>();

    final saved = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(existing == null ? 'Thêm chi nhánh' : 'Sửa chi nhánh'),
        content: Form(
          key: formKey,
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextFormField(
                  controller: nameController,
                  decoration: const InputDecoration(labelText: 'Tên chi nhánh'),
                  validator: (v) => Validators.required(v, field: 'Tên'),
                ),
                TextFormField(
                  controller: addressController,
                  decoration: const InputDecoration(labelText: 'Địa chỉ'),
                  validator: (v) => Validators.required(v, field: 'Địa chỉ'),
                ),
                TextFormField(
                  controller: phoneController,
                  decoration: const InputDecoration(labelText: 'Số điện thoại'),
                  keyboardType: TextInputType.phone,
                  validator: Validators.phone,
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
      final repo = ref.read(branchRepositoryProvider);
      try {
        if (existing == null) {
          await repo.addBranch(Branch(
            id: '',
            name: nameController.text.trim(),
            address: addressController.text.trim(),
            phone: phoneController.text.trim(),
          ));
        } else {
          await repo.updateBranch(existing.copyWith(
            name: nameController.text.trim(),
            address: addressController.text.trim(),
            phone: phoneController.text.trim(),
          ));
        }
        if (context.mounted) {
          AppSnackbar.showSuccess(context, 'Đã lưu chi nhánh.');
        }
      } catch (e) {
        if (context.mounted) AppSnackbar.showError(context, e.toString());
      }
    }
    nameController.dispose();
    addressController.dispose();
    phoneController.dispose();
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final branchesAsync = ref.watch(branchesProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Chi nhánh')),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _edit(context, ref, null),
        child: const Icon(Icons.add),
      ),
      body: branchesAsync.when(
        loading: () => const LoadingWidget(),
        error: (e, _) => ErrorView(message: e.toString()),
        data: (branches) {
          if (branches.isEmpty) {
            return const EmptyStateWidget(message: 'Chưa có chi nhánh nào.');
          }
          return ListView.separated(
            itemCount: branches.length,
            separatorBuilder: (context, index) => const Divider(height: 1),
            itemBuilder: (context, index) {
              final branch = branches[index];
              return ListTile(
                leading: const Icon(Icons.store_outlined),
                title: Text(branch.name),
                subtitle: Text('${branch.phone}\n${branch.address}'),
                isThreeLine: true,
                trailing: IconButton(
                  icon: const Icon(Icons.edit_outlined),
                  onPressed: () => _edit(context, ref, branch),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
