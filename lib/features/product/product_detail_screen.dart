import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter/material.dart';
import '../../core/theme/theme.dart';
import '../../core/constants/app_constants.dart';
import '../../core/models/models.dart';
import '../../widgets/widgets.dart';
import '../../core/providers/providers.dart';

/// Amma Food City — Product Detail Screen
///
/// Layout (top → bottom):
/// 1. SliverAppBar with hero product image + back/share/favourite buttons
/// 2. Product info: name, rating, weight selector chips
/// 3. SuperscriptPrice (large) with discount badge
/// 4. Expandable description
/// 5. Nutritional info (collapsible card)
/// 6. "You may also like" horizontal product list
/// 7. Sticky bottom bar: qty control + "Add to Cart" LimeCta
class ProductDetailScreen extends ConsumerStatefulWidget {
  final Product product;

  const ProductDetailScreen({
    super.key,
    required this.product,
  });

  @override
  ConsumerState<ProductDetailScreen> createState() =>
      _ProductDetailScreenState();
}

class _ProductDetailScreenState extends ConsumerState<ProductDetailScreen> {
  int _quantity = 1;
  int _selectedWeightIndex = 0;
  bool _isFavourite = false;
  bool _descriptionExpanded = false;
  bool _nutritionExpanded = false;

  // Mock weight variants — will come from product.variants in Firestore
  late final List<_WeightVariant> _weightVariants;

  @override
  void initState() {
    super.initState();
    _weightVariants = _generateWeightVariants(widget.product);
  }

  // Related products from provider
  List<Product> get _relatedProducts {
    final all = ref.watch(popularProductsDataProvider).valueOrNull ?? [];
    return all.where((p) => p.id != widget.product.id).take(5).toList();
  }

  // Cart quantities for related products section

  double get _currentPrice => _weightVariants[_selectedWeightIndex].price;
  double? get _currentOriginalPrice =>
      _weightVariants[_selectedWeightIndex].originalPrice;
  String get _currentWeight => _weightVariants[_selectedWeightIndex].label;

