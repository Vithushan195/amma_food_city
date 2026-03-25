import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter/material.dart';
import '../../core/theme/theme.dart';
import '../../core/constants/app_constants.dart';
import '../../core/providers/providers.dart';

/// Amma Food City — Signup Screen
class SignupScreen extends ConsumerStatefulWidget {
  final void Function(bool?)? onAuthResult;

  const SignupScreen({super.key, this.onAuthResult});

  @override
  ConsumerState<SignupScreen> createState() => _SignupScreenState();
}

class _SignupScreenState extends ConsumerState<SignupScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmController = TextEditingController();

  bool _obscurePassword = true;
  bool _obscureConfirm = true;
  bool _agreedToTerms = false;

  bool get _isLoading => ref.watch(authProvider).isLoading;

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmController.dispose();
    super.dispose();
  }

  void _signup() async {
    if (!_formKey.currentState!.validate()) return;
    if (!_agreedToTerms) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please agree to Terms & Conditions')),
      );
      return;
    }
    final success = await ref.read(authProvider.notifier).signUp(
          name: _nameController.text.trim(),
          email: _emailController.text.trim(),
          password: _passwordController.text,
        );
    if (success && mounted) {
      if (widget.onAuthResult != null) {
        widget.onAuthResult!(true);
      } else {
        Navigator.of(context).pop(true);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final statusBarHeight = MediaQuery.of(context).padding.top;

    return Scaffold(
      backgroundColor: AppColors.offWhite,
      body: SingleChildScrollView(
        child: Column(children: [
          // Header
          ClipPath(
            clipper: _SignupHeaderClipper(),
            child: Container(
              width: double.infinity,
              height: 160,
              decoration:
                  const BoxDecoration(gradient: AppColors.headerGradient),
              child: Center(
                child: Padding(
                  padding: EdgeInsets.only(top: statusBarHeight),
                  child: Row(children: [
                    IconButton(
                      onPressed: () => Navigator.of(context).pop(),
                      icon: const Icon(Icons.arrow_back_rounded,
                          color: AppColors.white),
                    ),
                    const Spacer(),
                    Text('Create Account',
                        style: AppTypography.sectionHeaderWhite
                            .copyWith(fontSize: 22)),
                    const Spacer(),
                    const SizedBox(width: 48),
                  ]),
                ),
              ),
            ),
          ),

          // Form
          Padding(
            padding: const EdgeInsets.all(AppSpacing.screenHorizontal),
            child: Form(
              key: _formKey,
              child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(AppStrings.signupTitle,
                        style: AppTypography.h1.copyWith(
                            fontFamily: AppTypography.fontHeading,
                            fontSize: 26)),
                    const SizedBox(height: 4),
                    const Text('Join Amma Food City for fresh Asian groceries',
                        style: AppTypography.bodySmall),
                    const SizedBox(height: AppSpacing.xl),

                    _buildField(
                        controller: _nameController,
                        label: 'Full Name',
                        hint: 'Enter your name',
                        icon: Icons.person_outline_rounded,
                        validator: (v) =>
                            v == null || v.isEmpty ? 'Enter your name' : null),
                    const SizedBox(height: AppSpacing.base),

                    _buildField(
                        controller: _emailController,
                        label: 'Email',
                        hint: 'you@example.com',
                        icon: Icons.email_outlined,
                        keyboardType: TextInputType.emailAddress,
                        validator: (v) {
                          if (v == null || v.isEmpty) return 'Enter your email';
                          if (!v.contains('@')) return 'Enter a valid email';
                          return null;
                        }),
                    const SizedBox(height: AppSpacing.base),

                    _buildField(
                        controller: _passwordController,
                        label: 'Password',
                        hint: 'Min 6 characters',
                        icon: Icons.lock_outline_rounded,
                        obscure: _obscurePassword,
                        suffix: GestureDetector(
                            onTap: () => setState(
                                () => _obscurePassword = !_obscurePassword),
                            child: Icon(
                                _obscurePassword
                                    ? Icons.visibility_off_outlined
                                    : Icons.visibility_outlined,
                                color: AppColors.textTertiary,
                                size: 20)),
                        validator: (v) {
                          if (v == null || v.isEmpty) return 'Enter a password';
                          if (v.length < 6) return 'Min 6 characters';
                          return null;
                        }),
                    const SizedBox(height: AppSpacing.base),

                    _buildField(
                        controller: _confirmController,
                        label: 'Confirm Password',
                        hint: 'Re-enter your password',
                        icon: Icons.lock_outline_rounded,
                        obscure: _obscureConfirm,
                        suffix: GestureDetector(
                            onTap: () => setState(
                                () => _obscureConfirm = !_obscureConfirm),
                            child: Icon(
                                _obscureConfirm
                                    ? Icons.visibility_off_outlined
                                    : Icons.visibility_outlined,
                                color: AppColors.textTertiary,
                                size: 20)),
                        validator: (v) {
                          if (v != _passwordController.text)
                            return "Passwords don't match";
                          return null;
                        }),

                    const SizedBox(height: AppSpacing.lg),

                    // T&C checkbox
                    Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          SizedBox(
                              width: 24,
                              height: 24,
                              child: Checkbox(
                                value: _agreedToTerms,
                                onChanged: (v) =>
                                    setState(() => _agreedToTerms = v ?? false),
                                activeColor: AppColors.primary,
                                shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(4)),
                              )),
                          const SizedBox(width: 10),
                          Expanded(
                              child: GestureDetector(
                            onTap: () => setState(
                                () => _agreedToTerms = !_agreedToTerms),
                            child: RichText(
                                text: TextSpan(
                                    style: AppTypography.bodySmall,
                                    children: [
                                  const TextSpan(text: 'I agree to the '),
                                  TextSpan(
                                      text: 'Terms & Conditions',
                                      style: AppTypography.bodySmall.copyWith(
                                          color: AppColors.primary,
                                          fontWeight: FontWeight.w600)),
                                  const TextSpan(text: ' and '),
                                  TextSpan(
                                      text: 'Privacy Policy',
                                      style: AppTypography.bodySmall.copyWith(
                                          color: AppColors.primary,
                                          fontWeight: FontWeight.w600)),
                                ])),
                          )),
                        ]),

                    const SizedBox(height: AppSpacing.xl),

                    SizedBox(
                      width: double.infinity,
                      height: AppSpacing.buttonHeight,
                      child: ElevatedButton(
                        onPressed: _isLoading ? null : _signup,
                        style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.accent,
                            foregroundColor: AppColors.textOnAccent,
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(
                                    AppSpacing.buttonRadius))),
                        child: _isLoading
                            ? const SizedBox(
                                width: 22,
                                height: 22,
                                child: CircularProgressIndicator(
                                    strokeWidth: 2.5,
                                    color: AppColors.textOnAccent))
                            : const Text(AppStrings.signupCta,
                                style: AppTypography.buttonLarge),
                      ),
                    ),

                    const SizedBox(height: AppSpacing.lg),

                    Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                      Text('Already have an account? ',
                          style: AppTypography.bodyMedium
                              .copyWith(color: AppColors.textSecondary)),
                      GestureDetector(
                        onTap: () => Navigator.of(context).pop(),
                        child: Text('Sign In',
                            style: AppTypography.bodyMedium.copyWith(
                                color: AppColors.primary,
                                fontWeight: FontWeight.w700)),
                      ),
                    ]),
                    const SizedBox(height: AppSpacing.xxl),
                  ]),
            ),
          ),
        ]),
      ),
    );
  }

  Widget _buildField({
    required TextEditingController controller,
    required String label,
    required String hint,
    required IconData icon,
    bool obscure = false,
    TextInputType? keyboardType,
    Widget? suffix,
    String? Function(String?)? validator,
  }) {
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
        style: AppTypography.bodyMedium,
        decoration: InputDecoration(
          hintText: hint,
          prefixIcon: Padding(
              padding: const EdgeInsets.only(left: 14, right: 10),
              child: Icon(icon, size: 20, color: AppColors.textTertiary)),
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

class _SignupHeaderClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    final path = Path();
    path.lineTo(0, size.height - 26);
    path.quadraticBezierTo(
        size.width / 2, size.height + 14, size.width, size.height - 26);
    path.lineTo(size.width, 0);
    path.close();
    return path;
  }

  @override
  bool shouldReclip(covariant CustomClipper<Path> oldClipper) => false;
}
