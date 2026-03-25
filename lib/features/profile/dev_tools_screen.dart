import 'package:flutter/material.dart';
import '../../core/theme/theme.dart';
import '../../core/services/firestore_seed.dart';

/// Developer Tools Screen — hidden in Profile > tap version 5 times.
/// Provides one-tap Firestore seeding and other dev utilities.
class DevToolsScreen extends StatefulWidget {
  const DevToolsScreen({super.key});

  @override
  State<DevToolsScreen> createState() => _DevToolsScreenState();
}

class _DevToolsScreenState extends State<DevToolsScreen> {
  bool _seedingAll = false;
  bool _seedingProducts = false;
  bool _seedingCategories = false;
  bool _seedingBanners = false;
  bool _seedingPromos = false;
  final List<String> _logs = [];

  void _log(String message) {
    setState(() {
      _logs.insert(0, '[${TimeOfDay.now().format(context)}] $message');
    });
  }

  Future<void> _seedAll() async {
    setState(() => _seedingAll = true);
    _log('Starting full seed...');
    try {
      await FirestoreSeed.seedAll();
      _log('All collections seeded successfully');
    } catch (e) {
      _log('ERROR: $e');
    }
    setState(() => _seedingAll = false);
  }

  Future<void> _seedCollection(
    String name,
    Future<void> Function() seedFn,
    void Function(bool) setLoading,
  ) async {
    setLoading(true);
    _log('Seeding $name...');
    try {
      await seedFn();
      _log('$name seeded successfully');
    } catch (e) {
      _log('ERROR seeding $name: $e');
    }
    setLoading(false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.offWhite,
      appBar: AppBar(
        title: const Text('Developer Tools'),
        backgroundColor: AppColors.primary,
        foregroundColor: AppColors.white,
      ),
      body: ListView(
        padding: const EdgeInsets.all(AppSpacing.screenHorizontal),
        children: [
          // ── Warning Banner ──────────────────────────────────
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: const Color(0xFFFFF3CD),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: const Color(0xFFFFD93D)),
            ),
            child: Row(
              children: [
                const Icon(Icons.warning_rounded,
                    color: Color(0xFF856404), size: 24),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    'These tools write directly to Firestore. '
                    'Only use in development.',
                    style: AppTypography.bodySmall.copyWith(
                      color: const Color(0xFF856404),
                    ),
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: AppSpacing.xl),

          // ── Seed All ────────────────────────────────────────
          Text('Database Seeding',
              style: AppTypography.h2.copyWith(fontSize: 18)),
          const SizedBox(height: 4),
          const Text(
            'Populate Firestore with initial data from mock models.',
            style: AppTypography.bodySmall,
          ),
          const SizedBox(height: AppSpacing.base),

          _SeedButton(
            label: 'Seed Everything',
            subtitle: 'Categories + Products + Banners + Promo Codes',
            icon: Icons.cloud_upload_rounded,
            isLoading: _seedingAll,
            isPrimary: true,
            onTap: _seedAll,
          ),

          const SizedBox(height: AppSpacing.base),

          // ── Individual Seeds ─────────────────────────────────
          Text('Individual Collections',
              style: AppTypography.label.copyWith(
                fontSize: 11,
                letterSpacing: 1,
                fontWeight: FontWeight.w700,
              )),
          const SizedBox(height: AppSpacing.sm),

          _SeedButton(
            label: 'Seed Categories',
            subtitle: '10 categories with emoji + colours',
            icon: Icons.grid_view_rounded,
            isLoading: _seedingCategories,
            onTap: () => _seedCollection(
              'Categories',
              FirestoreSeed.seedCategories,
              (v) => setState(() => _seedingCategories = v),
            ),
          ),
          const SizedBox(height: 8),

          _SeedButton(
            label: 'Seed Products',
            subtitle: '14 products across multiple categories',
            icon: Icons.shopping_bag_rounded,
            isLoading: _seedingProducts,
            onTap: () => _seedCollection(
              'Products',
              FirestoreSeed.seedProducts,
              (v) => setState(() => _seedingProducts = v),
            ),
          ),
          const SizedBox(height: 8),

          _SeedButton(
            label: 'Seed Promo Banners',
            subtitle: '3 carousel banners',
            icon: Icons.campaign_rounded,
            isLoading: _seedingBanners,
            onTap: () => _seedCollection(
              'Promo Banners',
              FirestoreSeed.seedPromoBanners,
              (v) => setState(() => _seedingBanners = v),
            ),
          ),
          const SizedBox(height: 8),

          _SeedButton(
            label: 'Seed Promo Codes',
            subtitle: 'AMMA10, WELCOME, AMMA20',
            icon: Icons.local_offer_rounded,
            isLoading: _seedingPromos,
            onTap: () => _seedCollection(
              'Promo Codes',
              FirestoreSeed.seedPromoCodes,
              (v) => setState(() => _seedingPromos = v),
            ),
          ),

          const SizedBox(height: AppSpacing.xl),

          // ── Log Output ──────────────────────────────────────
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Log', style: AppTypography.h3.copyWith(fontSize: 15)),
              if (_logs.isNotEmpty)
                GestureDetector(
                  onTap: () => setState(() => _logs.clear()),
                  child: Text(
                    'Clear',
                    style: AppTypography.bodySmall.copyWith(
                      color: AppColors.primary,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(height: AppSpacing.sm),

          Container(
            padding: const EdgeInsets.all(12),
            constraints: const BoxConstraints(minHeight: 120),
            decoration: BoxDecoration(
              color: const Color(0xFF1E1E1E),
              borderRadius: BorderRadius.circular(12),
            ),
            child: _logs.isEmpty
                ? Text(
                    'No activity yet. Tap a seed button above.',
                    style: AppTypography.bodySmall.copyWith(
                      color: const Color(0xFF6A9955),
                      fontFamily: 'monospace',
                    ),
                  )
                : Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: _logs
                        .map((log) => Padding(
                              padding: const EdgeInsets.only(bottom: 4),
                              child: Text(
                                log,
                                style: TextStyle(
                                  fontFamily: 'monospace',
                                  fontSize: 11,
                                  color: log.contains('ERROR')
                                      ? const Color(0xFFF44747)
                                      : log.contains('success')
                                          ? const Color(0xFF6A9955)
                                          : const Color(0xFFD4D4D4),
                                ),
                              ),
                            ))
                        .toList(),
                  ),
          ),

          const SizedBox(height: AppSpacing.xxxl),
        ],
      ),
    );
  }
}

class _SeedButton extends StatelessWidget {
  final String label;
  final String subtitle;
  final IconData icon;
  final bool isLoading;
  final bool isPrimary;
  final VoidCallback onTap;

