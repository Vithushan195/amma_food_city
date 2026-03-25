import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';
import '../core/theme/theme.dart';

/// Shimmer loading placeholder for product cards.
class ProductCardShimmer extends StatelessWidget {
  final int count;
  const ProductCardShimmer({super.key, this.count = 4});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 220,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: AppSpacing.screenHorizontal),
        itemCount: count,
        separatorBuilder: (_, __) => const SizedBox(width: 12),
        itemBuilder: (_, __) => Shimmer.fromColors(
          baseColor: AppColors.backgroundGrey,
          highlightColor: AppColors.white,
          child: Container(
            width: 150,
            decoration: BoxDecoration(
              color: AppColors.backgroundGrey,
              borderRadius: BorderRadius.circular(AppSpacing.cardRadiusSmall),
            ),
          ),
        ),
      ),
    );
  }
}

/// Shimmer loading for a full list screen.
class ListShimmer extends StatelessWidget {
  final int count;
  const ListShimmer({super.key, this.count = 5});

  @override
  Widget build(BuildContext context) {
    return Shimmer.fromColors(
      baseColor: AppColors.backgroundGrey,
      highlightColor: AppColors.white,
      child: ListView.separated(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        padding: const EdgeInsets.all(AppSpacing.screenHorizontal),
        itemCount: count,
        separatorBuilder: (_, __) => const SizedBox(height: 12),
        itemBuilder: (_, __) => Container(
          height: 80,
          decoration: BoxDecoration(
            color: AppColors.backgroundGrey,
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      ),
    );
  }
}

/// Shimmer loading for category circles.
class CategoryShimmer extends StatelessWidget {
  final int count;
  const CategoryShimmer({super.key, this.count = 6});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 90,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: AppSpacing.screenHorizontal),
        itemCount: count,
        separatorBuilder: (_, __) => const SizedBox(width: 16),
        itemBuilder: (_, __) => Shimmer.fromColors(
          baseColor: AppColors.backgroundGrey,
          highlightColor: AppColors.white,
          child: Column(
            children: [
              Container(width: 60, height: 60, decoration: const BoxDecoration(color: AppColors.backgroundGrey, shape: BoxShape.circle)),
              const SizedBox(height: 8),
              Container(width: 50, height: 10, decoration: BoxDecoration(color: AppColors.backgroundGrey, borderRadius: BorderRadius.circular(4))),
            ],
          ),
        ),
      ),
    );
  }
}

/// Shimmer loading for banner carousel.
class BannerShimmer extends StatelessWidget {
  const BannerShimmer({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.screenHorizontal),
      child: Shimmer.fromColors(
        baseColor: AppColors.backgroundGrey,
        highlightColor: AppColors.white,
        child: Container(
          height: 140,
          decoration: BoxDecoration(
            color: AppColors.backgroundGrey,
            borderRadius: BorderRadius.circular(16),
          ),
        ),
      ),
    );
  }
}
