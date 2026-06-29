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

  Future<void> _editRole(
      BuildContext context, WidgetRef ref, AppUser user) async {
    var selectedRole = user.role;
    String? selectedBranch = user.branchId;
    final branches = ref.read(branchesProvider).valueOrNull ?? const [];

    final saved = await showDialog<bool>(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) {
          final needsBranch = selectedRole == UserRole.staff ||
              selectedRole == UserRole.branchManager;
          return AlertDialog(
            title: Text('Phân quyền: ${user.fullName}'),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                DropdownButtonFormField<UserRole>(
                  initialValue: selectedRole,
                  decoration: const InputDecoration(labelText: 'Vai trò'),
                  items: UserRole.values
                      .map((r) => DropdownMenuItem(
                          value: r, child: Text(r.displayName)))
                      .toList(),
                  onChanged: (v) => setState(() {
                    selectedRole = v!;
                    if (selectedRole == UserRole.admin ||
                        selectedRole == UserRole.customer) {
                      selectedBranch = null;
                    }
                  }),
                ),
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

    if (saved == true) {
      try {
        await ref.read(userRepositoryProvider).updateRole(
              uid: user.uid,
              role: selectedRole,
              branchId: selectedBranch,
            );
        if (context.mounted) AppSnackbar.showSuccess(context, 'Đã phân quyền.');
      } catch (e) {
        if (context.mounted) AppSnackbar.showError(context, e.toString());
      }
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final usersAsync = ref.watch(allUsersProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Tài khoản & Phân quyền')),
      body: usersAsync.when(
        loading: () => const LoadingWidget(),
        error: (e, _) => ErrorView(message: e.toString()),
        data: (users) {
          if (users.isEmpty) {
            return const Center(child: Text('Chưa có tài khoản nào.'));
          }
          return ListView.separated(
            itemCount: users.length,
            separatorBuilder: (context, index) => const Divider(height: 1),
            itemBuilder: (context, index) {
              final user = users[index];
              return ListTile(
                leading: CircleAvatar(
                  child:
                      Text(user.fullName.isEmpty ? '?' : user.fullName[0]),
                ),
                title: Text(user.fullName),
                subtitle: Text('${user.email}\n${user.role.displayName}'
                    ' - ${user.status.displayName}'),
                isThreeLine: true,
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    IconButton(
                      tooltip: 'Phân quyền',
                      icon: const Icon(Icons.admin_panel_settings_outlined),
                      onPressed: () => _editRole(context, ref, user),
                    ),
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
