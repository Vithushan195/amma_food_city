import 'package:flutter/material.dart';
import '../core/theme/theme.dart';

/// Cart icon with item count badge.
/// Shows a lime circle badge over the cart icon when count > 0.
///
/// ```dart
/// CartBadge(itemCount: 3, onTap: () {})
/// ```
class CartBadge extends StatelessWidget {
  final int itemCount;
  final VoidCallback? onTap;
  final double iconSize;
  final Color? iconColor;

  const CartBadge({
    super.key,
    required this.itemCount,
    this.onTap,
    this.iconSize = 26,
    this.iconColor,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: SizedBox(
        width: iconSize + 14,
        height: iconSize + 10,
        child: Stack(
          clipBehavior: Clip.none,
          children: [
            Positioned(
              bottom: 0,
              left: 0,
              child: Icon(
                Icons.shopping_bag_outlined,
                size: iconSize,
                color: iconColor ?? AppColors.white,
              ),
            ),
            if (itemCount > 0)
              Positioned(
                top: 0,
                right: 0,
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 5,
                    vertical: 2,
                  ),
                  constraints: const BoxConstraints(minWidth: 18),
                  decoration: BoxDecoration(
                    color: AppColors.accent,
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(
                      color: AppColors.primary,
                      width: 1.5,
                    ),
                  ),
                  child: Text(
                    itemCount > 99 ? '99+' : '$itemCount',
                    style: AppTypography.badge.copyWith(
                      color: AppColors.textOnAccent,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
