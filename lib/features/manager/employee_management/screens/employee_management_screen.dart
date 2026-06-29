import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/constants/user_role.dart';
import '../../../../providers/auth_provider.dart';
import '../../../../providers/repository_providers.dart';
import '../../../../providers/user_provider.dart';
import '../../../../shared/widgets/app_snackbar.dart';
import '../../../../shared/widgets/empty_state_widget.dart';
import '../../../../shared/widgets/error_view.dart';
import '../../../../shared/widgets/loading_widget.dart';

/// Quản lý nhân viên thuộc chi nhánh (UC19).
///
/// [!] Tạo tài khoản Auth mới cần Admin SDK / Cloud Functions (ngoài phạm vi).
/// Nhân viên đăng ký tài khoản rồi Admin/Manager gán vai trò + chi nhánh.
class EmployeeManagementScreen extends ConsumerWidget {
  const EmployeeManagementScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(currentUserProvider).valueOrNull;
    final branchId = user?.branchId;

    if (branchId == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Nhân viên')),
        body: const EmptyStateWidget(
            message: 'Tài khoản chưa được gán chi nhánh.'),
      );
    }

    final staffAsync = ref.watch(branchStaffProvider(branchId));

    return Scaffold(
      appBar: AppBar(title: const Text('Nhân viên chi nhánh')),
      body: staffAsync.when(
        loading: () => const LoadingWidget(),
        error: (e, _) => ErrorView(message: e.toString()),
        data: (staffList) {
          if (staffList.isEmpty) {
            return const EmptyStateWidget(
              message: 'Chưa có nhân viên nào thuộc chi nhánh.',
            );
          }
          return ListView.separated(
            itemCount: staffList.length,
            separatorBuilder: (context, index) => const Divider(height: 1),
            itemBuilder: (context, index) {
              final staff = staffList[index];
              return ListTile(
                leading: CircleAvatar(
                  child: Text(
                      staff.fullName.isEmpty ? '?' : staff.fullName[0]),
                ),
                title: Text(staff.fullName),
                subtitle: Text('${staff.email}\n${staff.status.displayName}'),
                isThreeLine: true,
                trailing: Switch(
                  value: staff.status == UserStatus.active,
                  onChanged: (active) async {
                    try {
                      await ref.read(userRepositoryProvider).updateStatus(
                            uid: staff.uid,
                            status:
                                active ? UserStatus.active : UserStatus.blocked,
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
              );
            },
          );
        },
      ),
    );
  }
}
