import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../core/theme/theme.dart';
import '../../core/constants/app_constants.dart';
import '../../core/providers/providers.dart';
import 'signup_screen.dart';
import 'forgot_password_screen.dart';

/// Amma Food City — Login Screen
///
/// Supports: Email/password, Phone OTP, Continue as Guest
/// Reports result via [onAuthResult] callback:
///   true  = authenticated (email/phone/signup)
///   false = guest mode
///   null  = cancelled
class LoginScreen extends ConsumerStatefulWidget {
  final void Function(bool?)? onAuthResult;
  final bool showGuestOption;

  const LoginScreen(
      {super.key, this.onAuthResult, this.showGuestOption = true});

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _phoneController = TextEditingController();
  final _otpController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  bool _obscurePassword = true;
  bool _otpSent = false;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _phoneController.dispose();
    _otpController.dispose();
    super.dispose();
  }

  bool get _isLoading => ref.watch(authProvider).isLoading;

  void _reportResult(bool? result) {
    if (widget.onAuthResult != null) {
      widget.onAuthResult!(result);
    } else if (result == true && mounted) {
      // Standalone mode (pushed from cart) — pop back after successful login
      Navigator.of(context).pop();
    }
  }

  void _loginWithEmail() async {
    if (!_formKey.currentState!.validate()) return;
    final success = await ref.read(authProvider.notifier).signInWithEmail(
          _emailController.text.trim(),
          _passwordController.text,
        );
    if (success && mounted) _reportResult(true);
  }

  void _sendOtp() async {
    if (_phoneController.text.length < 10) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Enter a valid phone number')),
      );
      return;
    }
    final success =
        await ref.read(authProvider.notifier).sendOtp(_phoneController.text);
    if (success && mounted) setState(() => _otpSent = true);
  }

  void _verifyOtp() async {
    if (_otpController.text.length != 6) return;
    final success =
        await ref.read(authProvider.notifier).verifyOtp(_otpController.text);
    if (success && mounted) _reportResult(true);
  }

  @override
  Widget build(BuildContext context) {
    final statusBarHeight = MediaQuery.of(context).padding.top;

    return Scaffold(
      backgroundColor: AppColors.offWhite,
      body: SingleChildScrollView(
        child: Column(
          children: [
            // Header
            _buildHeader(statusBarHeight),

            // Form
            Padding(
              padding: const EdgeInsets.all(AppSpacing.screenHorizontal),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(AppStrings.loginTitle,
                      style: AppTypography.h1.copyWith(
                          fontFamily: AppTypography.fontHeading, fontSize: 28)),
                  const SizedBox(height: 4),
                  const Text('Sign in to your account to continue',
                      style: AppTypography.bodySmall),
                  const SizedBox(height: AppSpacing.xl),

                  // Tab toggle
                  Container(
                    height: 48,
                    decoration: BoxDecoration(
                      color: AppColors.backgroundGrey,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: TabBar(
                      controller: _tabController,
                      onTap: (_) => setState(() {}),
                      indicator: BoxDecoration(
                          color: AppColors.primary,
                          borderRadius: BorderRadius.circular(10)),
                      indicatorSize: TabBarIndicatorSize.tab,
                      dividerColor: Colors.transparent,
                      labelColor: AppColors.white,
                      unselectedLabelColor: AppColors.textSecondary,
                      labelStyle:
                          AppTypography.buttonMedium.copyWith(fontSize: 14),
                      tabs: const [Tab(text: 'Email'), Tab(text: 'Phone')],
                    ),
                  ),
                  const SizedBox(height: AppSpacing.xl),

                  // Tab content
                  AnimatedCrossFade(
                    firstChild: _buildEmailForm(),
                    secondChild: _buildPhoneForm(),
                    crossFadeState: _tabController.index == 0
                        ? CrossFadeState.showFirst
                        : CrossFadeState.showSecond,
                    duration: const Duration(milliseconds: 250),
                  ),

                  const SizedBox(height: AppSpacing.xxl),

                  if (widget.showGuestOption) ...[
                    // Divider
                    const Row(children: [
                      Expanded(child: Divider(color: AppColors.divider)),
                      Padding(
                        padding: EdgeInsets.symmetric(horizontal: 16),
                        child: Text('or', style: AppTypography.bodySmall),
                      ),
                      Expanded(child: Divider(color: AppColors.divider)),
                    ]),
                    const SizedBox(height: AppSpacing.lg),

                    // Continue as Guest
                    SizedBox(
                      width: double.infinity,
                      height: AppSpacing.buttonHeight,
                      child: OutlinedButton(
                        onPressed: () => _reportResult(false),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: AppColors.primary,
                          side: const BorderSide(
                              color: AppColors.divider, width: 1.5),
                          shape: RoundedRectangleBorder(
                            borderRadius:
                                BorderRadius.circular(AppSpacing.buttonRadius),
                          ),
                        ),
                        child: Text('Continue as Guest',
                            style: AppTypography.buttonLarge
                                .copyWith(color: AppColors.textSecondary)),
                      ),
                    ),
                  ] else ...[
                    // Back button for standalone mode (pushed from cart)
                    SizedBox(
                      width: double.infinity,
                      height: AppSpacing.buttonHeight,
                      child: OutlinedButton(
                        onPressed: () => Navigator.of(context).pop(),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: AppColors.textSecondary,
                          side: const BorderSide(
                              color: AppColors.divider, width: 1.5),
                          shape: RoundedRectangleBorder(
                            borderRadius:
                                BorderRadius.circular(AppSpacing.buttonRadius),
                          ),
                        ),
                        child: Text('Back to Cart',
                            style: AppTypography.buttonLarge
                                .copyWith(color: AppColors.textSecondary)),
                      ),
                    ),
                  ],
                  const SizedBox(height: AppSpacing.xl),

                  // Sign up link
                  Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                    Text("Don't have an account? ",
                        style: AppTypography.bodyMedium
                            .copyWith(color: AppColors.textSecondary)),
                    GestureDetector(
                      onTap: () async {
                        final result = await Navigator.of(context).push<bool>(
                          MaterialPageRoute(
                              builder: (_) =>
                                  SignupScreen(onAuthResult: _reportResult)),
                        );
                        if (result == true && mounted) _reportResult(true);
                      },
                      child: Text('Sign Up',
                          style: AppTypography.bodyMedium.copyWith(
                              color: AppColors.primary,
                              fontWeight: FontWeight.w700)),
                    ),
                  ]),
                  const SizedBox(height: AppSpacing.xxl),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(double statusBarHeight) {
    return ClipPath(
      clipper: _AuthHeaderClipper(),
      child: Container(
        width: double.infinity,
        height: 180,
        decoration: const BoxDecoration(gradient: AppColors.headerGradient),
        child: Center(
          child: Padding(
            padding: EdgeInsets.only(top: statusBarHeight),
            child: Column(mainAxisSize: MainAxisSize.min, children: [
              Container(
                width: 60,
                height: 60,
                decoration: BoxDecoration(
                  color: AppColors.accent.withOpacity(0.2),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.storefront_rounded,
                    color: AppColors.accent, size: 32),
              ),
              const SizedBox(height: 8),
              Text(AppStrings.appName,
                  style:
                      AppTypography.sectionHeaderWhite.copyWith(fontSize: 20)),
            ]),
          ),
        ),
      ),
    );
  }

  Widget _buildEmailForm() {
    return Form(
      key: _formKey,
      child: Column(children: [
        _AuthTextField(
          controller: _emailController,
          label: 'Email',
          hint: 'you@example.com',
          icon: Icons.email_outlined,
          keyboardType: TextInputType.emailAddress,
          validator: (v) {
            if (v == null || v.isEmpty) return 'Enter your email';
            if (!v.contains('@')) return 'Enter a valid email';
            return null;
          },
        ),
        const SizedBox(height: AppSpacing.base),
        _AuthTextField(
          controller: _passwordController,
          label: 'Password',
          hint: 'Enter your password',
          icon: Icons.lock_outline_rounded,
          obscure: _obscurePassword,
          suffix: GestureDetector(
            onTap: () => setState(() => _obscurePassword = !_obscurePassword),
            child: Icon(
                _obscurePassword
                    ? Icons.visibility_off_outlined
                    : Icons.visibility_outlined,
                color: AppColors.textTertiary,
                size: 20),
          ),
          validator: (v) {
            if (v == null || v.isEmpty) return 'Enter your password';
            if (v.length < 6) return 'Min 6 characters';
            return null;
          },
        ),
        const SizedBox(height: AppSpacing.sm),
        Align(
          alignment: Alignment.centerRight,
          child: GestureDetector(
            onTap: () => Navigator.of(context).push(MaterialPageRoute(
                builder: (_) => const ForgotPasswordScreen())),
            child: Text('Forgot Password?',
                style: AppTypography.bodySmall.copyWith(
                    color: AppColors.primary, fontWeight: FontWeight.w600)),
          ),
        ),
        const SizedBox(height: AppSpacing.xl),
        SizedBox(
          width: double.infinity,
          height: AppSpacing.buttonHeight,
          child: ElevatedButton(
            onPressed: _isLoading ? null : _loginWithEmail,
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.accent,
              foregroundColor: AppColors.textOnAccent,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(AppSpacing.buttonRadius)),
            ),
            child: _isLoading
                ? const SizedBox(
                    width: 22,
                    height: 22,
                    child: CircularProgressIndicator(
                        strokeWidth: 2.5, color: AppColors.textOnAccent))
                : const Text(AppStrings.loginCta,
                    style: AppTypography.buttonLarge),
          ),
        ),
      ]),
    );
  }

  Widget _buildPhoneForm() {
    return Column(children: [
      _AuthTextField(
        controller: _phoneController,
        label: 'Phone Number',
        hint: '07700 900123',
        icon: Icons.phone_outlined,
        keyboardType: TextInputType.phone,
        prefix: Text('+44  ',
            style: AppTypography.bodyMedium.copyWith(
                color: AppColors.textSecondary, fontWeight: FontWeight.w600)),
        inputFormatters: [
          FilteringTextInputFormatter.digitsOnly,
          LengthLimitingTextInputFormatter(11)
        ],
      ),
      if (_otpSent) ...[
        const SizedBox(height: AppSpacing.base),
        _AuthTextField(
          controller: _otpController,
          label: 'Verification Code',
          hint: '000000',
          icon: Icons.pin_outlined,
          keyboardType: TextInputType.number,
          inputFormatters: [
            FilteringTextInputFormatter.digitsOnly,
            LengthLimitingTextInputFormatter(6)
          ],
        ),
        const SizedBox(height: AppSpacing.sm),
        Align(
          alignment: Alignment.centerRight,
          child: GestureDetector(
            onTap: _sendOtp,
            child: Text('Resend Code',
                style: AppTypography.bodySmall.copyWith(
                    color: AppColors.primary, fontWeight: FontWeight.w600)),
          ),
        ),
      ],
      const SizedBox(height: AppSpacing.xl),
      SizedBox(
        width: double.infinity,
        height: AppSpacing.buttonHeight,
        child: ElevatedButton(
          onPressed: _isLoading ? null : (_otpSent ? _verifyOtp : _sendOtp),
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.accent,
            foregroundColor: AppColors.textOnAccent,
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(AppSpacing.buttonRadius)),
          ),
          child: _isLoading
              ? const SizedBox(
                  width: 22,
                  height: 22,
                  child: CircularProgressIndicator(
                      strokeWidth: 2.5, color: AppColors.textOnAccent))
              : Text(_otpSent ? 'Verify & Sign In' : 'Send OTP',
                  style: AppTypography.buttonLarge),
        ),
      ),
    ]);
  }
}

