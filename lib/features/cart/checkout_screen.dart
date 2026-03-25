import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/theme/theme.dart';
import '../../core/constants/app_constants.dart';
import '../../core/models/models.dart';
import '../../core/providers/providers.dart';
import '../../widgets/widgets.dart';
import '../orders/order_tracking_screen.dart';

/// Amma Food City — Checkout Screen (Multi-step)
///
/// Steps:
/// 1. Address — select saved address or add new
/// 2. Delivery — pick date + time slot
/// 3. Payment — Card (Stripe) or Cash on Delivery
/// 4. Confirmation — order placed
class CheckoutScreen extends ConsumerStatefulWidget {
  final List<CartItem> cartItems;
  final double subtotal;
  final double discount;
  final double deliveryFee;
  final double total;
  final String? promoCode;

  const CheckoutScreen({
    super.key,
    required this.cartItems,
    required this.subtotal,
    required this.discount,
    required this.deliveryFee,
    required this.total,
    this.promoCode,
  });

  @override
  ConsumerState<CheckoutScreen> createState() => _CheckoutScreenState();
}

class _CheckoutScreenState extends ConsumerState<CheckoutScreen>
    with TickerProviderStateMixin {
  int _currentStep = 0;
  late final PageController _pageController;

  // Step 1: Address
  final List<DeliveryAddress> _addresses = DeliveryAddress.mockAddresses;
  late String _selectedAddressId;

  // Step 2: Delivery
  int _selectedDateIndex = 0;
  int _selectedSlotIndex = -1;

  // Step 3: Payment
  int _selectedPaymentMethod = 0; // 0=card, 1=cash

  // Step 4: Confirmation
  late AnimationController _confettiController;
  late Animation<double> _scaleAnimation;

  final List<String> _stepLabels = [
    'Address',
    'Delivery',
    'Payment',
    'Confirm'
  ];
  late final List<DateTime> _deliveryDates;

  final List<String> _timeSlots = [
    '9:00 - 11:00',
    '11:00 - 13:00',
    '13:00 - 15:00',
    '15:00 - 17:00',
    '17:00 - 19:00',
    '19:00 - 21:00',
  ];

  @override
  void initState() {
    super.initState();
    _pageController = PageController();
    _selectedAddressId = _addresses
        .firstWhere((a) => a.isDefault, orElse: () => _addresses.first)
        .id;
    _deliveryDates =
        List.generate(5, (i) => DateTime.now().add(Duration(days: i)));
    _confettiController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );
    _scaleAnimation =
        CurvedAnimation(parent: _confettiController, curve: Curves.elasticOut);
  }

  @override
  void dispose() {
    _pageController.dispose();
    _confettiController.dispose();
    super.dispose();
  }

  DeliveryAddress get _selectedAddress =>
      _addresses.firstWhere((a) => a.id == _selectedAddressId);

  String get _selectedSlot =>
      _selectedSlotIndex >= 0 ? _timeSlots[_selectedSlotIndex] : 'N/A';

  void _nextStep() {
    if (_currentStep == 1 && _selectedSlotIndex == -1) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select a delivery time slot')),
      );
      return;
    }
    if (_currentStep < 3) {
      setState(() => _currentStep++);
      _pageController.animateToPage(_currentStep,
          duration: const Duration(milliseconds: 350), curve: Curves.easeInOut);
    }
  }

  void _prevStep() {
    if (_currentStep > 0) {
      setState(() => _currentStep--);
      _pageController.animateToPage(_currentStep,
          duration: const Duration(milliseconds: 350), curve: Curves.easeInOut);
    } else {
      Navigator.of(context).pop();
    }
  }

  void _placeOrder() async {
    final paymentNotifier = ref.read(paymentProvider.notifier);

    bool success;
    if (_selectedPaymentMethod == 0) {
      // Card payment via Stripe
      success = await paymentNotifier.processCardPayment(
        address: _selectedAddress,
        deliverySlot: _selectedSlot,
      );
    } else {
      // Cash on delivery
      success = await paymentNotifier.processCashPayment(
        address: _selectedAddress,
        deliverySlot: _selectedSlot,
      );
    }

    if (success && mounted) {
      setState(() => _currentStep = 3);
      _confettiController.forward();
    } else if (mounted) {
      final error = ref.read(paymentProvider).error;
      if (error != null && error != 'Payment cancelled') {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(error)),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final payment = ref.watch(paymentProvider);
    final statusBarHeight = MediaQuery.of(context).padding.top;
    final bottomPadding = MediaQuery.of(context).padding.bottom;

    return Scaffold(
      backgroundColor: AppColors.offWhite,
      body: Column(
        children: [
          // ── App Bar ──────────────────────────────────────────
          Container(
            color: AppColors.white,
            padding: EdgeInsets.fromLTRB(8, statusBarHeight + 4, 16, 12),
            child: Column(
              children: [
                Row(children: [
                  IconButton(
                    onPressed: payment.isComplete ? null : _prevStep,
                    icon: Icon(
                      _currentStep == 0
                          ? Icons.close_rounded
                          : Icons.arrow_back_rounded,
                      color: payment.isComplete
                          ? AppColors.textTertiary
                          : AppColors.textPrimary,
                    ),
                  ),
                  Expanded(
                      child: Text('Checkout',
                          style: AppTypography.h3.copyWith(fontSize: 18),
                          textAlign: TextAlign.center)),
                  const SizedBox(width: 48),
                ]),
                if (!payment.isComplete) ...[
                  const SizedBox(height: 8),
                  _buildStepIndicator(),
                ],
              ],
            ),
          ),

          // ── Pages ────────────────────────────────────────────
          Expanded(
            child: payment.isComplete
                ? _buildConfirmation(payment)
                : PageView(
                    controller: _pageController,
                    physics: const NeverScrollableScrollPhysics(),
                    children: [
                      _buildAddressStep(),
                      _buildDeliveryStep(),
                      _buildPaymentStep(),
                      const SizedBox(),
                    ],
                  ),
          ),

          // ── Bottom Action ────────────────────────────────────
          if (!payment.isComplete)
            Container(
              padding: EdgeInsets.fromLTRB(
                AppSpacing.screenHorizontal,
                AppSpacing.md,
                AppSpacing.screenHorizontal,
                AppSpacing.md + bottomPadding,
              ),
              decoration: BoxDecoration(
                  color: AppColors.white, boxShadow: AppColors.bottomNavShadow),
              child: Row(children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Text('Total', style: AppTypography.caption),
                    SuperscriptPrice(
                        price: widget.total, size: PriceSize.medium),
                  ],
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: LimeCta(
                    label: _currentStep == 2 ? 'Place Order' : 'Continue',
                    icon: _currentStep == 2
                        ? Icons.lock_rounded
                        : Icons.arrow_forward_rounded,
                    isLoading: payment.isProcessing,
                    onTap: payment.isProcessing
                        ? null
                        : (_currentStep == 2 ? _placeOrder : _nextStep),
                  ),
                ),
              ]),
            ),
        ],
      ),
    );
  }

  // ════════════════════════════════════════════════════════════════
  // STEP INDICATOR
  // ════════════════════════════════════════════════════════════════
  Widget _buildStepIndicator() {
    return Row(
      children: List.generate(_stepLabels.length, (index) {
        final isCompleted = index < _currentStep;
        final isCurrent = index == _currentStep;
        return Expanded(
          child: Row(children: [
            if (index > 0)
              Expanded(
                  child: Container(
                      height: 2,
                      color:
                          isCompleted ? AppColors.accent : AppColors.divider)),
            Container(
              width: 28,
              height: 28,
              decoration: BoxDecoration(
                color: isCompleted
                    ? AppColors.accent
                    : isCurrent
                        ? AppColors.primary
                        : AppColors.backgroundGrey,
                shape: BoxShape.circle,
              ),
              child: Center(
                child: isCompleted
                    ? const Icon(Icons.check_rounded,
                        size: 16, color: AppColors.textOnAccent)
                    : Text('${index + 1}',
                        style: AppTypography.caption.copyWith(
                            color: isCurrent
                                ? AppColors.white
                                : AppColors.textTertiary,
                            fontWeight: FontWeight.w700,
                            fontSize: 12)),
              ),
            ),
            if (index < _stepLabels.length - 1)
              Expanded(
                  child: Container(
                      height: 2,
                      color:
                          isCompleted ? AppColors.accent : AppColors.divider)),
          ]),
        );
      }),
    );
  }

  // ════════════════════════════════════════════════════════════════
  // STEP 1: ADDRESS
  // ════════════════════════════════════════════════════════════════
  Widget _buildAddressStep() {
    return ListView(
      padding: const EdgeInsets.all(AppSpacing.screenHorizontal),
      children: [
        Text('Delivery Address',
            style: AppTypography.h2.copyWith(fontSize: 20)),
        const SizedBox(height: 4),
        const Text('Choose where to deliver your order',
            style: AppTypography.bodySmall),
        const SizedBox(height: AppSpacing.lg),
        ...List.generate(_addresses.length, (index) {
          final addr = _addresses[index];
          final isSelected = addr.id == _selectedAddressId;
          return Padding(
            padding: const EdgeInsets.only(bottom: 10),
            child: GestureDetector(
              onTap: () => setState(() => _selectedAddressId = addr.id),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppColors.white,
                  borderRadius:
                      BorderRadius.circular(AppSpacing.cardRadiusSmall),
                  border: Border.all(
                      color: isSelected ? AppColors.primary : AppColors.divider,
                      width: isSelected ? 2 : 1),
                ),
                child: Row(children: [
                  Container(
                    width: 42,
                    height: 42,
                    decoration: BoxDecoration(
                      color: isSelected
                          ? AppColors.accentSubtle
                          : AppColors.backgroundGrey,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(
                      addr.label == 'Home'
                          ? Icons.home_rounded
                          : Icons.business_rounded,
                      color: isSelected
                          ? AppColors.primary
                          : AppColors.textTertiary,
                      size: 22,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                      child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                        Row(children: [
                          Text(addr.label,
                              style: AppTypography.bodyMedium
                                  .copyWith(fontWeight: FontWeight.w600)),
                          if (addr.isDefault) ...[
                            const SizedBox(width: 8),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 6, vertical: 2),
                              decoration: BoxDecoration(
                                  color: AppColors.accentSubtle,
                                  borderRadius: BorderRadius.circular(4)),
                              child: Text('DEFAULT',
                                  style: AppTypography.caption.copyWith(
                                      fontSize: 9,
                                      fontWeight: FontWeight.w700,
                                      color: AppColors.primary)),
                            ),
                          ],
                        ]),
                        const SizedBox(height: 2),
                        Text(addr.fullAddress,
                            style: AppTypography.bodySmall, maxLines: 2),
                      ])),
                  Radio<String>(
                      value: addr.id,
                      groupValue: _selectedAddressId,
                      onChanged: (v) => setState(() => _selectedAddressId = v!),
                      activeColor: AppColors.primary),
                ]),
              ),
            ),
          );
        }),
        const SizedBox(height: AppSpacing.sm),
        GestureDetector(
          onTap: () => debugPrint('Add new address'),
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
                color: AppColors.white,
                borderRadius: BorderRadius.circular(AppSpacing.cardRadiusSmall),
                border: Border.all(color: AppColors.divider)),
            child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [
              const Icon(Icons.add_rounded, color: AppColors.primary, size: 20),
              const SizedBox(width: 8),
              Text('Add New Address',
                  style: AppTypography.buttonMedium
                      .copyWith(color: AppColors.primary)),
            ]),
          ),
        ),
      ],
    );
  }

  // ════════════════════════════════════════════════════════════════
  // STEP 2: DELIVERY SLOT
  // ════════════════════════════════════════════════════════════════
  Widget _buildDeliveryStep() {
    final months = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec'
    ];
    final days = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];

    return ListView(
      padding: const EdgeInsets.all(AppSpacing.screenHorizontal),
      children: [
        Text('Delivery Time', style: AppTypography.h2.copyWith(fontSize: 20)),
        const SizedBox(height: 4),
        const Text('Choose your preferred delivery slot',
            style: AppTypography.bodySmall),
        const SizedBox(height: AppSpacing.lg),
        SizedBox(
          height: 80,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            itemCount: _deliveryDates.length,
            separatorBuilder: (_, __) => const SizedBox(width: 10),
            itemBuilder: (context, index) {
              final date = _deliveryDates[index];
              final isSelected = index == _selectedDateIndex;
              return GestureDetector(
                onTap: () => setState(() {
                  _selectedDateIndex = index;
                  _selectedSlotIndex = -1;
                }),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  width: 64,
                  decoration: BoxDecoration(
                    color: isSelected ? AppColors.primary : AppColors.white,
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(
                        color:
                            isSelected ? AppColors.primary : AppColors.divider),
                  ),
                  child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(index == 0 ? 'Today' : days[date.weekday - 1],
                            style: AppTypography.caption.copyWith(
                                color: isSelected
                                    ? AppColors.accentLight
                                    : AppColors.textSecondary,
                                fontWeight: FontWeight.w500,
                                fontSize: 11)),
                        const SizedBox(height: 4),
                        Text('${date.day}',
                            style: AppTypography.h2.copyWith(
                                fontSize: 22,
                                color: isSelected
                                    ? AppColors.white
                                    : AppColors.textPrimary)),
                        Text(months[date.month - 1],
                            style: AppTypography.caption.copyWith(
                                color: isSelected
                                    ? AppColors.accentLight
                                    : AppColors.textTertiary,
                                fontSize: 10)),
                      ]),
                ),
              );
            },
          ),
        ),
        const SizedBox(height: AppSpacing.xl),
        Text('Available Time Slots',
            style: AppTypography.h3.copyWith(fontSize: 15)),
        const SizedBox(height: AppSpacing.md),
        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              mainAxisSpacing: 10,
              crossAxisSpacing: 10,
              childAspectRatio: 2.8),
          itemCount: _timeSlots.length,
          itemBuilder: (context, index) {
            final isSelected = index == _selectedSlotIndex;
            final isUnavailable = _selectedDateIndex == 0 && index < 2;
            return GestureDetector(
              onTap: isUnavailable
                  ? null
                  : () => setState(() => _selectedSlotIndex = index),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                decoration: BoxDecoration(
                  color: isUnavailable
                      ? AppColors.backgroundGrey
                      : isSelected
                          ? AppColors.primary
                          : AppColors.white,
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(
                      color:
                          isSelected ? AppColors.primary : AppColors.divider),
                ),
                child: Center(
                    child: Text(_timeSlots[index],
                        style: AppTypography.buttonMedium.copyWith(
                            fontSize: 13,
                            color: isUnavailable
                                ? AppColors.textTertiary
                                : isSelected
                                    ? AppColors.white
                                    : AppColors.textPrimary))),
              ),
            );
          },
        ),
      ],
    );
  }

  // ════════════════════════════════════════════════════════════════
  // STEP 3: PAYMENT
  // ════════════════════════════════════════════════════════════════
  Widget _buildPaymentStep() {
    return ListView(
      padding: const EdgeInsets.all(AppSpacing.screenHorizontal),
      children: [
        Text('Payment Method', style: AppTypography.h2.copyWith(fontSize: 20)),
        const SizedBox(height: 4),
        const Text("Choose how you'd like to pay",
            style: AppTypography.bodySmall),
        const SizedBox(height: AppSpacing.lg),
        _PaymentOption(
          icon: Icons.credit_card_rounded,
          title: 'Credit / Debit Card',
          subtitle: 'Pay securely with Stripe',
          isSelected: _selectedPaymentMethod == 0,
          onTap: () => setState(() => _selectedPaymentMethod = 0),
        ),
        const SizedBox(height: 10),
        _PaymentOption(
          icon: Icons.payments_outlined,
          title: 'Cash on Delivery',
          subtitle: 'Pay when your order arrives',
          isSelected: _selectedPaymentMethod == 1,
          onTap: () => setState(() => _selectedPaymentMethod = 1),
        ),
        const SizedBox(height: AppSpacing.xxl),

        // Order summary
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
              color: AppColors.white,
              borderRadius: BorderRadius.circular(AppSpacing.cardRadius),
              boxShadow: AppColors.cardShadow),
          child:
              Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text('Order Summary',
                style: AppTypography.h3.copyWith(fontSize: 15)),
            const SizedBox(height: 12),
            ...widget.cartItems.map((item) => Padding(
                  padding: const EdgeInsets.symmetric(vertical: 4),
                  child: Row(children: [
                    Text('${item.quantity}x',
                        style: AppTypography.bodySmall.copyWith(
                            fontWeight: FontWeight.w600,
                            color: AppColors.primary)),
                    const SizedBox(width: 8),
                    Expanded(
                        child: Text(item.product.name,
                            style: AppTypography.bodySmall,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis)),
                    Text(
                        '${AppStrings.currency}${item.subtotal.toStringAsFixed(2)}',
                        style: AppTypography.bodySmall
                            .copyWith(fontWeight: FontWeight.w600)),
                  ]),
                )),
            const Padding(
                padding: EdgeInsets.symmetric(vertical: 10),
                child: Divider(height: 1)),
            _SummaryRow('Subtotal', widget.subtotal),
            if (widget.discount > 0)
              _SummaryRow('Discount', -widget.discount,
                  color: AppColors.accentDark),
            _SummaryRow('Delivery', widget.deliveryFee,
                isFree: widget.deliveryFee == 0),
            const Padding(
                padding: EdgeInsets.symmetric(vertical: 8),
                child: Divider(height: 1)),
            Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
              Text('Total', style: AppTypography.h3.copyWith(fontSize: 16)),
              Text('${AppStrings.currency}${widget.total.toStringAsFixed(2)}',
                  style: AppTypography.h3
                      .copyWith(fontSize: 18, color: AppColors.primary)),
            ]),
          ]),
        ),

        const SizedBox(height: AppSpacing.lg),
        Row(mainAxisAlignment: MainAxisAlignment.center, children: [
          const Icon(Icons.lock_outlined,
              size: 14, color: AppColors.textTertiary),
          const SizedBox(width: 6),
          Text('Secured by Stripe',
              style: AppTypography.caption
                  .copyWith(color: AppColors.textTertiary)),
        ]),
      ],
    );
  }

  // ════════════════════════════════════════════════════════════════
  // STEP 4: CONFIRMATION
  // ════════════════════════════════════════════════════════════════
  Widget _buildConfirmation(PaymentState payment) {
    final orderNumber = payment.placedOrder?.id ??
        'AMF-${DateTime.now().millisecondsSinceEpoch.toString().substring(7)}';

    return SingleChildScrollView(
      padding: const EdgeInsets.all(AppSpacing.screenHorizontal),
      child: Column(children: [
        const SizedBox(height: 24),
        ScaleTransition(
          scale: _scaleAnimation,
          child: Container(
            width: 100,
            height: 100,
            decoration: const BoxDecoration(
                color: AppColors.accentSubtle, shape: BoxShape.circle),
            child: const Icon(Icons.check_circle_rounded,
                size: 60, color: AppColors.primary),
          ),
        ),
        const SizedBox(height: AppSpacing.xl),
        Text('Order Placed!',
            style: AppTypography.h1.copyWith(
                fontFamily: AppTypography.fontHeading,
                fontSize: 28,
                color: AppColors.primary)),
        const SizedBox(height: 8),
        Text('Your order has been confirmed',
            style: AppTypography.bodyMedium
                .copyWith(color: AppColors.textSecondary)),
        const SizedBox(height: AppSpacing.xxl),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
              color: AppColors.white,
              borderRadius: BorderRadius.circular(AppSpacing.cardRadius),
              boxShadow: AppColors.cardShadow),
          child: Column(children: [
            _DetailRow('Order Number', orderNumber, isBold: true),
            _DetailRow('Delivery To', _selectedAddress.fullAddress),
            _DetailRow('Delivery Slot', _selectedSlot),
            _DetailRow(
                'Payment',
                _selectedPaymentMethod == 0
                    ? 'Card Payment'
                    : 'Cash on Delivery'),
            _DetailRow('Items',
                '${widget.cartItems.fold<int>(0, (s, i) => s + i.quantity)} items'),
            if (payment.paymentIntentId != null)
              _DetailRow('Payment ID', payment.paymentIntentId!),
            const Padding(
                padding: EdgeInsets.symmetric(vertical: 10),
                child: Divider(height: 1)),
            Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
              Text('Total Paid',
                  style: AppTypography.h3.copyWith(fontSize: 16)),
              Text('${AppStrings.currency}${widget.total.toStringAsFixed(2)}',
                  style: AppTypography.h3
                      .copyWith(fontSize: 20, color: AppColors.primary)),
            ]),
          ]),
        ),
        const SizedBox(height: AppSpacing.xl),
        LimeCta(
            label: 'Track My Order',
            icon: Icons.delivery_dining_rounded,
            onTap: () {
              if (payment.placedOrder != null)
                Navigator.of(context).push(MaterialPageRoute(
                    builder: (_) =>
                        OrderTrackingScreen(order: payment.placedOrder!)));
            }),
        const SizedBox(height: AppSpacing.md),
        SizedBox(
          width: double.infinity,
          height: AppSpacing.buttonHeight,
          child: OutlinedButton(
            onPressed: () {
              ref.read(paymentProvider.notifier).reset();
              Navigator.of(context).popUntil((route) => route.isFirst);
            },
            style: OutlinedButton.styleFrom(
                foregroundColor: AppColors.primary,
                side: const BorderSide(color: AppColors.primary, width: 1.5),
                shape: RoundedRectangleBorder(
                    borderRadius:
                        BorderRadius.circular(AppSpacing.buttonRadius))),
            child: const Text('Continue Shopping',
                style: AppTypography.buttonLarge),
          ),
        ),
        const SizedBox(height: AppSpacing.xxxl),
      ]),
    );
  }
}

