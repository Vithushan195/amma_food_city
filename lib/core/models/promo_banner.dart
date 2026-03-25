import 'package:flutter/material.dart';
import '../theme/app_colors.dart';

/// Promotional banner for home screen carousel.
class PromoBanner {
  final String id;
  final String title;
  final String subtitle;
  final String? ctaText;
  final String? imageUrl;
  final Color backgroundColor;
  final Color textColor;
  final String? routeTo; // deep link route

  const PromoBanner({
    required this.id,
    required this.title,
    required this.subtitle,
    this.ctaText,
    this.imageUrl,
    this.backgroundColor = AppColors.primary,
    this.textColor = AppColors.white,
    this.routeTo,
  });

  static List<PromoBanner> get mockBanners => [
        const PromoBanner(
          id: 'b1',
          title: 'Free Delivery',
          subtitle: 'On orders over £30 this week',
          ctaText: 'Shop Now',
          backgroundColor: AppColors.primary,
        ),
        const PromoBanner(
          id: 'b2',
          title: '20% Off Spices',
          subtitle: 'Explore our full masala range',
          ctaText: 'View Offers',
          backgroundColor: Color(0xFF8B2252),
        ),
        const PromoBanner(
          id: 'b3',
          title: 'Fresh Arrivals',
          subtitle: 'New Sri Lankan & Tamil products',
          ctaText: 'Discover',
          backgroundColor: Color(0xFF1A5276),
        ),
      ];
}
