import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/theme/theme.dart';
import '../../core/models/models.dart';
import '../../core/providers/providers.dart';

class EditProfileScreen extends ConsumerStatefulWidget {
  const EditProfileScreen({super.key});
  @override
  ConsumerState<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends ConsumerState<EditProfileScreen> {
  late TextEditingController _nameCtrl;
  late TextEditingController _emailCtrl;
  late TextEditingController _phoneCtrl;
  bool _isLoading = false;
  bool _hasChanges = false;

  @override
  void initState() {
    super.initState();
    final user = ref.read(currentUserProvider) ?? AppUser.mockUser;
    _nameCtrl = TextEditingController(text: user.name);
    _emailCtrl = TextEditingController(text: user.email);
    _phoneCtrl = TextEditingController(text: user.phone ?? '');
    _nameCtrl.addListener(_onChanged);
    _emailCtrl.addListener(_onChanged);
    _phoneCtrl.addListener(_onChanged);
  }

  void _onChanged() {
    final user = ref.read(currentUserProvider) ?? AppUser.mockUser;
    setState(() {
      _hasChanges = _nameCtrl.text != user.name ||
          _emailCtrl.text != user.email ||
          _phoneCtrl.text != (user.phone ?? '');
    });
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _emailCtrl.dispose();
    _phoneCtrl.dispose();
    super.dispose();
  }

  void _save() async {
    if (!_hasChanges) return;
    setState(() => _isLoading = true);
    // TODO: Update Firestore user document via UserService
    await Future.delayed(const Duration(seconds: 1));
    if (mounted) {
      setState(() => _isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Profile updated successfully')),
      );
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    final user = ref.watch(currentUserProvider) ?? AppUser.mockUser;
    final statusBarHeight = MediaQuery.of(context).padding.top;

    return Scaffold(
      backgroundColor: AppColors.offWhite,
      body: Column(children: [
        // App bar
        Container(
          color: AppColors.white,
          padding: EdgeInsets.fromLTRB(8, statusBarHeight + 4, 8, 12),
          child: Row(children: [
            IconButton(
                onPressed: () => Navigator.pop(context),
                icon: const Icon(Icons.arrow_back_rounded)),
            Expanded(
                child: Text('Edit Profile',
                    style: AppTypography.h3.copyWith(fontSize: 18),
                    textAlign: TextAlign.center)),
            TextButton(
              onPressed: _hasChanges && !_isLoading ? _save : null,
              child: _isLoading
                  ? const SizedBox(
                      width: 18,
                      height: 18,
                      child: CircularProgressIndicator(
                          strokeWidth: 2, color: AppColors.primary))
                  : Text('Save',
                      style: AppTypography.buttonMedium.copyWith(
                          color: _hasChanges
                              ? AppColors.primary
                              : AppColors.textTertiary)),
            ),
          ]),
        ),

        // Content
        Expanded(
          child: ListView(
            padding: const EdgeInsets.all(AppSpacing.screenHorizontal),
            children: [
              // Avatar
              Center(
                child: Stack(children: [
                  Container(
                    width: 90,
                    height: 90,
                    decoration: const BoxDecoration(
                        color: AppColors.accent, shape: BoxShape.circle),
                    child: Center(
                        child: Text(user.initials,
                            style: AppTypography.h1.copyWith(
                                color: AppColors.textOnAccent, fontSize: 32))),
                  ),
                  Positioned(
                    bottom: 0,
                    right: 0,
                    child: Container(
                      width: 32,
                      height: 32,
                      decoration: BoxDecoration(
                        color: AppColors.primary,
                        shape: BoxShape.circle,
                        border: Border.all(color: AppColors.white, width: 2),
                      ),
                      child: const Icon(Icons.camera_alt_rounded,
                          size: 16, color: AppColors.white),
                    ),
                  ),
                ]),
              ),

              const SizedBox(height: AppSpacing.xxl),

              _buildField(
                  label: 'Full Name',
                  controller: _nameCtrl,
                  icon: Icons.person_outline_rounded),
              const SizedBox(height: AppSpacing.base),
              _buildField(
                  label: 'Email',
                  controller: _emailCtrl,
                  icon: Icons.email_outlined,
                  keyboardType: TextInputType.emailAddress),
              const SizedBox(height: AppSpacing.base),
              _buildField(
                  label: 'Phone Number',
                  controller: _phoneCtrl,
                  icon: Icons.phone_outlined,
                  keyboardType: TextInputType.phone),

              const SizedBox(height: AppSpacing.xxl),

              // Joined date
              Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                    color: AppColors.backgroundGrey,
                    borderRadius: BorderRadius.circular(12)),
                child: Row(children: [
                  const Icon(Icons.calendar_today_outlined,
                      size: 18, color: AppColors.textTertiary),
                  const SizedBox(width: 10),
                  Text('Member since ${_formatDate(user.createdAt)}',
                      style: AppTypography.bodySmall
                          .copyWith(color: AppColors.textSecondary)),
                ]),
              ),
            ],
          ),
        ),
      ]),
    );
  }

  Widget _buildField(
      {required String label,
      required TextEditingController controller,
      required IconData icon,
      TextInputType? keyboardType}) {
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Text(label,
          style: AppTypography.label.copyWith(
              color: AppColors.textPrimary, fontWeight: FontWeight.w600)),
      const SizedBox(height: 6),
      TextField(
        controller: controller,
        keyboardType: keyboardType,
        style: AppTypography.bodyMedium,
        decoration: InputDecoration(
          prefixIcon: Padding(
              padding: const EdgeInsets.only(left: 14, right: 10),
              child: Icon(icon, size: 20, color: AppColors.textTertiary)),
          prefixIconConstraints: const BoxConstraints(minWidth: 0),
          filled: true,
          fillColor: AppColors.white,
          contentPadding:
              const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: AppColors.divider)),
          enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: AppColors.divider)),
          focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide:
                  const BorderSide(color: AppColors.primary, width: 1.5)),
        ),
      ),
    ]);
  }

  String _formatDate(DateTime date) {
    final months = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec'
    ];
    return '${months[date.month - 1]} ${date.year}';
  }
}
