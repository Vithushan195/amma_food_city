import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../../core/models/app_order.dart';
import '../../core/models/order_status.dart';
import '../../core/providers/order_tracking_providers.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_typography.dart';
import '../../widgets/superscript_price.dart';
import 'widgets/driver_info_card.dart';
import 'widgets/live_tracking_map.dart';
import 'widgets/order_tracking_timeline.dart';
import 'widgets/order_action_buttons.dart';
import 'revision_confirmation_screen.dart';

/// Real-time order tracking screen — Step 7B.
///
/// Accepts either [orderId] or [order] (for navigation from checkout).
/// Uses Riverpod StreamProvider to listen to Firestore in real-time.
class OrderTrackingScreen extends ConsumerWidget {
  final String? orderId;
  final AppOrder? order;

  const OrderTrackingScreen({
    super.key,
    this.orderId,
    this.order,
  }) : assert(orderId != null || order != null,
            'Either orderId or order must be provided');

  String get _orderId => orderId ?? order!.id;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final orderAsync = ref.watch(orderStreamProvider(_orderId));

    return Scaffold(
      backgroundColor: AppColors.offWhite,
      body: orderAsync.when(
        loading: () => const Center(
          child: CircularProgressIndicator(color: AppColors.primary),
        ),
        error: (err, _) => _ErrorView(error: err.toString()),
        data: (liveOrder) {
          // Use live order if available, fall back to passed-in order
          final displayOrder = liveOrder ?? order;
          if (displayOrder == null) {
            return const _ErrorView(error: 'Order not found');
          }
          return _TrackingBody(order: displayOrder);
        },
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════
// Error view
// ═══════════════════════════════════════════════════════════

class _ErrorView extends StatelessWidget {
  final String error;
  const _ErrorView({required this.error});

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Center(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.error_outline_rounded,
                  size: 56, color: AppColors.textTertiary),
              const SizedBox(height: 16),
              Text(error,
                  textAlign: TextAlign.center,
                  style: AppTypography.bodyMedium
                      .copyWith(color: AppColors.textSecondary)),
              const SizedBox(height: 24),
              TextButton.icon(
                onPressed: () => Navigator.of(context).pop(),
                icon: const Icon(Icons.arrow_back_rounded),
                label: const Text('Go Back'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════
// Main body
// ═══════════════════════════════════════════════════════════

class _TrackingBody extends StatelessWidget {
  final AppOrder order;
  const _TrackingBody({required this.order});

  @override
  Widget build(BuildContext context) {
    final statusMsg = order.statusMessage ?? order.status.customerMessage;

    return CustomScrollView(
      slivers: [
        _Header(order: order, statusMessage: statusMsg),
        SliverPadding(
          padding: const EdgeInsets.only(top: 20, bottom: 40),
          sliver: SliverList(
            delegate: SliverChildListDelegate([
              // ETA banner
              if (order.status.isDeliveryPhase &&
                  order.estimatedMinutes != null)
                _EtaBanner(minutes: order.estimatedMinutes!),

              // Driver card
              if (order.driver != null) ...[
                const SizedBox(height: 16),
                DriverInfoCard(
                  driver: order.driver!,
                  estimatedMinutes: order.status.isDeliveryPhase
                      ? order.estimatedMinutes
                      : null,
                ),
              ],

              // Live map
              if (order.status.isDeliveryPhase) ...[
                const SizedBox(height: 16),
                LiveTrackingMap(driverLocation: order.driverLocation),
              ],

              // Timeline
              const SizedBox(height: 16),
              OrderTrackingTimeline(
                currentStatus: order.status,
                statusHistory: order.statusHistory,
              ),

              // Address
              const SizedBox(height: 16),
              _AddressCard(order: order),

              // Order summary
              const SizedBox(height: 16),
              _OrderSummaryCard(order: order),

              // After _OrderSummaryCard
              const SizedBox(height: 16),
              OrderActionButtons(
                order: order,
                onCancelled: () => Navigator.of(context).pop(),
                onConfirmRevision: () => Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (_) =>
                        RevisionConfirmationScreen(orderId: order.id),
                  ),
                ),
              ),
              const SizedBox(height: 16),
            ]),
          ),
        ),
      ],
    );
  }
}

// ═══════════════════════════════════════════════════════════
// Header
// ═══════════════════════════════════════════════════════════

class _Header extends StatelessWidget {
  final AppOrder order;
  final String statusMessage;
  const _Header({required this.order, required this.statusMessage});

  @override
  Widget build(BuildContext context) {
    final dateFmt = DateFormat('dd MMM yyyy, h:mm a');
    final shortId = order.id.length >= 8
        ? order.id.substring(0, 8).toUpperCase()
        : order.id.toUpperCase();

    return SliverAppBar(
      expandedHeight: 185,
      pinned: true,
      backgroundColor: AppColors.primary,
      leading: IconButton(
        icon: const Icon(Icons.arrow_back_rounded, color: AppColors.white),
        onPressed: () => Navigator.of(context).pop(),
      ),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(bottom: Radius.circular(28)),
      ),
      flexibleSpace: FlexibleSpaceBar(
        background: Container(
          decoration: const BoxDecoration(
            gradient: AppColors.headerGradient,
            borderRadius: BorderRadius.vertical(bottom: Radius.circular(28)),
          ),
          child: SafeArea(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 56, 20, 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Order #$shortId',
                    style: AppTypography.sectionHeaderWhite,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    dateFmt.format(order.createdAt),
                    style: AppTypography.sectionSubHeaderWhite,
                  ),
                  const Spacer(),
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                    decoration: BoxDecoration(
                      color: AppColors.accent,
                      borderRadius: BorderRadius.circular(24),
                    ),
                    child: Text(
                      statusMessage,
                      style: AppTypography.bodySmall.copyWith(
                        color: AppColors.primary,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════
// ETA Banner
// ═══════════════════════════════════════════════════════════

class _EtaBanner extends StatelessWidget {
  final int minutes;
  const _EtaBanner({required this.minutes});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      decoration: BoxDecoration(
        gradient: AppColors.headerGradient,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: AppColors.accent.withOpacity(0.2),
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.access_time_rounded,
                color: AppColors.accent, size: 24),
          ),
          const SizedBox(width: 16),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Estimated Arrival',
                  style: AppTypography.caption
                      .copyWith(color: AppColors.accentLight)),
              const SizedBox(height: 2),
              Text(
                '$minutes minutes',
                style: AppTypography.h1.copyWith(
                  color: AppColors.white,
                  letterSpacing: -0.5,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════
// Address Card
// ═══════════════════════════════════════════════════════════

class _AddressCard extends StatelessWidget {
  final AppOrder order;
  const _AddressCard({required this.order});

  @override
  Widget build(BuildContext context) {
    final addr = order.deliveryAddress;

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: AppColors.cardShadow,
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: AppColors.accentSubtle,
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(Icons.location_on_rounded,
                color: AppColors.primary, size: 22),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Delivery Address', style: AppTypography.caption),
                const SizedBox(height: 4),
                Text(addr.line1,
                    style: AppTypography.bodyMedium
                        .copyWith(fontWeight: FontWeight.w600)),
                if (addr.line2 != null && addr.line2!.isNotEmpty)
                  Text(addr.line2!, style: AppTypography.bodySmall),
                Text('${addr.city}, ${addr.postcode}',
                    style: AppTypography.bodySmall),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════
// Order Summary Card
// ═══════════════════════════════════════════════════════════

class _OrderSummaryCard extends StatelessWidget {
  final AppOrder order;
  const _OrderSummaryCard({required this.order});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: AppColors.cardShadow,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Order Summary',
              style: AppTypography.h3.copyWith(color: AppColors.primary)),
          const SizedBox(height: 12),

          // Items
          ...order.items.map((item) => Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: Row(
                  children: [
                    Container(
                      width: 28,
                      height: 28,
                      decoration: BoxDecoration(
                        color: AppColors.accentSubtle,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      alignment: Alignment.center,
                      child: Text(
                        '${item.quantity}×',
                        style: AppTypography.caption.copyWith(
                          fontWeight: FontWeight.w700,
                          color: AppColors.primary,
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(item.product.name,
                          style: AppTypography.bodyMedium),
                    ),
                    Text(
                      '£${(item.product.price * item.quantity).toStringAsFixed(2)}',
                      style: AppTypography.bodyMedium
                          .copyWith(fontWeight: FontWeight.w600),
                    ),
                  ],
                ),
              )),

          const Divider(height: 24, color: AppColors.divider),

          // Totals
          _row('Subtotal', order.subtotal),
          if (order.discount > 0)
            _row('Discount', -order.discount, color: AppColors.success),
          _row('Delivery', order.deliveryFee),
          const SizedBox(height: 8),

          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Total',
                  style: AppTypography.bodyLarge.copyWith(
                    fontWeight: FontWeight.w700,
                    color: AppColors.primary,
                  )),
              SuperscriptPrice(price: order.total, size: PriceSize.medium),
            ],
          ),
        ],
      ),
    );
  }

  Widget _row(String label, double amount, {Color? color}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: AppTypography.caption),
          Text(
            '${amount < 0 ? '-' : ''}£${amount.abs().toStringAsFixed(2)}',
            style: AppTypography.bodySmall.copyWith(
              color: color ?? AppColors.textSecondary,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}
