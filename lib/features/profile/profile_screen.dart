import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter/material.dart';
import '../../core/theme/theme.dart';
import '../../core/models/models.dart';
import '../../core/providers/providers.dart';
import '../../core/services/fcm_service.dart';
import 'dev_tools_screen.dart';
import 'edit_profile_screen.dart';
import 'saved_addresses_screen.dart';
import 'help_centre_screen.dart';
import 'contact_us_screen.dart';

/// Amma Food City — Profile Screen
///
/// Layout:
/// 1. User avatar + name + email header card
/// 2. Quick stats row (orders, addresses, loyalty points)
/// 3. Settings groups: Account, Preferences, Support, Legal
/// 4. Sign out button
/// 5. App version
class ProfileScreen extends ConsumerStatefulWidget {
  const ProfileScreen({super.key});

  @override
  ConsumerState<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends ConsumerState<ProfileScreen> {
  bool _notificationsEnabled = true;
  int _versionTapCount = 0;

  AppUser get _user => ref.watch(currentUserProvider) ?? AppUser.mockUser;

  @override
  Widget build(BuildContext context) {
    final statusBarHeight = MediaQuery.of(context).padding.top;

    return Scaffold(
      backgroundColor: AppColors.offWhite,
      body: ListView(
        padding: EdgeInsets.zero,
        children: [
          // ── HEADER ──────────────────────────────────────────
          _buildHeader(statusBarHeight),

          // ── QUICK STATS ─────────────────────────────────────
          _buildQuickStats(),

          // ── ACCOUNT SETTINGS ────────────────────────────────
          _buildSectionTitle('Account'),
          _SettingsTile(
            icon: Icons.person_outline_rounded,
            title: 'Personal Information',
            subtitle: 'Name, email, phone',
            onTap: () => Navigator.of(context).push(
                MaterialPageRoute(builder: (_) => const EditProfileScreen())),
          ),
          _SettingsTile(
            icon: Icons.location_on_outlined,
            title: 'Saved Addresses',
            subtitle: '${DeliveryAddress.mockAddresses.length} addresses',
            onTap: () => Navigator.of(context).push(MaterialPageRoute(
                builder: (_) => const SavedAddressesScreen())),
          ),
          _SettingsTile(
            icon: Icons.credit_card_outlined,
            title: 'Payment Methods',
            subtitle: 'Manage your cards',
            onTap: () => debugPrint('Payment methods — coming soon'),
          ),

          // ── PREFERENCES ─────────────────────────────────────
          _buildSectionTitle('Preferences'),
          _SettingsTile(
            icon: Icons.notifications_outlined,
            title: 'Notifications',
            subtitle: _notificationsEnabled ? 'Enabled' : 'Disabled',
            trailing: Switch(
              value: _notificationsEnabled,
              onChanged: (v) => setState(() => _notificationsEnabled = v),
              activeColor: AppColors.primary,
              activeTrackColor: AppColors.accentSubtle,
            ),
          ),
          _SettingsTile(
            icon: Icons.language_rounded,
            title: 'Language',
            subtitle: 'English',
            onTap: () => debugPrint('Language settings — coming soon'),
          ),
          _SettingsTile(
            icon: Icons.dark_mode_outlined,
            title: 'Dark Mode',
            subtitle: 'Coming soon',
            trailing: Container(
              padding: const EdgeInsets.symmetric(
                horizontal: 8,
                vertical: 3,
              ),
              decoration: BoxDecoration(
                color: AppColors.accentSubtle,
                borderRadius: BorderRadius.circular(6),
              ),
              child: Text(
                'SOON',
                style: AppTypography.caption.copyWith(
                  fontWeight: FontWeight.w700,
                  color: AppColors.primary,
                  fontSize: 9,
                ),
              ),
            ),
          ),

          // ── SUPPORT ─────────────────────────────────────────
          _buildSectionTitle('Support'),
          _SettingsTile(
            icon: Icons.help_outline_rounded,
            title: 'Help Centre',
            subtitle: 'FAQs and support',
            onTap: () => Navigator.of(context).push(
                MaterialPageRoute(builder: (_) => const HelpCentreScreen())),
          ),
          _SettingsTile(
            icon: Icons.chat_bubble_outline_rounded,
            title: 'Contact Us',
            subtitle: 'Get in touch',
            onTap: () => Navigator.of(context).push(
                MaterialPageRoute(builder: (_) => const ContactUsScreen())),
          ),
          _SettingsTile(
            icon: Icons.star_outline_rounded,
            title: 'Rate the App',
            subtitle: 'Leave a review',
            onTap: () => debugPrint('Rate app — opens store listing'),
          ),

          // ── LEGAL ───────────────────────────────────────────
          _buildSectionTitle('Legal'),
          _SettingsTile(
            icon: Icons.description_outlined,
            title: 'Terms & Conditions',
            onTap: () => debugPrint('Terms'),
          ),
          _SettingsTile(
            icon: Icons.privacy_tip_outlined,
            title: 'Privacy Policy',
            onTap: () => debugPrint('Privacy'),
          ),

          // ── SIGN OUT ────────────────────────────────────────
          Padding(
            padding: const EdgeInsets.fromLTRB(
              AppSpacing.screenHorizontal,
              AppSpacing.xl,
              AppSpacing.screenHorizontal,
              0,
            ),
            child: SizedBox(
              width: double.infinity,
              height: AppSpacing.buttonHeight,
              child: OutlinedButton.icon(
                onPressed: () {
                  _showSignOutDialog();
                },
                icon: const Icon(Icons.logout_rounded, size: 20),
                label: Text(
                  'Sign Out',
                  style: AppTypography.buttonLarge.copyWith(
                    color: AppColors.error,
                  ),
                ),
                style: OutlinedButton.styleFrom(
                  foregroundColor: AppColors.error,
                  side: const BorderSide(color: AppColors.error),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(
                      AppSpacing.buttonRadius,
                    ),
                  ),
                ),
              ),
            ),
          ),

          // ── VERSION ─────────────────────────────────────────
          Padding(
            padding: const EdgeInsets.symmetric(vertical: AppSpacing.xl),
            child: Center(
              child: GestureDetector(
                onTap: () {
                  _versionTapCount++;
                  if (_versionTapCount >= 5) {
                    _versionTapCount = 0;
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (_) => const DevToolsScreen(),
                      ),
                    );
                  }
                },
                child: Text(
                  'Amma Food City v1.0.0',
                  style: AppTypography.caption.copyWith(
                    color: AppColors.textTertiary,
                  ),
                ),
              ),
            ),
          ),

          const SizedBox(height: AppSpacing.xxxl),
        ],
      ),
    );
  }

  Widget _buildHeader(double statusBarHeight) {
    return Container(
      decoration: const BoxDecoration(
        gradient: AppColors.headerGradient,
      ),
      child: Column(
        children: [
          SizedBox(height: statusBarHeight + AppSpacing.base),

          // Title
          Text(
            'Profile',
            style: AppTypography.sectionHeaderWhite.copyWith(fontSize: 22),
          ),

          const SizedBox(height: AppSpacing.xl),

          // Avatar
          Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              color: AppColors.accent,
              shape: BoxShape.circle,
              border: Border.all(
                color: AppColors.white.withOpacity(0.3),
                width: 3,
              ),
            ),
            child: Center(
              child: Text(
                _user.initials,
                style: AppTypography.h1.copyWith(
                  color: AppColors.textOnAccent,
                  fontSize: 28,
                ),
              ),
            ),
          ),

          const SizedBox(height: AppSpacing.md),

          // Name
          Text(
            _user.name,
            style: AppTypography.h2.copyWith(
              color: AppColors.white,
              fontSize: 20,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            _user.email,
            style: AppTypography.bodySmall.copyWith(
              color: AppColors.accentLight.withOpacity(0.8),
            ),
          ),

          const SizedBox(height: 6),

          // Edit profile button
          GestureDetector(
            onTap: () => Navigator.of(context).push(
                MaterialPageRoute(builder: (_) => const EditProfileScreen())),
            child: Container(
              padding: const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 6,
              ),
              decoration: BoxDecoration(
                color: AppColors.white.withOpacity(0.15),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                'Edit Profile',
                style: AppTypography.caption.copyWith(
                  color: AppColors.accentLight,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),

          const SizedBox(height: AppSpacing.xl),

          // Bottom curve
          Container(
            height: 20,
            decoration: const BoxDecoration(
              color: AppColors.offWhite,
              borderRadius: BorderRadius.vertical(
                top: Radius.circular(20),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQuickStats() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.screenHorizontal,
        0,
        AppSpacing.screenHorizontal,
        AppSpacing.base,
      ),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 16),
        decoration: BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.circular(AppSpacing.cardRadius),
          boxShadow: AppColors.cardShadow,
        ),
        child: Row(
          children: [
            _StatItem(
              value: '${ref.watch(ordersProvider).orders.length}',
              label: 'Orders',
              icon: Icons.receipt_long_rounded,
            ),
            Container(
              width: 1,
              height: 36,
              color: AppColors.divider,
            ),
            _StatItem(
              value: '${DeliveryAddress.mockAddresses.length}',
              label: 'Addresses',
              icon: Icons.location_on_rounded,
            ),
            Container(
              width: 1,
              height: 36,
              color: AppColors.divider,
            ),
            const _StatItem(
              value: '120',
              label: 'Points',
              icon: Icons.stars_rounded,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.screenHorizontal,
        AppSpacing.lg,
        AppSpacing.screenHorizontal,
        AppSpacing.sm,
      ),
      child: Text(
        title.toUpperCase(),
        style: AppTypography.label.copyWith(
          letterSpacing: 1.0,
          fontSize: 11,
          fontWeight: FontWeight.w700,
          color: AppColors.textTertiary,
        ),
      ),
    );
  }

  void _showSignOutDialog() {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        title: const Text('Sign Out', style: AppTypography.h3),
        content: Text(
          'Are you sure you want to sign out?',
          style: AppTypography.bodyMedium.copyWith(
            color: AppColors.textSecondary,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text(
              'Cancel',
              style: AppTypography.buttonMedium.copyWith(
                color: AppColors.textSecondary,
              ),
            ),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(ctx);
              await FcmService.instance.clearToken(); // ← add this line
              ref.read(authProvider.notifier).signOut();
              ref.read(signOutTriggerProvider.notifier).state++;
            },
            child: Text(
              'Sign Out',
              style: AppTypography.buttonMedium.copyWith(
                color: AppColors.error,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════════
class _StatItem extends StatelessWidget {
  final String value;
  final String label;
  final IconData icon;

  const _StatItem({
    required this.value,
    required this.label,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Column(
        children: [
          Icon(icon, size: 20, color: AppColors.primary),
          const SizedBox(height: 6),
          Text(
            value,
            style: AppTypography.h3.copyWith(
              fontSize: 18,
              color: AppColors.primary,
            ),
          ),
          Text(label, style: AppTypography.caption),
        ],
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════════
class _SettingsTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final String? subtitle;
  final VoidCallback? onTap;
  final Widget? trailing;

  const _SettingsTile({
    required this.icon,
    required this.title,
    this.subtitle,
    this.onTap,
    this.trailing,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.screenHorizontal,
        vertical: 1,
      ),
      child: Material(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(0),
        child: InkWell(
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 14,
            ),
            child: Row(
              children: [
                Container(
                  width: 36,
                  height: 36,
                  decoration: BoxDecoration(
                    color: AppColors.backgroundGrey,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(icon, size: 20, color: AppColors.primary),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: AppTypography.bodyMedium.copyWith(
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      if (subtitle != null)
                        Text(
                          subtitle!,
                          style: AppTypography.caption,
                        ),
                    ],
                  ),
                ),
                trailing ??
                    const Icon(
                      Icons.chevron_right_rounded,
                      color: AppColors.textTertiary,
                      size: 22,
                    ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
