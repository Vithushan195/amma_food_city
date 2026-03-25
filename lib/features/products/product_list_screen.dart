import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/theme/theme.dart';
import '../../core/constants/app_constants.dart';
import '../../core/models/models.dart';
import '../../core/providers/providers.dart';
import '../../widgets/widgets.dart';
import '../product/product_detail_screen.dart';

/// Reusable product list screen — used by "View All" on Home and elsewhere.
///
/// Accepts a [title] and a Riverpod [provider] that supplies `List<Product>`.
/// Shows a grid of products with sort, grid/list toggle, and cart integration.
class ProductListScreen extends ConsumerStatefulWidget {
  final String title;
  final AutoDisposeFutureProvider<List<Product>>? provider;
  final FutureProvider<List<Product>>? keepAliveProvider;

  /// Use [provider] for auto-dispose or [keepAliveProvider] for keep-alive.
  const ProductListScreen({
    super.key,
    required this.title,
    this.provider,
    this.keepAliveProvider,
  }) : assert(provider != null || keepAliveProvider != null,
            'Must provide either provider or keepAliveProvider');

  @override
  ConsumerState<ProductListScreen> createState() => _ProductListScreenState();
}

enum _SortOption { popularity, priceLow, priceHigh, nameAZ, rating }

class _ProductListScreenState extends ConsumerState<ProductListScreen> {
  _SortOption _currentSort = _SortOption.popularity;

  void _updateQty(String productId, int qty) {
    ref.read(cartProvider.notifier).updateQuantity(productId, qty);
  }

  AsyncValue<List<Product>> _watchProducts() {
    if (widget.provider != null) {
      return ref.watch(widget.provider!);
    }
    return ref.watch(widget.keepAliveProvider!);
  }

  void _invalidateProducts() {
    if (widget.provider != null) {
      ref.invalidate(widget.provider!);
    } else {
      ref.invalidate(widget.keepAliveProvider!);
    }
  }

  List<Product> _sort(List<Product> products) {
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
    final productsAsync = _watchProducts();

    return Scaffold(
      backgroundColor: AppColors.offWhite,
      appBar: AppBar(
        backgroundColor: AppColors.primary,
        foregroundColor: AppColors.white,
        elevation: 0,
        title: Text(
          widget.title,
          style: AppTypography.sectionHeaderWhite.copyWith(fontSize: 20),
        ),
        actions: [
          // Sort button
          IconButton(
            onPressed: () => _showSortSheet(context),
            icon: const Icon(Icons.sort_rounded, size: 22),
          ),
        ],
      ),
      body: productsAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, _) => _buildError(error),
        data: (products) {
          if (products.isEmpty) {
            return _buildEmpty();
          }
          final sorted = _sort(products);
          return GridView.builder(
            padding: const EdgeInsets.all(AppSpacing.screenHorizontal),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              mainAxisSpacing: 12,
              crossAxisSpacing: 12,
              childAspectRatio: 0.62,
            ),
            itemCount: sorted.length,
            itemBuilder: (context, index) {
              final product = sorted[index];
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
          );
        },
      ),
    );
  }

  Widget _buildEmpty() {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.inventory_2_outlined, size: 64, color: Colors.grey[300]),
          const SizedBox(height: 16),
          Text(
            'No products found',
            style: AppTypography.bodyMedium.copyWith(
              color: AppColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildError(Object error) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.error_outline_rounded, size: 56, color: Colors.red[300]),
            const SizedBox(height: 16),
            Text(
              'Something went wrong',
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
              onPressed: _invalidateProducts,
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
                  final isSelected = option == _currentSort;
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
                      setState(() => _currentSort = option);
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

  String _sortLabel(_SortOption o) => switch (o) {
        _SortOption.popularity => 'Popularity',
        _SortOption.priceLow => 'Price: Low to High',
        _SortOption.priceHigh => 'Price: High to Low',
        _SortOption.nameAZ => 'Name: A to Z',
        _SortOption.rating => 'Highest Rated',
      };

  IconData _sortIcon(_SortOption o) => switch (o) {
        _SortOption.popularity => Icons.trending_up_rounded,
        _SortOption.priceLow => Icons.arrow_upward_rounded,
        _SortOption.priceHigh => Icons.arrow_downward_rounded,
        _SortOption.nameAZ => Icons.sort_by_alpha_rounded,
        _SortOption.rating => Icons.star_rounded,
      };
}
