import '../core/utils/firestore_utils.dart';

/// Sản phẩm trong giỏ hàng, ánh xạ carts/{userId}/items/{itemId}.
class CartItem {
  const CartItem({
    required this.id,
    required this.productId,
    required this.productName,
    required this.productPrice,
    required this.imageUrl,
    required this.quantity,
  });

  final String id;
  final String productId;
  final String productName;

  /// Giá tại thời điểm thêm vào giỏ.
  final double productPrice;
  final String imageUrl;
  final int quantity;

  /// Thành tiền của dòng giỏ hàng này.
  double get subtotal => productPrice * quantity;

  factory CartItem.fromMap(Map<String, dynamic> map, String id) {
    return CartItem(
      id: id,
      productId: FirestoreUtils.asString(map['productId']),
      productName: FirestoreUtils.asString(map['productName']),
      productPrice: FirestoreUtils.asDouble(map['productPrice']),
      imageUrl: FirestoreUtils.asString(map['imageUrl']),
      quantity: FirestoreUtils.asInt(map['quantity'], fallback: 1),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'productId': productId,
      'productName': productName,
      'productPrice': productPrice,
      'imageUrl': imageUrl,
      'quantity': quantity,
    };
  }

  CartItem copyWith({int? quantity}) {
    return CartItem(
      id: id,
      productId: productId,
      productName: productName,
      productPrice: productPrice,
      imageUrl: imageUrl,
      quantity: quantity ?? this.quantity,
    );
  }
}
