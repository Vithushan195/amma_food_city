import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:amma_food_city/core/providers/cart_provider.dart';
import 'package:amma_food_city/core/models/models.dart';

void main() {
  late ProviderContainer container;

  setUp(() {
    container = ProviderContainer();
  });

  tearDown(() {
    container.dispose();
  });

  group('CartNotifier', () {
    test('starts empty', () {
      final cart = container.read(cartProvider);
      expect(cart.isEmpty, true);
      expect(cart.totalItems, 0);
      expect(cart.subtotal, 0.0);
    });

    test('addItem adds product to cart', () {
      final product = Product.mockFeatured.first;
      container.read(cartProvider.notifier).addItem(product);

      final cart = container.read(cartProvider);
      expect(cart.totalItems, 1);
      expect(cart.items.containsKey(product.id), true);
    });

    test('addItem increments quantity for existing product', () {
      final product = Product.mockFeatured.first;
      container.read(cartProvider.notifier).addItem(product);
      container.read(cartProvider.notifier).addItem(product);

      final cart = container.read(cartProvider);
      expect(cart.totalItems, 2);
      expect(cart.items[product.id]!.quantity, 2);
    });

    test('addItem with qty parameter', () {
      final product = Product.mockFeatured.first;
      container.read(cartProvider.notifier).addItem(product, qty: 3);

      expect(container.read(cartProvider).totalItems, 3);
    });

    test('updateQuantity changes quantity', () {
      final product = Product.mockFeatured.first;
      container.read(cartProvider.notifier).addItem(product);
      container.read(cartProvider.notifier).updateQuantity(product.id, 5);

      expect(container.read(cartProvider).items[product.id]!.quantity, 5);
    });

    test('updateQuantity to 0 removes item', () {
      final product = Product.mockFeatured.first;
      container.read(cartProvider.notifier).addItem(product);
      container.read(cartProvider.notifier).updateQuantity(product.id, 0);

      expect(container.read(cartProvider).isEmpty, true);
    });

    test('removeItem removes product', () {
      final product = Product.mockFeatured.first;
      container.read(cartProvider.notifier).addItem(product, qty: 3);
      container.read(cartProvider.notifier).removeItem(product.id);

      expect(container.read(cartProvider).isEmpty, true);
    });

    test('restoreItem puts item back', () {
      final product = Product.mockFeatured.first;
      final item = CartItem(product: product, quantity: 2);

      container.read(cartProvider.notifier).restoreItem(item);
      expect(container.read(cartProvider).totalItems, 2);
    });

    test('clear empties cart', () {
      for (final p in Product.mockFeatured.take(3)) {
        container.read(cartProvider.notifier).addItem(p);
      }
      expect(container.read(cartProvider).isEmpty, false);

      container.read(cartProvider.notifier).clear();
      expect(container.read(cartProvider).isEmpty, true);
    });

    test('subtotal calculates correctly', () {
      final p1 = Product.mockFeatured[0]; // price varies
      final p2 = Product.mockFeatured[1];
      container.read(cartProvider.notifier).addItem(p1, qty: 2);
      container.read(cartProvider.notifier).addItem(p2, qty: 1);

      final cart = container.read(cartProvider);
      final expected = (p1.price * 2) + (p2.price * 1);
      expect(cart.subtotal, closeTo(expected, 0.01));
    });

    test('qualifiesForFreeDelivery at £30', () {
      // Add enough items to exceed £30
      final expensive = Product.mockFeatured.firstWhere((p) => p.price > 5);
      container.read(cartProvider.notifier).addItem(expensive, qty: 10);

      expect(container.read(cartProvider).qualifiesForFreeDelivery, true);
      expect(container.read(cartProvider).deliveryFee, 0.0);
    });

    test('delivery fee £2.99 under £30', () {
      final cheap = Product.mockFeatured.firstWhere((p) => p.price < 3);
      container.read(cartProvider.notifier).addItem(cheap);

      expect(container.read(cartProvider).qualifiesForFreeDelivery, false);
      expect(container.read(cartProvider).deliveryFee, 2.99);
    });

    test('cartItemCountProvider reflects total', () {
      container.read(cartProvider.notifier).addItem(Product.mockFeatured[0], qty: 3);
      container.read(cartProvider.notifier).addItem(Product.mockFeatured[1], qty: 2);

      expect(container.read(cartItemCountProvider), 5);
    });

    test('addItems bulk adds for reorder', () {
      final items = [
        CartItem(product: Product.mockFeatured[0], quantity: 2),
        CartItem(product: Product.mockFeatured[1], quantity: 3),
      ];
      container.read(cartProvider.notifier).addItems(items);

      expect(container.read(cartProvider).totalItems, 5);
    });
  });
}
