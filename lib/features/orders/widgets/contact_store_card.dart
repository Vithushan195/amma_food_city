import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_typography.dart';

/// Widget shown instead of cancel button when order is past confirmation.
/// Displays phone call + WhatsApp buttons for the store.
class ContactStoreCard extends StatelessWidget {
  /// Store phone number — update to your real number
  static const storePhone = '+441234567890'; // TODO: Replace with real number
  static const storeWhatsApp = '+441234567890'; // TODO: Replace

  const ContactStoreCard({super.key});

  Future<void> _callStore() async {
    final uri = Uri(scheme: 'tel', path: storePhone);
    if (await canLaunchUrl(uri)) await launchUrl(uri);
  }

  Future<void> _whatsAppStore() async {
    final uri = Uri.parse(
      'https://wa.me/${storeWhatsApp.replaceAll('+', '')}?text=Hi, I need to cancel or modify my order.',
    );
    if (await canLaunchUrl(uri))
      await launchUrl(uri, mode: LaunchMode.externalApplication);
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: AppColors.cardShadow,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Need to cancel?',
              style: AppTypography.h3.copyWith(color: AppColors.primary)),
          const SizedBox(height: 4),
          Text(
            'Orders cannot be cancelled after confirmation. Please contact the store.',
            style: AppTypography.bodySmall,
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: _ContactButton(
                  icon: Icons.phone_rounded,
                  label: 'Call Store',
                  color: AppColors.primary,
                  onTap: _callStore,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _ContactButton(
                  icon: Icons.chat_rounded,
                  label: 'WhatsApp',
                  color: const Color(0xFF25D366),
                  onTap: _whatsAppStore,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _ContactButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback onTap;

  const _ContactButton({
    required this.icon,
    required this.label,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: color.withOpacity(0.08),
      borderRadius: BorderRadius.circular(12),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 14),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, size: 20, color: color),
              const SizedBox(width: 8),
              Text(label,
                  style: AppTypography.buttonMedium.copyWith(color: color)),
            ],
          ),
        ),
      ),
    );
  }
}
