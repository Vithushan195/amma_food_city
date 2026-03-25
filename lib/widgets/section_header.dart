import 'package:flutter/material.dart';
import '../core/theme/theme.dart';

/// Section header with title and optional "View All" action.
/// Used between horizontal product lists on the home screen.
///
/// ```dart
/// SectionHeader(title: 'Featured Products', onViewAll: () {})
/// ```
class SectionHeader extends StatelessWidget {
  final String title;
  final VoidCallback? onViewAll;
  final String viewAllText;

  const SectionHeader({
    super.key,
    required this.title,
    this.onViewAll,
    this.viewAllText = 'View All',
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.screenHorizontal,
        vertical: AppSpacing.md,
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(title, style: AppTypography.h2),
          if (onViewAll != null)
            GestureDetector(
              onTap: onViewAll,
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    viewAllText,
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
    );
  }
}
