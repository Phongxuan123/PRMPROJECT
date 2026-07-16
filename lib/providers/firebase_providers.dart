// Provider gốc cho các instance Firebase singleton và service wrapper.
// Tách riêng để dễ override bằng fake/mock trong unit test.
// Đây là tầng thấp nhất trong chuỗi: firebase_providers → repository_providers → feature providers.
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../data/firebase/fcm_service.dart';
import '../data/firebase/firebase_auth_service.dart';
import '../data/firebase/firebase_storage_service.dart'; // CloudinaryService

/// Các provider gốc cung cấp instance Firebase và service bao bọc.
///
/// Tách riêng để dễ override trong unit test (ví dụ dùng fake Firestore).

final firestoreProvider = Provider<FirebaseFirestore>((ref) {
  return FirebaseFirestore.instance;
});

final firebaseAuthServiceProvider = Provider<FirebaseAuthService>((ref) {
  return FirebaseAuthService();
});

final firebaseStorageServiceProvider = Provider<FirebaseStorageService>((ref) {
  return FirebaseStorageService();
});

final fcmServiceProvider = Provider<FcmService>((ref) {
  return FcmService();
});
