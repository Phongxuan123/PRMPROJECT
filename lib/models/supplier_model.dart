// Model nhà cung cấp hàng hóa, ánh xạ collection suppliers/{supplierId}.
// Được dùng khi tạo phiếu nhập hàng (ImportReceipt).
import '../core/utils/firestore_utils.dart';

/// Nhà cung cấp, ánh xạ suppliers/{supplierId}.
class Supplier {
  const Supplier({
    required this.id,
    required this.name,
    required this.phone,
    required this.address,
    required this.email,
  });

  final String id;
  final String name;
  final String phone;
  final String address;
  final String email;

  factory Supplier.fromMap(Map<String, dynamic> map, String id) {
    return Supplier(
      id: id,
      name: FirestoreUtils.asString(map['name']),
      phone: FirestoreUtils.asString(map['phone']),
      address: FirestoreUtils.asString(map['address']),
      email: FirestoreUtils.asString(map['email']),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'phone': phone,
      'address': address,
      'email': email,
    };
  }

  Supplier copyWith({
    String? name,
    String? phone,
    String? address,
    String? email,
  }) {
    return Supplier(
      id: id,
      name: name ?? this.name,
      phone: phone ?? this.phone,
      address: address ?? this.address,
      email: email ?? this.email,
    );
  }
}
