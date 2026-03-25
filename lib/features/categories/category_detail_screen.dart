import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter/material.dart';
import '../../core/theme/theme.dart';
import '../../core/constants/app_constants.dart';
import '../../core/models/models.dart';
import '../../widgets/widgets.dart';
import '../../core/providers/providers.dart';
import '../product/product_detail_screen.dart';
import '../search/search_screen.dart';

/// Category Detail Screen — shows filtered products for a single category.
///
/// Layout:
/// 1. Custom app bar with category emoji, name, product count
/// 2. Sort/filter bar (Price, A-Z, Popularity, Rating)
/// 3. Two-column vertical product grid
/// 4. Proper loading / error / empty states
class CategoryDetailScreen extends ConsumerStatefulWidget {
  final Category category;

  const CategoryDetailScreen({
    super.key,
    required this.category,
  });

  @override
  ConsumerState<CategoryDetailScreen> createState() =>
      _CategoryDetailScreenState();
}

enum _SortOption { popularity, priceLow, priceHigh, nameAZ, rating }

class _CategoryDetailScreenState extends ConsumerState<CategoryDetailScreen> {
  _SortOption _currentSort = _SortOption.popularity;
  bool _isGridView = true;

  void _updateQty(String productId, int qty) {
    ref.read(cartProvider.notifier).updateQuantity(productId, qty);
  }

  int get _totalCartItems => ref.watch(cartItemCountProvider);

  List<Product> _sortProducts(List<Product> products) {
    final sorted = List<Product>.from(products);
    switch (_currentSort) {
      case _SortOption.priceLow:
        sorted.sort((a, b) => a.price.compareTo(b.price));
      case _SortOption.priceHigh:
        sorted.sort((a, b) => b.price.compareTo(a.price));
      case _SortOption.nameAZ:
        sorted.sort((a, b) => a.name.compareTo(b.name));
      case _SortOption.rating:
        sorted.sort((a, b) => (b.rating ?? 0).compareTo(a.rating ?? 0));
      case _SortOption.popularity:
        sorted
            .sort((a, b) => (b.reviewCount ?? 0).compareTo(a.reviewCount ?? 0));
    }
    return sorted;
  }

  @override
  Widget build(BuildContext context) {
    final statusBarHeight = MediaQuery.of(context).padding.top;

    // Watch the provider — this gives us loading/error/data states
    final productsAsync =
        ref.watch(categoryProductsDataProvider(widget.category.id));

    return Scaffold(
      backgroundColor: AppColors.offWhite,
      body: CustomScrollView(
        slivers: [
          // ── HEADER ────────────────────────────────────────────
          SliverToBoxAdapter(
            child: _buildHeader(statusBarHeight),
          ),

          // ── CONTENT (loading / error / empty / products) ──────
          ...productsAsync.when(
            loading: () => [
              const SliverFillRemaining(
                hasScrollBody: false,
                child: Center(
                  child: Padding(
                    padding: EdgeInsets.only(bottom: 100),
                    child: CircularProgressIndicator(
                      color: AppColors.primary,
                    ),
                  ),
                ),
              ),
            ],
            error: (error, _) => [
              SliverFillRemaining(
                hasScrollBody: false,
                child: _buildErrorState(error),
              ),
            ],
            data: (products) {
              if (products.isEmpty) {
                return [
                  SliverFillRemaining(
                    hasScrollBody: false,
                    child: _buildEmptyState(),
                  ),
                ];
              }

              final sorted = _sortProducts(products);
              return [
                // Sort bar
                SliverPersistentHeader(
                  pinned: true,
                  delegate: _SortBarDelegate(
                    currentSort: _currentSort,
                    isGridView: _isGridView,
                    productCount: products.length,
                    onSortChanged: (sort) {
                      setState(() => _currentSort = sort);
                    },
                    onViewToggle: () {
                      setState(() => _isGridView = !_isGridView);
                    },
                  ),
                ),
                // Product grid or list
                _isGridView
                    ? _buildProductGrid(sorted)
                    : _buildProductList(sorted),
                // Bottom padding
                const SliverToBoxAdapter(
                  child: SizedBox(height: AppSpacing.xxxl),
                ),
              ];
            },
          ),
        ],
      ),

      // Floating cart indicator
      floatingActionButton:
          _totalCartItems > 0 ? _buildFloatingCartButton() : null,
    );
  }

