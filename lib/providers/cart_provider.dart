// Provider giỏ hàng: stream realtime items, tổng tiền và badge số lượng.
// Dùng .select() để chỉ rebuild khi UID thay đổi, tránh restart stream khi token refresh.
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/cart_item_model.dart';
import 'auth_provider.dart';
import 'repository_providers.dart';

/// Giỏ hàng của người dùng đang đăng nhập (UC07).
final cartItemsProvider = StreamProvider<List<CartItem>>((ref) {
  // Dùng select để chỉ rebuild khi UID thay đổi (không rebuild khi Firebase
  // Auth re-emit cùng user do token refresh). Tránh stream restart không cần
  // thiết dẫn đến CartScreen hiển thị trống trong thời gian chờ.
  final uid = ref.watch(authStateProvider.select((s) => s.valueOrNull?.uid));
  if (uid == null) return Stream.value(const []);
  return ref.read(cartRepositoryProvider).watchCartItems(uid);
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
