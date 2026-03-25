import 'package:flutter/material.dart';
import '../core/theme/theme.dart';

/// Circular quantity selector (Gromuse-style).
/// Displays – [qty] + with circular lime-accented buttons.
///
/// When qty is 0, shows a single "+" add button.
/// When qty > 0, expands to show "– qty +".
///
/// ```dart
/// CircularQtyControl(
///   quantity: 2,
///   onChanged: (newQty) => setState(() => qty = newQty),
/// )
/// ```
class CircularQtyControl extends StatelessWidget {
  final int quantity;
  final ValueChanged<int> onChanged;
  final double size;
  final int maxQty;

  const CircularQtyControl({
    super.key,
    required this.quantity,
    required this.onChanged,
    this.size = AppSpacing.qtyButtonSize,
    this.maxQty = 99,
  });

  @override
  Widget build(BuildContext context) {
    // Collapsed state: just an "Add" circle button
    if (quantity <= 0) {
      return _CircleButton(
        icon: Icons.add_rounded,
        size: size,
        fillColor: AppColors.accent,
        iconColor: AppColors.textOnAccent,
        onTap: () => onChanged(1),
      );
    }

    // Expanded state: – [qty] +
    return Container(
      decoration: BoxDecoration(
        color: AppColors.accentSubtle,
        borderRadius: BorderRadius.circular(size),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 2),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          _CircleButton(
            icon: quantity == 1
                ? Icons.delete_outline_rounded
                : Icons.remove_rounded,
            size: size - 4,
            fillColor: AppColors.white,
            iconColor: quantity == 1 ? AppColors.error : AppColors.primary,
            onTap: () => onChanged(quantity - 1),
          ),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: size * 0.35),
            child: Text(
              '$quantity',
              style: AppTypography.buttonMedium.copyWith(
                fontSize: AppSpacing.qtyFontSize,
                color: AppColors.primary,
              ),
            ),
          ),
          _CircleButton(
            icon: Icons.add_rounded,
            size: size - 4,
            fillColor: AppColors.accent,
            iconColor: AppColors.textOnAccent,
            onTap: quantity < maxQty ? () => onChanged(quantity + 1) : null,
          ),
        ],
      ),
    );
  }
}

class _CircleButton extends StatelessWidget {
  final IconData icon;
  final double size;
  final Color fillColor;
  final Color iconColor;
  final VoidCallback? onTap;

  const _CircleButton({
    required this.icon,
    required this.size,
    required this.fillColor,
    required this.iconColor,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          color: onTap != null ? fillColor : fillColor.withOpacity(0.5),
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.06),
              blurRadius: 4,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Icon(
          icon,
          size: size * 0.55,
          color: onTap != null ? iconColor : iconColor.withOpacity(0.5),
        ),
      ),
    );
  }
}