  // ── Empty State ──────────────────────────────────────────────
  Widget _buildEmptyState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.only(bottom: 100),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                color: widget.category.backgroundColor.withOpacity(0.3),
                shape: BoxShape.circle,
              ),
              child: Center(
                child: Text(
                  widget.category.emoji,
                  style: const TextStyle(fontSize: 36),
                ),
              ),
            ),
            const SizedBox(height: 20),
            Text(
              'No products yet',
              style: AppTypography.h3.copyWith(
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Products for ${widget.category.name} are\ncoming soon!',
              style: AppTypography.bodySmall.copyWith(
                color: AppColors.textSecondary,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            TextButton.icon(
              onPressed: () => ref
                  .invalidate(categoryProductsDataProvider(widget.category.id)),
              icon: const Icon(Icons.refresh_rounded, size: 18),
              label: const Text('Refresh'),
              style: TextButton.styleFrom(
                foregroundColor: AppColors.primary,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ── Error State ──────────────────────────────────────────────
  Widget _buildErrorState(Object error) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.error_outline_rounded, size: 56, color: Colors.red[300]),
            const SizedBox(height: 16),
            Text(
              'Failed to load products',
              style: AppTypography.bodyMedium.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              error.toString(),
              style: AppTypography.caption.copyWith(
                color: AppColors.textTertiary,
                fontFamily: 'monospace',
                fontSize: 10,
              ),
              textAlign: TextAlign.center,
              maxLines: 4,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 20),
            ElevatedButton.icon(
              onPressed: () => ref
                  .invalidate(categoryProductsDataProvider(widget.category.id)),
              icon: const Icon(Icons.refresh_rounded, size: 18),
              label: const Text('Retry'),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: AppColors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ── Header ───────────────────────────────────────────────────
  Widget _buildHeader(double statusBarHeight) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: widget.category.backgroundColor,
      ),
      child: Column(
        children: [
          // App bar row
          Padding(
            padding: EdgeInsets.fromLTRB(
              8,
              statusBarHeight + 4,
              8,
              0,
            ),
            child: Row(
              children: [
                // Back button
                IconButton(
                  onPressed: () => Navigator.of(context).pop(),
                  icon: Container(
                    width: 38,
                    height: 38,
                    decoration: BoxDecoration(
                      color: AppColors.white.withOpacity(0.7),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.arrow_back_rounded,
                      size: 20,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  padding: EdgeInsets.zero,
                ),
                const Spacer(),
                // Search in category
                IconButton(
                  onPressed: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (_) => const SearchScreen(),
                      ),
                    );
                  },
                  icon: Container(
                    width: 38,
                    height: 38,
                    decoration: BoxDecoration(
                      color: AppColors.white.withOpacity(0.7),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.search_rounded,
                      size: 20,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  padding: EdgeInsets.zero,
                ),
              ],
            ),
          ),

          // Category info
          Padding(
            padding: const EdgeInsets.fromLTRB(
              AppSpacing.screenHorizontal,
              AppSpacing.sm,
              AppSpacing.screenHorizontal,
              AppSpacing.xl,
            ),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        widget.category.name,
                        style: AppTypography.h1.copyWith(
                          fontFamily: AppTypography.fontHeading,
                          fontSize: 28,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '${widget.category.productCount} products available',
                        style: AppTypography.bodySmall.copyWith(
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ),
                // Large emoji
                Container(
                  width: 72,
                  height: 72,
                  decoration: BoxDecoration(
                    color: AppColors.white.withOpacity(0.5),
                    shape: BoxShape.circle,
                  ),
                  child: Center(
                    child: Text(
                      widget.category.emoji,
                      style: const TextStyle(fontSize: 40),
                    ),
                  ),
                ),
              ],
            ),
          ),

          // Bottom curve
          Container(
            height: 20,
            decoration: const BoxDecoration(
              color: AppColors.offWhite,
              borderRadius: BorderRadius.vertical(
                top: Radius.circular(20),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ── Product Grid (2 columns) ─────────────────────────────────
  Widget _buildProductGrid(List<Product> products) {
    return SliverPadding(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.screenHorizontal,
      ),
      sliver: SliverGrid(
        delegate: SliverChildBuilderDelegate(
          (context, index) {
            final product = products[index];
            return ProductCard(
              productId: product.id,
              name: product.name,
              imageUrl: product.imageUrl,
              weight: product.weight,
              price: product.price,
              originalPrice: product.originalPrice,
              tag: product.tag,
              quantity: ref.watch(cartQuantitiesProvider)[product.id] ?? 0,
              width: double.infinity,
              onQtyChanged: (qty) => _updateQty(product.id, qty),
              onTap: () {
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (_) => ProductDetailScreen(product: product),
                  ),
                );
              },
            );
          },
          childCount: products.length,
        ),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          mainAxisSpacing: 12,
          crossAxisSpacing: 12,
          childAspectRatio: 0.62,
        ),
      ),
    );
  }

  // ── Product List (single column) ─────────────────────────────
  Widget _buildProductList(List<Product> products) {
    return SliverPadding(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.screenHorizontal,
      ),
      sliver: SliverList(
        delegate: SliverChildBuilderDelegate(
          (context, index) {
            final product = products[index];
            return Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: _ProductListTile(
                product: product,
                quantity: ref.watch(cartQuantitiesProvider)[product.id] ?? 0,
                onQtyChanged: (qty) => _updateQty(product.id, qty),
                onTap: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (_) => ProductDetailScreen(product: product),
                    ),
                  );
                },
              ),
            );
          },
          childCount: products.length,
        ),
      ),
    );
  }

  // ── Floating Cart Button ─────────────────────────────────────
  Widget _buildFloatingCartButton() {
    final cartState = ref.watch(cartProvider);
    final total = cartState.subtotal;

    return Container(
      height: 52,
      padding: const EdgeInsets.symmetric(horizontal: 4),
      decoration: BoxDecoration(
        color: AppColors.primary,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withOpacity(0.3),
            blurRadius: 16,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const SizedBox(width: 14),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
            decoration: BoxDecoration(
              color: AppColors.accent,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Text(
              '$_totalCartItems',
              style: AppTypography.badge.copyWith(
                color: AppColors.textOnAccent,
                fontSize: 12,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
          const SizedBox(width: 10),
          Text(
            'View Cart',
            style: AppTypography.buttonMedium.copyWith(
              color: AppColors.white,
            ),
          ),
          const SizedBox(width: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: AppColors.white.withOpacity(0.15),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              '${AppStrings.currency}${total.toStringAsFixed(2)}',
              style: AppTypography.buttonMedium.copyWith(
                color: AppColors.accent,
                fontSize: 13,
              ),
            ),
          ),
          const SizedBox(width: 14),
        ],
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════════
// Sort Bar — Persistent Header Delegate (sticky)
// ═══════════════════════════════════════════════════════════════════
class _SortBarDelegate extends SliverPersistentHeaderDelegate {
  final _SortOption currentSort;
  final bool isGridView;
  final int productCount;
  final ValueChanged<_SortOption> onSortChanged;
  final VoidCallback onViewToggle;

  _SortBarDelegate({
    required this.currentSort,
    required this.isGridView,
    required this.productCount,
    required this.onSortChanged,
    required this.onViewToggle,
  });

  @override
  double get minExtent => 56;
  @override
  double get maxExtent => 56;

  @override
  Widget build(
      BuildContext context, double shrinkOffset, bool overlapsContent) {
    return Container(
      color: AppColors.offWhite,
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.screenHorizontal,
      ),
      child: Row(
        children: [
          GestureDetector(
            onTap: () => _showSortSheet(context),
            child: Container(
              padding: const EdgeInsets.symmetric(
                horizontal: 12,
                vertical: 8,
              ),
              decoration: BoxDecoration(
                color: AppColors.white,
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: AppColors.divider),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.sort_rounded,
                      size: 18, color: AppColors.primary),
                  const SizedBox(width: 6),
                  Text(
                    _sortLabel(currentSort),
                    style: AppTypography.buttonMedium.copyWith(
                      fontSize: 12,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(width: 4),
                  const Icon(Icons.keyboard_arrow_down_rounded,
                      size: 16, color: AppColors.textSecondary),
                ],
              ),
            ),
          ),
          const Spacer(),
          Text('$productCount items', style: AppTypography.bodySmall),
          const SizedBox(width: 12),
          GestureDetector(
            onTap: onViewToggle,
            child: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: AppColors.white,
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: AppColors.divider),
              ),
              child: Icon(
                isGridView ? Icons.view_list_rounded : Icons.grid_view_rounded,
                size: 18,
                color: AppColors.primary,
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showSortSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(20, 16, 20, 20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: Container(
                    width: 40,
                    height: 4,
                    decoration: BoxDecoration(
                      color: AppColors.divider,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                const Text('Sort by', style: AppTypography.h2),
                const SizedBox(height: 16),
                ..._SortOption.values.map((option) {
                  final isSelected = option == currentSort;
                  return ListTile(
                    contentPadding: EdgeInsets.zero,
                    leading: Icon(
                      _sortIcon(option),
                      color: isSelected
                          ? AppColors.primary
                          : AppColors.textSecondary,
                      size: 22,
                    ),
                    title: Text(
                      _sortLabel(option),
                      style: AppTypography.bodyMedium.copyWith(
                        fontWeight:
                            isSelected ? FontWeight.w600 : FontWeight.w400,
                        color: isSelected
                            ? AppColors.primary
                            : AppColors.textPrimary,
                      ),
                    ),
                    trailing: isSelected
                        ? const Icon(Icons.check_circle_rounded,
                            color: AppColors.accent, size: 22)
                        : null,
                    onTap: () {
                      onSortChanged(option);
                      Navigator.pop(ctx);
                    },
                  );
                }),
              ],
            ),
          ),
        );
      },
    );
  }

  String _sortLabel(_SortOption option) => switch (option) {
        _SortOption.popularity => 'Popularity',
        _SortOption.priceLow => 'Price: Low to High',
        _SortOption.priceHigh => 'Price: High to Low',
        _SortOption.nameAZ => 'Name: A to Z',
        _SortOption.rating => 'Highest Rated',
      };

  IconData _sortIcon(_SortOption option) => switch (option) {
        _SortOption.popularity => Icons.trending_up_rounded,
        _SortOption.priceLow => Icons.arrow_upward_rounded,
        _SortOption.priceHigh => Icons.arrow_downward_rounded,
        _SortOption.nameAZ => Icons.sort_by_alpha_rounded,
        _SortOption.rating => Icons.star_rounded,
      };

  @override
  bool shouldRebuild(covariant _SortBarDelegate oldDelegate) =>
      currentSort != oldDelegate.currentSort ||
      isGridView != oldDelegate.isGridView ||
      productCount != oldDelegate.productCount;
}

// ═══════════════════════════════════════════════════════════════════
// Product List Tile (for list view mode)
// ═══════════════════════════════════════════════════════════════════
class _ProductListTile extends StatelessWidget {
  final Product product;
  final int quantity;
  final ValueChanged<int> onQtyChanged;
  final VoidCallback onTap;

  const _ProductListTile({
    required this.product,
    required this.quantity,
    required this.onQtyChanged,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.circular(AppSpacing.cardRadiusSmall),
          boxShadow: AppColors.cardShadow,
        ),
        child: Row(
          children: [
            // Image
            Container(
              width: 72,
              height: 72,
              decoration: BoxDecoration(
                color: AppColors.backgroundGrey,
                borderRadius: BorderRadius.circular(12),
              ),
              child: product.imageUrl != null
                  ? ClipRRect(
                      borderRadius: BorderRadius.circular(12),
                      child: Image.network(
                        product.imageUrl!,
                        fit: BoxFit.cover,
                        errorBuilder: (_, __, ___) => const Center(
                          child: Icon(Icons.image_outlined,
                              color: AppColors.textTertiary, size: 28),
                        ),
                      ),
                    )
                  : const Center(
                      child: Icon(Icons.image_outlined,
                          color: AppColors.textTertiary, size: 28),
                    ),
            ),

            const SizedBox(width: 12),

            // Info
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (product.weight != null)
                    Text(product.weight!, style: AppTypography.caption),
                  Text(
                    product.name,
                    style: AppTypography.bodyMedium.copyWith(
                      fontWeight: FontWeight.w500,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      SuperscriptPrice(
                        price: product.price,
                        originalPrice: product.originalPrice,
                        size: PriceSize.small,
                      ),
                      if (product.rating != null) ...[
                        const Spacer(),
                        const Icon(Icons.star_rounded,
                            size: 14, color: Color(0xFFFBBF24)),
                        const SizedBox(width: 2),
                        Text(
                          '${product.rating}',
                          style: AppTypography.caption.copyWith(
                            fontWeight: FontWeight.w600,
                            color: AppColors.textPrimary,
                          ),
                        ),
                      ],
                    ],
                  ),
                ],
              ),
            ),

            const SizedBox(width: 8),

            // Qty control
            CircularQtyControl(
              quantity: quantity,
              onChanged: onQtyChanged,
            ),
          ],
        ),
      ),
    );
  }
}
