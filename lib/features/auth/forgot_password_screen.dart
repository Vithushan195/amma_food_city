import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/theme/theme.dart';

class ForgotPasswordScreen extends ConsumerStatefulWidget {
  const ForgotPasswordScreen({super.key});
  @override
  ConsumerState<ForgotPasswordScreen> createState() =>
      _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends ConsumerState<ForgotPasswordScreen> {
  final _emailController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  bool _isLoading = false;
  bool _emailSent = false;

  @override
  void dispose() {
    _emailController.dispose();
    super.dispose();
  }

  void _sendResetEmail() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _isLoading = true);
    // TODO: FirebaseAuth.sendPasswordResetEmail
    await Future.delayed(const Duration(seconds: 1));
    if (mounted)
      setState(() {
        _isLoading = false;
        _emailSent = true;
      });
  }

  @override
  Widget build(BuildContext context) {
    final statusBarHeight = MediaQuery.of(context).padding.top;

    return Scaffold(
      backgroundColor: AppColors.offWhite,
      body: SingleChildScrollView(
        child: Column(children: [
          // Header
          Container(
            width: double.infinity,
            padding: EdgeInsets.fromLTRB(8, statusBarHeight + 4, 16, 20),
            decoration: const BoxDecoration(gradient: AppColors.headerGradient),
            child: Row(children: [
              IconButton(
                onPressed: () => Navigator.pop(context),
                icon: const Icon(Icons.arrow_back_rounded,
                    color: AppColors.white),
              ),
              const Spacer(),
              Text('Reset Password',
                  style:
                      AppTypography.sectionHeaderWhite.copyWith(fontSize: 20)),
              const Spacer(),
              const SizedBox(width: 48),
            ]),
          ),

          Padding(
            padding: const EdgeInsets.all(AppSpacing.screenHorizontal),
            child: _emailSent ? _buildSuccessState() : _buildFormState(),
          ),
        ]),
      ),
    );
  }

  Widget _buildFormState() {
    return Form(
      key: _formKey,
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        const SizedBox(height: AppSpacing.xl),
        Container(
          width: 72,
          height: 72,
          decoration: const BoxDecoration(
              color: AppColors.accentSubtle, shape: BoxShape.circle),
          child: const Icon(Icons.lock_reset_rounded,
              size: 36, color: AppColors.primary),
        ),
        const SizedBox(height: AppSpacing.xl),
        Text('Forgot your password?',
            style: AppTypography.h1
                .copyWith(fontFamily: AppTypography.fontHeading, fontSize: 24)),
        const SizedBox(height: 8),
        Text(
          "Enter the email address associated with your account and we'll send you a link to reset your password.",
          style: AppTypography.bodyMedium
              .copyWith(color: AppColors.textSecondary, height: 1.6),
        ),
        const SizedBox(height: AppSpacing.xxl),
        Text('Email Address',
            style: AppTypography.label.copyWith(
                color: AppColors.textPrimary, fontWeight: FontWeight.w600)),
        const SizedBox(height: 6),
        TextFormField(
          controller: _emailController,
          keyboardType: TextInputType.emailAddress,
          style: AppTypography.bodyMedium,
          validator: (v) {
            if (v == null || v.isEmpty) return 'Enter your email';
            if (!v.contains('@')) return 'Enter a valid email';
            return null;
          },
          decoration: InputDecoration(
            hintText: 'you@example.com',
            prefixIcon: const Padding(
                padding: EdgeInsets.only(left: 14, right: 10),
                child: Icon(Icons.email_outlined,
                    size: 20, color: AppColors.textTertiary)),
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
            errorBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(color: AppColors.error)),
          ),
        ),
        const SizedBox(height: AppSpacing.xl),
        SizedBox(
          width: double.infinity,
          height: AppSpacing.buttonHeight,
          child: ElevatedButton(
            onPressed: _isLoading ? null : _sendResetEmail,
            style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.accent,
                foregroundColor: AppColors.textOnAccent,
                shape: RoundedRectangleBorder(
                    borderRadius:
                        BorderRadius.circular(AppSpacing.buttonRadius))),
            child: _isLoading
                ? const SizedBox(
                    width: 22,
                    height: 22,
                    child: CircularProgressIndicator(
                        strokeWidth: 2.5, color: AppColors.textOnAccent))
                : const Text('Send Reset Link',
                    style: AppTypography.buttonLarge),
          ),
        ),
        const SizedBox(height: AppSpacing.lg),
        Center(
          child: GestureDetector(
            onTap: () => Navigator.pop(context),
            child: Text('Back to Sign In',
                style: AppTypography.bodyMedium.copyWith(
                    color: AppColors.primary, fontWeight: FontWeight.w600)),
          ),
        ),
      ]),
    );
  }

  Widget _buildSuccessState() {
    return Column(children: [
      const SizedBox(height: 60),
      Container(
        width: 90,
        height: 90,
        decoration: const BoxDecoration(
            color: AppColors.accentSubtle, shape: BoxShape.circle),
        child: const Icon(Icons.mark_email_read_rounded,
            size: 44, color: AppColors.primary),
      ),
      const SizedBox(height: AppSpacing.xl),
      Text('Check your email',
          style: AppTypography.h1
              .copyWith(fontFamily: AppTypography.fontHeading, fontSize: 24)),
      const SizedBox(height: 8),
      Text(
        'We\'ve sent a password reset link to\n${_emailController.text}',
        style: AppTypography.bodyMedium
            .copyWith(color: AppColors.textSecondary, height: 1.6),
        textAlign: TextAlign.center,
      ),
      const SizedBox(height: AppSpacing.xxl),
      SizedBox(
        width: double.infinity,
        height: AppSpacing.buttonHeight,
        child: ElevatedButton(
          onPressed: () => Navigator.pop(context),
          style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.accent,
              foregroundColor: AppColors.textOnAccent,
              shape: RoundedRectangleBorder(
                  borderRadius:
                      BorderRadius.circular(AppSpacing.buttonRadius))),
          child:
              const Text('Back to Sign In', style: AppTypography.buttonLarge),
        ),
      ),
      const SizedBox(height: AppSpacing.base),
      GestureDetector(
        onTap: () {
          setState(() => _emailSent = false);
          _sendResetEmail();
        },
        child: Text("Didn't receive it? Resend",
            style: AppTypography.bodySmall.copyWith(
                color: AppColors.primary, fontWeight: FontWeight.w600)),
      ),
    ]);
  }
}
