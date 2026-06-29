import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/cart_item_model.dart';
import 'auth_provider.dart';
import 'repository_providers.dart';

/// Giỏ hàng của người dùng đang đăng nhập (UC07).
final cartItemsProvider = StreamProvider<List<CartItem>>((ref) {
  // Dùng authStateProvider thay vì currentUserProvider để có UID ngay khi
  // Firebase Auth xong, không cần chờ Firestore user doc load.
  final firebaseUser = ref.watch(authStateProvider).valueOrNull;
  if (firebaseUser == null) return Stream.value(const []);
  return ref.watch(cartRepositoryProvider).watchCartItems(firebaseUser.uid);
});

/// Tổng tiền giỏ hàng.
final cartTotalProvider = Provider<double>((ref) {
  final items = ref.watch(cartItemsProvider).valueOrNull ?? const [];
  return items.fold<double>(0, (sum, item) => sum + item.subtotal);
});

/// Tổng số lượng sản phẩm trong giỏ (để hiện badge).
final cartCountProvider = Provider<int>((ref) {
  final items = ref.watch(cartItemsProvider).valueOrNull ?? const [];
  return items.fold<int>(0, (sum, item) => sum + item.quantity);
});
