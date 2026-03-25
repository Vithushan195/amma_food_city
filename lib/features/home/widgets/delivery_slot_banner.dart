import 'package:flutter/material.dart';
import '../../../core/theme/theme.dart';
import '../../../core/providers/data_providers.dart';

/// Compact delivery slot banner for the top of the home screen.
/// Shows the next available delivery window with a "Change" button.
class DeliverySlotBanner extends StatelessWidget {
  final DeliverySlot? slot;
  final VoidCallback? onChangeTap;

  const DeliverySlotBanner({
    super.key,
    required this.slot,
    this.onChangeTap,
  });

  @override
  Widget build(BuildContext context) {
    if (slot == null) return const SizedBox.shrink();

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [Color(0xFF0B3B2D), Color(0xFF145A3E)],
          begin: Alignment.centerLeft,
          end: Alignment.centerRight,
        ),
      ),
      child: SafeArea(
        bottom: false,
        child: Row(
          children: [
            // Clock icon
            Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                color: AppColors.accent.withOpacity(0.15),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.schedule_rounded,
                size: 18,
                color: AppColors.accent,
              ),
            ),
            const SizedBox(width: 12),
            // Slot info
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    'Delivering ${slot!.label}',
                    style: AppTypography.bodySmall.copyWith(
                      color: AppColors.white,
                      fontWeight: FontWeight.w600,
                      fontSize: 13,
                    ),
                  ),
                  const SizedBox(height: 1),
                  Text(
                    'Next available slot',
                    style: AppTypography.caption.copyWith(
                      color: AppColors.accent.withOpacity(0.7),
                      fontSize: 11,
                    ),
                  ),
                ],
              ),
            ),
            // Change button
            GestureDetector(
              onTap: onChangeTap,
              child: Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: AppColors.accent.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  'Change',
                  style: AppTypography.caption.copyWith(
                    color: AppColors.accent,
                    fontWeight: FontWeight.w600,
                    fontSize: 11,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
