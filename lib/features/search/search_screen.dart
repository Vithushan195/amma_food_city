import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'dart:async';
import 'package:flutter/material.dart';
import '../../core/theme/theme.dart';
import '../../core/constants/app_constants.dart';
import '../../core/models/models.dart';
import '../../widgets/widgets.dart';
import '../../core/providers/providers.dart';
import '../product/product_detail_screen.dart';

/// Amma Food City — Search Screen
///
/// States:
/// 1. Empty state: Recent searches + trending + popular categories
/// 2. Typing state: Live filtered results as user types (debounced)
/// 3. Results state: Filtered product list with category chips
/// 4. No results state: Suggestions and popular alternatives
class SearchScreen extends ConsumerStatefulWidget {
  const SearchScreen({super.key});

  @override
  ConsumerState<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends ConsumerState<SearchScreen> {
  final TextEditingController _searchController = TextEditingController();
  final FocusNode _focusNode = FocusNode();
  Timer? _debounce;

  String _query = '';
  String? _selectedCategoryFilter;

  // Mock recent searches — will use shared_preferences in production
  final List<String> _recentSearches = [
    'basmati rice',
    'coconut oil',
    'curry leaves',
    'garam masala',
    'mango',
  ];

  // Mock trending searches
  final List<String> _trendingSearches = [
    'Jaffna curry powder',
    'Alphonso mango',
    'Parle-G biscuits',
    'Maggi noodles',
    'Amul paneer',
    'Elephant House cream soda',
  ];

  // All products from data provider
  List<Product> get _allProducts =>
      ref.watch(allProductsProvider).valueOrNull ?? [];

  @override
  void initState() {
    super.initState();
    // Autofocus the search field
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _focusNode.requestFocus();
    });
  }

  @override
  void dispose() {
    _debounce?.cancel();
    _searchController.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  void _onSearchChanged(String value) {
    _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 300), () {
      setState(() {
        _query = value.trim().toLowerCase();
        _selectedCategoryFilter = null;
      });
    });
  }

  void _performSearch(String term) {
    _searchController.text = term;
    _searchController.selection = TextSelection.fromPosition(
      TextPosition(offset: term.length),
    );
    setState(() {
      _query = term.trim().toLowerCase();
      _selectedCategoryFilter = null;
    });

    // Add to recent searches
    _recentSearches.remove(term.toLowerCase());
    _recentSearches.insert(0, term.toLowerCase());
    if (_recentSearches.length > 8) {
      _recentSearches.removeLast();
    }
  }

  void _clearSearch() {
    _searchController.clear();
    setState(() {
      _query = '';
      _selectedCategoryFilter = null;
    });
    _focusNode.requestFocus();
  }

  void _removeRecentSearch(String term) {
    setState(() {
      _recentSearches.remove(term);
    });
  }

  void _clearAllRecent() {
    setState(() {
      _recentSearches.clear();
    });
  }

  List<Product> get _searchResults {
    if (_query.isEmpty) return [];

    var results = _allProducts.where((p) {
      final nameMatch = p.name.toLowerCase().contains(_query);
      final categoryMatch = p.categoryId.toLowerCase().contains(_query);
      final weightMatch = p.weight?.toLowerCase().contains(_query) ?? false;
      return nameMatch || categoryMatch || weightMatch;
    }).toList();

    // Apply category filter
    if (_selectedCategoryFilter != null) {
      results = results
          .where((p) => p.categoryId == _selectedCategoryFilter)
          .toList();
    }

    return results;
  }

  // Unique categories from search results for filter chips
  List<String> get _resultCategories {
    if (_query.isEmpty) return [];
    final cats = _allProducts
        .where((p) {
          final nameMatch = p.name.toLowerCase().contains(_query);
          final categoryMatch = p.categoryId.toLowerCase().contains(_query);
          return nameMatch || categoryMatch;
        })
        .map((p) => p.categoryId)
        .toSet()
        .toList();
    return cats;
  }

  void _updateQty(String productId, int qty) {
    ref.read(cartProvider.notifier).updateQuantity(productId, qty);
  }

  @override
  Widget build(BuildContext context) {
    final statusBarHeight = MediaQuery.of(context).padding.top;

    return Scaffold(
      backgroundColor: AppColors.offWhite,
      body: Column(
        children: [
          // ── SEARCH HEADER ──────────────────────────────────────
          _buildSearchHeader(statusBarHeight),

          // ── CATEGORY FILTER CHIPS (only when results exist) ────
          if (_query.isNotEmpty && _resultCategories.length > 1)
            _buildCategoryFilters(),

          // ── CONTENT ────────────────────────────────────────────
          Expanded(
            child: _query.isEmpty
                ? _buildEmptyState()
                : _searchResults.isEmpty
                    ? _buildNoResults()
                    : _buildSearchResults(),
          ),
        ],
      ),
    );
  }

  // ════════════════════════════════════════════════════════════════
  // SEARCH HEADER
  // ════════════════════════════════════════════════════════════════
  Widget _buildSearchHeader(double statusBarHeight) {
    return Container(
      color: AppColors.white,
      padding: EdgeInsets.fromLTRB(
        AppSpacing.sm,
        statusBarHeight + AppSpacing.sm,
        AppSpacing.screenHorizontal,
        AppSpacing.md,
      ),
      child: Row(
        children: [
          // Back button
          IconButton(
            onPressed: () => Navigator.of(context).pop(),
            icon: const Icon(
              Icons.arrow_back_rounded,
              color: AppColors.textPrimary,
            ),
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints(
              minWidth: 40,
              minHeight: 40,
            ),
          ),

          const SizedBox(width: 4),

          // Search input
          Expanded(
            child: Container(
              height: AppSpacing.searchBarHeight,
              decoration: BoxDecoration(
                color: AppColors.backgroundGrey,
                borderRadius: BorderRadius.circular(
                  AppSpacing.searchBarRadius,
                ),
              ),
              child: Row(
                children: [
                  const SizedBox(width: 14),
                  const Icon(
                    Icons.search_rounded,
                    color: AppColors.textTertiary,
                    size: 22,
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: TextField(
                      controller: _searchController,
                      focusNode: _focusNode,
                      onChanged: _onSearchChanged,
                      onSubmitted: (value) {
                        if (value.trim().isNotEmpty) {
                          _performSearch(value.trim());
                        }
                      },
                      textInputAction: TextInputAction.search,
                      style: AppTypography.bodyMedium,
                      decoration: InputDecoration(
                        hintText: AppStrings.searchHint,
                        hintStyle: AppTypography.bodyMedium.copyWith(
                          color: AppColors.textTertiary,
                        ),
                        border: InputBorder.none,
                        enabledBorder: InputBorder.none,
                        focusedBorder: InputBorder.none,
                        contentPadding: EdgeInsets.zero,
                        isDense: true,
                      ),
                    ),
                  ),

                  // Clear button
                  if (_searchController.text.isNotEmpty)
                    GestureDetector(
                      onTap: _clearSearch,
                      child: Container(
                        padding: const EdgeInsets.all(6),
                        child: Container(
                          width: 20,
                          height: 20,
                          decoration: BoxDecoration(
                            color: AppColors.textTertiary.withOpacity(0.3),
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(
                            Icons.close_rounded,
                            size: 14,
                            color: AppColors.textSecondary,
                          ),
                        ),
                      ),
                    ),

                  const SizedBox(width: 10),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ════════════════════════════════════════════════════════════════
  // CATEGORY FILTER CHIPS
  // ════════════════════════════════════════════════════════════════
  Widget _buildCategoryFilters() {
    return Container(
      color: AppColors.white,
      padding: const EdgeInsets.only(bottom: AppSpacing.md),
      child: SizedBox(
        height: 36,
        child: ListView.separated(
          scrollDirection: Axis.horizontal,
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.screenHorizontal,
          ),
          itemCount: _resultCategories.length + 1, // +1 for "All"
          separatorBuilder: (_, __) => const SizedBox(width: 8),
          itemBuilder: (context, index) {
            if (index == 0) {
              return _FilterChip(
                label: 'All',
                isSelected: _selectedCategoryFilter == null,
                onTap: () {
                  setState(() => _selectedCategoryFilter = null);
                },
              );
            }

            final catId = _resultCategories[index - 1];
            final allCats = ref.watch(categoriesProvider).valueOrNull ?? [];
            final category = allCats.cast<Category>().firstWhere(
                  (c) => c.id == catId,
                  orElse: () => Category(
                    id: catId,
                    name: catId.replaceAll('-', ' '),
                    emoji: '📦',
                  ),
                );

            return _FilterChip(
              label: category.name,
              emoji: category.emoji,
              isSelected: _selectedCategoryFilter == catId,
              onTap: () {
                setState(() {
                  _selectedCategoryFilter =
                      _selectedCategoryFilter == catId ? null : catId;
                });
              },
            );
          },
        ),
      ),
    );
  }

  // ════════════════════════════════════════════════════════════════
  // EMPTY STATE — Recent searches + Trending + Categories
  // ════════════════════════════════════════════════════════════════
  Widget _buildEmptyState() {
    return ListView(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.screenHorizontal,
        vertical: AppSpacing.base,
      ),
      children: [
        // ── Recent Searches ──────────────────────────────────
        if (_recentSearches.isNotEmpty) ...[
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Recent Searches',
                style: AppTypography.h3.copyWith(fontSize: 16),
              ),
              GestureDetector(
                onTap: _clearAllRecent,
                child: Text(
                  'Clear All',
                  style: AppTypography.bodySmall.copyWith(
                    color: AppColors.error,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.md),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: _recentSearches.map((term) {
              return _RecentSearchChip(
                term: term,
                onTap: () => _performSearch(term),
                onRemove: () => _removeRecentSearch(term),
              );
            }).toList(),
          ),
          const SizedBox(height: AppSpacing.xl),
        ],

        // ── Trending Searches ────────────────────────────────
        Text(
          'Trending Now',
          style: AppTypography.h3.copyWith(fontSize: 16),
        ),
        const SizedBox(height: AppSpacing.md),

        ...List.generate(_trendingSearches.length, (index) {
          final term = _trendingSearches[index];
          return _TrendingSearchTile(
            rank: index + 1,
            term: term,
            onTap: () => _performSearch(term),
          );
        }),

        const SizedBox(height: AppSpacing.xl),

        // ── Popular Categories ───────────────────────────────
        Text(
          'Browse by Category',
          style: AppTypography.h3.copyWith(fontSize: 16),
        ),
        const SizedBox(height: AppSpacing.md),

        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 4,
            mainAxisSpacing: 12,
            crossAxisSpacing: 8,
            childAspectRatio: 0.85,
          ),
          itemCount:
              (ref.watch(categoriesProvider).valueOrNull ?? []).take(8).length,
          itemBuilder: (context, index) {
            final cats = ref.watch(categoriesProvider).valueOrNull ?? [];
            if (index >= cats.length) return const SizedBox.shrink();
            final cat = cats[index];
            return GestureDetector(
              onTap: () => _performSearch(cat.name),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 52,
                    height: 52,
                    decoration: BoxDecoration(
                      color: cat.backgroundColor,
                      shape: BoxShape.circle,
                    ),
                    child: Center(
                      child: Text(
                        cat.emoji,
                        style: const TextStyle(fontSize: 24),
                      ),
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    cat.name,
                    style: AppTypography.caption.copyWith(
                      color: AppColors.textPrimary,
                      fontWeight: FontWeight.w500,
                      fontSize: 10,
                    ),
                    textAlign: TextAlign.center,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            );
          },
        ),

        const SizedBox(height: AppSpacing.xxl),
      ],
    );
  }

  // ════════════════════════════════════════════════════════════════
  // SEARCH RESULTS
  // ════════════════════════════════════════════════════════════════
  Widget _buildSearchResults() {
    final results = _searchResults;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Result count
        Padding(
          padding: const EdgeInsets.fromLTRB(
            AppSpacing.screenHorizontal,
            AppSpacing.sm,
            AppSpacing.screenHorizontal,
            AppSpacing.sm,
          ),
          child: Text(
            '${results.length} result${results.length == 1 ? '' : 's'} for "$_query"',
            style: AppTypography.bodySmall.copyWith(
              color: AppColors.textSecondary,
            ),
          ),
        ),

        // Results list
        Expanded(
          child: ListView.separated(
            padding: const EdgeInsets.fromLTRB(
              AppSpacing.screenHorizontal,
              0,
              AppSpacing.screenHorizontal,
              AppSpacing.xxxl,
            ),
            itemCount: results.length,
            separatorBuilder: (_, __) => const SizedBox(height: 10),
            itemBuilder: (context, index) {
              final product = results[index];
              return _SearchResultTile(
                product: product,
                query: _query,
                quantity: ref.watch(cartQuantitiesProvider)[product.id] ?? 0,
                onQtyChanged: (qty) => _updateQty(product.id, qty),
                onTap: () {
                  // Add to recent
                  _performSearch(_query);
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (_) => ProductDetailScreen(product: product),
                    ),
                  );
                },
              );
            },
          ),
        ),
      ],
    );
  }

  // ════════════════════════════════════════════════════════════════
  // NO RESULTS STATE
  // ════════════════════════════════════════════════════════════════
  Widget _buildNoResults() {
    return Padding(
      padding: const EdgeInsets.all(AppSpacing.screenHorizontal),
      child: Column(
        children: [
          const SizedBox(height: 60),

          // Illustration
          Container(
            width: 100,
            height: 100,
            decoration: const BoxDecoration(
              color: AppColors.backgroundGrey,
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.search_off_rounded,
              size: 48,
              color: AppColors.textTertiary,
            ),
          ),

          const SizedBox(height: AppSpacing.xl),

          const Text(
            'No results found',
            style: AppTypography.h2,
          ),

          const SizedBox(height: AppSpacing.sm),

          Text(
            'We couldn\'t find anything for "$_query".\nTry a different search term.',
            style: AppTypography.bodyMedium.copyWith(
              color: AppColors.textSecondary,
              height: 1.5,
            ),
            textAlign: TextAlign.center,
          ),

          const SizedBox(height: AppSpacing.xxl),

          // Suggestions
          Align(
            alignment: Alignment.centerLeft,
            child: Text(
              'Suggestions',
              style: AppTypography.h3.copyWith(fontSize: 16),
            ),
          ),
          const SizedBox(height: AppSpacing.md),

          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: _trendingSearches.take(4).map((term) {
              return GestureDetector(
                onTap: () => _performSearch(term),
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 14,
                    vertical: 8,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.white,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: AppColors.divider),
                  ),
                  child: Text(
                    term,
                    style: AppTypography.bodySmall.copyWith(
                      color: AppColors.textPrimary,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════════
// Filter Chip
// ═══════════════════════════════════════════════════════════════════
class _FilterChip extends StatelessWidget {
  final String label;
  final String? emoji;
  final bool isSelected;
  final VoidCallback onTap;

  const _FilterChip({
    required this.label,
    this.emoji,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.primary : AppColors.white,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(
            color: isSelected ? AppColors.primary : AppColors.divider,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (emoji != null) ...[
              Text(emoji!, style: const TextStyle(fontSize: 14)),
              const SizedBox(width: 5),
            ],
            Text(
              label,
              style: AppTypography.buttonMedium.copyWith(
                fontSize: 12,
                color: isSelected ? AppColors.white : AppColors.textSecondary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════════
// Recent Search Chip (with X remove button)
// ═══════════════════════════════════════════════════════════════════
class _RecentSearchChip extends StatelessWidget {
  final String term;
  final VoidCallback onTap;
  final VoidCallback onRemove;

  const _RecentSearchChip({
    required this.term,
    required this.onTap,
    required this.onRemove,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.only(left: 12, right: 4, top: 6, bottom: 6),
        decoration: BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: AppColors.divider),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(
              Icons.history_rounded,
              size: 14,
              color: AppColors.textTertiary,
            ),
            const SizedBox(width: 6),
            Text(
              term,
              style: AppTypography.bodySmall.copyWith(
                color: AppColors.textPrimary,
                fontWeight: FontWeight.w500,
              ),
            ),
            GestureDetector(
              onTap: onRemove,
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 6,
                  vertical: 2,
                ),
                child: Icon(
                  Icons.close_rounded,
                  size: 14,
                  color: AppColors.textTertiary.withOpacity(0.6),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════════
// Trending Search Tile
// ═══════════════════════════════════════════════════════════════════
class _TrendingSearchTile extends StatelessWidget {
  final int rank;
  final String term;
  final VoidCallback onTap;

  const _TrendingSearchTile({
    required this.rank,
    required this.term,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 10),
        child: Row(
          children: [
            // Rank number
            SizedBox(
              width: 28,
              child: Text(
                '$rank',
                style: AppTypography.h3.copyWith(
                  fontSize: 16,
                  color: rank <= 3 ? AppColors.primary : AppColors.textTertiary,
                  fontWeight: rank <= 3 ? FontWeight.w700 : FontWeight.w500,
                ),
              ),
            ),

            // Trending icon
            Icon(
              Icons.trending_up_rounded,
              size: 18,
              color: rank <= 3 ? AppColors.accent : AppColors.textTertiary,
            ),

            const SizedBox(width: 12),

            // Term
            Expanded(
              child: Text(
                term,
                style: AppTypography.bodyMedium.copyWith(
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),

            // Arrow
            const Icon(
              Icons.north_west_rounded,
              size: 16,
              color: AppColors.textTertiary,
            ),
          ],
        ),
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════════
// Search Result Tile (with highlight matching text)
// ═══════════════════════════════════════════════════════════════════
class _SearchResultTile extends StatelessWidget {
  final Product product;
  final String query;
  final int quantity;
  final ValueChanged<int> onQtyChanged;
  final VoidCallback onTap;

  const _SearchResultTile({
    required this.product,
    required this.query,
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
              width: 68,
              height: 68,
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
                        errorBuilder: (_, __, ___) => _placeholder(),
                      ),
                    )
                  : _placeholder(),
            ),

            const SizedBox(width: 12),

            // Info
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Tag
                  if (product.tag != null)
                    Container(
                      margin: const EdgeInsets.only(bottom: 3),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 6,
                        vertical: 2,
                      ),
                      decoration: BoxDecoration(
                        color: product.tag == 'NEW'
                            ? AppColors.primary
                            : AppColors.accent,
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text(
                        product.tag!,
                        style: AppTypography.caption.copyWith(
                          fontSize: 9,
                          fontWeight: FontWeight.w700,
                          color: product.tag == 'NEW'
                              ? AppColors.white
                              : AppColors.textOnAccent,
                        ),
                      ),
                    ),

                  // Weight
                  if (product.weight != null)
                    Text(product.weight!, style: AppTypography.caption),

                  // Name with highlighted match
                  _HighlightedText(
                    text: product.name,
                    query: query,
                    style: AppTypography.bodyMedium.copyWith(
                      fontWeight: FontWeight.w500,
                    ),
                    highlightColor: AppColors.accentSubtle,
                  ),

                  const SizedBox(height: 4),

                  // Price + rating
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

  Widget _placeholder() {
    return const Center(
      child: Icon(
        Icons.image_outlined,
        color: AppColors.textTertiary,
        size: 28,
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════════
// Text with highlighted query match
// ═══════════════════════════════════════════════════════════════════
class _HighlightedText extends StatelessWidget {
  final String text;
  final String query;
  final TextStyle style;
  final Color highlightColor;

  const _HighlightedText({
    required this.text,
    required this.query,
    required this.style,
    required this.highlightColor,
  });

  @override
  Widget build(BuildContext context) {
    if (query.isEmpty) {
      return Text(text, style: style, maxLines: 2);
    }

    final lowerText = text.toLowerCase();
    final lowerQuery = query.toLowerCase();
    final matchIndex = lowerText.indexOf(lowerQuery);

    if (matchIndex == -1) {
      return Text(text, style: style, maxLines: 2);
    }

    return RichText(
      maxLines: 2,
      overflow: TextOverflow.ellipsis,
      text: TextSpan(
        children: [
          if (matchIndex > 0)
            TextSpan(
              text: text.substring(0, matchIndex),
              style: style,
            ),
          TextSpan(
            text: text.substring(matchIndex, matchIndex + query.length),
            style: style.copyWith(
              backgroundColor: highlightColor,
              fontWeight: FontWeight.w700,
              color: AppColors.primary,
            ),
          ),
          if (matchIndex + query.length < text.length)
            TextSpan(
              text: text.substring(matchIndex + query.length),
              style: style,
            ),
        ],
      ),
    );
  }
}
