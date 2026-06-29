import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/constants/app_constants.dart';
import '../../../core/routes/app_routes.dart';
import '../../../core/utils/validators.dart';
import '../../../providers/auth_provider.dart';
import '../../../shared/widgets/app_snackbar.dart';
import '../widgets/auth_text_field.dart';

/// Màn hình đăng nhập (UC02).
class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _obscurePassword = true;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    final success = await ref.read(authControllerProvider.notifier).signIn(
          email: _emailController.text,
          password: _passwordController.text,
        );

    if (!mounted) return;
    if (!success) {
      final error = ref.read(authControllerProvider).error;
      AppSnackbar.showError(context, error?.toString() ?? 'Đăng nhập thất bại.');
    }
    // Điều hướng sau đăng nhập do router redirect đảm nhận.
  }

  Future<void> _forgotPassword() async {
    final email = _emailController.text.trim();
    if (Validators.email(email) != null) {
      AppSnackbar.showError(context, 'Nhập email hợp lệ để đặt lại mật khẩu.');
      return;
    }
    final success =
        await ref.read(authControllerProvider.notifier).sendPasswordReset(email);
    if (!mounted) return;
    AppSnackbar.showSuccess(
      context,
      success ? 'Đã gửi email đặt lại mật khẩu.' : 'Gửi email thất bại.',
    );
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authControllerProvider);
    final isLoading = authState.isLoading;

    return Scaffold(
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Form(
              key: _formKey,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.storefront,
                      size: 72, color: Theme.of(context).colorScheme.primary),
                  const SizedBox(height: 12),
                  Text(AppConstants.appName,
                      style: Theme.of(context).textTheme.headlineSmall),
                  const SizedBox(height: 32),
                  AuthTextField(
                    controller: _emailController,
                    label: 'Email',
                    icon: Icons.email_outlined,
                    keyboardType: TextInputType.emailAddress,
                    validator: Validators.email,
                  ),
                  const SizedBox(height: 16),
                  AuthTextField(
                    controller: _passwordController,
                    label: 'Mật khẩu',
                    icon: Icons.lock_outline,
                    obscureText: _obscurePassword,
                    validator: Validators.password,
                    suffixIcon: IconButton(
                      icon: Icon(_obscurePassword
                          ? Icons.visibility_outlined
                          : Icons.visibility_off_outlined),
                      onPressed: () =>
                          setState(() => _obscurePassword = !_obscurePassword),
                    ),
                  ),
                  Align(
                    alignment: Alignment.centerRight,
                    child: TextButton(
                      onPressed: isLoading ? null : _forgotPassword,
                      child: const Text('Quên mật khẩu?'),
                    ),
                  ),
                  const SizedBox(height: 8),
                  FilledButton(
                    onPressed: isLoading ? null : _submit,
                    child: isLoading
                        ? const SizedBox(
                            height: 20,
                            width: 20,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : const Text('Đăng nhập'),
                  ),
                  const SizedBox(height: 12),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Text('Chưa có tài khoản?'),
                      TextButton(
                        onPressed: isLoading
                            ? null
                            : () => context.push(AppRoutes.register),
                        child: const Text('Đăng ký'),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
