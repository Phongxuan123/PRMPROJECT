// Màn hình Quản lý Danh mục Sản phẩm (UC25).
// Admin có thể xem, thêm mới, chỉnh sửa và xoá các danh mục.
// Danh mục được dùng để phân loại sản phẩm trong toàn hệ thống.

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

  // Hàm dùng chung cho cả thêm mới lẫn chỉnh sửa danh mục.
  // Nếu existing == null → chế độ thêm mới.
  // Nếu existing != null → chế độ chỉnh sửa, điền sẵn dữ liệu vào form.
  Future<void> _edit(
      BuildContext context, WidgetRef ref, Category? existing) async {
    // Khởi tạo controller với dữ liệu hiện có (nếu đang sửa) hoặc rỗng (nếu thêm mới).
    final nameController = TextEditingController(text: existing?.name ?? '');
    final descController =
        TextEditingController(text: existing?.description ?? '');
    var status = existing?.status ?? true;

    // formKey dùng để kích hoạt validate toàn bộ các trường trong Form.
    final formKey = GlobalKey<FormState>();

    // Mở hộp thoại nhập liệu và chờ kết quả bấm Lưu hoặc Hủy.
    final saved = await showDialog<bool>(
      context: context,
      // StatefulBuilder cần thiết để gọi setState cập nhật Switch bên trong dialog.
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          // Tiêu đề thay đổi tuỳ theo chế độ thêm mới hay chỉnh sửa.
          title: Text(existing == null ? 'Thêm danh mục' : 'Sửa danh mục'),
          content: Form(
            key: formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Trường nhập tên danh mục — bắt buộc phải điền.
                TextFormField(
                  controller: nameController,
                  decoration: const InputDecoration(labelText: 'Tên danh mục'),
                  // Validators.required kiểm tra không để trống.
                  validator: (v) => Validators.required(v, field: 'Tên'),
                ),
                // Trường nhập mô tả — không bắt buộc.
                TextFormField(
                  controller: descController,
                  decoration: const InputDecoration(labelText: 'Mô tả'),
                ),
                // Switch bật/tắt trạng thái hoạt động của danh mục.
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
                // Chỉ đóng dialog và trả về true nếu form hợp lệ.
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

    // Thực hiện lưu vào Firestore sau khi người dùng xác nhận.
    if (saved == true) {
      final repo = ref.read(categoryRepositoryProvider);
      final category = Category(
        // Nếu thêm mới thì id để rỗng, Firestore sẽ tự sinh ID.
        id: existing?.id ?? '',
        name: nameController.text.trim(),
        // Nếu mô tả bỏ trống thì lưu null thay vì chuỗi rỗng.
        description:
            descController.text.trim().isEmpty ? null : descController.text.trim(),
        status: status,
      );
      try {
        // Phân biệt thêm mới hay cập nhật dựa vào existing.
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
    // Giải phóng bộ nhớ của controller sau khi không còn dùng đến.
    nameController.dispose();
    descController.dispose();
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Lắng nghe danh sách danh mục theo thời gian thực từ Firestore.
    final categoriesAsync = ref.watch(categoriesProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Danh mục sản phẩm')),
      // Nút thêm danh mục mới, hiển thị ở góc dưới bên phải màn hình.
      floatingActionButton: FloatingActionButton(
        // Gọi _edit với existing = null để vào chế độ thêm mới.
        onPressed: () => _edit(context, ref, null),
        child: const Icon(Icons.add),
      ),
      // Xử lý 3 trạng thái của dữ liệu bất đồng bộ.
      body: categoriesAsync.when(
        loading: () => const LoadingWidget(),
        error: (e, _) => ErrorView(message: e.toString()),
        data: (categories) {
          if (categories.isEmpty) {
            return const EmptyStateWidget(message: 'Chưa có danh mục nào.');
          }
          // Danh sách danh mục, mỗi dòng có icon, tên, trạng thái và 2 nút thao tác.
          return ListView.separated(
            itemCount: categories.length,
            separatorBuilder: (context, index) => const Divider(height: 1),
            itemBuilder: (context, index) {
              final category = categories[index];
              return ListTile(
                leading: const Icon(Icons.category_outlined),
                title: Text(category.name),
                // Hiển thị trạng thái hoạt động hay đã ngừng.
                subtitle: Text(category.status ? 'Hoạt động' : 'Ngừng'),
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Nút mở hộp thoại chỉnh sửa danh mục đã chọn.
                    IconButton(
                      icon: const Icon(Icons.edit_outlined),
                      onPressed: () => _edit(context, ref, category),
                    ),
                    // Nút xoá danh mục — yêu cầu xác nhận trước khi thực hiện.
                    IconButton(
                      icon: const Icon(Icons.delete_outline),
                      onPressed: () async {
                        // Hiển thị hộp thoại xác nhận để tránh xoá nhầm.
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
