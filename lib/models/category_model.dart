// Model danh mục sản phẩm, ánh xạ collection categories/{categoryId} trong Firestore.
// Dùng để nhóm sản phẩm và cho phép khách hàng lọc theo danh mục.
import '../core/utils/firestore_utils.dart';

/// Danh mục sản phẩm, ánh xạ categories/{categoryId}.
class Category {
  const Category({
    required this.id,
    required this.name,
    this.description,
    this.status = true,
  });

  final String id;
  final String name;
  final String? description;
  final bool status;

  factory Category.fromMap(Map<String, dynamic> map, String id) {
    return Category(
      id: id,
      name: FirestoreUtils.asString(map['name']),
      description: FirestoreUtils.asStringOrNull(map['description']),
      status: FirestoreUtils.asBool(map['status'], fallback: true),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'description': description,
      'status': status,
    };
  }

  Category copyWith({String? name, String? description, bool? status}) {
    return Category(
      id: id,
      name: name ?? this.name,
      description: description ?? this.description,
      status: status ?? this.status,
    );
  }
}
