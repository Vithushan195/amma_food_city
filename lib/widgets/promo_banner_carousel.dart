import 'dart:async';
import 'package:flutter/material.dart';
import '../core/theme/theme.dart';
import '../core/models/promo_banner.dart';

/// Auto-scrolling promotional banner carousel with page indicator.
/// Sits below the curved header on the home screen.
///
/// ```dart
/// PromoBannerCarousel(
///   banners: PromoBanner.mockBanners,
///   onBannerTap: (banner) => navigateTo(banner.routeTo),
/// )
/// ```
class PromoBannerCarousel extends StatefulWidget {
  final List<PromoBanner> banners;
  final ValueChanged<PromoBanner>? onBannerTap;
  final Duration autoScrollDuration;

  const PromoBannerCarousel({
    super.key,
    required this.banners,
    this.onBannerTap,
    this.autoScrollDuration = const Duration(seconds: 4),
  });

  @override
  State<PromoBannerCarousel> createState() => _PromoBannerCarouselState();
}

class _PromoBannerCarouselState extends State<PromoBannerCarousel> {
  late final PageController _pageController;
  int _currentPage = 0;
  Timer? _autoScrollTimer;

  @override
  void initState() {
    super.initState();
    _pageController = PageController(viewportFraction: 0.9);
    _startAutoScroll();
  }

  @override
  void dispose() {
    _autoScrollTimer?.cancel();
    _pageController.dispose();
    super.dispose();
  }

  void _startAutoScroll() {
    if (widget.banners.length <= 1) return;
    _autoScrollTimer = Timer.periodic(widget.autoScrollDuration, (_) {
      final nextPage = (_currentPage + 1) % widget.banners.length;
      _pageController.animateToPage(
        nextPage,
        duration: const Duration(milliseconds: 400),
        curve: Curves.easeInOut,
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    if (widget.banners.isEmpty) return const SizedBox.shrink();

    return Column(
      children: [
        // Banner PageView
        SizedBox(
          height: 140,
          child: PageView.builder(
            controller: _pageController,
            itemCount: widget.banners.length,
            onPageChanged: (index) {
              setState(() => _currentPage = index);
            },
            itemBuilder: (context, index) {
              final banner = widget.banners[index];
              return _BannerCard(
                banner: banner,
                onTap: () => widget.onBannerTap?.call(banner),
              );
            },
          ),
        ),

        const SizedBox(height: AppSpacing.md),

        // Page indicator dots
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: List.generate(
            widget.banners.length,
            (index) => AnimatedContainer(
              duration: const Duration(milliseconds: 250),
              width: index == _currentPage ? 24 : 8,
              height: 8,
              margin: const EdgeInsets.symmetric(horizontal: 3),
              decoration: BoxDecoration(
                color: index == _currentPage
                    ? AppColors.primary
                    : AppColors.divider,
                borderRadius: BorderRadius.circular(4),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _BannerCard extends StatelessWidget {
  final PromoBanner banner;
  final VoidCallback? onTap;

  const _BannerCard({required this.banner, this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 6),
        decoration: BoxDecoration(
          color: banner.backgroundColor,
          borderRadius: BorderRadius.circular(AppSpacing.cardRadius),
          boxShadow: AppColors.cardShadow,
        ),
        child: Stack(
          children: [
            // Decorative circle accents
            Positioned(
              right: -20,
              top: -20,
              child: Container(
                width: 100,
                height: 100,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.white.withOpacity(0.08),
                ),
              ),
            ),
            Positioned(
              right: 30,
              bottom: -30,
              child: Container(
                width: 80,
                height: 80,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.white.withOpacity(0.05),
                ),
              ),
            ),

            // Content
            Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    banner.title,
                    style: AppTypography.h1.copyWith(
                      color: banner.textColor,
                      fontSize: 22,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    banner.subtitle,
                    style: AppTypography.bodyMedium.copyWith(
                      color: banner.textColor.withOpacity(0.8),
                    ),
                  ),
                  if (banner.ctaText != null) ...[
                    const SizedBox(height: 14),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 8,
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.accent,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        banner.ctaText!,
                        style: AppTypography.buttonMedium.copyWith(
                          color: AppColors.textOnAccent,
                          fontSize: 13,
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
