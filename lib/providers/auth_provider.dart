import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/user_model.dart';
import 'repository_providers.dart';

/// Stream User của Firebase Auth (chỉ cho biết đã đăng nhập hay chưa).
final authStateProvider = StreamProvider<User?>((ref) {
  return ref.watch(authRepositoryProvider).authStateChanges();
});

/// Hồ sơ [AppUser] của người dùng đang đăng nhập (null nếu chưa đăng nhập).
///
/// Lắng nghe authState, sau đó lắng nghe document users/{uid} để tự động
/// cập nhật khi hồ sơ thay đổi (role, status...).
final currentUserProvider = StreamProvider<AppUser?>((ref) {
  final authState = ref.watch(authStateProvider);
  final firebaseUser = authState.valueOrNull;

  if (firebaseUser == null) {
    return Stream.value(null);
  }
  return ref.watch(userRepositoryProvider).watchUser(firebaseUser.uid);
});

/// Controller xử lý đăng nhập / đăng ký / đăng xuất.
///
/// Trạng thái `AsyncValue<void>`: loading khi đang xử lý, error khi thất bại.
class AuthController extends AsyncNotifier<void> {
  @override
  Future<void> build() async {}

  Future<bool> signIn({required String email, required String password}) async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() async {
      await ref
          .read(authRepositoryProvider)
          .signIn(email: email, password: password);
    });
    return !state.hasError;
  }

  Future<bool> register({
    required String fullName,
    required String email,
    required String password,
    String? phone,
  }) async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() async {
      await ref.read(authRepositoryProvider).register(
            fullName: fullName,
            email: email,
            password: password,
            phone: phone,
          );
    });
    return !state.hasError;
  }

  Future<void> signOut() async {
    await ref.read(authRepositoryProvider).signOut();
  }

  Future<bool> sendPasswordReset(String email) async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() async {
      await ref.read(authRepositoryProvider).sendPasswordResetEmail(email);
    });
    return !state.hasError;
  }
}

final authControllerProvider =
    AsyncNotifierProvider<AuthController, void>(AuthController.new);
