// Model sản phẩm và đánh giá sản phẩm.
// Product ánh xạ products/{productId}, Review là subcollection reviews.
// Ảnh sản phẩm được lưu dưới dạng danh sách URL từ Cloudinary.
import 'package:cloud_firestore/cloud_firestore.dart';

import '../core/utils/firestore_utils.dart';

/// Sản phẩm, ánh xạ products/{productId}.
class Product {
  const Product({
    required this.id,
    required this.name,
    required this.categoryId,
    required this.price,
    required this.unit,
    required this.barcode,
    this.description,
    this.status = true,
    this.images = const [],
    this.createdAt,
  });

  final String id;
  final String name;
  final String categoryId;
  final double price;
  final String unit;
  final String barcode;
  final String? description;
  final bool status;

  /// Danh sách URL ảnh từ Firebase Storage.
  final List<String> images;
  final DateTime? createdAt;

  /// Ảnh chính hiển thị (ảnh đầu tiên, null nếu chưa có ảnh).
  String? get primaryImage => images.isNotEmpty ? images.first : null;

  factory Product.fromMap(Map<String, dynamic> map, String id) {
    return Product(
      id: id,
      name: FirestoreUtils.asString(map['name']),
      categoryId: FirestoreUtils.asString(map['categoryId']),
      price: FirestoreUtils.asDouble(map['price']),
      unit: FirestoreUtils.asString(map['unit']),
      barcode: FirestoreUtils.asString(map['barcode']),
      description: FirestoreUtils.asStringOrNull(map['description']),
      status: FirestoreUtils.asBool(map['status'], fallback: true),
      images: FirestoreUtils.asStringList(map['images']),
      createdAt: FirestoreUtils.asDateTimeOrNull(map['createdAt']),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'categoryId': categoryId,
      'price': price,
      'unit': unit,
      'barcode': barcode,
      'description': description,
      'status': status,
      'images': images,
      'createdAt':
          createdAt == null ? FieldValue.serverTimestamp() : Timestamp.fromDate(createdAt!),
    };
  }

  Product copyWith({
    String? name,
    String? categoryId,
    double? price,
    String? unit,
    String? barcode,
    String? description,
    bool? status,
    List<String>? images,
  }) {
    return Product(
      id: id,
      name: name ?? this.name,
      categoryId: categoryId ?? this.categoryId,
      price: price ?? this.price,
      unit: unit ?? this.unit,
      barcode: barcode ?? this.barcode,
      description: description ?? this.description,
      status: status ?? this.status,
      images: images ?? this.images,
      createdAt: createdAt,
    );
  }
}

/// Đánh giá sản phẩm, ánh xạ products/{productId}/reviews/{reviewId}.
class Review {
  const Review({
    required this.id,
    required this.userId,
    required this.userName,
    required this.rating,
    required this.comment,
    required this.createdAt,
  });

  final String id;
  final String userId;
  final String userName;
  final int rating;
  final String comment;
  final DateTime createdAt;

  factory Review.fromMap(Map<String, dynamic> map, String id) {
    return Review(
      id: id,
      userId: FirestoreUtils.asString(map['userId']),
      userName: FirestoreUtils.asString(map['userName']),
      rating: FirestoreUtils.asInt(map['rating'], fallback: 5).clamp(1, 5),
      comment: FirestoreUtils.asString(map['comment']),
      createdAt: FirestoreUtils.asDateTime(map['createdAt']),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'userId': userId,
      'userName': userName,
      'rating': rating,
      'comment': comment,
      'createdAt': FieldValue.serverTimestamp(),
    };
  }
}
