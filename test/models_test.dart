import 'package:flutter_test/flutter_test.dart';
import 'package:amma_food_city/core/models/models.dart';

void main() {
  group('Product', () {
    test('mockFeatured is not empty', () {
      expect(Product.mockFeatured.isNotEmpty, true);
    });

    test('mockPopular is not empty', () {
      expect(Product.mockPopular.isNotEmpty, true);
    });

    test('mockOffers have OFFER tag', () {
      for (final p in Product.mockOffers) {
        expect(p.tag, 'OFFER');
      }
    });

    test('products have valid prices', () {
      final all = [
        ...Product.mockFeatured,
        ...Product.mockPopular,
        ...Product.mockOffers
      ];
      for (final p in all) {
        expect(p.price, greaterThan(0));
        if (p.originalPrice != null) {
          expect(p.originalPrice!, greaterThan(p.price));
        }
      }
    });

    test('inStock defaults to true', () {
      const p =
          Product(id: 'test', name: 'Test', price: 1.0, categoryId: 'cat');
      expect(p.inStock, true);
    });
  });

  group('CartItem', () {
    test('subtotal calculates correctly', () {
      const item = CartItem(
        product: Product(id: 't', name: 'T', price: 2.50, categoryId: 'c'),
        quantity: 3,
      );
      expect(item.subtotal, 7.50);
    });

    test('copyWith preserves fields', () {
      const item = CartItem(
        product: Product(id: 't', name: 'T', price: 2.50, categoryId: 'c'),
        quantity: 2,
      );
      final updated = item.copyWith(quantity: 5);
      expect(updated.quantity, 5);
      expect(updated.product.id, 't');
    });
  });

  group('Category', () {
    test('mockCategories has 10 items', () {
      expect(Category.mockCategories.length, 10);
    });

    test('all categories have emoji', () {
      for (final c in Category.mockCategories) {
        expect(c.emoji.isNotEmpty, true);
      }
    });
  });

  group('AppUser', () {
    test('mockUser has valid data', () {
      final u = AppUser.mockUser;
      expect(u.name.isNotEmpty, true);
      expect(u.email.contains('@'), true);
    });

    test('initials from single name', () {
      final u = AppUser(
          uid: '1', name: 'Alice', email: 'a@b.com', createdAt: DateTime.now());
      expect(u.initials, 'A');
    });

    test('initials from full name', () {
      final u = AppUser(
          uid: '1',
          name: 'Bob Smith',
          email: 'b@c.com',
          createdAt: DateTime.now());
      expect(u.initials, 'BS');
    });
  });

  group('AppOrder', () {
    test('mockOrders has items', () {
      expect(AppOrder.mockOrders.isNotEmpty, true);
    });

    test('statusLabel returns correct text', () {
      final order = AppOrder.mockOrders.first;
      expect(order.statusLabel, isNotEmpty);
    });

    test('itemCount sums quantities', () {
      for (final o in AppOrder.mockOrders) {
        final expected = o.items.fold<int>(0, (s, i) => s + i.quantity);
        expect(o.itemCount, expected);
      }
    });
  });

  group('DeliveryAddress', () {
    test('fullAddress combines fields', () {
      final addr = DeliveryAddress.mockAddresses.first;
      expect(addr.fullAddress.contains(addr.line1), true);
      expect(addr.fullAddress.contains(addr.postcode), true);
    });

    test('mockAddresses has default', () {
      expect(DeliveryAddress.mockAddresses.any((a) => a.isDefault), true);
    });
  });
}