// ═══════════════════════════════════════════════════════════════
// Helper widgets
// ═══════════════════════════════════════════════════════════════

class _PaymentOption extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final bool isSelected;
  final VoidCallback onTap;

  const _PaymentOption(
      {required this.icon,
      required this.title,
      required this.subtitle,
      required this.isSelected,
      required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.circular(AppSpacing.cardRadiusSmall),
          border: Border.all(
              color: isSelected ? AppColors.primary : AppColors.divider,
              width: isSelected ? 2 : 1),
        ),
        child: Row(children: [
          Container(
            width: 46,
            height: 46,
            decoration: BoxDecoration(
                color: isSelected
                    ? AppColors.accentSubtle
                    : AppColors.backgroundGrey,
                borderRadius: BorderRadius.circular(12)),
            child: Icon(icon,
                color: isSelected ? AppColors.primary : AppColors.textSecondary,
                size: 24),
          ),
          const SizedBox(width: 14),
          Expanded(
              child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                Text(title,
                    style: AppTypography.bodyMedium
                        .copyWith(fontWeight: FontWeight.w600)),
                Text(subtitle, style: AppTypography.caption),
              ])),
          Radio<bool>(
              value: true,
              groupValue: isSelected,
              onChanged: (_) => onTap(),
              activeColor: AppColors.primary),
        ]),
      ),
    );
  }
}

class _SummaryRow extends StatelessWidget {
  final String label;
  final double value;
  final Color? color;
  final bool isFree;
  const _SummaryRow(this.label, this.value, {this.color, this.isFree = false});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 3),
      child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
        Text(label, style: AppTypography.bodySmall),
        isFree
            ? Text('FREE',
                style: AppTypography.caption.copyWith(
                    color: AppColors.primary, fontWeight: FontWeight.w700))
            : Text('${value < 0 ? '-' : ''}£${value.abs().toStringAsFixed(2)}',
                style: AppTypography.bodySmall
                    .copyWith(fontWeight: FontWeight.w600, color: color)),
      ]),
    );
  }
}

class _DetailRow extends StatelessWidget {
  final String label;
  final String value;
  final bool isBold;
  const _DetailRow(this.label, this.value, {this.isBold = false});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
        SizedBox(
            width: 110, child: Text(label, style: AppTypography.bodySmall)),
        Expanded(
            child: Text(value,
                style: AppTypography.bodyMedium.copyWith(
                    fontWeight: isBold ? FontWeight.w700 : FontWeight.w500,
                    color: isBold ? AppColors.primary : null),
                textAlign: TextAlign.right)),
      ]),
    );
  }
}
