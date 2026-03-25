import 'package:flutter/material.dart';
import '../core/theme/theme.dart';
import '../core/models/product.dart';
import 'product_card.dart';

/// Horizontal scrolling product list used for Featured, Popular, Offers sections.
///
/// ```dart
/// HorizontalProductList(
///   products: Product.mockFeatured,
///   cartQuantities: _cartQtys,
///   onQtyChanged: (productId, qty) {},
///   onProductTap: (product) {},
/// )
/// ```
class HorizontalProductList extends StatelessWidget {
  final List<Product> products;
  final Map<String, int> cartQuantities;
  final void Function(String productId, int qty)? onQtyChanged;
  final ValueChanged<Product>? onProductTap;
  final double cardWidth;
  final bool showShimmer;

  const HorizontalProductList({
    super.key,
    required this.products,
    this.cartQuantities = const {},
    this.onQtyChanged,
    this.onProductTap,
    this.cardWidth = AppSpacing.productCardWidth,
    this.showShimmer = false,
  });

  @override
  Widget build(BuildContext context) {
    if (showShimmer) {
      return _buildShimmer();
    }

    return SizedBox(
      height: 260,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.screenHorizontal,
        ),
        itemCount: products.length,
        separatorBuilder: (_, __) => const SizedBox(width: 12),
        itemBuilder: (context, index) {
          final product = products[index];
          return ProductCard(
            productId: product.id,
            name: product.name,
            imageUrl: product.imageUrl,
            weight: product.weight,
            price: product.price,
            originalPrice: product.originalPrice,
            tag: product.tag,
            quantity: cartQuantities[product.id] ?? 0,
            width: cardWidth,
            onQtyChanged: onQtyChanged != null
                ? (qty) => onQtyChanged!(product.id, qty)
                : null,
            onTap: () => onProductTap?.call(product),
          );
        },
      ),
    );
  }

  Widget _buildShimmer() {
    return SizedBox(
      height: 260,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.screenHorizontal,
        ),
        itemCount: 3,
        separatorBuilder: (_, __) => const SizedBox(width: 12),
        itemBuilder: (context, index) {
          return Container(
            width: cardWidth,
            decoration: BoxDecoration(
              color: AppColors.white,
              borderRadius: BorderRadius.circular(AppSpacing.productCardRadius),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Image placeholder
                Container(
                  height: AppSpacing.productImageHeight,
                  decoration: const BoxDecoration(
                    color: AppColors.backgroundGrey,
                    borderRadius: BorderRadius.vertical(
                      top: Radius.circular(AppSpacing.productCardRadius),
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(AppSpacing.cardPadding),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        width: 50,
                        height: 10,
                        decoration: BoxDecoration(
                          color: AppColors.backgroundGrey,
                          borderRadius: BorderRadius.circular(4),
                        ),
                      ),
                      const SizedBox(height: 8),
                      Container(
                        width: 100,
                        height: 14,
                        decoration: BoxDecoration(
                          color: AppColors.backgroundGrey,
                          borderRadius: BorderRadius.circular(4),
                        ),
                      ),
                      const SizedBox(height: 12),
                      Container(
                        width: 60,
                        height: 18,
                        decoration: BoxDecoration(
                          color: AppColors.backgroundGrey,
                          borderRadius: BorderRadius.circular(4),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
