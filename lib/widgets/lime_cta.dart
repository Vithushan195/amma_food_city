import 'package:flutter/material.dart';
import '../core/theme/theme.dart';

/// Primary lime-green CTA button.
/// Full-width by default. Supports icon prefix and loading state.
///
/// ```dart
/// LimeCta(label: 'Add to Cart', onTap: () {})
/// LimeCta(label: 'Checkout', icon: Icons.shopping_bag, isLoading: true)
/// LimeCta.small(label: 'View All', onTap: () {})
/// ```
class LimeCta extends StatelessWidget {
  final String label;
  final VoidCallback? onTap;
  final IconData? icon;
  final bool isLoading;
  final bool isFullWidth;
  final bool isSmall;
  final bool isPill;

  const LimeCta({
    super.key,
    required this.label,
    this.onTap,
    this.icon,
    this.isLoading = false,
    this.isFullWidth = true,
    this.isSmall = false,
    this.isPill = false,
  });

  const LimeCta.small({
    super.key,
    required this.label,
    this.onTap,
    this.icon,
    this.isLoading = false,
  })  : isFullWidth = false,
        isSmall = true,
        isPill = true;

  @override
  Widget build(BuildContext context) {
    final height = isSmall ? AppSpacing.buttonHeightSmall : AppSpacing.buttonHeight;
    final radius = isPill ? AppSpacing.buttonRadiusPill : AppSpacing.buttonRadius;
    final textStyle = isSmall ? AppTypography.buttonMedium : AppTypography.buttonLarge;

    return SizedBox(
      width: isFullWidth ? double.infinity : null,
      height: height,
      child: ElevatedButton(
        onPressed: isLoading ? null : onTap,
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.accent,
          foregroundColor: AppColors.textOnAccent,
          disabledBackgroundColor: AppColors.accent.withOpacity(0.5),
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(radius),
          ),
          padding: EdgeInsets.symmetric(
            horizontal: isSmall ? AppSpacing.base : AppSpacing.xl,
          ),
          textStyle: textStyle,
        ),
        child: isLoading
            ? SizedBox(
                width: 22,
                height: 22,
                child: CircularProgressIndicator(
                  strokeWidth: 2.5,
                  color: AppColors.textOnAccent.withOpacity(0.7),
                ),
              )
            : Row(
                mainAxisSize: isFullWidth ? MainAxisSize.max : MainAxisSize.min,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  if (icon != null) ...[
                    Icon(icon, size: isSmall ? 18 : 20),
                    const SizedBox(width: AppSpacing.sm),
                  ],
                  Text(label),
                ],
              ),
      ),
    );
  }
}
