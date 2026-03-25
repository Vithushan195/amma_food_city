import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/theme/theme.dart';
import '../../core/constants/app_constants.dart';
import '../../core/models/models.dart';
import '../../core/providers/providers.dart';
import '../../widgets/widgets.dart';
import '../auth/login_screen.dart';
import 'checkout_screen.dart';

class CartScreen extends ConsumerStatefulWidget {
  const CartScreen({super.key});
  @override
  ConsumerState<CartScreen> createState() => _CartScreenState();
}

class _CartScreenState extends ConsumerState<CartScreen> {
  final _promoController = TextEditingController();

  @override
  void dispose() {
    _promoController.dispose();
    super.dispose();
  }

  void _removeItem(String productId) {
    final cart = ref.read(cartProvider);
    final removed = cart.items[productId];
    if (removed == null) return;

    ref.read(cartProvider.notifier).removeItem(productId);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('${removed.product.name} removed'),
        action: SnackBarAction(
          label: 'UNDO',
          textColor: AppColors.accent,
          onPressed: () => ref.read(cartProvider.notifier).restoreItem(removed),
        ),
      ),
    );
  }

  void _applyPromo() async {
    final success =
        await ref.read(promoProvider.notifier).applyCode(_promoController.text);
    if (!success && mounted) {
      final error = ref.read(promoProvider).error;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(error ?? 'Invalid promo code. Try AMMA10')),
      );
    }
  }

  void _proceedToCheckout() {
    // Auth guard — guest users must sign in before checkout
    final isAuth = ref.read(authProvider).isAuthenticated;
    if (!isAuth) {
      _showLoginRequiredDialog();
      return;
    }

    final cart = ref.read(cartProvider);
    final promo = ref.read(promoProvider);
    final discount = ref.read(discountAmountProvider);
    final total = ref.read(cartTotalProvider);

    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => CheckoutScreen(
          cartItems: cart.itemList,
          subtotal: cart.subtotal,
          discount: discount,
          deliveryFee: cart.deliveryFee,
          total: total,
          promoCode: promo.code,
        ),
      ),
    );
  }

  void _showLoginRequiredDialog() {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Row(children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: AppColors.accentSubtle,
              borderRadius: BorderRadius.circular(10),
            ),
            child: const Icon(Icons.lock_outline_rounded,
                color: AppColors.primary, size: 22),
          ),
          const SizedBox(width: 12),
          const Text('Sign In Required', style: AppTypography.h3),
        ]),
        content: Text(
          'Please sign in to your account to place an order. This helps us track your delivery and order history.',
          style: AppTypography.bodyMedium
              .copyWith(color: AppColors.textSecondary, height: 1.5),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text('Cancel',
                style: AppTypography.buttonMedium
                    .copyWith(color: AppColors.textSecondary)),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(ctx);
              // Navigate to login screen
              Navigator.of(context).push(
                MaterialPageRoute(
                    builder: (_) => const LoginScreen(showGuestOption: false)),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.accent,
              foregroundColor: AppColors.textOnAccent,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10)),
            ),
            child: const Text('Sign In', style: AppTypography.buttonMedium),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final cart = ref.watch(cartProvider);
    final promo = ref.watch(promoProvider);
    final discount = ref.watch(discountAmountProvider);
    final total = ref.watch(cartTotalProvider);

    if (cart.isEmpty) return _buildEmptyCart();

    final bottomPadding = MediaQuery.of(context).padding.bottom;
    final items = cart.itemList;

    return Scaffold(
      backgroundColor: AppColors.offWhite,
      body: Stack(
        children: [
          CustomScrollView(
            slivers: [
              SliverToBoxAdapter(child: _buildHeader(cart)),
              SliverPadding(
                padding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.screenHorizontal),
                sliver: SliverList(
                  delegate: SliverChildBuilderDelegate(
                    (context, index) => Padding(
                      padding: const EdgeInsets.only(bottom: 10),
                      child: _CartItemTile(
                        item: items[index],
                        onQtyChanged: (qty) => ref
                            .read(cartProvider.notifier)
                            .updateQuantity(items[index].product.id, qty),
                        onRemove: () => _removeItem(items[index].product.id),
                      ),
                    ),
                    childCount: items.length,
                  ),
                ),
              ),
              SliverToBoxAdapter(child: _buildPromoCode(promo)),
              SliverToBoxAdapter(
                  child: _buildPricingSummary(cart, promo, discount, total)),
              SliverToBoxAdapter(child: _buildDeliveryInfo()),
              SliverToBoxAdapter(child: SizedBox(height: 100 + bottomPadding)),
            ],
          ),
          _buildCheckoutButton(bottomPadding, total),
        ],
      ),
    );
  }

  Widget _buildHeader(CartState cart) {
    final statusBarHeight = MediaQuery.of(context).padding.top;
    return ClipPath(
      clipper: _CartHeaderClipper(),
      child: Container(
        width: double.infinity,
        decoration: const BoxDecoration(gradient: AppColors.headerGradient),
        padding: EdgeInsets.fromLTRB(
            AppSpacing.screenHorizontal,
            statusBarHeight + AppSpacing.base,
            AppSpacing.screenHorizontal,
            AppSpacing.xxl + 10),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
              Text('My Cart',
                  style:
                      AppTypography.sectionHeaderWhite.copyWith(fontSize: 26)),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
                decoration: BoxDecoration(
                    color: AppColors.accent.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(12)),
                child: Text('${cart.totalItems} items',
                    style: AppTypography.caption.copyWith(
                        color: AppColors.accentLight,
                        fontWeight: FontWeight.w600)),
              ),
            ]),
            const SizedBox(height: 4),
            Text(
              cart.qualifiesForFreeDelivery
                  ? 'You qualify for free delivery! 🎉'
                  : '£${(30 - cart.subtotal).toStringAsFixed(2)} more for free delivery',
              style: AppTypography.sectionSubHeaderWhite,
            ),
            const SizedBox(height: 12),
            ClipRRect(
              borderRadius: BorderRadius.circular(4),
              child: LinearProgressIndicator(
                value: (cart.subtotal / 30).clamp(0, 1),
                backgroundColor: AppColors.white.withOpacity(0.15),
                valueColor: AlwaysStoppedAnimation<Color>(
                    cart.qualifiesForFreeDelivery
                        ? AppColors.accent
                        : AppColors.accentLight),
                minHeight: 6,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPromoCode(PromoState promo) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(AppSpacing.screenHorizontal,
          AppSpacing.base, AppSpacing.screenHorizontal, 0),
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
            color: AppColors.white,
            borderRadius: BorderRadius.circular(AppSpacing.cardRadiusSmall),
            boxShadow: AppColors.cardShadow),
        child: promo.isApplied
            ? Row(children: [
                Container(
                    width: 36,
                    height: 36,
                    decoration: BoxDecoration(
                        color: AppColors.accentSubtle,
                        borderRadius: BorderRadius.circular(10)),
                    child: const Icon(Icons.local_offer_rounded,
                        color: AppColors.primary, size: 20)),
                const SizedBox(width: 12),
                Expanded(
                    child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                      Text(promo.code!,
                          style: AppTypography.buttonMedium
                              .copyWith(color: AppColors.primary)),
                      Text(
                          '${(promo.discountPercent * 100).toInt()}% discount applied',
                          style: AppTypography.caption
                              .copyWith(color: AppColors.accentDark)),
                    ])),
                GestureDetector(
                    onTap: () => ref.read(promoProvider.notifier).removePromo(),
                    child: const Icon(Icons.close_rounded,
                        color: AppColors.textTertiary, size: 20)),
              ])
            : Row(children: [
                const Icon(Icons.local_offer_outlined,
                    color: AppColors.textTertiary, size: 22),
                const SizedBox(width: 10),
                Expanded(
                    child: TextField(
                  controller: _promoController,
                  textCapitalization: TextCapitalization.characters,
                  style: AppTypography.bodyMedium,
                  decoration: InputDecoration(
                      hintText: 'Enter promo code',
                      hintStyle: AppTypography.bodyMedium
                          .copyWith(color: AppColors.textTertiary),
                      border: InputBorder.none,
                      contentPadding: EdgeInsets.zero,
                      isDense: true),
                )),
                GestureDetector(
                  onTap: promo.isLoading ? null : _applyPromo,
                  child: Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    decoration: BoxDecoration(
                        color: AppColors.primary,
                        borderRadius: BorderRadius.circular(8)),
                    child: promo.isLoading
                        ? const SizedBox(
                            width: 16,
                            height: 16,
                            child: CircularProgressIndicator(
                                strokeWidth: 2, color: AppColors.white))
                        : Text('Apply',
                            style: AppTypography.buttonMedium.copyWith(
                                color: AppColors.white, fontSize: 13)),
                  ),
                ),
              ]),
      ),
    );
  }

  Widget _buildPricingSummary(
      CartState cart, PromoState promo, double discount, double total) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(AppSpacing.screenHorizontal,
          AppSpacing.base, AppSpacing.screenHorizontal, 0),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
            color: AppColors.white,
            borderRadius: BorderRadius.circular(AppSpacing.cardRadius),
            boxShadow: AppColors.cardShadow),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text('Order Summary', style: AppTypography.h3.copyWith(fontSize: 15)),
          const SizedBox(height: 14),
          _PriceRow(
              label: '${AppStrings.cartSubtotal} (${cart.totalItems} items)',
              value: cart.subtotal),
          if (promo.isApplied)
            _PriceRow(
                label: 'Discount (${promo.code})',
                value: -discount,
                valueColor: AppColors.accentDark),
          _PriceRow(
              label: AppStrings.cartDelivery,
              value: cart.deliveryFee,
              isFree: cart.deliveryFee == 0),
          Padding(
              padding: const EdgeInsets.symmetric(vertical: 12),
              child: Container(height: 1, color: AppColors.divider)),
          Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
            Text(AppStrings.cartTotal,
                style: AppTypography.h3.copyWith(fontSize: 17)),
            SuperscriptPrice(price: total, size: PriceSize.large),
          ]),
        ]),
      ),
    );
  }

  Widget _buildDeliveryInfo() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(AppSpacing.screenHorizontal,
          AppSpacing.base, AppSpacing.screenHorizontal, 0),
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
            color: AppColors.accentSubtle.withOpacity(0.5),
            borderRadius: BorderRadius.circular(AppSpacing.cardRadiusSmall)),
        child: Row(children: [
          const Icon(Icons.local_shipping_outlined,
              color: AppColors.primary, size: 22),
          const SizedBox(width: 10),
          Expanded(
              child: Text('Estimated delivery: 30-45 minutes',
                  style: AppTypography.bodySmall.copyWith(
                      color: AppColors.primary, fontWeight: FontWeight.w500))),
        ]),
      ),
    );
  }

  Widget _buildCheckoutButton(double bottomPadding, double total) {
    return Positioned(
      bottom: 0,
      left: 0,
      right: 0,
      child: Container(
        padding: EdgeInsets.fromLTRB(AppSpacing.screenHorizontal, AppSpacing.md,
            AppSpacing.screenHorizontal, AppSpacing.md + bottomPadding),
        decoration: BoxDecoration(
            color: AppColors.white, boxShadow: AppColors.bottomNavShadow),
        child: LimeCta(
          label:
              '${AppStrings.cartCheckout} • ${AppStrings.currency}${total.toStringAsFixed(2)}',
          icon: Icons.arrow_forward_rounded,
          onTap: _proceedToCheckout,
        ),
      ),
    );
  }

  Widget _buildEmptyCart() {
    return Scaffold(
      backgroundColor: AppColors.offWhite,
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.screenHorizontal),
          child: Column(mainAxisSize: MainAxisSize.min, children: [
            Container(
                width: 120,
                height: 120,
                decoration: const BoxDecoration(
                    color: AppColors.backgroundGrey, shape: BoxShape.circle),
                child: Icon(Icons.shopping_bag_outlined,
                    size: 56, color: AppColors.textTertiary.withOpacity(0.4))),
            const SizedBox(height: AppSpacing.xl),
            const Text(AppStrings.cartEmpty, style: AppTypography.h2),
            const SizedBox(height: AppSpacing.sm),
            Text('Looks like you haven\'t added\nanything to your cart yet.',
                style: AppTypography.bodyMedium
                    .copyWith(color: AppColors.textSecondary, height: 1.5),
                textAlign: TextAlign.center),
            const SizedBox(height: AppSpacing.xxl),
            LimeCta.small(
                label: 'Start Shopping',
                icon: Icons.shopping_bag_outlined,
                onTap: () =>
                    Navigator.of(context).popUntil((route) => route.isFirst)),
          ]),
        ),
      ),
    );
  }
}

