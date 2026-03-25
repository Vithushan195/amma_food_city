import 'package:flutter/material.dart';
import '../core/theme/theme.dart';

/// Reusable error state widget.
/// Used when data fails to load on any screen.
class ErrorState extends StatelessWidget {
  final String message;
  final String? detail;
  final IconData icon;
  final VoidCallback? onRetry;

  const ErrorState({
    super.key,
    this.message = 'Something went wrong',
    this.detail,
    this.icon = Icons.error_outline_rounded,
    this.onRetry,
  });

  /// No internet variant
  const ErrorState.offline({super.key, this.onRetry})
      : message = 'No internet connection',
        detail = 'Check your connection and try again',
        icon = Icons.wifi_off_rounded;

  /// Empty data variant
  const ErrorState.empty({
    super.key,
    this.message = 'Nothing here yet',
    this.detail,
    this.icon = Icons.inbox_rounded,
    this.onRetry,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 90,
              height: 90,
              decoration: const BoxDecoration(
                color: AppColors.backgroundGrey,
                shape: BoxShape.circle,
              ),
              child: Icon(icon,
                  size: 42, color: AppColors.textTertiary.withOpacity(0.5)),
            ),
            const SizedBox(height: 20),
            Text(
              message,
              style: AppTypography.h2.copyWith(fontSize: 18),
              textAlign: TextAlign.center,
            ),
            if (detail != null) ...[
              const SizedBox(height: 8),
              Text(
                detail!,
                style: AppTypography.bodySmall.copyWith(
                  color: AppColors.textSecondary,
                  height: 1.5,
                ),
                textAlign: TextAlign.center,
              ),
            ],
            if (onRetry != null) ...[
              const SizedBox(height: 24),
              SizedBox(
                height: 44,
                child: ElevatedButton.icon(
                  onPressed: onRetry,
                  icon: const Icon(Icons.refresh_rounded, size: 18),
                  label: const Text('Try Again',
                      style: AppTypography.buttonMedium),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.accent,
                    foregroundColor: AppColors.textOnAccent,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
