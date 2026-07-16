// Service tạo dữ liệu mẫu (seed data) cho môi trường debug.
// Chỉ chạy một lần khi collection categories còn trống.
// QUAN TRỌNG: _seedUsers() gọi signOut() — không chạy mỗi lần khởi động để tránh đăng xuất người dùng thật.
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';

import '../../core/constants/firestore_paths.dart';
import '../../core/constants/user_role.dart';

/// Tạo dữ liệu mẫu (seed data) cho môi trường dev (Mục 18 tài liệu).
///
/// [!] Chỉ chạy 1 lần. Gọi [run] khi khởi động app trong chế độ debug,
/// sau khi đã cấu hình Firebase thật (flutterfire configure).
class SeedService {
  SeedService({
    FirebaseFirestore? firestore,
    FirebaseAuth? auth,
  })  : _firestore = firestore ?? FirebaseFirestore.instance,
        _auth = auth ?? FirebaseAuth.instance;

  final FirebaseFirestore _firestore;
  final FirebaseAuth _auth;

  static const String _seedPassword = '123456';

  // Ảnh sản phẩm thực đã upload lên Cloudinary.
  static const Map<String, String> _productImages = {
    'Coca Cola':
        'https://res.cloudinary.com/dkebx9err/image/upload/v1782376861/products/real/products/real/coca_cola.webp',
    'Pepsi':
        'https://res.cloudinary.com/dkebx9err/image/upload/v1782376863/products/real/products/real/pepsi.webp',
    'Bánh Oreo':
        'https://res.cloudinary.com/dkebx9err/image/upload/v1782376865/products/real/products/real/oreo.jpg',
    'Sữa tươi Vinamilk':
        'https://res.cloudinary.com/dkebx9err/image/upload/v1782376867/products/real/products/real/vinamilk.jpg',
    'Mì Hảo Hảo':
        'https://res.cloudinary.com/dkebx9err/image/upload/v1782376869/products/real/products/real/hao_hao.webp',
    'Nước suối Lavie':
        'https://res.cloudinary.com/dkebx9err/image/upload/v1782376873/products/real/products/real/lavie.jpg',
    'Khăn giấy':
        'https://res.cloudinary.com/dkebx9err/image/upload/v1782376874/products/real/products/real/khan_giay.webp',
    'Dầu gội':
        'https://res.cloudinary.com/dkebx9err/image/upload/v1782376877/products/real/products/real/dau_goi.webp',
    'Kem đánh răng':
        'https://res.cloudinary.com/dkebx9err/image/upload/v1782376879/products/real/products/real/kem_danh_rang.jpg',
  };

  /// Chạy seed nếu chưa có dữ liệu. Trả về true nếu đã seed lần này.
  ///
  /// [!] QUAN TRỌNG: [_seedUsers] đăng nhập 4 tài khoản demo rồi gọi signOut().
  /// Vì vậy CHỈ chạy nó ở lần seed đầu tiên. Nếu chạy mỗi lần khởi động, nó sẽ
  /// đăng xuất phiên người dùng thật đang đăng nhập (gây lỗi "giỏ hàng trống" /
  /// bị đá về login khi hot restart trong chế độ debug).
  Future<bool> run() async {
    final categoriesSnap =
        await _firestore.collection(FirestorePaths.categories).limit(1).get();

    if (categoriesSnap.docs.isEmpty) {
      debugPrint('[Seed] Bắt đầu tạo dữ liệu mẫu...');
      final branchIds = await _seedBranches();
      final categoryIds = await _seedCategories();
      final productIds = await _seedProducts(categoryIds);
      await _seedInventory(branchIds, productIds);
      await _seedVouchers();
      await _seedPromotions(productIds);
      // Chỉ tạo tài khoản demo ở lần seed đầu -> signOut() bên trong không
      // ảnh hưởng phiên đăng nhập thật (lúc này chưa có ai đăng nhập).
      await _seedUsers(branchIds.first);
    } else {
      debugPrint('[Seed] Dữ liệu đã có -> bỏ qua seedUsers để KHÔNG đăng xuất '
          'phiên hiện tại.');
    }

    // Cập nhật ảnh/tên sản phẩm: an toàn chạy mọi lần (không đụng tới auth).
    await _updateProducts();
    debugPrint('[Seed] Hoàn tất kiểm tra seed.');
    return true;
  }

