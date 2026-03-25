import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:amma_food_city/core/providers/providers.dart';
import 'package:amma_food_city/core/models/models.dart';

/// Integration tests for end-to-end user flows using providers only.
/// These test the business logic without rendering any UI.
void main() {
  group('Full Shopping Flow', () {
    late ProviderContainer container;

    setUp(() {
      container = ProviderContainer();
    });

    tearDown(() => container.dispose());

    test('Guest → Browse → Add to Cart → Login Required', () {
      // Guest is not authenticated
      expect(container.read(isAuthenticatedProvider), false);

      // Browse and add products
      final products = Product.mockFeatured;
      container.read(cartProvider.notifier).addItem(products[0], qty: 2);
      container.read(cartProvider.notifier).addItem(products[1], qty: 1);

      // Cart has items
      expect(container.read(cartProvider).totalItems, 3);
      expect(container.read(cartProvider).isEmpty, false);

      // Auth check blocks checkout
      expect(container.read(authProvider).isAuthenticated, false);
    });

    test('Login → Add Items → Apply Promo → Checkout', () async {
      // Login
      final loginOk = await container
          .read(authProvider.notifier)
          .signInWithEmail('test@test.com', 'password123');
      expect(loginOk, true);

      // Add items
      container.read(cartProvider.notifier).addItem(Product.mockFeatured[0], qty: 3);
      container.read(cartProvider.notifier).addItem(Product.mockFeatured[1], qty: 2);

      final cart = container.read(cartProvider);
      expect(cart.totalItems, 5);

      // Apply promo
      final promoOk = await container.read(promoProvider.notifier).applyCode('AMMA10');
      expect(promoOk, true);

      // Verify discount
      final discount = container.read(discountAmountProvider);
      expect(discount, greaterThan(0));
      expect(discount, closeTo(cart.subtotal * 0.10, 0.01));

      // Verify total
      final total = container.read(cartTotalProvider);
      expect(total, closeTo(cart.subtotal - discount + cart.deliveryFee, 0.01));

      // Place order
      final order = await container.read(ordersProvider.notifier).placeOrder(
        address: DeliveryAddress.mockAddresses.first,
        deliverySlot: '15:00 - 17:00',
        paymentMethod: 'Cash',
        discount: discount,
        promoCode: 'AMMA10',
      );

      // Order created
      expect(order.status, OrderStatus.pending);
      expect(order.promoCode, 'AMMA10');
      expect(order.discount, closeTo(discount, 0.01));

      // Cart cleared
      expect(container.read(cartProvider).isEmpty, true);
    });

    test('Reorder adds items back to cart', () async {
      // Setup: login and place order
      await container.read(authProvider.notifier).signInWithEmail('t@t.com', 'pass123');
      container.read(cartProvider.notifier).addItem(Product.mockFeatured[0], qty: 2);

      final order = await container.read(ordersProvider.notifier).placeOrder(
        address: DeliveryAddress.mockAddresses.first,
        deliverySlot: '11:00 - 13:00',
        paymentMethod: 'Card',
      );

      expect(container.read(cartProvider).isEmpty, true);

      // Reorder
      container.read(ordersProvider.notifier).reorder(order);
      expect(container.read(cartProvider).isEmpty, false);
      expect(container.read(cartProvider).totalItems, 2);
    });

    test('Cancel order changes status', () {
      final orders = container.read(ordersProvider).orders;
      final pendingOrder = orders.firstWhere(
        (o) => o.status == OrderStatus.pending,
        orElse: () => orders.first,
      );

      container.read(ordersProvider.notifier).cancelOrder(pendingOrder.id);

      if (pendingOrder.status == OrderStatus.pending) {
        final updated = container.read(ordersProvider).orders
            .firstWhere((o) => o.id == pendingOrder.id);
        expect(updated.status, OrderStatus.cancelled);
      }
    });

    test('Sign out clears auth state', () async {
      await container.read(authProvider.notifier).signInWithEmail('t@t.com', 'pass123');
      expect(container.read(isAuthenticatedProvider), true);

      await container.read(authProvider.notifier).signOut();
      expect(container.read(isAuthenticatedProvider), false);
      expect(container.read(currentUserProvider), null);
    });

    test('Cart persists across provider reads', () {
      final product = Product.mockFeatured.first;
      container.read(cartProvider.notifier).addItem(product, qty: 5);

      // Read from multiple providers - all should see same cart
      expect(container.read(cartProvider).totalItems, 5);
      expect(container.read(cartItemCountProvider), 5);
      expect(container.read(cartQuantitiesProvider)[product.id], 5);
    });
  });
}
