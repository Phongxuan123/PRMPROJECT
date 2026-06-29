import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/utils/validators.dart';
import '../../../providers/auth_provider.dart';
import '../../../shared/widgets/app_snackbar.dart';
import '../widgets/auth_text_field.dart';

/// Màn hình đăng ký tài khoản (UC01).
class RegisterScreen extends ConsumerStatefulWidget {
  const RegisterScreen({super.key});

  @override
  ConsumerState<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends ConsumerState<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmController = TextEditingController();

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _passwordController.dispose();
    _confirmController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    final success = await ref.read(authControllerProvider.notifier).register(
          fullName: _nameController.text,
          email: _emailController.text,
          password: _passwordController.text,
          phone: _phoneController.text,
        );

    if (!mounted) return;
    if (success) {
      AppSnackbar.showSuccess(context, 'Đăng ký thành công!');
      context.pop();
    } else {
      final error = ref.read(authControllerProvider).error;
      AppSnackbar.showError(context, error?.toString() ?? 'Đăng ký thất bại.');
    }
  }

  @override
  Widget build(BuildContext context) {
    final isLoading = ref.watch(authControllerProvider).isLoading;

    return Scaffold(
      appBar: AppBar(title: const Text('Đăng ký tài khoản')),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Form(
            key: _formKey,
            child: Column(
              children: [
                AuthTextField(
                  controller: _nameController,
                  label: 'Họ và tên',
                  icon: Icons.person_outline,
                  validator: (v) => Validators.required(v, field: 'Họ tên'),
                ),
                const SizedBox(height: 16),
                AuthTextField(
                  controller: _emailController,
                  label: 'Email',
                  icon: Icons.email_outlined,
                  keyboardType: TextInputType.emailAddress,
                  validator: Validators.email,
                ),
                const SizedBox(height: 16),
                AuthTextField(
                  controller: _phoneController,
                  label: 'Số điện thoại',
                  icon: Icons.phone_outlined,
                  keyboardType: TextInputType.phone,
                  validator: Validators.phone,
                ),
                const SizedBox(height: 16),
                AuthTextField(
                  controller: _passwordController,
                  label: 'Mật khẩu',
                  icon: Icons.lock_outline,
                  obscureText: true,
                  validator: Validators.password,
                ),
                const SizedBox(height: 16),
                AuthTextField(
                  controller: _confirmController,
                  label: 'Xác nhận mật khẩu',
                  icon: Icons.lock_outline,
                  obscureText: true,
                  validator: (v) => Validators.confirmPassword(
                      v, _passwordController.text),
                ),
                const SizedBox(height: 24),
                FilledButton(
                  onPressed: isLoading ? null : _submit,
                  child: isLoading
                      ? const SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Text('Đăng ký'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