  @override
  Widget build(BuildContext context) {
    final statusBarHeight = MediaQuery.of(context).padding.top;
    final bottomPadding = MediaQuery.of(context).padding.bottom;

    return Scaffold(
      backgroundColor: AppColors.offWhite,
      body: Stack(
        children: [
          // ── Scrollable Content ────────────────────────────────
          CustomScrollView(
            slivers: [
              // 1. HERO IMAGE
              _buildHeroImage(statusBarHeight),

              // 2-6. PRODUCT INFO
              SliverToBoxAdapter(
                child: Padding(
                  padding: EdgeInsets.only(
                    bottom: 100 + bottomPadding, // space for sticky bar
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildProductInfo(),
                      _buildWeightSelector(),
                      _buildPriceSection(),
                      _buildDescription(),
                      _buildNutritionInfo(),
                      _buildRelatedProducts(),
                    ],
                  ),
                ),
              ),
            ],
          ),

          // 7. STICKY BOTTOM BAR
          _buildStickyBottomBar(bottomPadding),
        ],
      ),
    );
  }

  // ════════════════════════════════════════════════════════════════
  // 1. HERO IMAGE with SliverAppBar
  // ════════════════════════════════════════════════════════════════
  Widget _buildHeroImage(double statusBarHeight) {
    return SliverAppBar(
      expandedHeight: 320,
      pinned: true,
      backgroundColor: AppColors.white,
      elevation: 0,
      leading: _CircleIconButton(
        icon: Icons.arrow_back_rounded,
        onTap: () => Navigator.of(context).pop(),
      ),
      actions: [
        _CircleIconButton(
          icon: Icons.share_outlined,
          onTap: () {
            debugPrint('Share product');
          },
        ),
        const SizedBox(width: 4),
        _CircleIconButton(
          icon: _isFavourite
              ? Icons.favorite_rounded
              : Icons.favorite_outline_rounded,
          iconColor: _isFavourite ? AppColors.error : null,
          onTap: () {
            setState(() => _isFavourite = !_isFavourite);
          },
        ),
        const SizedBox(width: 8),
      ],
      flexibleSpace: FlexibleSpaceBar(
        background: Stack(
          fit: StackFit.expand,
          children: [
            // Product image
            Container(
              color: AppColors.backgroundGrey,
              child: widget.product.imageUrl != null
                  ? Hero(
                      tag: 'product-${widget.product.id}',
                      child: Image.network(
                        widget.product.imageUrl!,
                        fit: BoxFit.contain,
                        errorBuilder: (_, __, ___) => _imagePlaceholder(),
                      ),
                    )
                  : Hero(
                      tag: 'product-${widget.product.id}',
                      child: _imagePlaceholder(),
                    ),
            ),

            // Discount badge
            if (widget.product.hasDiscount)
              Positioned(
                top: statusBarHeight + 56,
                left: 16,
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.error,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    '-${widget.product.discountPercentage.toInt()}%',
                    style: AppTypography.buttonMedium.copyWith(
                      color: AppColors.white,
                      fontSize: 13,
                    ),
                  ),
                ),
              ),

            // Tag badge (BESTSELLER, NEW, etc.)
            if (widget.product.tag != null && !widget.product.hasDiscount)
              Positioned(
                top: statusBarHeight + 56,
                left: 16,
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.accent,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    widget.product.tag!,
                    style: AppTypography.buttonMedium.copyWith(
                      color: AppColors.textOnAccent,
                      fontSize: 12,
                    ),
                  ),
                ),
              ),

            // Bottom curve
            Positioned(
              bottom: -1,
              left: 0,
              right: 0,
              child: Container(
                height: 24,
                decoration: const BoxDecoration(
                  color: AppColors.offWhite,
                  borderRadius: BorderRadius.vertical(
                    top: Radius.circular(24),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ════════════════════════════════════════════════════════════════
  // 2. PRODUCT INFO — Name, rating, category
  // ════════════════════════════════════════════════════════════════
  Widget _buildProductInfo() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.screenHorizontal,
        0,
        AppSpacing.screenHorizontal,
        AppSpacing.sm,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Category chip
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: AppColors.accentSubtle,
              borderRadius: BorderRadius.circular(6),
            ),
            child: Text(
              widget.product.categoryId.replaceAll('-', ' ').toUpperCase(),
              style: AppTypography.caption.copyWith(
                fontWeight: FontWeight.w600,
                color: AppColors.primary,
                letterSpacing: 0.5,
                fontSize: 10,
              ),
            ),
          ),

          const SizedBox(height: AppSpacing.md),

          // Product name
          Text(
            widget.product.name,
            style: AppTypography.h1.copyWith(
              fontFamily: AppTypography.fontHeading,
              fontSize: 26,
              height: 1.2,
            ),
          ),

          const SizedBox(height: AppSpacing.sm),

          // Rating row
          if (widget.product.rating != null)
            Row(
              children: [
                // Stars
                ...List.generate(5, (i) {
                  final rating = widget.product.rating!;
                  if (i < rating.floor()) {
                    return const Icon(Icons.star_rounded,
                        size: 18, color: Color(0xFFFBBF24));
                  } else if (i < rating.ceil() && rating % 1 != 0) {
                    return const Icon(Icons.star_half_rounded,
                        size: 18, color: Color(0xFFFBBF24));
                  }
                  return const Icon(Icons.star_outline_rounded,
                      size: 18, color: AppColors.divider);
                }),
                const SizedBox(width: 8),
                Text(
                  '${widget.product.rating}',
                  style: AppTypography.bodyMedium.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                if (widget.product.reviewCount != null) ...[
                  const SizedBox(width: 4),
                  Text(
                    '(${widget.product.reviewCount} reviews)',
                    style: AppTypography.bodySmall,
                  ),
                ],
              ],
            ),
        ],
      ),
    );
  }

  // ════════════════════════════════════════════════════════════════
  // 3. WEIGHT SELECTOR
  // ════════════════════════════════════════════════════════════════
  Widget _buildWeightSelector() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.screenHorizontal,
        AppSpacing.base,
        AppSpacing.screenHorizontal,
        AppSpacing.sm,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Size / Weight',
            style: AppTypography.label.copyWith(
              fontWeight: FontWeight.w600,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: AppSpacing.sm),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: List.generate(_weightVariants.length, (index) {
              final variant = _weightVariants[index];
              final isSelected = index == _selectedWeightIndex;

              return GestureDetector(
                onTap: () {
                  setState(() => _selectedWeightIndex = index);
                },
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 10,
                  ),
                  decoration: BoxDecoration(
                    color: isSelected ? AppColors.primary : AppColors.white,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: isSelected ? AppColors.primary : AppColors.divider,
                      width: 1.5,
                    ),
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        variant.label,
                        style: AppTypography.bodyMedium.copyWith(
                          fontWeight: FontWeight.w600,
                          color: isSelected
                              ? AppColors.white
                              : AppColors.textPrimary,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        '${AppStrings.currency}${variant.price.toStringAsFixed(2)}',
                        style: AppTypography.caption.copyWith(
                          color: isSelected
                              ? AppColors.accentLight
                              : AppColors.textSecondary,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
              );
            }),
          ),
        ],
      ),
    );
  }

  // ════════════════════════════════════════════════════════════════
  // 4. PRICE SECTION
  // ════════════════════════════════════════════════════════════════
  Widget _buildPriceSection() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.screenHorizontal,
        AppSpacing.base,
        AppSpacing.screenHorizontal,
        AppSpacing.sm,
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          SuperscriptPrice(
            price: _currentPrice,
            originalPrice: _currentOriginalPrice,
            size: PriceSize.large,
          ),
          const SizedBox(width: 12),
          if (widget.product.hasDiscount)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
              decoration: BoxDecoration(
                color: AppColors.error.withOpacity(0.1),
                borderRadius: BorderRadius.circular(6),
              ),
              child: Text(
                'Save ${AppStrings.currency}${(_currentOriginalPrice! - _currentPrice).toStringAsFixed(2)}',
                style: AppTypography.caption.copyWith(
                  color: AppColors.error,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          const Spacer(),
          // Per-unit price
          Text(
            '${AppStrings.currency}${(_currentPrice / _parseWeight(_currentWeight)).toStringAsFixed(2)}/kg',
            style: AppTypography.bodySmall.copyWith(
              color: AppColors.textTertiary,
            ),
          ),
        ],
      ),
    );
  }

  // ════════════════════════════════════════════════════════════════
  // 5. DESCRIPTION (expandable)
  // ════════════════════════════════════════════════════════════════
  Widget _buildDescription() {
    // Mock description — will come from Firestore
    const desc = 'Premium quality product sourced from trusted suppliers. '
        'Carefully selected and packaged to ensure maximum freshness '
        'and authentic taste. Perfect for everyday cooking and special '
        'occasions alike. Our products go through rigorous quality checks '
        'to bring you the very best. Store in a cool, dry place away from '
        'direct sunlight. Once opened, consume within the recommended period '
        'for the best experience.';

    return Padding(
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.screenHorizontal,
        AppSpacing.base,
        AppSpacing.screenHorizontal,
        0,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Divider
          Container(
            height: 1,
            color: AppColors.divider,
            margin: const EdgeInsets.only(bottom: AppSpacing.base),
          ),

          Text(
            'Description',
            style: AppTypography.h3.copyWith(fontSize: 16),
          ),
          const SizedBox(height: AppSpacing.sm),

          AnimatedCrossFade(
            firstChild: Text(
              desc,
              maxLines: 3,
              overflow: TextOverflow.ellipsis,
              style: AppTypography.bodyMedium.copyWith(
                color: AppColors.textSecondary,
                height: 1.6,
              ),
            ),
            secondChild: Text(
              desc,
              style: AppTypography.bodyMedium.copyWith(
                color: AppColors.textSecondary,
                height: 1.6,
              ),
            ),
            crossFadeState: _descriptionExpanded
                ? CrossFadeState.showSecond
                : CrossFadeState.showFirst,
            duration: const Duration(milliseconds: 200),
          ),

          GestureDetector(
            onTap: () {
              setState(() => _descriptionExpanded = !_descriptionExpanded);
            },
            child: Padding(
              padding: const EdgeInsets.only(top: 6),
              child: Text(
                _descriptionExpanded ? 'Read less' : 'Read more',
                style: AppTypography.bodySmall.copyWith(
                  color: AppColors.primary,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ════════════════════════════════════════════════════════════════
  // 6. NUTRITION INFO (collapsible)
  // ════════════════════════════════════════════════════════════════
  Widget _buildNutritionInfo() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.screenHorizontal,
        AppSpacing.lg,
        AppSpacing.screenHorizontal,
        0,
      ),
      child: Container(
        decoration: BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.circular(AppSpacing.cardRadius),
          boxShadow: AppColors.cardShadow,
        ),
        child: Column(
          children: [
            // Header (tappable)
            GestureDetector(
              onTap: () {
                setState(() => _nutritionExpanded = !_nutritionExpanded);
              },
              child: Padding(
                padding: const EdgeInsets.all(AppSpacing.base),
                child: Row(
                  children: [
                    Container(
                      width: 36,
                      height: 36,
                      decoration: BoxDecoration(
                        color: AppColors.accentSubtle,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: const Icon(
                        Icons.info_outline_rounded,
                        color: AppColors.primary,
                        size: 20,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        'Nutritional Information',
                        style: AppTypography.h3.copyWith(fontSize: 15),
                      ),
                    ),
                    AnimatedRotation(
                      turns: _nutritionExpanded ? 0.5 : 0,
                      duration: const Duration(milliseconds: 200),
                      child: const Icon(
                        Icons.keyboard_arrow_down_rounded,
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // Expandable content
            AnimatedCrossFade(
              firstChild: const SizedBox(width: double.infinity),
              secondChild: Padding(
                padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                child: Column(
                  children: [
                    Container(
                      height: 1,
                      color: AppColors.divider,
                      margin: const EdgeInsets.only(bottom: 12),
                    ),
                    // Mock nutrition data
                    ...[
                      ('Energy', '356 kcal'),
                      ('Protein', '8.1g'),
                      ('Carbohydrates', '78g'),
                      ('Fat', '0.6g'),
                      ('Fibre', '1.4g'),
                      ('Salt', '0.01g'),
                    ].map((entry) => Padding(
                          padding: const EdgeInsets.symmetric(vertical: 6),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                entry.$1,
                                style: AppTypography.bodyMedium.copyWith(
                                  color: AppColors.textSecondary,
                                ),
                              ),
                              Text(
                                entry.$2,
                                style: AppTypography.bodyMedium.copyWith(
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ),
                        )),
                    const SizedBox(height: 4),
                    const Text(
                      'Per 100g serving. Values are approximate.',
                      style: AppTypography.caption,
                    ),
                  ],
                ),
              ),
              crossFadeState: _nutritionExpanded
                  ? CrossFadeState.showSecond
                  : CrossFadeState.showFirst,
              duration: const Duration(milliseconds: 200),
            ),
          ],
        ),
      ),
    );
  }

  // ════════════════════════════════════════════════════════════════
  // 7. RELATED PRODUCTS
  // ════════════════════════════════════════════════════════════════
  Widget _buildRelatedProducts() {
    return Padding(
      padding: const EdgeInsets.only(top: AppSpacing.xl),
      child: Column(
        children: [
          SectionHeader(
            title: 'You may also like',
            onViewAll: () {
              debugPrint('View all related');
            },
          ),
          HorizontalProductList(
            products: _relatedProducts,
            cartQuantities: ref.watch(cartQuantitiesProvider),
            onQtyChanged: (id, qty) {
              ref.read(cartProvider.notifier).updateQuantity(id, qty);
            },
            onProductTap: (product) {
              // Navigate to another product detail
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (_) => ProductDetailScreen(product: product),
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  // ════════════════════════════════════════════════════════════════
  // 8. STICKY BOTTOM BAR
  // ════════════════════════════════════════════════════════════════
  Widget _buildStickyBottomBar(double bottomPadding) {
    return Positioned(
      bottom: 0,
      left: 0,
      right: 0,
      child: Container(
        padding: EdgeInsets.fromLTRB(
          AppSpacing.screenHorizontal,
          AppSpacing.md,
          AppSpacing.screenHorizontal,
          AppSpacing.md + bottomPadding,
        ),
        decoration: BoxDecoration(
          color: AppColors.white,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.08),
              blurRadius: 20,
              offset: const Offset(0, -4),
            ),
          ],
        ),
        child: Row(
          children: [
            // Quantity control
            CircularQtyControl(
              quantity: _quantity,
              onChanged: (qty) {
                setState(() {
                  _quantity = qty < 1 ? 1 : qty;
                });
              },
              size: AppSpacing.qtyButtonSizeLarge,
            ),

            const SizedBox(width: AppSpacing.base),

            // Add to Cart button with total
            Expanded(
              child: SizedBox(
                height: AppSpacing.buttonHeight,
                child: ElevatedButton(
                  onPressed: () {
                    ref
                        .read(cartProvider.notifier)
                        .addItem(widget.product, qty: _quantity);
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(
                          'Added $_quantity × ${widget.product.name} to cart',
                        ),
                        action: SnackBarAction(
                          label: 'VIEW CART',
                          textColor: AppColors.accent,
                          onPressed: () {
                            debugPrint('Navigate to cart');
                          },
                        ),
                      ),
                    );
                    Navigator.of(context).pop();
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.accent,
                    foregroundColor: AppColors.textOnAccent,
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(
                        AppSpacing.buttonRadius,
                      ),
                    ),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.shopping_bag_outlined, size: 20),
                      const SizedBox(width: 8),
                      const Text(
                        'Add to Cart',
                        style: AppTypography.buttonLarge,
                      ),
                      const SizedBox(width: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 2,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.black.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          '${AppStrings.currency}${(_currentPrice * _quantity).toStringAsFixed(2)}',
                          style: AppTypography.buttonMedium.copyWith(
                            fontSize: 13,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ── Helpers ──────────────────────────────────────────────────
  Widget _imagePlaceholder() {
    return Center(
      child: Icon(
        Icons.image_outlined,
        size: 80,
        color: AppColors.textTertiary.withOpacity(0.3),
      ),
    );
  }

  double _parseWeight(String weight) {
    final match = RegExp(r'(\d+\.?\d*)').firstMatch(weight);
    if (match == null) return 1;
    double value = double.parse(match.group(1)!);
    if (weight.toLowerCase().contains('g') &&
        !weight.toLowerCase().contains('kg')) {
      value /= 1000;
    }
    return value > 0 ? value : 1;
  }

  List<_WeightVariant> _generateWeightVariants(Product product) {
    // Generate plausible weight variants based on the product
    final baseWeight = product.weight ?? '500g';
    final basePrice = product.price;

    if (baseWeight.contains('kg')) {
      final kg = double.tryParse(
              RegExp(r'(\d+\.?\d*)').firstMatch(baseWeight)?.group(1) ?? '1') ??
          1;
      return [
        _WeightVariant(
          label:
              '${(kg / 2).toStringAsFixed(kg / 2 == (kg / 2).round() ? 0 : 1)} kg',
          price: (basePrice * 0.55).roundToPlaces(2),
          originalPrice: product.originalPrice != null
              ? (product.originalPrice! * 0.55).roundToPlaces(2)
              : null,
        ),
        _WeightVariant(
          label: baseWeight,
          price: basePrice,
          originalPrice: product.originalPrice,
        ),
        _WeightVariant(
          label: '${(kg * 2).toStringAsFixed(0)} kg',
          price: (basePrice * 1.85).roundToPlaces(2),
          originalPrice: product.originalPrice != null
              ? (product.originalPrice! * 1.85).roundToPlaces(2)
              : null,
        ),
      ];
    }

    // Default: generate small/medium/large
    return [
      _WeightVariant(
        label: baseWeight,
        price: basePrice,
        originalPrice: product.originalPrice,
      ),
    ];
  }
}

// ── Circle Icon Button for AppBar ────────────────────────────────
class _CircleIconButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;
  final Color? iconColor;

  const _CircleIconButton({
    required this.icon,
    required this.onTap,
    this.iconColor,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(4),
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: AppColors.white.withOpacity(0.9),
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.08),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Icon(
            icon,
            size: 20,
            color: iconColor ?? AppColors.textPrimary,
          ),
        ),
      ),
    );
  }
}

// ── Weight Variant Model ─────────────────────────────────────────
class _WeightVariant {
  final String label;
  final double price;
  final double? originalPrice;

  const _WeightVariant({
    required this.label,
    required this.price,
    this.originalPrice,
  });
}

// ── Extension for rounding ───────────────────────────────────────
extension _DoubleRound on double {
  double roundToPlaces(int places) {
    final mod = 1.0 * (10 * places);
    return (this * mod).round() / mod;
  }
}
