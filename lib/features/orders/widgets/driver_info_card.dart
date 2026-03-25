import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../core/models/driver_info.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_typography.dart';

/// Card showing driver name, vehicle, rating, and call/message buttons.
class DriverInfoCard extends StatelessWidget {
  final DriverInfo driver;
  final int? estimatedMinutes;

  const DriverInfoCard({
    super.key,
    required this.driver,
    this.estimatedMinutes,
  });

  Future<void> _callDriver() async {
    final uri = Uri(scheme: 'tel', path: driver.phone);
    if (await canLaunchUrl(uri)) await launchUrl(uri);
  }

  Future<void> _messageDriver() async {
    final uri = Uri(scheme: 'sms', path: driver.phone);
    if (await canLaunchUrl(uri)) await launchUrl(uri);
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: AppColors.cardShadow,
      ),
      child: Row(
        children: [
          _buildAvatar(),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  driver.name,
                  style: AppTypography.bodyLarge.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                if (driver.vehicle != null) ...[
                  const SizedBox(height: 2),
                  Text(
                    driver.vehicle!,
                    style: AppTypography.bodySmall.copyWith(
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
                if (driver.rating != null) ...[
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      const Icon(Icons.star_rounded,
                          size: 16, color: Color(0xFFFFC107)),
                      const SizedBox(width: 3),
                      Text(
                        driver.rating!.toStringAsFixed(1),
                        style: AppTypography.bodySmall.copyWith(
                          fontWeight: FontWeight.w500,
                          color: AppColors.textPrimary,
                        ),
                      ),
                    ],
                  ),
                ],
              ],
            ),
          ),

          // ETA chip
          if (estimatedMinutes != null) ...[
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
              decoration: BoxDecoration(
                color: AppColors.accentSubtle,
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                '$estimatedMinutes min',
                style: AppTypography.bodySmall.copyWith(
                  fontWeight: FontWeight.w700,
                  color: AppColors.primary,
                ),
              ),
            ),
            const SizedBox(width: 8),
          ],

          _ActionCircle(icon: Icons.phone_rounded, onTap: _callDriver),
          const SizedBox(width: 8),
          _ActionCircle(icon: Icons.message_rounded, onTap: _messageDriver),
        ],
      ),
    );
  }

  Widget _buildAvatar() {
    if (driver.photo != null && driver.photo!.isNotEmpty) {
      return CircleAvatar(
        radius: 24,
        backgroundImage: NetworkImage(driver.photo!),
        backgroundColor: AppColors.accentSubtle,
      );
    }
    return CircleAvatar(
      radius: 24,
      backgroundColor: AppColors.primary,
      child: Text(
        driver.initials,
        style: const TextStyle(
          color: AppColors.white,
          fontWeight: FontWeight.w600,
          fontSize: 18,
        ),
      ),
    );
  }
}

class _ActionCircle extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;
  const _ActionCircle({required this.icon, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppColors.primary.withOpacity(0.08),
      shape: const CircleBorder(),
      child: InkWell(
        onTap: onTap,
        customBorder: const CircleBorder(),
        child: Padding(
          padding: const EdgeInsets.all(10),
          child: Icon(icon, size: 20, color: AppColors.primary),
        ),
      ),
    );
  }
}