class _CartItemTile extends StatelessWidget {
  final CartItem item;
  final ValueChanged<int> onQtyChanged;
  final VoidCallback onRemove;
  const _CartItemTile(
      {required this.item, required this.onQtyChanged, required this.onRemove});

  @override
  Widget build(BuildContext context) {
    return Dismissible(
      key: ValueKey(item.product.id),
      direction: DismissDirection.endToStart,
      onDismissed: (_) => onRemove(),
      background: Container(
          alignment: Alignment.centerRight,
          padding: const EdgeInsets.only(right: 20),
          decoration: BoxDecoration(
              color: AppColors.error,
              borderRadius: BorderRadius.circular(AppSpacing.cardRadiusSmall)),
          child: const Icon(Icons.delete_outline_rounded,
              color: AppColors.white, size: 26)),
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
            color: AppColors.white,
            borderRadius: BorderRadius.circular(AppSpacing.cardRadiusSmall),
            boxShadow: AppColors.cardShadow),
        child: Row(children: [
          Container(
              width: 72,
              height: 72,
              decoration: BoxDecoration(
                  color: AppColors.backgroundGrey,
                  borderRadius: BorderRadius.circular(12)),
              child: const Center(
                  child: Icon(Icons.image_outlined,
                      color: AppColors.textTertiary, size: 28))),
          const SizedBox(width: 12),
          Expanded(
              child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                if (item.product.weight != null)
                  Text(item.product.weight!, style: AppTypography.caption),
                Text(item.product.name,
                    style: AppTypography.bodyMedium
                        .copyWith(fontWeight: FontWeight.w500),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis),
                const SizedBox(height: 8),
                Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      SuperscriptPrice(
                          price: item.subtotal, size: PriceSize.small),
                      CircularQtyControl(
                          quantity: item.quantity, onChanged: onQtyChanged),
                    ]),
              ])),
        ]),
      ),
    );
  }
}