// ── Auth Text Field ─────────────────────────────────────────────
class _AuthTextField extends StatelessWidget {
  final TextEditingController controller;
  final String label;
  final String hint;
  final IconData icon;
  final bool obscure;
  final TextInputType? keyboardType;
  final Widget? suffix;
  final Widget? prefix;
  final String? Function(String?)? validator;
  final List<TextInputFormatter>? inputFormatters;

  const _AuthTextField({
    required this.controller,
    required this.label,
    required this.hint,
    required this.icon,
    this.obscure = false,
    this.keyboardType,
    this.suffix,
    this.prefix,
    this.validator,
    this.inputFormatters,
  });

  @override
  Widget build(BuildContext context) {
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Text(label,
          style: AppTypography.label.copyWith(
              color: AppColors.textPrimary, fontWeight: FontWeight.w600)),
      const SizedBox(height: 6),
      TextFormField(
        controller: controller,
        obscureText: obscure,
        keyboardType: keyboardType,
        validator: validator,
        inputFormatters: inputFormatters,
        style: AppTypography.bodyMedium,
        decoration: InputDecoration(
          hintText: hint,
          prefixIcon: Row(mainAxisSize: MainAxisSize.min, children: [
            const SizedBox(width: 14),
            Icon(icon, size: 20, color: AppColors.textTertiary),
            const SizedBox(width: 10),
            if (prefix != null) prefix!,
          ]),
          prefixIconConstraints: const BoxConstraints(minWidth: 0),
          suffixIcon: suffix != null
              ? Padding(
                  padding: const EdgeInsets.only(right: 12), child: suffix)
              : null,
          suffixIconConstraints: const BoxConstraints(minWidth: 0),
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
          errorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: AppColors.error)),
        ),
      ),
    ]);
  }
}

class _AuthHeaderClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    final path = Path();
    path.lineTo(0, size.height - 30);
    path.quadraticBezierTo(
        size.width / 2, size.height + 16, size.width, size.height - 30);
    path.lineTo(size.width, 0);
    path.close();
    return path;
  }

  @override
  bool shouldReclip(covariant CustomClipper<Path> oldClipper) => false;
}
