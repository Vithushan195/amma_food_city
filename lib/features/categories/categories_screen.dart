import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/theme/theme.dart';
import '../../core/models/models.dart';
import '../../core/providers/providers.dart';
import '../../widgets/widgets.dart';
import 'category_detail_screen.dart';
import '../search/search_screen.dart';

/// Amma Food City — Categories Screen
///
/// Layout:
/// 1. Curved green header with title + search bar
/// 2. Grid of CategoryCircle widgets (2 rows visible, scrollable)
/// 3. "Shop by Diet" horizontal filter chips
/// 4. "All Products" section with vertical grid
class CategoriesScreen extends ConsumerStatefulWidget {
  const CategoriesScreen({super.key});

  @override
  ConsumerState<CategoriesScreen> createState() => _CategoriesScreenState();
}

class _CategoriesScreenState extends ConsumerState<CategoriesScreen> {
  String? _selectedDiet;

  final List<String> _dietFilters = [
    'All',
    'Vegetarian',
    'Vegan',
    'Gluten Free',
    'Halal',
    'Low Carb',
  ];

  void _openCategory(Category category) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => CategoryDetailScreen(category: category),
      ),
    );
  }

  List<Category> get _categories =>
      ref.watch(categoriesProvider).valueOrNull ?? [];

  @override
  Widget build(BuildContext context) {
    final statusBarHeight = MediaQuery.of(context).padding.top;

    return Scaffold(
      backgroundColor: AppColors.offWhite,
      body: CustomScrollView(
        slivers: [
          // ── HEADER ─────────────────────────────────────────────
          SliverToBoxAdapter(
            child: _buildHeader(statusBarHeight),
          ),

          // ── CATEGORY GRID ──────────────────────────────────────
          SliverToBoxAdapter(
            child: _buildCategoryGrid(),
          ),

          // ── DIET FILTER CHIPS ──────────────────────────────────
          SliverToBoxAdapter(
            child: _buildDietFilters(),
          ),

          // ── POPULAR IN CATEGORIES ──────────────────────────────
          SliverToBoxAdapter(
            child: _buildPopularSection(),
          ),

          // Bottom padding
          const SliverToBoxAdapter(
            child: SizedBox(height: AppSpacing.xxxl + AppSpacing.xxl),
          ),
        ],
      ),
    );
  }

  // ── Header ───────────────────────────────────────────────────
  Widget _buildHeader(double statusBarHeight) {
    return ClipPath(
      clipper: _CategoriesHeaderClipper(),
      child: Container(
        width: double.infinity,
        decoration: const BoxDecoration(
          gradient: AppColors.headerGradient,
        ),
        padding: EdgeInsets.fromLTRB(
          AppSpacing.screenHorizontal,
          statusBarHeight + AppSpacing.base,
          AppSpacing.screenHorizontal,
          AppSpacing.xxxl + 8,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Title row
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Categories',
                  style: AppTypography.sectionHeaderWhite.copyWith(
                    fontSize: 26,
                  ),
                ),
                // Category count badge
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 5,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.accent.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    '${_categories.length} types',
                    style: AppTypography.caption.copyWith(
                      color: AppColors.accentLight,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 4),

            const Text(
              'Browse our full range of Asian groceries',
              style: AppTypography.sectionSubHeaderWhite,
            ),

            const SizedBox(height: AppSpacing.base),

            // Search bar
            AppSearchBar(
              hint: 'Search categories...',
              readOnly: true,
              onTap: () {
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (_) => const SearchScreen(),
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  // ── Category Grid ────────────────────────────────────────────
  Widget _buildCategoryGrid() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.screenHorizontal,
        AppSpacing.sm,
        AppSpacing.screenHorizontal,
        0,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'All Categories',
            style: AppTypography.h2.copyWith(fontSize: 18),
          ),
          const SizedBox(height: AppSpacing.md),

          // Grid
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 4,
              mainAxisSpacing: 12,
              crossAxisSpacing: 4,
              childAspectRatio: 0.75,
            ),
            itemCount: _categories.length,
            itemBuilder: (context, index) {
              final cat = _categories[index];
              return _CategoryGridItem(
                category: cat,
                onTap: () => _openCategory(cat),
              );
            },
          ),
        ],
      ),
    );
  }

  // ── Diet Filters ─────────────────────────────────────────────
  Widget _buildDietFilters() {
    return Padding(
      padding: const EdgeInsets.only(top: AppSpacing.xl),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.screenHorizontal,
            ),
            child: Text(
              'Shop by Diet',
              style: AppTypography.h2.copyWith(fontSize: 18),
            ),
          ),
          const SizedBox(height: AppSpacing.md),
          SizedBox(
            height: 40,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.screenHorizontal,
              ),
              itemCount: _dietFilters.length,
              separatorBuilder: (_, __) => const SizedBox(width: 8),
              itemBuilder: (context, index) {
                final diet = _dietFilters[index];
                final isSelected = (_selectedDiet == null && diet == 'All') ||
                    _selectedDiet == diet;

                return GestureDetector(
                  onTap: () {
                    setState(() {
                      _selectedDiet = diet == 'All' ? null : diet;
                    });
                  },
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 18,
                      vertical: 8,
                    ),
                    decoration: BoxDecoration(
                      color: isSelected ? AppColors.primary : AppColors.white,
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color:
                            isSelected ? AppColors.primary : AppColors.divider,
                      ),
                    ),
                    child: Text(
                      diet,
                      style: AppTypography.buttonMedium.copyWith(
                        fontSize: 13,
                        color: isSelected
                            ? AppColors.white
                            : AppColors.textSecondary,
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  // ── Popular In Categories ────────────────────────────────────
  Widget _buildPopularSection() {
    // Show a few featured categories with product counts
    final featured = _categories.take(4).toList();

    return Padding(
      padding: const EdgeInsets.only(top: AppSpacing.xl),
      child: Column(
        children: [
          SectionHeader(
            title: 'Popular Categories',
            onViewAll: () {},
          ),
          SizedBox(
            height: 140,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.screenHorizontal,
              ),
              itemCount: featured.length,
              separatorBuilder: (_, __) => const SizedBox(width: 12),
              itemBuilder: (context, index) {
                final cat = featured[index];
                return _PopularCategoryCard(
                  category: cat,
                  onTap: () => _openCategory(cat),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════════
// Category Grid Item
// ═══════════════════════════════════════════════════════════════════
class _CategoryGridItem extends StatelessWidget {
  final Category category;
  final VoidCallback onTap;

  const _CategoryGridItem({
    required this.category,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Circle icon
          Container(
            width: 60,
            height: 60,
            decoration: BoxDecoration(
              color: category.backgroundColor,
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: category.backgroundColor.withOpacity(0.4),
                  blurRadius: 8,
                  offset: const Offset(0, 3),
                ),
              ],
            ),
            child: Center(
              child: Text(
                category.emoji,
                style: const TextStyle(fontSize: 28),
              ),
            ),
          ),

          const SizedBox(height: 8),

          // Label
          Text(
            category.name,
            style: AppTypography.caption.copyWith(
              color: AppColors.textPrimary,
              fontWeight: FontWeight.w500,
              fontSize: 11,
            ),
            textAlign: TextAlign.center,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),

          // Product count
          Text(
            '${category.productCount} items',
            style: AppTypography.caption.copyWith(
              fontSize: 9,
              color: AppColors.textTertiary,
            ),
          ),
        ],
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════════
// Popular Category Card (wide card with gradient)
// ═══════════════════════════════════════════════════════════════════
class _PopularCategoryCard extends StatelessWidget {
  final Category category;
  final VoidCallback onTap;

  const _PopularCategoryCard({
    required this.category,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 200,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(AppSpacing.cardRadius),
          color: category.backgroundColor,
          boxShadow: AppColors.cardShadow,
        ),
        child: Stack(
          children: [
            // Decorative circle
            Positioned(
              right: -15,
              bottom: -15,
              child: Container(
                width: 80,
                height: 80,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.white.withOpacity(0.2),
                ),
              ),
            ),

            // Content
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Emoji
                  Text(
                    category.emoji,
                    style: const TextStyle(fontSize: 36),
                  ),
                  const Spacer(),
                  // Name
                  Text(
                    category.name,
                    style: AppTypography.h3.copyWith(
                      fontSize: 16,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    '${category.productCount} products',
                    style: AppTypography.caption.copyWith(
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
            ),

            // Arrow
            Positioned(
              right: 12,
              bottom: 12,
              child: Container(
                width: 28,
                height: 28,
                decoration: BoxDecoration(
                  color: AppColors.white.withOpacity(0.7),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.arrow_forward_rounded,
                  size: 16,
                  color: AppColors.primary,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Header Clipper ─────────────────────────────────────────────
class _CategoriesHeaderClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    final path = Path();
    path.lineTo(0, size.height - 30);
    path.quadraticBezierTo(
      size.width / 2,
      size.height + 18,
      size.width,
      size.height - 30,
    );
    path.lineTo(size.width, 0);
    path.close();
    return path;
  }

  @override
  bool shouldReclip(covariant CustomClipper<Path> oldClipper) => false;
}
