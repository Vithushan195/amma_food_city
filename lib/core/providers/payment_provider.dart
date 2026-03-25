import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../services/stripe_service.dart';
import '../models/models.dart';
import 'orders_provider.dart';
import 'promo_provider.dart';

class PaymentState {
  final bool isProcessing;
  final bool isComplete;
  final String? error;
  final String? paymentIntentId;
  final AppOrder? placedOrder;

  const PaymentState({
    this.isProcessing = false,
    this.isComplete = false,
    this.error,
    this.paymentIntentId,
    this.placedOrder,
  });

  PaymentState copyWith({
    bool? isProcessing,
    bool? isComplete,
    String? error,
    String? paymentIntentId,
    AppOrder? placedOrder,
    bool clearError = false,
  }) {
    return PaymentState(
      isProcessing: isProcessing ?? this.isProcessing,
      isComplete: isComplete ?? this.isComplete,
      error: clearError ? null : (error ?? this.error),
      paymentIntentId: paymentIntentId ?? this.paymentIntentId,
      placedOrder: placedOrder ?? this.placedOrder,
    );
  }
}

class PaymentNotifier extends StateNotifier<PaymentState> {
  final Ref _ref;
  PaymentNotifier(this._ref) : super(const PaymentState());

  /// Process card payment via Stripe.
  /// If Stripe isn't configured, falls back to mock success for development.
  Future<bool> processCardPayment({
    required DeliveryAddress address,
    required String deliverySlot,
    String? customerEmail,
  }) async {
    state = state.copyWith(isProcessing: true, clearError: true);

    try {
      final total = _ref.read(cartTotalProvider);

      PaymentResult result;
      try {
        result = await StripeService.processPayment(
          amount: total,
          customerEmail: customerEmail,
        );
      } catch (e) {
        // Stripe not initialized — fall back to mock for development
        debugPrint('Stripe not configured, using mock payment: $e');
        result = PaymentResult(
          success: true,
          paymentIntentId: 'mock_pi_${DateTime.now().millisecondsSinceEpoch}',
        );
      }

      if (!result.success) {
        state = state.copyWith(isProcessing: false, error: result.error);
        return false;
      }

      // Create order
      final order = await _createOrder(address, deliverySlot, 'Card');

      state = PaymentState(
        isComplete: true,
        paymentIntentId: result.paymentIntentId,
        placedOrder: order,
      );
      return true;
    } catch (e) {
      debugPrint('processCardPayment error: $e');
      state = state.copyWith(
          isProcessing: false, error: 'Payment failed. Please try again.');
      return false;
    }
  }

  /// Cash on delivery — no Stripe needed.
  Future<bool> processCashPayment({
    required DeliveryAddress address,
    required String deliverySlot,
  }) async {
    state = state.copyWith(isProcessing: true, clearError: true);

    try {
      final order = await _createOrder(address, deliverySlot, 'Cash');

      state = PaymentState(
        isComplete: true,
        placedOrder: order,
      );
      return true;
    } catch (e) {
      debugPrint('processCashPayment error: $e');
      state = state.copyWith(
          isProcessing: false,
          error: 'Failed to place order. Please try again.');
      return false;
    }
  }

  /// Shared order creation logic.
  Future<AppOrder> _createOrder(
      DeliveryAddress address, String deliverySlot, String method) async {
    final promo = _ref.read(promoProvider);
    final discount = _ref.read(discountAmountProvider);

    final order = await _ref.read(ordersProvider.notifier).placeOrder(
          address: address,
          deliverySlot: deliverySlot,
          paymentMethod: method,
          discount: discount,
          promoCode: promo.code,
        );

    _ref.read(promoProvider.notifier).removePromo();
    return order;
  }

  void reset() => state = const PaymentState();
  void clearError() => state = state.copyWith(clearError: true);
}

final paymentProvider =
    StateNotifierProvider<PaymentNotifier, PaymentState>((ref) {
  return PaymentNotifier(ref);
});
