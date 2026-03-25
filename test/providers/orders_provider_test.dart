import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:amma_food_city/core/providers/orders_provider.dart';
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

  group('OrdersNotifier', () {
    test('starts with mock orders', () {
      final orders = container.read(ordersProvider);
      expect(orders.orders.isNotEmpty, true);
    });

    test('placeOrder creates order and clears cart', () async {
      // Add items to cart
      container
          .read(cartProvider.notifier)
          .addItem(Product.mockFeatured[0], qty: 2);
      container
          .read(cartProvider.notifier)
          .addItem(Product.mockFeatured[1], qty: 1);
      expect(container.read(cartProvider).isEmpty, false);

      final initialCount = container.read(ordersProvider).orders.length;

      final order = await container.read(ordersProvider.notifier).placeOrder(
            address: DeliveryAddress.mockAddresses.first,
            deliverySlot: '15:00 - 17:00',
            paymentMethod: 'Card',
          );

      // Order created
      expect(order.id, startsWith('AMF-'));
      expect(order.status, OrderStatus.pending);
      expect(container.read(ordersProvider).orders.length, initialCount + 1);
      expect(container.read(ordersProvider).orders.first.id, order.id);

      // Cart cleared
      expect(container.read(cartProvider).isEmpty, true);
    });

    test('placeOrder includes discount and promo', () async {
      container.read(cartProvider.notifier).addItem(Product.mockFeatured[0]);

      final order = await container.read(ordersProvider.notifier).placeOrder(
            address: DeliveryAddress.mockAddresses.first,
            deliverySlot: '11:00 - 13:00',
            paymentMethod: 'Cash',
            discount: 2.50,
            promoCode: 'AMMA10',
          );

      expect(order.discount, 2.50);
      expect(order.promoCode, 'AMMA10');
      expect(order.paymentMethod, 'Cash');
    });

    test('cancelOrder changes status', () {
      final orders = container.read(ordersProvider).orders;
      final pending = orders.firstWhere(
        (o) =>
            o.status == OrderStatus.pending ||
            o.status == OrderStatus.confirmed,
        orElse: () => orders.first,
      );

      container.read(ordersProvider.notifier).cancelOrder(pending.id);

      final updated = container
          .read(ordersProvider)
          .orders
          .firstWhere((o) => o.id == pending.id);
      // Only pending/confirmed can be cancelled
      if (pending.status == OrderStatus.pending ||
          pending.status == OrderStatus.confirmed) {
        expect(updated.status, OrderStatus.cancelled);
      }
    });

    test('reorder adds items back to cart', () {
      final order = container.read(ordersProvider).orders.first;
      container.read(ordersProvider.notifier).reorder(order);

      expect(container.read(cartProvider).isEmpty, false);
      expect(container.read(cartProvider).totalItems, order.itemCount);
    });

    test('activeOrders filters correctly', () {
      final state = container.read(ordersProvider);
      for (final o in state.activeOrders) {
        expect(o.status, isNot(OrderStatus.delivered));
        expect(o.status, isNot(OrderStatus.cancelled));
      }
    });

    test('completedOrders filters correctly', () {
      final state = container.read(ordersProvider);
      for (final o in state.completedOrders) {
        expect(
          o.status == OrderStatus.delivered ||
              o.status == OrderStatus.cancelled,
          true,
        );
      }
    });
  });
}