class _PriceRow extends StatelessWidget {
  final String label;
  final double value;
  final Color? valueColor;
  final bool isFree;
  const _PriceRow(
      {required this.label,
      required this.value,
      this.valueColor,
      this.isFree = false});
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 5),
      child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
        Text(label,
            style: AppTypography.bodyMedium
                .copyWith(color: AppColors.textSecondary)),
        isFree
            ? Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(
                    color: AppColors.accentSubtle,
                    borderRadius: BorderRadius.circular(6)),
                child: Text('FREE',
                    style: AppTypography.caption.copyWith(
                        color: AppColors.primary, fontWeight: FontWeight.w700)))
            : Text(
                '${value < 0 ? '-' : ''}${AppStrings.currency}${value.abs().toStringAsFixed(2)}',
                style: AppTypography.bodyMedium.copyWith(
                    fontWeight: FontWeight.w600,
                    color: valueColor ?? AppColors.textPrimary)),
      ]),
    );
  }
}

class _CartHeaderClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    final path = Path();
    path.lineTo(0, size.height - 28);
    path.quadraticBezierTo(
        size.width / 2, size.height + 16, size.width, size.height - 28);
    path.lineTo(size.width, 0);
    path.close();
    return path;
  }

  @override
  bool shouldReclip(covariant CustomClipper<Path> oldClipper) => false;
}
