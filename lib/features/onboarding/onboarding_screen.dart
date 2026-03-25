import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../core/theme/theme.dart';

/// Amma Food City — Onboarding Screen
///
/// Shows 3 pages on first launch explaining the app.
/// Stores 'onboarding_complete' flag in SharedPreferences.
class OnboardingScreen extends StatefulWidget {
  final VoidCallback onComplete;

  const OnboardingScreen({super.key, required this.onComplete});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final PageController _pageController = PageController();
  int _currentPage = 0;

  final List<_OnboardingPage> _pages = const [
    _OnboardingPage(
      icon: Icons.local_grocery_store_rounded,
      emoji: '🥭',
      title: 'Fresh Asian Groceries',
      description:
          'Browse hundreds of authentic South Asian products — from Basmati rice to fresh curry leaves, all in one place.',
      backgroundColor: Color(0xFF0B3B2D),
    ),
    _OnboardingPage(
      icon: Icons.delivery_dining_rounded,
      emoji: '🚚',
      title: 'Fast Delivery',
      description:
          'Get your groceries delivered to your door in 30-45 minutes. Free delivery on orders over £30.',
      backgroundColor: Color(0xFF145A44),
    ),
    _OnboardingPage(
      icon: Icons.local_offer_rounded,
      emoji: '💰',
      title: 'Great Deals',
      description:
          'Enjoy weekly offers, promo codes, and loyalty rewards. Save on every shop with Amma Food City.',
      backgroundColor: Color(0xFF1A5276),
    ),
  ];

  void _nextPage() {
    if (_currentPage < _pages.length - 1) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 350),
        curve: Curves.easeInOut,
      );
    } else {
      _completeOnboarding();
    }
  }

  void _skip() => _completeOnboarding();

  void _completeOnboarding() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('onboarding_complete', true);
    widget.onComplete();
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final bottomPadding = MediaQuery.of(context).padding.bottom;

    return Scaffold(
      body: Stack(
        children: [
          // Page View
          PageView.builder(
            controller: _pageController,
            itemCount: _pages.length,
            onPageChanged: (index) {
              setState(() => _currentPage = index);
            },
            itemBuilder: (context, index) {
              final page = _pages[index];
              return Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      page.backgroundColor,
                      page.backgroundColor.withOpacity(0.85)
                    ],
                  ),
                ),
                child: SafeArea(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 32),
                    child: Column(
                      children: [
                        const Spacer(flex: 2),

                        // Icon circle
                        Container(
                          width: 140,
                          height: 140,
                          decoration: BoxDecoration(
                            color: AppColors.accent.withOpacity(0.15),
                            shape: BoxShape.circle,
                          ),
                          child: Center(
                            child: Text(
                              page.emoji,
                              style: const TextStyle(fontSize: 64),
                            ),
                          ),
                        ),

                        const Spacer(flex: 1),

                        // Title
                        Text(
                          page.title,
                          style: AppTypography.displayMedium.copyWith(
                            fontFamily: AppTypography.fontHeading,
                            color: AppColors.white,
                            fontSize: 28,
                          ),
                          textAlign: TextAlign.center,
                        ),

                        const SizedBox(height: 16),

                        // Description
                        Text(
                          page.description,
                          style: AppTypography.bodyLarge.copyWith(
                            color: AppColors.white.withOpacity(0.75),
                            height: 1.6,
                          ),
                          textAlign: TextAlign.center,
                        ),

                        const Spacer(flex: 3),
                      ],
                    ),
                  ),
                ),
              );
            },
          ),

          // Bottom controls
          Positioned(
            bottom: bottomPadding + 24,
            left: 32,
            right: 32,
            child: Column(
              children: [
                // Page dots
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: List.generate(_pages.length, (index) {
                    return AnimatedContainer(
                      duration: const Duration(milliseconds: 250),
                      width: index == _currentPage ? 28 : 8,
                      height: 8,
                      margin: const EdgeInsets.symmetric(horizontal: 4),
                      decoration: BoxDecoration(
                        color: index == _currentPage
                            ? AppColors.accent
                            : AppColors.white.withOpacity(0.3),
                        borderRadius: BorderRadius.circular(4),
                      ),
                    );
                  }),
                ),

                const SizedBox(height: 32),

                // Next / Get Started button
                SizedBox(
                  width: double.infinity,
                  height: AppSpacing.buttonHeight,
                  child: ElevatedButton(
                    onPressed: _nextPage,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.accent,
                      foregroundColor: AppColors.textOnAccent,
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius:
                            BorderRadius.circular(AppSpacing.buttonRadius),
                      ),
                    ),
                    child: Text(
                      _currentPage == _pages.length - 1
                          ? 'Get Started'
                          : 'Next',
                      style: AppTypography.buttonLarge,
                    ),
                  ),
                ),

                const SizedBox(height: 12),

                // Skip button (hidden on last page)
                if (_currentPage < _pages.length - 1)
                  GestureDetector(
                    onTap: _skip,
                    child: Padding(
                      padding: const EdgeInsets.symmetric(vertical: 8),
                      child: Text(
                        'Skip',
                        style: AppTypography.buttonMedium.copyWith(
                          color: AppColors.white.withOpacity(0.5),
                        ),
                      ),
                    ),
                  )
                else
                  const SizedBox(height: 36),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _OnboardingPage {
  final IconData icon;
  final String emoji;
  final String title;
  final String description;
  final Color backgroundColor;

  const _OnboardingPage({
    required this.icon,
    required this.emoji,
    required this.title,
    required this.description,
    required this.backgroundColor,
  });
}
