import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter/material.dart';
import '../../core/theme/theme.dart';
import '../../core/constants/app_constants.dart';
import '../../core/models/models.dart';
import '../../widgets/widgets.dart';
import '../../core/providers/providers.dart';
import '../product/product_detail_screen.dart';
import '../search/search_screen.dart';
import '../categories/category_detail_screen.dart';
import '../products/product_list_screen.dart';
import '../../features/profile/notifications_screen.dart';
import 'widgets/delivery_slot_banner.dart';
import 'widgets/weekly_deals_section.dart';
import 'widgets/new_arrivals_section.dart';

/// Amma Food City Home Screen
///
/// Layout (top → bottom):
/// 1. Delivery slot banner (NEW)
/// 2. Curved green header: delivery address + search bar + cart badge
/// 3. Category circles (horizontal scroll)
/// 4. Promotional banner carousel
/// 5. Featured Products (horizontal list)
/// 6. Weekly Deals with countdown timer (NEW)
/// 7. Popular Items (horizontal list)
/// 8. New Arrivals with "Added Xd ago" labels (NEW)
/// 9. Special Offers (horizontal list)
class HomeScreen extends ConsumerStatefulWidget {
  final void Function(int tabIndex)? onSwitchTab;

  const HomeScreen({super.key, this.onSwitchTab});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  int get _totalCartItems => ref.watch(cartItemCountProvider);

  void _updateQty(String productId, int qty) {
    ref.read(cartProvider.notifier).updateQuantity(productId, qty);
  }