  /// Cập nhật tên (tiếng Việt có dấu) và ảnh cho tất cả sản phẩm hiện có.
  /// Luôn ghi đè ảnh để đảm bảo dùng ảnh mới nhất.
  Future<void> _updateProducts() async {
    final snap = await _firestore.collection(FirestorePaths.products).get();
    if (snap.docs.isEmpty) return;

    const nameMap = <String, String>{
      'Banh Oreo': 'Bánh Oreo',
      'Sua tuoi Vinamilk': 'Sữa tươi Vinamilk',
      'Mi Hao Hao': 'Mì Hảo Hảo',
      'Nuoc suoi Lavie': 'Nước suối Lavie',
      'Khan giay': 'Khăn giấy',
      'Dau goi': 'Dầu gội',
      'Kem danh rang': 'Kem đánh răng',
    };

    final batch = _firestore.batch();
    for (final doc in snap.docs) {
      final data = doc.data();
      var name = data['name'] as String? ?? '';
      final updates = <String, dynamic>{};

      // Sửa tên không dấu → có dấu.
      if (nameMap.containsKey(name)) {
        name = nameMap[name]!;
        updates['name'] = name;
      }

      // Luôn ghi đè ảnh bằng ảnh thực từ Cloudinary.
      if (_productImages.containsKey(name)) {
        updates['images'] = [_productImages[name]];
      }

      if (updates.isNotEmpty) {
        batch.update(doc.reference, updates);
      }
    }
    await batch.commit();
    debugPrint('[Seed] Đã cập nhật ảnh thực và tên sản phẩm.');
  }

  Future<List<String>> _seedBranches() async {
    // Seed branches trước với managerId = null để tránh circular reference.
    const branches = [
      {'name': 'Siêu thị Quận 1', 'address': '123 Nguyen Trai, Q1, TP.HCM'},
      {'name': 'Siêu thị Bình Thạnh', 'address': '45 Xo Viet Nghe Tinh, BT'},
      {'name': 'Siêu thị Thủ Đức', 'address': '89 Kha Van Can, TD, TP.HCM'},
    ];
    final ids = <String>[];
    for (final branch in branches) {
      final ref = await _firestore.collection(FirestorePaths.branches).add({
        'name': branch['name'],
        'address': branch['address'],
        'phone': '02838000000',
        'managerId': null,
        'status': true,
      });
      ids.add(ref.id);
    }
    return ids;
  }

  Future<List<String>> _seedCategories() async {
    const names = [
      'Đồ uống',
      'Bánh kẹo',
      'Thực phẩm tươi sống',
      'Gia dụng',
      'Mỹ phẩm',
    ];
    final ids = <String>[];
    for (final name in names) {
      final ref = await _firestore.collection(FirestorePaths.categories).add({
        'name': name,
        'description': null,
        'status': true,
      });
      ids.add(ref.id);
    }
    return ids;
  }

  Future<List<String>> _seedProducts(List<String> categoryIds) async {
    final products = [
      {'name': 'Coca Cola', 'cat': 0, 'price': 12000.0, 'unit': 'chai'},
      {'name': 'Pepsi', 'cat': 0, 'price': 11000.0, 'unit': 'chai'},
      {'name': 'Bánh Oreo', 'cat': 1, 'price': 18000.0, 'unit': 'hộp'},
      {'name': 'Sữa tươi Vinamilk', 'cat': 2, 'price': 35000.0, 'unit': 'hộp'},
      {'name': 'Mì Hảo Hảo', 'cat': 1, 'price': 4000.0, 'unit': 'gói'},
      {'name': 'Nước suối Lavie', 'cat': 0, 'price': 6000.0, 'unit': 'chai'},
      {'name': 'Khăn giấy', 'cat': 3, 'price': 25000.0, 'unit': 'bịch'},
      {'name': 'Dầu gội', 'cat': 4, 'price': 65000.0, 'unit': 'chai'},
      {'name': 'Kem đánh răng', 'cat': 4, 'price': 28000.0, 'unit': 'tuýp'},
    ];
    final ids = <String>[];
    var barcode = 8930000000001;
    for (final p in products) {
      final ref = await _firestore.collection(FirestorePaths.products).add({
        'name': p['name'],
        'categoryId': categoryIds[p['cat'] as int],
        'price': p['price'],
        'unit': p['unit'],
        'barcode': '${barcode++}',
        'description': 'Sản phẩm mẫu ${p['name']}',
        'status': true,
        'images': <String>[],
        'createdAt': FieldValue.serverTimestamp(),
      });
      ids.add(ref.id);
    }
    return ids;
  }

