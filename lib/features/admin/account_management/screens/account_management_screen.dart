// Màn hình Quản lý Tài khoản & Phân quyền (UC23, UC24).
// Admin xem danh sách toàn bộ người dùng trong hệ thống,
// có thể thay đổi vai trò (role) và kích hoạt/khoá tài khoản từng người.

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/constants/user_role.dart';
import '../../../../models/user_model.dart';
import '../../../../providers/catalog_providers.dart';
import '../../../../providers/repository_providers.dart';
import '../../../../providers/user_provider.dart';
import '../../../../shared/widgets/app_snackbar.dart';
import '../../../../shared/widgets/error_view.dart';
import '../../../../shared/widgets/loading_widget.dart';

/// Quản lý tài khoản và phân quyền người dùng (UC23, UC24).
class AccountManagementScreen extends ConsumerWidget {
  const AccountManagementScreen({super.key});

  // Hàm mở hộp thoại phân quyền cho một người dùng cụ thể.
  // Nhận vào thông tin user hiện tại, hiển thị dropdown chọn vai trò,
  // và nếu vai trò cần chi nhánh thì hiện thêm dropdown chọn chi nhánh.
  Future<void> _editRole(
      BuildContext context, WidgetRef ref, AppUser user) async {
    // Khởi tạo giá trị mặc định từ dữ liệu hiện tại của user.
    var selectedRole = user.role;
    String? selectedBranch = user.branchId;

    // Đọc danh sách chi nhánh từ provider — dùng read vì chỉ cần lấy 1 lần.
    final branches = ref.read(branchesProvider).valueOrNull ?? const [];

    // Mở hộp thoại và chờ kết quả: true = người dùng bấm Lưu, false/null = Hủy.
    final saved = await showDialog<bool>(
      context: context,
      // StatefulBuilder cho phép gọi setState bên trong dialog để cập nhật UI
      // khi người dùng thay đổi lựa chọn vai trò.
      builder: (context) => StatefulBuilder(
        builder: (context, setState) {
          // Xác định xem vai trò được chọn có cần gán chi nhánh không.
          final needsBranch = selectedRole == UserRole.staff ||
              selectedRole == UserRole.branchManager;
          return AlertDialog(
            title: Text('Phân quyền: ${user.fullName}'),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Dropdown chọn vai trò: Admin, Manager, Staff, Customer.
                DropdownButtonFormField<UserRole>(
                  initialValue: selectedRole,
                  decoration: const InputDecoration(labelText: 'Vai trò'),
                  items: UserRole.values
                      .map((r) => DropdownMenuItem(
                          value: r, child: Text(r.displayName)))
                      .toList(),
                  onChanged: (v) => setState(() {
                    selectedRole = v!;
                    // Xoá chi nhánh khi chọn vai trò không cần chi nhánh.
                    if (selectedRole == UserRole.admin ||
                        selectedRole == UserRole.customer) {
                      selectedBranch = null;
                    }
                  }),
                ),
                // Dropdown chọn chi nhánh chỉ hiện ra khi cần thiết.
                if (needsBranch) ...[
                  const SizedBox(height: 12),
                  DropdownButtonFormField<String>(
                    initialValue: selectedBranch,
                    decoration: const InputDecoration(labelText: 'Chi nhánh'),
                    items: branches
                        .map((b) => DropdownMenuItem(
                            value: b.id, child: Text(b.name)))
                        .toList(),
                    onChanged: (v) => setState(() => selectedBranch = v),
                  ),
                ],
              ],
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context, false),
                child: const Text('Hủy'),
              ),
              FilledButton(
                onPressed: () {
                  // Bắt buộc chọn chi nhánh nếu vai trò yêu cầu.
                  if (needsBranch && selectedBranch == null) {
                    AppSnackbar.showError(
                        context, 'Vui lòng chọn chi nhánh cho vai trò này.');
                    return;
                  }
                  Navigator.pop(context, true);
                },
                child: const Text('Lưu'),
              ),
            ],
          );
        },
      ),
    );

    // Chỉ ghi vào Firestore khi người dùng xác nhận bấm Lưu.
    if (saved == true) {
      try {
        await ref.read(userRepositoryProvider).updateRole(
              uid: user.uid,
              role: selectedRole,
              branchId: selectedBranch,
            );
        // Kiểm tra context.mounted trước khi hiển thị thông báo,
        // vì màn hình có thể đã bị đóng trong khi chờ await.
        if (context.mounted) AppSnackbar.showSuccess(context, 'Đã phân quyền.');
      } catch (e) {
        if (context.mounted) AppSnackbar.showError(context, e.toString());
      }
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Lắng nghe danh sách toàn bộ người dùng theo thời gian thực từ Firestore.
    // Mỗi khi có thay đổi (thêm/sửa/xoá user), danh sách tự động cập nhật.
    final usersAsync = ref.watch(allUsersProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Tài khoản & Phân quyền')),
      // Xử lý 3 trạng thái của dữ liệu bất đồng bộ:
      // loading (đang tải), error (lỗi), data (có dữ liệu).
      body: usersAsync.when(
        loading: () => const LoadingWidget(),
        error: (e, _) => ErrorView(message: e.toString()),
        data: (users) {
          if (users.isEmpty) {
            return const Center(child: Text('Chưa có tài khoản nào.'));
          }
          // Danh sách người dùng, mỗi dòng có avatar, thông tin và 2 nút thao tác.
          return ListView.separated(
            itemCount: users.length,
            separatorBuilder: (context, index) => const Divider(height: 1),
            itemBuilder: (context, index) {
              final user = users[index];
              return ListTile(
                // Avatar hiển thị chữ cái đầu của tên người dùng.
                leading: CircleAvatar(
                  child:
                      Text(user.fullName.isEmpty ? '?' : user.fullName[0]),
                ),
                title: Text(user.fullName),
                // Hiển thị email, vai trò và trạng thái hoạt động.
                subtitle: Text('${user.email}\n${user.role.displayName}'
                    ' - ${user.status.displayName}'),
                isThreeLine: true,
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Nút mở hộp thoại thay đổi vai trò và chi nhánh.
                    IconButton(
                      tooltip: 'Phân quyền',
                      icon: const Icon(Icons.admin_panel_settings_outlined),
                      onPressed: () => _editRole(context, ref, user),
                    ),
                    // Switch kích hoạt/khoá tài khoản ngay lập tức.
                    // Ghi vào Firestore mà không cần bước xác nhận thêm.
                    Switch(
                      value: user.status == UserStatus.active,
                      onChanged: (active) async {
                        try {
                          await ref.read(userRepositoryProvider).updateStatus(
                                uid: user.uid,
                                status: active
                                    ? UserStatus.active
                                    : UserStatus.blocked,
                              );
                          if (context.mounted) {
                            AppSnackbar.showSuccess(
                                context, 'Đã cập nhật trạng thái.');
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
