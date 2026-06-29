import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/utils/validators.dart';
import '../../../../models/category_model.dart';
import '../../../../providers/catalog_providers.dart';
import '../../../../providers/repository_providers.dart';
import '../../../../shared/dialogs/confirm_dialog.dart';
import '../../../../shared/widgets/app_snackbar.dart';
import '../../../../shared/widgets/empty_state_widget.dart';
import '../../../../shared/widgets/error_view.dart';
import '../../../../shared/widgets/loading_widget.dart';

/// Quản lý danh mục sản phẩm (UC25).
class CategoryManagementScreen extends ConsumerWidget {
  const CategoryManagementScreen({super.key});

  Future<void> _edit(
      BuildContext context, WidgetRef ref, Category? existing) async {
    final nameController = TextEditingController(text: existing?.name ?? '');
    final descController =
        TextEditingController(text: existing?.description ?? '');
    var status = existing?.status ?? true;
    final formKey = GlobalKey<FormState>();

    final saved = await showDialog<bool>(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          title: Text(existing == null ? 'Thêm danh mục' : 'Sửa danh mục'),
          content: Form(
            key: formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextFormField(
                  controller: nameController,
                  decoration: const InputDecoration(labelText: 'Tên danh mục'),
                  validator: (v) => Validators.required(v, field: 'Tên'),
                ),
                TextFormField(
                  controller: descController,
                  decoration: const InputDecoration(labelText: 'Mô tả'),
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
      final repo = ref.read(categoryRepositoryProvider);
      final category = Category(
        id: existing?.id ?? '',
        name: nameController.text.trim(),
        description:
            descController.text.trim().isEmpty ? null : descController.text.trim(),
        status: status,
      );
      try {
        if (existing == null) {
          await repo.addCategory(category);
        } else {
          await repo.updateCategory(category);
        }
        if (context.mounted) AppSnackbar.showSuccess(context, 'Đã lưu danh mục.');
      } catch (e) {
        if (context.mounted) AppSnackbar.showError(context, e.toString());
      }
    }
    nameController.dispose();
    descController.dispose();
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final categoriesAsync = ref.watch(categoriesProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Danh mục sản phẩm')),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _edit(context, ref, null),
        child: const Icon(Icons.add),
      ),
      body: categoriesAsync.when(
        loading: () => const LoadingWidget(),
        error: (e, _) => ErrorView(message: e.toString()),
        data: (categories) {
          if (categories.isEmpty) {
            return const EmptyStateWidget(message: 'Chưa có danh mục nào.');
          }
          return ListView.separated(
            itemCount: categories.length,
            separatorBuilder: (context, index) => const Divider(height: 1),
            itemBuilder: (context, index) {
              final category = categories[index];
              return ListTile(
                leading: const Icon(Icons.category_outlined),
                title: Text(category.name),
                subtitle: Text(category.status ? 'Hoạt động' : 'Ngừng'),
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    IconButton(
                      icon: const Icon(Icons.edit_outlined),
                      onPressed: () => _edit(context, ref, category),
                    ),
                    IconButton(
                      icon: const Icon(Icons.delete_outline),
                      onPressed: () async {
                        final confirm = await showConfirmDialog(
                          context,
                          title: 'Xóa danh mục',
                          message: 'Xóa "${category.name}"?',
                          isDestructive: true,
                        );
                        if (!confirm) return;
                        try {
                          await ref
                              .read(categoryRepositoryProvider)
                              .deleteCategory(category.id);
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
