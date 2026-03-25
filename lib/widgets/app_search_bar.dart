import 'package:flutter/material.dart';
import '../core/theme/theme.dart';

/// Search bar widget styled for use inside the CurvedHeader or standalone.
/// White background, rounded, with search icon and optional filter button.
///
/// ```dart
/// AppSearchBar(
///   hint: 'Search groceries...',
///   onTap: () => Navigator.pushNamed(context, '/search'),
/// )
/// ```
class AppSearchBar extends StatelessWidget {
  final String hint;
  final VoidCallback? onTap;
  final ValueChanged<String>? onChanged;
  final TextEditingController? controller;
  final bool readOnly;
  final bool showFilterButton;
  final VoidCallback? onFilterTap;

  const AppSearchBar({
    super.key,
    this.hint = 'Search for groceries...',
    this.onTap,
    this.onChanged,
    this.controller,
    this.readOnly = false,
    this.showFilterButton = false,
    this.onFilterTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: readOnly ? onTap : null,
      child: Container(
        height: AppSpacing.searchBarHeight,
        decoration: BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.circular(AppSpacing.searchBarRadius),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.06),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          children: [
            const SizedBox(width: AppSpacing.base),
            const Icon(
              Icons.search_rounded,
              color: AppColors.textTertiary,
              size: 22,
            ),
            const SizedBox(width: AppSpacing.md),
            Expanded(
              child: readOnly
                  ? Text(
                      hint,
                      style: AppTypography.bodyMedium.copyWith(
                        color: AppColors.textTertiary,
                      ),
                    )
                  : TextField(
                      controller: controller,
                      onChanged: onChanged,
                      onTap: onTap,
                      decoration: InputDecoration(
                        hintText: hint,
                        border: InputBorder.none,
                        enabledBorder: InputBorder.none,
                        focusedBorder: InputBorder.none,
                        contentPadding: EdgeInsets.zero,
                        isDense: true,
                        hintStyle: AppTypography.bodyMedium.copyWith(
                          color: AppColors.textTertiary,
                        ),
                      ),
                      style: AppTypography.bodyMedium,
                    ),
            ),
            if (showFilterButton) ...[
              Container(
                width: 1,
                height: 24,
                color: AppColors.divider,
              ),
              IconButton(
                onPressed: onFilterTap,
                icon: const Icon(
                  Icons.tune_rounded,
                  color: AppColors.primary,
                  size: 22,
                ),
              ),
            ] else
              const SizedBox(width: AppSpacing.base),
          ],
        ),
      ),
    );
  }
}
