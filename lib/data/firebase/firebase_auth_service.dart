// Service bao bọc FirebaseAuth, tập trung các thao tác xác thực.
// Không xử lý logic nghiệp vụ ở đây — chỉ gọi FirebaseAuth API.
// AuthRepository là nơi dịch FirebaseAuthException sang domain exception.
import 'package:firebase_auth/firebase_auth.dart';

/// Bao bọc FirebaseAuth, tập trung các thao tác xác thực.
///
/// Không xử lý logic nghiệp vụ ở đây - chỉ gọi FirebaseAuth và ném lại
/// [FirebaseAuthException] để [AuthRepository] dịch sang domain exception.
class FirebaseAuthService {
  FirebaseAuthService({FirebaseAuth? auth})
      : _auth = auth ?? FirebaseAuth.instance;

  final FirebaseAuth _auth;

  /// Stream phát ra khi trạng thái đăng nhập thay đổi.
  Stream<User?> authStateChanges() => _auth.authStateChanges();

  /// Người dùng đang đăng nhập hiện tại (null nếu chưa đăng nhập).
  User? get currentUser => _auth.currentUser;

  Future<UserCredential> signIn({
    required String email,
    required String password,
  }) {
    return _auth.signInWithEmailAndPassword(email: email, password: password);
  }

  Future<UserCredential> signUp({
    required String email,
    required String password,
  }) {
    return _auth.createUserWithEmailAndPassword(
      email: email,
      password: password,
    );
  }

  Future<void> signOut() => _auth.signOut();

  Future<void> sendPasswordResetEmail(String email) {
    return _auth.sendPasswordResetEmail(email: email);
  }
}
