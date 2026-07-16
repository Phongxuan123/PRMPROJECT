// Model chi nhánh siêu thị, ánh xạ collection branches/{branchId} trong Firestore.
// Mỗi chi nhánh có thể gán một BranchManager (managerId) và trạng thái hoạt động.
import '../core/utils/firestore_utils.dart';

/// Chi nhánh siêu thị, ánh xạ branches/{branchId}.
class Branch {
  const Branch({
    required this.id,
    required this.name,
    required this.address,
    required this.phone,
    this.managerId,
    this.status = true,
  });

  final String id;
  final String name;
  final String address;
  final String phone;

  /// uid của BranchManager phụ trách (null nếu chưa gán).
  final String? managerId;
  final bool status;

  factory Branch.fromMap(Map<String, dynamic> map, String id) {
    return Branch(
      id: id,
      name: FirestoreUtils.asString(map['name']),
      address: FirestoreUtils.asString(map['address']),
      phone: FirestoreUtils.asString(map['phone']),
      managerId: FirestoreUtils.asStringOrNull(map['managerId']),
      status: FirestoreUtils.asBool(map['status'], fallback: true),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'address': address,
      'phone': phone,
      'managerId': managerId,
      'status': status,
    };
  }

  Branch copyWith({
    String? name,
    String? address,
    String? phone,
    String? managerId,
    bool? status,
  }) {
    return Branch(
      id: id,
      name: name ?? this.name,
      address: address ?? this.address,
      phone: phone ?? this.phone,
      managerId: managerId ?? this.managerId,
      status: status ?? this.status,
    );
  }
}
