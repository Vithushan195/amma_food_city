import 'package:flutter/material.dart';
import '../../core/theme/theme.dart';
import '../../core/constants/app_constants.dart';

class SplashScreen extends StatefulWidget {
  final VoidCallback onComplete;
  const SplashScreen({super.key, required this.onComplete});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> with TickerProviderStateMixin {
  late AnimationController _logoCtrl;
  late AnimationController _textCtrl;
  late AnimationController _tagCtrl;
  late AnimationController _barCtrl;

  late Animation<double> _logoScale;
  late Animation<double> _logoFade;
  late Animation<double> _textFade;
  late Animation<Offset> _textSlide;
  late Animation<double> _tagFade;
  late Animation<double> _barValue;

  @override
  void initState() {
    super.initState();

    _logoCtrl = AnimationController(vsync: this, duration: const Duration(milliseconds: 800));
    _logoScale = Tween<double>(begin: 0.5, end: 1.0).animate(CurvedAnimation(parent: _logoCtrl, curve: Curves.elasticOut));
    _logoFade = Tween<double>(begin: 0.0, end: 1.0).animate(CurvedAnimation(parent: _logoCtrl, curve: Curves.easeIn));

    _textCtrl = AnimationController(vsync: this, duration: const Duration(milliseconds: 600));
    _textFade = Tween<double>(begin: 0.0, end: 1.0).animate(CurvedAnimation(parent: _textCtrl, curve: Curves.easeOut));
    _textSlide = Tween<Offset>(begin: const Offset(0, 0.3), end: Offset.zero).animate(CurvedAnimation(parent: _textCtrl, curve: Curves.easeOut));

    _tagCtrl = AnimationController(vsync: this, duration: const Duration(milliseconds: 500));
    _tagFade = Tween<double>(begin: 0.0, end: 1.0).animate(CurvedAnimation(parent: _tagCtrl, curve: Curves.easeIn));

    _barCtrl = AnimationController(vsync: this, duration: const Duration(milliseconds: 1200));
    _barValue = Tween<double>(begin: 0.0, end: 1.0).animate(CurvedAnimation(parent: _barCtrl, curve: Curves.easeInOut));

    _runSequence();
  }

  void _runSequence() async {
    await Future.delayed(const Duration(milliseconds: 200));
    _logoCtrl.forward();
    await Future.delayed(const Duration(milliseconds: 500));
    _textCtrl.forward();
    await Future.delayed(const Duration(milliseconds: 400));
    _tagCtrl.forward();
    await Future.delayed(const Duration(milliseconds: 200));
    _barCtrl.forward();
    await Future.delayed(const Duration(milliseconds: 1400));
    if (mounted) widget.onComplete();
  }

  @override
  void dispose() {
    _logoCtrl.dispose();
    _textCtrl.dispose();
    _tagCtrl.dispose();
    _barCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(gradient: AppColors.headerGradient),
        child: Stack(
          children: [
            // Decorative circles
            Positioned(top: -60, right: -40, child: _circle(200, 0.06)),
            Positioned(bottom: -80, left: -60, child: _circle(250, 0.04)),

            // Main content
            Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Logo
                  FadeTransition(
                    opacity: _logoFade,
                    child: ScaleTransition(
                      scale: _logoScale,
                      child: Container(
                        width: 110, height: 110,
                        decoration: BoxDecoration(
                          color: AppColors.accent.withOpacity(0.15),
                          shape: BoxShape.circle,
                          border: Border.all(color: AppColors.accent.withOpacity(0.3), width: 2),
                        ),
                        child: const Center(
                          child: Icon(Icons.storefront_rounded, size: 52, color: AppColors.accent),
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 28),

                  // App name
                  SlideTransition(
                    position: _textSlide,
                    child: FadeTransition(
                      opacity: _textFade,
                      child: Text(
                        AppStrings.appName,
                        style: AppTypography.displayLarge.copyWith(
                          fontFamily: AppTypography.fontHeading,
                          color: AppColors.white, fontSize: 34, letterSpacing: 0.5,
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 10),

                  // Tagline
                  FadeTransition(
                    opacity: _tagFade,
                    child: Text(
                      AppStrings.appTagline,
                      style: AppTypography.bodyMedium.copyWith(
                        color: AppColors.accentLight.withOpacity(0.8), fontSize: 15,
                      ),
                    ),
                  ),

                  const SizedBox(height: 48),

                  // Progress bar
                  AnimatedBuilder(
                    animation: _barCtrl,
                    builder: (context, _) {
                      return Container(
                        width: 160, height: 4,
                        decoration: BoxDecoration(
                          color: AppColors.white.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(2),
                        ),
                        child: Align(
                          alignment: Alignment.centerLeft,
                          child: FractionallySizedBox(
                            widthFactor: _barValue.value,
                            child: Container(
                              decoration: BoxDecoration(
                                color: AppColors.accent,
                                borderRadius: BorderRadius.circular(2),
                              ),
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ],
              ),
            ),

            // Version
            Positioned(
              bottom: MediaQuery.of(context).padding.bottom + 24,
              left: 0, right: 0,
              child: FadeTransition(
                opacity: _tagFade,
                child: Text('v1.0.0', textAlign: TextAlign.center,
                    style: AppTypography.caption.copyWith(color: AppColors.white.withOpacity(0.3))),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _circle(double size, double opacity) {
    return Container(
      width: size, height: size,
      decoration: BoxDecoration(shape: BoxShape.circle, color: AppColors.accent.withOpacity(opacity)),
    );
  }
}
