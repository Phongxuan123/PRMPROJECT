// Unit test co ban cho logic domain thuan (khong phu thuoc Firebase).

import 'package:flutter_test/flutter_test.dart';

import 'package:prm_project/core/constants/order_status.dart';
import 'package:prm_project/core/constants/user_role.dart';
import 'package:prm_project/core/utils/validators.dart';
import 'package:prm_project/models/cart_item_model.dart';

void main() {
  group('Validators', () {
    test('email hop le tra ve null', () {
      expect(Validators.email('user@example.com'), isNull);
    });

    test('email rong tra ve thong bao loi', () {
      expect(Validators.email(''), isNotNull);
    });

    test('mat khau ngan hon 6 ky tu khong hop le', () {
      expect(Validators.password('123'), isNotNull);
      expect(Validators.password('123456'), isNull);
    });

    test('so dien thoai Viet Nam', () {
      expect(Validators.phone('0901234567'), isNull);
      expect(Validators.phone('1234'), isNotNull);
    });
  });

  group('OrderStatus', () {
    test('pending va confirmed cho phep huy', () {
      expect(OrderStatus.pending.isCancellable, isTrue);
      expect(OrderStatus.confirmed.isCancellable, isTrue);
    });

    test('shipping va completed khong cho phep huy', () {
      expect(OrderStatus.shipping.isCancellable, isFalse);
      expect(OrderStatus.completed.isCancellable, isFalse);
    });

    test('trang thai ke tiep dung thu tu', () {
      expect(OrderStatus.pending.next, OrderStatus.confirmed);
      expect(OrderStatus.confirmed.next, OrderStatus.shipping);
      expect(OrderStatus.shipping.next, OrderStatus.completed);
      expect(OrderStatus.completed.next, isNull);
    });
  });

  group('UserRole', () {
    test('staff tro len co quyen quan tri', () {
      expect(UserRole.staff.isStaffOrAbove, isTrue);
      expect(UserRole.branchManager.isStaffOrAbove, isTrue);
      expect(UserRole.admin.isStaffOrAbove, isTrue);
      expect(UserRole.customer.isStaffOrAbove, isFalse);
    });

    test('fromValue mac dinh la customer', () {
      expect(UserRole.fromValue('khong_ton_tai'), UserRole.customer);
      expect(UserRole.fromValue('admin'), UserRole.admin);
    });
  });

  group('CartItem', () {
    test('subtotal = gia x so luong', () {
      const item = CartItem(
        id: '1',
        productId: 'p1',
        productName: 'Test',
        productPrice: 10000,
        imageUrl: '',
        quantity: 3,
      );
      expect(item.subtotal, 30000);
    });
  });
}
