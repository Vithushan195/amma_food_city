import 'package:flutter/material.dart';
import '../core/theme/theme.dart';

/// Delivery address display shown in the home screen header.
/// Tappable to open address picker/selector.
///
/// ```dart
/// DeliveryAddressBar(
///   address: 'Glasgow G1 2FF',
///   onTap: () => showAddressPicker(),
/// )
/// ```
class DeliveryAddressBar extends StatelessWidget {
  final String address;
  final VoidCallback? onTap;

  const DeliveryAddressBar({
    super.key,
    required this.address,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Row(
        children: [
          // Location icon
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: AppColors.accent.withOpacity(0.2),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.location_on_rounded,
              color: AppColors.accent,
              size: 20,
            ),
          ),
          const SizedBox(width: 10),

          // Address text
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'Delivery to',
                  style: AppTypography.caption.copyWith(
                    color: AppColors.accentLight.withOpacity(0.7),
                    fontSize: 11,
                  ),
                ),
                const SizedBox(height: 1),
                Row(
                  children: [
                    Flexible(
                      child: Text(
                        address,
                        style: AppTypography.bodyMedium.copyWith(
                          color: AppColors.white,
                          fontWeight: FontWeight.w600,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    const SizedBox(width: 4),
                    const Icon(
                      Icons.keyboard_arrow_down_rounded,
                      color: AppColors.accentLight,
                      size: 18,
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
