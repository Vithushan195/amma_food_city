import 'package:flutter/material.dart';
import '../core/theme/theme.dart';

/// Circular category selector for the home screen grid.
/// Shows an icon/emoji in a pastel circle with a label below.
///
/// ```dart
/// CategoryCircle(
///   label: 'Vegetables',
///   icon: Icons.eco,
///   backgroundColor: AppColors.chipVegetables,
///   onTap: () {},
/// )
/// ```
class CategoryCircle extends StatelessWidget {
  final String label;
  final IconData? icon;
  final String? emoji;
  final Color backgroundColor;
  final VoidCallback? onTap;
  final bool isSelected;

  const CategoryCircle({
    super.key,
    required this.label,
    this.icon,
    this.emoji,
    this.backgroundColor = AppColors.accentSubtle,
    this.onTap,
    this.isSelected = false,
  }) : assert(icon != null || emoji != null, 'Provide either icon or emoji');

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: SizedBox(
        width: AppSpacing.categoryCircleSize + 16,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Circle
            AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              width: AppSpacing.categoryCircleSize,
              height: AppSpacing.categoryCircleSize,
              decoration: BoxDecoration(
                color: backgroundColor,
                shape: BoxShape.circle,
                border: isSelected
                    ? Border.all(color: AppColors.primary, width: 2.5)
                    : null,
                boxShadow: isSelected ? AppColors.cardShadow : null,
              ),
              child: Center(
                child: emoji != null
                    ? Text(
                        emoji!,
                        style: const TextStyle(
                            fontSize: AppSpacing.categoryIconSize),
                      )
                    : Icon(
                        icon,
                        size: AppSpacing.categoryIconSize,
                        color: AppColors.primary,
                      ),
              ),
            ),

            const SizedBox(height: AppSpacing.sm),

            // Label
            Text(
              label,
              style: AppTypography.caption.copyWith(
                color: isSelected
                    ? AppColors.textPrimary
                    : AppColors.textSecondary,
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
              ),
              textAlign: TextAlign.center,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }
}
