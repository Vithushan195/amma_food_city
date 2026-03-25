import 'package:flutter/material.dart';
import '../core/theme/theme.dart';
import 'superscript_price.dart';
import 'circular_qty_control.dart';

/// Product card for horizontal/vertical lists.
/// Gromuse-inspired: rounded corners, white card, image top, price + qty bottom.
///
/// ```dart
/// ProductCard(
///   imageUrl: 'https://...',
///   name: 'Basmati Rice',
///   weight: '5 kg',
///   price: 8.49,
///   quantity: 0,
///   onQtyChanged: (qty) {},
///   onTap: () {},
/// )
/// ```
class ProductCard extends StatelessWidget {
  final String? imageUrl;
  final String name;
  final String? weight;
  final double price;
  final double? originalPrice;
  final int quantity;
  final ValueChanged<int>? onQtyChanged;
  final VoidCallback? onTap;
  final String? tag; // e.g. "OFFER", "NEW"
  final double width;
  final String? productId; // for Hero animation

  const ProductCard({
    super.key,
    this.imageUrl,
    required this.name,
    this.weight,
    required this.price,
    this.originalPrice,
    this.quantity = 0,
    this.onQtyChanged,
    this.onTap,
    this.tag,
    this.width = AppSpacing.productCardWidth,
    this.productId,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: width,
        decoration: BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.circular(AppSpacing.productCardRadius),
          boxShadow: AppColors.cardShadow,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── Image Area ───────────────────────────────────────
            Stack(
              children: [
                ClipRRect(
                  borderRadius: const BorderRadius.vertical(
                    top: Radius.circular(AppSpacing.productCardRadius),
                  ),
                  child: Container(
                    width: double.infinity,
                    height: AppSpacing.productImageHeight,
                    color: AppColors.backgroundGrey,
                    child: imageUrl != null
                        ? Image.network(
                            imageUrl!,
                            fit: BoxFit.cover,
                            errorBuilder: (_, __, ___) => _placeholder(),
                          )
                        : _placeholder(),
                  ),
                ),
                // Tag badge (OFFER, NEW, etc.)
                if (tag != null)
                  Positioned(
                    top: 8,
                    left: 8,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.accent,
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        tag!,
                        style: AppTypography.caption.copyWith(
                          fontWeight: FontWeight.w700,
                          color: AppColors.textOnAccent,
                          fontSize: 10,
                        ),
                      ),
                    ),
                  ),
              ],
            ),

            // ── Product Info ─────────────────────────────────────
            Padding(
              padding: const EdgeInsets.all(AppSpacing.cardPadding),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Weight/unit
                  if (weight != null)
                    Padding(
                      padding: const EdgeInsets.only(bottom: 2),
                      child: Text(
                        weight!,
                        style: AppTypography.caption,
                        maxLines: 1,
                      ),
                    ),

                  // Product name
                  Text(
                    name,
                    style: AppTypography.bodyMedium.copyWith(
                      fontWeight: FontWeight.w500,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),

                  const SizedBox(height: AppSpacing.sm),

                  // Price + Qty Control row
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Flexible(
                        child: SuperscriptPrice(
                          price: price,
                          originalPrice: originalPrice,
                          size: PriceSize.small,
                        ),
                      ),
                      if (onQtyChanged != null)
                        CircularQtyControl(
                          quantity: quantity,
                          onChanged: onQtyChanged!,
                          size: 28,
                        ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _placeholder() {
    return const Center(
      child: Icon(
        Icons.image_outlined,
        color: AppColors.textTertiary,
        size: 36,
      ),
    );
  }
}
