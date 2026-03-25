import 'package:flutter/material.dart';
import '../../../core/theme/theme.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/models/models.dart';
import '../../../widgets/widgets.dart';

/// New Arrivals section for the home screen.
/// Shows recently added products with "NEW" badge and relative timestamps.
class NewArrivalsSection extends StatelessWidget {
  final List<Product> arrivals;
  final Map<String, int> cartQuantities;
  final ValueChanged<Product> onProductTap;
  final void Function(String productId, int qty) onQtyChanged;
  final VoidCallback? onViewAll;

  const NewArrivalsSection({
    super.key,
    required this.arrivals,
    required this.cartQuantities,
    required this.onProductTap,
    required this.onQtyChanged,
    this.onViewAll,
  });

  @override
  Widget build(BuildContext context) {
    if (arrivals.isEmpty) return const SizedBox.shrink();

    return Padding(
      padding: const EdgeInsets.only(top: AppSpacing.lg),
      child: Column(
        children: [
          // ── Header ─────────────────────────────────────────────
          Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.screenHorizontal,
            ),
            child: Row(
              children: [
                Text('New Arrivals', style: AppTypography.h2),
                const SizedBox(width: 8),
                // "Fresh stock" badge
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(
                    color: AppColors.accent,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Text(
                    'FRESH STOCK',
                    style: TextStyle(
                      fontSize: 9,
                      fontWeight: FontWeight.w700,
                      color: Color(0xFF0B3B2D),
                      letterSpacing: 0.5,
                    ),
                  ),
                ),
                const Spacer(),
                if (onViewAll != null)
                  GestureDetector(
                    onTap: onViewAll,
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          'View All',
                          style: AppTypography.bodySmall.copyWith(
                            color: AppColors.primary,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(width: 2),
                        const Icon(
                          Icons.arrow_forward_ios_rounded,
                          size: 12,
                          color: AppColors.primary,
                        ),
                      ],
                    ),
                  ),
              ],
            ),
          ),

          const SizedBox(height: AppSpacing.md),

          // ── Arrival Cards ──────────────────────────────────────
          SizedBox(
            height: 230,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.screenHorizontal,
              ),
              itemCount: arrivals.length,
              separatorBuilder: (_, __) => const SizedBox(width: 12),
              itemBuilder: (context, index) {
                final product = arrivals[index];
                return _NewArrivalCard(
                  product: product,
                  quantity: cartQuantities[product.id] ?? 0,
                  onTap: () => onProductTap(product),
                  onQtyChanged: (qty) => onQtyChanged(product.id, qty),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════════
// New Arrival Card
// ═══════════════════════════════════════════════════════════════════
class _NewArrivalCard extends StatelessWidget {
  final Product product;
  final int quantity;
  final VoidCallback onTap;
  final ValueChanged<int> onQtyChanged;

  const _NewArrivalCard({
    required this.product,
    required this.quantity,
    required this.onTap,
    required this.onQtyChanged,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 160,
        decoration: BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.circular(AppSpacing.cardRadius),
          boxShadow: AppColors.cardShadow,
        ),
        clipBehavior: Clip.antiAlias,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Image area with NEW badge + "Added Xd ago"
            Stack(
              children: [
                Container(
                  height: 120,
                  width: double.infinity,
                  color: AppColors.backgroundGrey,
                  child: product.imageUrl != null
                      ? Image.network(
                          product.imageUrl!,
                          fit: BoxFit.cover,
                          errorBuilder: (_, __, ___) => const Center(
                            child: Icon(Icons.image_outlined,
                                color: AppColors.textTertiary, size: 32),
                          ),
                        )
                      : const Center(
                          child: Icon(Icons.image_outlined,
                              color: AppColors.textTertiary, size: 32),
                        ),
                ),
                // NEW badge (top-left)
                Positioned(
                  top: 8,
                  left: 8,
                  child: Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: const Color(0xFF0B3B2D),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: const Text(
                      'NEW',
                      style: TextStyle(
                        fontSize: 9,
                        fontWeight: FontWeight.w700,
                        color: Color(0xFFA8E06C),
                        letterSpacing: 0.5,
                      ),
                    ),
                  ),
                ),
                // "Added Xd ago" (top-right)
                Positioned(
                  top: 10,
                  right: 8,
                  child: Text(
                    product.arrivalLabel,
                    style: AppTypography.caption.copyWith(
                      fontSize: 9,
                      color: AppColors.textTertiary,
                    ),
                  ),
                ),
              ],
            ),
            // Product info
            Padding(
              padding: const EdgeInsets.all(10),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (product.weight != null)
                    Text(
                      product.weight!,
                      style: AppTypography.caption.copyWith(fontSize: 10),
                    ),
                  Text(
                    product.name,
                    style: AppTypography.bodyMedium.copyWith(
                      fontWeight: FontWeight.w500,
                      fontSize: 13,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 6),
                  Row(
                    children: [
                      SuperscriptPrice(
                        price: product.price,
                        originalPrice: product.originalPrice,
                        size: PriceSize.small,
                      ),
                      const Spacer(),
                      CircularQtyControl(
                        quantity: quantity,
                        onChanged: onQtyChanged,
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
}
