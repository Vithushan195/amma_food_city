import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:amma_food_city/core/providers/promo_provider.dart';
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

  group('PromoNotifier', () {
    test('starts with no promo applied', () {
      final promo = container.read(promoProvider);
      expect(promo.isApplied, false);
      expect(promo.code, null);
      expect(promo.discountPercent, 0);
    });

    test('AMMA10 applies 10% discount', () async {
      final success = await container.read(promoProvider.notifier).applyCode('AMMA10');

      expect(success, true);
      final promo = container.read(promoProvider);
      expect(promo.isApplied, true);
      expect(promo.code, 'AMMA10');
      expect(promo.discountPercent, 0.10);
    });

    test('WELCOME applies 10% discount', () async {
      final success = await container.read(promoProvider.notifier).applyCode('welcome');

      expect(success, true);
      expect(container.read(promoProvider).code, 'WELCOME');
    });

    test('AMMA20 applies 20% discount', () async {
      final success = await container.read(promoProvider.notifier).applyCode('AMMA20');

      expect(success, true);
      expect(container.read(promoProvider).discountPercent, 0.20);
    });

    test('invalid code fails', () async {
      final success = await container.read(promoProvider.notifier).applyCode('INVALID');

      expect(success, false);
      expect(container.read(promoProvider).isApplied, false);
      expect(container.read(promoProvider).error, isNotNull);
    });

    test('empty code fails', () async {
      final success = await container.read(promoProvider.notifier).applyCode('');
      expect(success, false);
    });

    test('removePromo clears state', () async {
      await container.read(promoProvider.notifier).applyCode('AMMA10');
      expect(container.read(promoProvider).isApplied, true);

      container.read(promoProvider.notifier).removePromo();
      expect(container.read(promoProvider).isApplied, false);
      expect(container.read(promoProvider).code, null);
    });

    test('case insensitive matching', () async {
      final success = await container.read(promoProvider.notifier).applyCode('amma10');
      expect(success, true);
      expect(container.read(promoProvider).code, 'AMMA10');
    });

    test('discountAmountProvider calculates correctly', () async {
      // Add items to cart
      container.read(cartProvider.notifier).addItem(Product.mockFeatured[0], qty: 5);
      await container.read(promoProvider.notifier).applyCode('AMMA10');

      final subtotal = container.read(cartProvider).subtotal;
      final discount = container.read(discountAmountProvider);
      expect(discount, closeTo(subtotal * 0.10, 0.01));
    });

    test('cartTotalProvider includes discount and delivery', () async {
      container.read(cartProvider.notifier).addItem(Product.mockFeatured[0], qty: 2);
      await container.read(promoProvider.notifier).applyCode('AMMA10');

      final cart = container.read(cartProvider);
      final discount = container.read(discountAmountProvider);
      final total = container.read(cartTotalProvider);

      expect(total, closeTo(cart.subtotal - discount + cart.deliveryFee, 0.01));
    });
  });
}
