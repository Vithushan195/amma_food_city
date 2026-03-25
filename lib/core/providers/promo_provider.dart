import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'cart_provider.dart';

/// Promo code state — shared between Cart and Checkout screens.
class PromoState {
  final String? code;
  final bool isApplied;
  final bool isLoading;
  final double discountPercent; // 0.10 = 10%
  final String? error;

  const PromoState({
    this.code,
    this.isApplied = false,
    this.isLoading = false,
    this.discountPercent = 0,
    this.error,
  });

  PromoState copyWith({
    String? code,
    bool? isApplied,
    bool? isLoading,
    double? discountPercent,
    String? error,
    bool clearCode = false,
    bool clearError = false,
  }) {
    return PromoState(
      code: clearCode ? null : (code ?? this.code),
      isApplied: isApplied ?? this.isApplied,
      isLoading: isLoading ?? this.isLoading,
      discountPercent: discountPercent ?? this.discountPercent,
      error: clearError ? null : (error ?? this.error),
    );
  }
}

class PromoNotifier extends StateNotifier<PromoState> {
  final Ref _ref;

  PromoNotifier(this._ref) : super(const PromoState());

  /// Validate and apply a promo code.
  /// In production: Cloud Function to verify against Firestore promo collection.
  Future<bool> applyCode(String code) async {
    if (code.trim().isEmpty) return false;

    state = state.copyWith(isLoading: true, clearError: true);

    await Future.delayed(const Duration(milliseconds: 800));

    final upper = code.trim().toUpperCase();

    // Mock validation
    if (upper == 'AMMA10' || upper == 'WELCOME') {
      state = PromoState(
        code: upper,
        isApplied: true,
        discountPercent: 0.10,
      );
      return true;
    } else if (upper == 'AMMA20') {
      state = PromoState(
        code: upper,
        isApplied: true,
        discountPercent: 0.20,
      );
      return true;
    }

    state = state.copyWith(
      isLoading: false,
      error: 'Invalid promo code',
    );
    return false;
  }

  /// Remove applied promo.
  void removePromo() {
    state = const PromoState();
  }
}

final promoProvider =
    StateNotifierProvider<PromoNotifier, PromoState>((ref) {
  return PromoNotifier(ref);
});

/// Computed discount amount based on cart subtotal.
final discountAmountProvider = Provider<double>((ref) {
  final promo = ref.watch(promoProvider);
  if (!promo.isApplied) return 0;
  final subtotal = ref.watch(cartProvider).subtotal;
  return subtotal * promo.discountPercent;
});

/// Computed cart total (subtotal - discount + delivery).
final cartTotalProvider = Provider<double>((ref) {
  final cart = ref.watch(cartProvider);
  final discount = ref.watch(discountAmountProvider);
  return cart.subtotal - discount + cart.deliveryFee;
});
