import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../../core/constants/firestore_paths.dart';
import '../../core/constants/user_role.dart';
import '../../core/errors/app_exceptions.dart';
import '../../models/user_model.dart';
import '../firebase/firebase_auth_service.dart';

/// Quản lý luồng xác thực và hồ sơ người dùng.
///
/// Kết hợp Firebase Auth (xác thực) và Firestore (hồ sơ / role).
class AuthRepository {
  AuthRepository({
    required FirebaseAuthService authService,
    required FirebaseFirestore firestore,
  })  : _authService = authService,
        _firestore = firestore;

  final FirebaseAuthService _authService;
  final FirebaseFirestore _firestore;

  /// Stream phát ra User của Firebase Auth khi trạng thái đăng nhập thay đổi.
  Stream<User?> authStateChanges() => _authService.authStateChanges();

  String? get currentUid => _authService.currentUser?.uid;

  /// Đăng nhập và trả về hồ sơ [AppUser] từ Firestore.
  ///
  /// Throws [AuthException] nếu đăng nhập thất bại hoặc tài khoản bị khóa.
  Future<AppUser> signIn({
    required String email,
    required String password,
  }) async {
    try {
      final credential = await _authService.signIn(
        email: email.trim(),
        password: password,
      );
      final uid = credential.user!.uid;
      final profile = await fetchUserProfile(uid);

      if (profile == null) {
        throw const AuthException('Không tìm thấy hồ sơ người dùng.');
      }
      if (profile.status == UserStatus.blocked) {
        await _authService.signOut();
        throw const AuthException('Tài khoản đã bị khóa.');
      }
      return profile;
    } on FirebaseAuthException catch (e) {
      throw AuthException(_mapAuthError(e.code), code: e.code);
    }
  }

  /// Đăng ký tài khoản mới (mặc định role là customer) và tạo hồ sơ Firestore.
  Future<AppUser> register({
    required String fullName,
    required String email,
    required String password,
    String? phone,
  }) async {
    try {
      final credential = await _authService.signUp(
        email: email.trim(),
        password: password,
      );
      final uid = credential.user!.uid;

      final user = AppUser(
        uid: uid,
        fullName: fullName.trim(),
        email: email.trim(),
        role: UserRole.customer,
        phone: phone?.trim(),
        status: UserStatus.active,
      );

      try {
        await _firestore.doc(FirestorePaths.user(uid)).set(user.toMap());
      } on FirebaseException catch (e) {
        // Ghi hồ sơ thất bại -> xóa luôn Auth user để không để lại tài khoản
        // "mồ côi" (có Auth nhưng không có hồ sơ Firestore).
        await credential.user?.delete();
        throw DataException('Tạo hồ sơ người dùng thất bại.', code: e.code);
      }
      return user;
    } on FirebaseAuthException catch (e) {
      throw AuthException(_mapAuthError(e.code), code: e.code);
    }
  }

  /// Lấy hồ sơ người dùng từ Firestore (null nếu chưa có document).
  Future<AppUser?> fetchUserProfile(String uid) async {
    try {
      final doc = await _firestore.doc(FirestorePaths.user(uid)).get();
      if (!doc.exists || doc.data() == null) return null;
      return AppUser.fromMap(doc.data()!, doc.id);
    } on FirebaseException catch (e) {
      throw DataException('Không thể đọc hồ sơ người dùng.', code: e.code);
    }
  }

  Future<void> signOut() => _authService.signOut();

  /// Gửi email đặt lại mật khẩu (UC "Quên mật khẩu" - xử lý bởi Firebase Auth).
  Future<void> sendPasswordResetEmail(String email) async {
    try {
      await _authService.sendPasswordResetEmail(email.trim());
    } on FirebaseAuthException catch (e) {
      throw AuthException(_mapAuthError(e.code), code: e.code);
    }
  }

  /// Dịch mã lỗi Firebase Auth sang thông báo tiếng Việt.
  String _mapAuthError(String code) {
    switch (code) {
      case 'invalid-email':
        return 'Email không hợp lệ.';
      case 'user-disabled':
        return 'Tài khoản đã bị vô hiệu hóa.';
      case 'user-not-found':
      case 'wrong-password':
      case 'invalid-credential':
        return 'Email hoặc mật khẩu không đúng.';
      case 'email-already-in-use':
        return 'Email đã được sử dụng.';
      case 'weak-password':
        return 'Mật khẩu quá yếu.';
      case 'too-many-requests':
        return 'Bạn đã thử quá nhiều lần, vui lòng thử lại sau.';
      default:
        return 'Đã có lỗi xác thực, vui lòng thử lại.';
    }
  }
}
