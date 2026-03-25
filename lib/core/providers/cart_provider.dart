import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/models.dart';

/// Cart state — immutable map of productId → CartItem.
/// Shared across Home, Product Detail, Categories, Cart, and Checkout screens.
class CartState {
  final Map<String, CartItem> items;

  const CartState({this.items = const {}});

  List<CartItem> get itemList => items.values.toList();
  int get totalItems => items.values.fold(0, (s, i) => s + i.quantity);
  double get subtotal => items.values.fold(0, (s, i) => s + i.subtotal);
  bool get isEmpty => items.isEmpty;
  bool get qualifiesForFreeDelivery => subtotal >= 30.0;
  double get deliveryFee => qualifiesForFreeDelivery ? 0 : 2.99;

  int quantityOf(String productId) => items[productId]?.quantity ?? 0;

  CartState copyWith({Map<String, CartItem>? items}) {
    return CartState(items: items ?? this.items);
  }
}

class CartNotifier extends StateNotifier<CartState> {
  CartNotifier() : super(const CartState());

  /// Add a product to cart or increment quantity.
  void addItem(Product product, {int qty = 1}) {
    final current = state.items[product.id];
    final updated = Map<String, CartItem>.from(state.items);
    updated[product.id] = CartItem(
      product: product,
      quantity: (current?.quantity ?? 0) + qty,
    );
    state = state.copyWith(items: updated);
  }

  /// Set exact quantity for a product.
  void updateQuantity(String productId, int qty) {
    final updated = Map<String, CartItem>.from(state.items);
    if (qty <= 0) {
      updated.remove(productId);
    } else {
      final existing = updated[productId];
      if (existing != null) {
        updated[productId] = existing.copyWith(quantity: qty);
      }
    }
    state = state.copyWith(items: updated);
  }

  /// Remove item entirely.
  void removeItem(String productId) {
    final updated = Map<String, CartItem>.from(state.items);
    updated.remove(productId);
    state = state.copyWith(items: updated);
  }

  /// Restore a previously removed item (for undo).
  void restoreItem(CartItem item) {
    final updated = Map<String, CartItem>.from(state.items);
    updated[item.product.id] = item;
    state = state.copyWith(items: updated);
  }

  /// Clear entire cart (after order placed).
  void clear() {
    state = const CartState();
  }

  /// Bulk add items (for reorder).
  void addItems(List<CartItem> items) {
    final updated = Map<String, CartItem>.from(state.items);
    for (final item in items) {
      final existing = updated[item.product.id];
      updated[item.product.id] = CartItem(
        product: item.product,
        quantity: (existing?.quantity ?? 0) + item.quantity,
      );
    }
    state = state.copyWith(items: updated);
  }
}

/// Global cart provider — use ref.watch(cartProvider) in widgets.
final cartProvider = StateNotifierProvider<CartNotifier, CartState>((ref) {
  return CartNotifier();
});

/// Convenience: cart item count for badges.
final cartItemCountProvider = Provider<int>((ref) {
  return ref.watch(cartProvider).totalItems;
});

/// Convenience: cart quantities map for product cards.
final cartQuantitiesProvider = Provider<Map<String, int>>((ref) {
  final cart = ref.watch(cartProvider);
  return cart.items.map((k, v) => MapEntry(k, v.quantity));
});