  const _SeedButton({
    required this.label,
    required this.subtitle,
    required this.icon,
    required this.isLoading,
    this.isPrimary = false,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: isLoading ? null : onTap,
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: isPrimary ? AppColors.primary : AppColors.white,
          borderRadius: BorderRadius.circular(12),
          boxShadow: AppColors.cardShadow,
        ),
        child: Row(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: isPrimary
                    ? AppColors.accent.withOpacity(0.2)
                    : AppColors.accentSubtle,
                borderRadius: BorderRadius.circular(10),
              ),
              child: isLoading
                  ? Padding(
                      padding: const EdgeInsets.all(10),
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: isPrimary ? AppColors.accent : AppColors.primary,
                      ),
                    )
                  : Icon(icon,
                      size: 20,
                      color: isPrimary ? AppColors.accent : AppColors.primary),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    label,
                    style: AppTypography.bodyMedium.copyWith(
                      fontWeight: FontWeight.w600,
                      color:
                          isPrimary ? AppColors.white : AppColors.textPrimary,
                    ),
                  ),
                  Text(
                    subtitle,
                    style: AppTypography.caption.copyWith(
                      color: isPrimary
                          ? AppColors.accentLight
                          : AppColors.textTertiary,
                    ),
                  ),
                ],
              ),
            ),
            Icon(
              Icons.arrow_forward_ios_rounded,
              size: 14,
              color: isPrimary ? AppColors.accentLight : AppColors.textTertiary,
            ),
          ],
        ),
      ),
    );
  }
}
