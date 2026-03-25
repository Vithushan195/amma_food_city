import 'dart:async';
import 'package:flutter/material.dart';
import '../../../core/theme/theme.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/models/models.dart';
import '../../../widgets/widgets.dart';

/// Weekly Deals section for the home screen.
/// Features a live countdown timer and horizontal scroll of deal cards
/// with prominent discount badges.
class WeeklyDealsSection extends StatefulWidget {
  final List<Product> deals;
  final Map<String, int> cartQuantities;
  final ValueChanged<Product> onProductTap;
  final void Function(String productId, int qty) onQtyChanged;
  final VoidCallback? onViewAll;

  const WeeklyDealsSection({
    super.key,
    required this.deals,
    required this.cartQuantities,
    required this.onProductTap,
    required this.onQtyChanged,
    this.onViewAll,
  });

  @override
  State<WeeklyDealsSection> createState() => _WeeklyDealsSectionState();
}

class _WeeklyDealsSectionState extends State<WeeklyDealsSection> {
  Timer? _timer;
  Duration _remaining = Duration.zero;

  @override
  void initState() {
    super.initState();
    _calculateRemaining();
    _timer = Timer.periodic(const Duration(minutes: 1), (_) {
      _calculateRemaining();
    });
  }

  void _calculateRemaining() {
    // Find the nearest expiry from the deals
    DateTime? nearestExpiry;
    for (final deal in widget.deals) {
      if (deal.dealExpiry != null) {
        if (nearestExpiry == null || deal.dealExpiry!.isBefore(nearestExpiry)) {
          nearestExpiry = deal.dealExpiry;
        }
      }
    }
    if (nearestExpiry != null) {
      final diff = nearestExpiry.difference(DateTime.now());
      setState(() {
        _remaining = diff.isNegative ? Duration.zero : diff;
      });
    }
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (widget.deals.isEmpty) return const SizedBox.shrink();

    return Padding(
      padding: const EdgeInsets.only(top: AppSpacing.lg),
      child: Column(
        children: [
          // ── Header with countdown ──────────────────────────────
          Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.screenHorizontal,
            ),
            child: Row(
              children: [
                // Title
                Expanded(
                  child: Text(
                    'Weekly Deals',
                    style: AppTypography.h2,
                  ),
                ),
                // Countdown timer
                if (_remaining > Duration.zero) ...[
                  const Icon(
                    Icons.timer_outlined,
                    size: 14,
                    color: Color(0xFFE24B4A),
                  ),
                  const SizedBox(width: 4),
                  _CountdownChip(
                    label: '${_remaining.inDays}d',
                  ),
                  const SizedBox(width: 3),
                  _CountdownChip(
                    label: '${_remaining.inHours % 24}h',
                  ),
                  const SizedBox(width: 3),
                  _CountdownChip(
                    label: '${_remaining.inMinutes % 60}m',
                  ),
                ],
                if (widget.onViewAll != null) ...[
                  const SizedBox(width: 10),
                  GestureDetector(
                    onTap: widget.onViewAll,
                    child: Text(
                      'View All',
                      style: AppTypography.bodySmall.copyWith(
                        color: AppColors.primary,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ),

          const SizedBox(height: AppSpacing.md),

          // ── Deal Cards ─────────────────────────────────────────
          SizedBox(
            height: 230,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.screenHorizontal,
              ),
              itemCount: widget.deals.length,
              separatorBuilder: (_, __) => const SizedBox(width: 12),
              itemBuilder: (context, index) {
                final deal = widget.deals[index];
                return _WeeklyDealCard(
                  product: deal,
                  quantity: widget.cartQuantities[deal.id] ?? 0,
                  onTap: () => widget.onProductTap(deal),
                  onQtyChanged: (qty) => widget.onQtyChanged(deal.id, qty),
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
// Countdown Chip
// ═══════════════════════════════════════════════════════════════════
class _CountdownChip extends StatelessWidget {
  final String label;

  const _CountdownChip({required this.label});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
      decoration: BoxDecoration(
        color: const Color(0xFF501313),
        borderRadius: BorderRadius.circular(4),
      ),
      child: Text(
        label,
        style: const TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w700,
          color: Color(0xFFF09595),
          fontFeatures: [FontFeature.tabularFigures()],
        ),
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════════
// Weekly Deal Card
// ═══════════════════════════════════════════════════════════════════
class _WeeklyDealCard extends StatelessWidget {
  final Product product;
  final int quantity;
  final VoidCallback onTap;
  final ValueChanged<int> onQtyChanged;

  const _WeeklyDealCard({
    required this.product,
    required this.quantity,
    required this.onTap,
    required this.onQtyChanged,
  });

  @override
  Widget build(BuildContext context) {
    final discountText = product.dealDiscount != null
        ? '${product.dealDiscount!.round()}% OFF'
        : product.hasDiscount
            ? '${product.discountPercentage.round()}% OFF'
            : 'DEAL';

    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 180,
        decoration: BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.circular(AppSpacing.cardRadius),
          boxShadow: AppColors.cardShadow,
        ),
        clipBehavior: Clip.antiAlias,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Image area with discount badge
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
                // Discount badge
                Positioned(
                  top: 8,
                  left: 8,
                  child: Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: const Color(0xFFE24B4A),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Text(
                      discountText,
                      style: const TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.w700,
                        color: Colors.white,
                      ),
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