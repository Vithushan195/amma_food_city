import 'product.dart';

/// Represents a single item in the shopping cart.
class CartItem {
  final Product product;
  final int quantity;
  final String? selectedWeight;

  const CartItem({
    required this.product,
    this.quantity = 1,
    this.selectedWeight,
  });

  double get subtotal => product.price * quantity;

  CartItem copyWith({
    Product? product,
    int? quantity,
    String? selectedWeight,
  }) {
    return CartItem(
      product: product ?? this.product,
      quantity: quantity ?? this.quantity,
      selectedWeight: selectedWeight ?? this.selectedWeight,
    );
  }

  /// Mock cart for development
  static List<CartItem> get mockCart => [
    CartItem(
      product: Product.mockFeatured[0], // Tilda Basmati Rice
      quantity: 1,
    ),
    CartItem(
      product: Product.mockFeatured[1], // Alphonso Mango
      quantity: 2,
    ),
    CartItem(
      product: Product.mockPopular[0], // Aachi Chicken 65
      quantity: 3,
    ),
    CartItem(
      product: Product.mockPopular[2], // KTC Coconut Oil
      quantity: 1,
    ),
    CartItem(
      product: Product.mockFeatured[2], // MDH Garam Masala
      quantity: 2,
    ),
  ];
}