  void _onProductTap(Product product) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => ProductDetailScreen(product: product),
      ),
    );
  }

  void _onCategoryTap(Category category) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => CategoryDetailScreen(category: category),
      ),
    );
  }

  void _onViewAllFeatured() {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => ProductListScreen(
          title: AppStrings.sectionFeatured,
          keepAliveProvider: featuredProductsDataProvider,
        ),
      ),
    );
  }

  void _onViewAllPopular() {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => ProductListScreen(
          title: AppStrings.sectionPopular,
          keepAliveProvider: popularProductsDataProvider,
        ),
      ),
    );
  }

  void _onViewAllOffers() {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => ProductListScreen(
          title: AppStrings.sectionOffers,
          keepAliveProvider: offerProductsDataProvider,
        ),
      ),
    );
  }

  void _onViewAllWeeklyDeals() {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => ProductListScreen(
          title: 'Weekly Deals',
          keepAliveProvider: weeklyDealsProvider,
        ),
      ),
    );
  }

  void _onViewAllNewArrivals() {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => ProductListScreen(
          title: 'New Arrivals',
          keepAliveProvider: newArrivalsProvider,
        ),
      ),
    );
  }

  void _onViewAllCategories() {
    if (widget.onSwitchTab != null) {
      widget.onSwitchTab!(1);
    }
  }

  void _onCartTap() {
    if (widget.onSwitchTab != null) {
      widget.onSwitchTab!(2);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.offWhite,
      body: CustomScrollView(
        slivers: [
          // ────────────────────────────────────────────────────────
          // 1. DELIVERY SLOT BANNER (NEW)
          // ────────────────────────────────────────────────────────
          SliverToBoxAdapter(
            child: ref.watch(nextDeliverySlotProvider).when(
                  data: (slot) => DeliverySlotBanner(
                    slot: slot,
                    onChangeTap: () {
                      debugPrint('Open delivery slot picker');
                    },
                  ),
                  loading: () => const SizedBox.shrink(),
                  error: (_, __) => const SizedBox.shrink(),
                ),
          ),

          // ────────────────────────────────────────────────────────
          // 2. CURVED HEADER — Address, Search, Cart
          // ────────────────────────────────────────────────────────
          SliverToBoxAdapter(
            child: _buildHeader(context),
          ),

          // ────────────────────────────────────────────────────────
          // 3. CATEGORIES
          // ────────────────────────────────────────────────────────
          SliverToBoxAdapter(
            child: _buildCategoriesSection(),
          ),

          // ────────────────────────────────────────────────────────
          // 4. PROMO BANNERS
          // ────────────────────────────────────────────────────────
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.only(top: AppSpacing.lg),
              child: PromoBannerCarousel(
                banners: ref.watch(promoBannersDataProvider).valueOrNull ?? [],
                onBannerTap: (banner) {
                  debugPrint('Banner tapped: ${banner.title}');
                },
              ),
            ),
          ),

          // ────────────────────────────────────────────────────────
          // 5. FEATURED PRODUCTS
          // ────────────────────────────────────────────────────────
          SliverToBoxAdapter(
            child: Column(
              children: [
                SectionHeader(
                  title: AppStrings.sectionFeatured,
                  onViewAll: _onViewAllFeatured,
                ),
                ref.watch(featuredProductsDataProvider).when(
                      data: (products) => HorizontalProductList(
                        products: products,
                        cartQuantities: ref.watch(cartQuantitiesProvider),
                        onQtyChanged: _updateQty,
                        onProductTap: _onProductTap,
                      ),
                      loading: () => const HorizontalProductList(
                        products: [],
                        showShimmer: true,
                      ),
                      error: (error, _) => _ErrorRow(
                        message: 'Could not load featured products',
                        detail: error.toString(),
                        onRetry: () =>
                            ref.invalidate(featuredProductsDataProvider),
                      ),
                    ),
              ],
            ),
          ),

          // ────────────────────────────────────────────────────────
          // 6. WEEKLY DEALS (NEW)
          // ────────────────────────────────────────────────────────
          SliverToBoxAdapter(
            child: ref.watch(weeklyDealsProvider).when(
                  data: (deals) => WeeklyDealsSection(
                    deals: deals,
                    cartQuantities: ref.watch(cartQuantitiesProvider),
                    onProductTap: _onProductTap,
                    onQtyChanged: _updateQty,
                    onViewAll: _onViewAllWeeklyDeals,
                  ),
                  loading: () => const SizedBox.shrink(),
                  error: (_, __) => const SizedBox.shrink(),
                ),
          ),

          // ────────────────────────────────────────────────────────
          // 7. POPULAR ITEMS
          // ────────────────────────────────────────────────────────
          SliverToBoxAdapter(
            child: Column(
              children: [
                SectionHeader(
                  title: AppStrings.sectionPopular,
                  onViewAll: _onViewAllPopular,
                ),
                ref.watch(popularProductsDataProvider).when(
                      data: (products) => HorizontalProductList(
                        products: products,
                        cartQuantities: ref.watch(cartQuantitiesProvider),
                        onQtyChanged: _updateQty,
                        onProductTap: _onProductTap,
                      ),
                      loading: () => const HorizontalProductList(
                        products: [],
                        showShimmer: true,
                      ),
                      error: (error, _) => _ErrorRow(
                        message: 'Could not load popular items',
                        detail: error.toString(),
                        onRetry: () =>
                            ref.invalidate(popularProductsDataProvider),
                      ),
                    ),
              ],
            ),
          ),

          // ────────────────────────────────────────────────────────
          // 8. NEW ARRIVALS (NEW)
          // ────────────────────────────────────────────────────────
          SliverToBoxAdapter(
            child: ref.watch(newArrivalsProvider).when(
                  data: (arrivals) => NewArrivalsSection(
                    arrivals: arrivals,
                    cartQuantities: ref.watch(cartQuantitiesProvider),
                    onProductTap: _onProductTap,
                    onQtyChanged: _updateQty,
                    onViewAll: _onViewAllNewArrivals,
                  ),
                  loading: () => const SizedBox.shrink(),
                  error: (_, __) => const SizedBox.shrink(),
                ),
          ),

          // ────────────────────────────────────────────────────────
          // 9. SPECIAL OFFERS
          // ────────────────────────────────────────────────────────
          SliverToBoxAdapter(
            child: Column(
              children: [
                SectionHeader(
                  title: AppStrings.sectionOffers,
                  onViewAll: _onViewAllOffers,
                ),
                ref.watch(offerProductsDataProvider).when(
                      data: (products) => HorizontalProductList(
                        products: products,
                        cartQuantities: ref.watch(cartQuantitiesProvider),
                        onQtyChanged: _updateQty,
                        onProductTap: _onProductTap,
                      ),
                      loading: () => const HorizontalProductList(
                        products: [],
                        showShimmer: true,
                      ),
                      error: (error, _) => _ErrorRow(
                        message: 'Could not load offers',
                        detail: error.toString(),
                        onRetry: () =>
                            ref.invalidate(offerProductsDataProvider),
                      ),
                    ),
              ],
            ),
          ),

          // Bottom padding for nav bar clearance
          const SliverToBoxAdapter(
            child: SizedBox(height: AppSpacing.xxxl + AppSpacing.xxl),
          ),
        ],
      ),
    );
  }

  // ── Header Builder ─────────────────────────────────────────────
  Widget _buildHeader(BuildContext context) {
    final statusBarHeight = MediaQuery.of(context).padding.top;

    return ClipPath(
      clipper: _HomeHeaderClipper(),
      child: Container(
        width: double.infinity,
        decoration: const BoxDecoration(
          gradient: AppColors.headerGradient,
        ),
        child: Padding(
          padding: EdgeInsets.fromLTRB(
            AppSpacing.screenHorizontal,
            statusBarHeight + AppSpacing.base,
            AppSpacing.screenHorizontal,
            AppSpacing.xxxl + 10,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Row: Delivery address + Cart badge
              Row(
                children: [
                  Expanded(
                    child: DeliveryAddressBar(
                      address: '3 Clarence St, Paisley',
                      onTap: () {
                        debugPrint('Open address picker');
                      },
                    ),
                  ),
                  const SizedBox(width: 12),
                  IconButton(
                    onPressed: () {
                      Navigator.of(context).push(MaterialPageRoute(
                          builder: (_) => const NotificationsScreen()));
                    },
                    icon: const Icon(
                      Icons.notifications_outlined,
                      color: AppColors.white,
                      size: 24,
                    ),
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(),
                  ),
                  const SizedBox(width: 8),
                  CartBadge(
                    itemCount: _totalCartItems,
                    onTap: _onCartTap,
                  ),
                ],
              ),
              const SizedBox(height: AppSpacing.lg),
              Text(
                'What are you\nlooking for?',
                style: AppTypography.sectionHeaderWhite.copyWith(
                  fontSize: 24,
                  height: 1.2,
                ),
              ),
              const SizedBox(height: AppSpacing.base),
              AppSearchBar(
                hint: AppStrings.searchHint,
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
      ),
    );
  }

  // ── Categories Section Builder ─────────────────────────────────
  Widget _buildCategoriesSection() {
    final categories = ref.watch(categoriesProvider).valueOrNull ?? [];

    return Padding(
      padding: const EdgeInsets.only(top: AppSpacing.sm),
      child: Column(
        children: [
          SectionHeader(
            title: 'Categories',
            onViewAll: _onViewAllCategories,
          ),
          SizedBox(
            height: 100,
            child: categories.isEmpty
                ? const Center(
                    child: SizedBox(
                      width: 24,
                      height: 24,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    ),
                  )
                : ListView.separated(
                    scrollDirection: Axis.horizontal,
                    padding: const EdgeInsets.symmetric(
                      horizontal: AppSpacing.screenHorizontal,
                    ),
                    itemCount: categories.length,
                    separatorBuilder: (_, __) => const SizedBox(width: 4),
                    itemBuilder: (context, index) {
                      final cat = categories[index];
                      return CategoryCircle(
                        label: cat.name,
                        emoji: cat.emoji,
                        backgroundColor: cat.backgroundColor,
                        onTap: () => _onCategoryTap(cat),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}

// ── Custom Header Clipper ──────────────────────────────────────────
class _HomeHeaderClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    final path = Path();
    path.lineTo(0, size.height - 35);
    path.quadraticBezierTo(
      size.width / 2,
      size.height + 20,
      size.width,
      size.height - 35,
    );
    path.lineTo(size.width, 0);
    path.close();
    return path;
  }

  @override
  bool shouldReclip(covariant CustomClipper<Path> oldClipper) => false;
}

// ── Error Row for failed data loads ───────────────────────────────
class _ErrorRow extends StatelessWidget {
  final String message;
  final String? detail;
  final VoidCallback? onRetry;

  const _ErrorRow({
    required this.message,
    this.detail,
    this.onRetry,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.screenHorizontal,
        vertical: AppSpacing.sm,
      ),
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: const Color(0xFFFFF3CD),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: const Color(0xFFFFD93D)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.warning_amber_rounded,
                    size: 18, color: Color(0xFF856404)),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    message,
                    style: AppTypography.bodySmall.copyWith(
                      color: const Color(0xFF856404),
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                if (onRetry != null)
                  GestureDetector(
                    onTap: onRetry,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: const Color(0xFF856404),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        'Retry',
                        style: AppTypography.caption.copyWith(
                          color: AppColors.white,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
              ],
            ),
            if (detail != null) ...[
              const SizedBox(height: 6),
              Text(
                detail!,
                style: AppTypography.caption.copyWith(
                  color: const Color(0xFF856404),
                  fontSize: 10,
                  fontFamily: 'monospace',
                ),
                maxLines: 3,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ],
        ),
      ),
    );
  }
}
