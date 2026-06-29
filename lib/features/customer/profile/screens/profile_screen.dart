import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/routes/app_routes.dart';
import '../../../../core/utils/validators.dart';
import '../../../../providers/auth_provider.dart';
import '../../../../providers/repository_providers.dart';
import '../../../../providers/user_provider.dart';
import '../../../../shared/widgets/app_snackbar.dart';
import '../../../../shared/widgets/loading_widget.dart';

/// Hồ sơ cá nhân khách hàng (UC05).
class ProfileScreen extends ConsumerWidget {
  const ProfileScreen({super.key});

  Future<void> _editProfile(BuildContext context, WidgetRef ref,
      String uid, String currentName, String? currentPhone) async {
    final nameController = TextEditingController(text: currentName);
    final phoneController = TextEditingController(text: currentPhone ?? '');
    final formKey = GlobalKey<FormState>();

    final saved = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Cập nhật hồ sơ'),
        content: Form(
          key: formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextFormField(
                controller: nameController,
                decoration: const InputDecoration(labelText: 'Họ tên'),
                validator: (v) => Validators.required(v, field: 'Họ tên'),
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: phoneController,
                decoration: const InputDecoration(labelText: 'Số điện thoại'),
                keyboardType: TextInputType.phone,
                validator: Validators.phone,
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
    );

    if (saved == true) {
      try {
        await ref.read(userRepositoryProvider).updateProfile(
              uid: uid,
              fullName: nameController.text.trim(),
              phone: phoneController.text.trim(),
            );
        if (context.mounted) {
          AppSnackbar.showSuccess(context, 'Đã cập nhật hồ sơ.');
        }
      } catch (e) {
        if (context.mounted) AppSnackbar.showError(context, e.toString());
      }
    }
    nameController.dispose();
    phoneController.dispose();
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final userAsync = ref.watch(currentUserProvider);
    final unreadCount = ref.watch(unreadNotificationCountProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Tài khoản')),
      body: userAsync.when(
        loading: () => const LoadingWidget(),
        error: (e, _) => Center(child: Text('Lỗi: $e')),
        data: (user) {
          if (user == null) {
            return const Center(child: Text('Chưa đăng nhập.'));
          }
          return ListView(
            children: [
              const SizedBox(height: 16),
              Center(
                child: CircleAvatar(
                  radius: 40,
                  child: Text(
                    user.fullName.isEmpty ? '?' : user.fullName[0],
                    style: const TextStyle(fontSize: 32),
                  ),
                ),
              ),
              const SizedBox(height: 12),
              Center(child: Text(user.fullName,
                  style: Theme.of(context).textTheme.titleLarge)),
              Center(child: Text(user.email)),
              const SizedBox(height: 24),
              ListTile(
                leading: const Icon(Icons.edit_outlined),
                title: const Text('Cập nhật hồ sơ'),
                onTap: () => _editProfile(
                    context, ref, user.uid, user.fullName, user.phone),
              ),
              ListTile(
                leading: const Icon(Icons.location_on_outlined),
                title: const Text('Địa chỉ giao hàng'),
                onTap: () => context.push(AppRoutes.addresses),
              ),
              ListTile(
                leading: Badge(
                  isLabelVisible: unreadCount > 0,
                  label: Text('$unreadCount'),
                  child: const Icon(Icons.notifications_outlined),
                ),
                title: const Text('Thông báo'),
                onTap: () => context.push(AppRoutes.notifications),
              ),
              const Divider(),
              ListTile(
                leading: Icon(Icons.logout,
                    color: Theme.of(context).colorScheme.error),
                title: Text('Đăng xuất',
                    style:
                        TextStyle(color: Theme.of(context).colorScheme.error)),
                onTap: () =>
                    ref.read(authControllerProvider.notifier).signOut(),
              ),
            ],
          );
        },
      ),
    );
  }
}
