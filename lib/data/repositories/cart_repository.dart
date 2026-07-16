// Repository giỏ hàng (UC07): thêm, cập nhật số lượng, xóa và xóa toàn bộ giỏ.
// Mỗi user có đúng 1 cart document; items là subcollection carts/{userId}/items.
// addToCart() cộng dồn nếu sản phẩm đã có trong giỏ, không tạo bản ghi trùng.
import 'package:cloud_firestore/cloud_firestore.dart';

import '../../core/constants/firestore_paths.dart';
import '../../core/errors/app_exceptions.dart';
import '../../models/cart_item_model.dart';
import '../../models/product_model.dart';

/// Quản lý giỏ hàng của khách hàng (UC07).
///
/// Mỗi user có đúng 1 cart document, items là subcollection.
class CartRepository {
  CartRepository({required FirebaseFirestore firestore})
      : _firestore = firestore;

  final FirebaseFirestore _firestore;

  Stream<List<CartItem>> watchCartItems(String userId) {
    return _firestore
        .collection(FirestorePaths.cartItems(userId))
        .snapshots()
        .map((snap) =>
            snap.docs.map((d) => CartItem.fromMap(d.data(), d.id)).toList());
  }

  Future<List<CartItem>> getCartItems(String userId) async {
    final snap =
        await _firestore.collection(FirestorePaths.cartItems(userId)).get();
    return snap.docs.map((d) => CartItem.fromMap(d.data(), d.id)).toList();
  }

  /// Thêm sản phẩm vào giỏ. Nếu đã có thì cộng dồn số lượng.
  Future<void> addToCart({
    required String userId,
    required Product product,
    int quantity = 1,
  }) async {
    try {
      final itemsRef = _firestore.collection(FirestorePaths.cartItems(userId));
      final existing = await itemsRef
          .where('productId', isEqualTo: product.id)
          .limit(1)
          .get();

      if (existing.docs.isNotEmpty) {
        final doc = existing.docs.first;
        final currentQty = (doc.data()['quantity'] as num?)?.toInt() ?? 0;
        await doc.reference.update({'quantity': currentQty + quantity});
        return;
      }

      final item = CartItem(
        id: '',
        productId: product.id,
        productName: product.name,
        productPrice: product.price,
        imageUrl: product.primaryImage ?? '',
        quantity: quantity,
      );
      await itemsRef.add(item.toMap());
    } on FirebaseException catch (e) {
      throw DataException('Thêm vào giỏ hàng thất bại.', code: e.code);
    }
  }

  /// Cập nhật số lượng của một dòng giỏ hàng.
  Future<void> updateQuantity({
    required String userId,
    required String itemId,
    required int quantity,
  }) async {
    if (quantity <= 0) {
      await removeItem(userId: userId, itemId: itemId);
      return;
    }
    try {
      await _firestore
          .collection(FirestorePaths.cartItems(userId))
          .doc(itemId)
          .update({'quantity': quantity});
    } on FirebaseException catch (e) {
      throw DataException('Cập nhật giỏ hàng thất bại.', code: e.code);
    }
  }

  Future<void> removeItem({
    required String userId,
    required String itemId,
  }) async {
    try {
      await _firestore
          .collection(FirestorePaths.cartItems(userId))
          .doc(itemId)
          .delete();
    } on FirebaseException catch (e) {
      throw DataException('Xóa khỏi giỏ hàng thất bại.', code: e.code);
    }
  }

  /// Xóa toàn bộ giỏ hàng (dùng sau khi đặt hàng thành công).
  Future<void> clearCart(String userId) async {
    final snap =
        await _firestore.collection(FirestorePaths.cartItems(userId)).get();
    final batch = _firestore.batch();
    for (final doc in snap.docs) {
      batch.delete(doc.reference);
    }
    await batch.commit();
  }
}