  Future<void> _seedUsers(String defaultBranchId) async {
    final users = [
      ('admin@minimart.com', 'Quản trị viên', UserRole.admin, null),
      (
        'manager@minimart.com',
        'Quản lý chi nhánh',
        UserRole.branchManager,
        defaultBranchId
      ),
      ('staff@minimart.com', 'Nhân viên', UserRole.staff, defaultBranchId),
      ('customer@minimart.com', 'Khách hàng', UserRole.customer, null),
    ];

    for (final (email, name, role, branchId) in users) {
      try {
        UserCredential credential;
        try {
          credential = await _auth.createUserWithEmailAndPassword(
            email: email,
            password: _seedPassword,
          );
        } on FirebaseAuthException catch (e) {
          if (e.code == 'email-already-in-use') {
            // User đã tồn tại trong Auth (tạo thủ công) - sign in để lấy UID.
            credential = await _auth.signInWithEmailAndPassword(
              email: email,
              password: _seedPassword,
            );
          } else {
            rethrow;
          }
        }
        final uid = credential.user!.uid;
        final docRef = _firestore.doc(FirestorePaths.user(uid));
        final docSnap = await docRef.get();
        if (!docSnap.exists) {
          await docRef.set({
            'uid': uid,
            'fullName': name,
            'email': email,
            'role': role.value,
            'phone': '0900000000',
            'avatarUrl': null,
            'branchId': branchId,
            'status': UserStatus.active.value,
            'createdAt': FieldValue.serverTimestamp(),
            'updatedAt': FieldValue.serverTimestamp(),
          });
          debugPrint('[Seed] Đã tạo Firestore doc cho $email');
        } else {
          debugPrint('[Seed] Doc đã tồn tại cho $email, bỏ qua.');
        }
      } on FirebaseAuthException catch (e) {
        debugPrint('[Seed] Lỗi user $email: ${e.code}');
      }
    }
    await _auth.signOut();
  }

  Future<void> _seedInventory(
    List<String> branchIds,
    List<String> productIds,
  ) async {
    final batch = _firestore.batch();
    for (final branchId in branchIds) {
      for (final productId in productIds) {
        final invId = FirestorePaths.inventoryId(branchId, productId);
        final ref = _firestore.doc(FirestorePaths.inventoryDoc(invId));
        batch.set(ref, {
          'inventoryId': invId,
          'branchId': branchId,
          'productId': productId,
          'quantity': 100,
          'lastUpdated': FieldValue.serverTimestamp(),
        });
      }
    }
    await batch.commit();
  }

  Future<void> _seedVouchers() async {
    await _firestore.collection(FirestorePaths.vouchers).add({
      'code': 'WELCOME10',
      'discountValue': 10000.0,
      'minOrderAmount': 50000.0,
      'expiredDate': Timestamp.fromDate(
          DateTime.now().add(const Duration(days: 365))),
      'quantity': 100,
      'status': true,
    });
  }

  Future<void> _seedPromotions(List<String> productIds) async {
    await _firestore.collection(FirestorePaths.promotions).add({
      'name': 'Khuyến mãi khai trương',
      'discountPercent': 15,
      'startDate': Timestamp.fromDate(DateTime.now()),
      'endDate':
          Timestamp.fromDate(DateTime.now().add(const Duration(days: 30))),
      'status': true,
      'productIds': productIds.take(3).toList(),
    });
  }
}
