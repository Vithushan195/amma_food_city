import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter/material.dart';
import '../../core/theme/theme.dart';
import '../../core/constants/app_constants.dart';
import '../../core/models/models.dart';
import '../../widgets/widgets.dart';
import '../../core/providers/providers.dart';
import '../../core/providers/order_tracking_providers.dart';

import 'widgets/status_chip_data.dart';
import 'widgets/order_action_buttons.dart';
import 'revision_confirmation_screen.dart';
import 'order_tracking_screen.dart';

/// Amma Food City — Order Detail Screen (Live Listener Fix)
///
/// Now uses orderStreamProvider for real-time Firestore updates.
/// No more crashes when admin changes status while customer views this screen.
class OrderDetailScreen extends ConsumerWidget {
  /// Pass either an AppOrder object (for initial data) or just an orderId.
  final AppOrder? order;
  final String? orderId;

  const OrderDetailScreen({super.key, this.order, this.orderId})
      : assert(order != null || orderId != null);

  String get _orderId => orderId ?? order!.id;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Use real-time stream — updates when admin changes status
    final orderAsync = ref.watch(orderStreamProvider(_orderId));

    return Scaffold(
      backgroundColor: AppColors.offWhite,
      body: orderAsync.when(
        loading: () {
          // Show initial data while loading stream
          if (order != null) {
            return _OrderDetailBody(order: order!);
          }
          return const Center(
            child: CircularProgressIndicator(color: AppColors.primary),
          );
        },
        error: (err, _) => SafeArea(
          child: Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.error_outline,
                    size: 48, color: AppColors.textTertiary),
                const SizedBox(height: 12),
                Text('Error: $err', style: AppTypography.bodySmall),
                const SizedBox(height: 16),
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('Go Back'),
                ),
              ],
            ),
          ),
        ),
        data: (liveOrder) {
          final displayOrder = liveOrder ?? order;
          if (displayOrder == null) {
            return const Center(child: Text('Order not found'));
          }
          return _OrderDetailBody(order: displayOrder);
        },
      ),
    );
  }
}

/// The actual order detail content — extracted so it rebuilds on every stream update
class _OrderDetailBody extends ConsumerWidget {
  final AppOrder order;
  const _OrderDetailBody({required this.order});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final statusBarHeight = MediaQuery.of(context).padding.top;

    return Column(
      children: [
        // ── App Bar ────────────────────────────────────────
        Container(
          color: AppColors.white,
          padding: EdgeInsets.fromLTRB(8, statusBarHeight + 4, 16, 12),
          child: Row(
            children: [
              IconButton(
                onPressed: () => Navigator.pop(context),
                icon: const Icon(Icons.arrow_back_rounded),
              ),
              Expanded(
                child: Column(
                  children: [
                    Text(
                      'Order ${order.id.length > 8 ? order.id.substring(0, 8).toUpperCase() : order.id}',
                      style: AppTypography.h3.copyWith(fontSize: 16),
                    ),
                    Text(
                      _formatFullDate(order.createdAt),
                      style: AppTypography.caption,
                    ),
                  ],
                ),
              ),
              // Live status chip
              _StatusChipSmall(status: order.status),
            ],
          ),
        ),

        // ── Content ────────────────────────────────────────
        Expanded(
          child: ListView(
            padding: const EdgeInsets.all(AppSpacing.screenHorizontal),
            children: [
              // ── Status Timeline ─────────────────────────
              _buildTimeline(context),

              const SizedBox(height: AppSpacing.xl),

              // ── Track Order button (delivery phase) ─────
              if (order.status.isDeliveryPhase)
                Padding(
                  padding: const EdgeInsets.only(bottom: AppSpacing.base),
                  child: LimeCta(
                    label: 'Track Order Live',
                    icon: Icons.map_rounded,
                    onTap: () {
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (_) =>
                              OrderTrackingScreen(orderId: order.id),
                        ),
                      );
                    },
                  ),
                ),

              // ── Delivery Info ───────────────────────────
              _buildInfoCard(
                title: 'Delivery Details',
                children: [
                  _InfoRow(
                    icon: Icons.location_on_outlined,
                    label: 'Address',
                    value: order.deliveryAddress.fullAddress,
                  ),
                  _InfoRow(
                    icon: Icons.schedule_rounded,
                    label: 'Time Slot',
                    value: order.deliverySlot,
                  ),
                  _InfoRow(
                    icon: Icons.payment_rounded,
                    label: 'Payment',
                    value: order.paymentMethod,
                  ),
                ],
              ),

              const SizedBox(height: AppSpacing.base),

              // ── Items ───────────────────────────────────
              _buildInfoCard(
                title: 'Items (${order.itemCount})',
                children: [
                  ...order.items.map((item) => Padding(
                        padding: const EdgeInsets.symmetric(vertical: 8),
                        child: Row(
                          children: [
                            Container(
                              width: 48,
                              height: 48,
                              decoration: BoxDecoration(
                                color: AppColors.backgroundGrey,
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: const Center(
                                child: Icon(Icons.image_outlined,
                                    size: 22, color: AppColors.textTertiary),
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    item.product.name,
                                    style: AppTypography.bodyMedium.copyWith(
                                      fontWeight: FontWeight.w500,
                                    ),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                  Text(
                                    '${item.product.weight ?? ''} × ${item.quantity}',
                                    style: AppTypography.caption,
                                  ),
                                ],
                              ),
                            ),
                            Text(
                              '${AppStrings.currency}${item.subtotal.toStringAsFixed(2)}',
                              style: AppTypography.bodyMedium.copyWith(
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      )),
                ],
              ),

              const SizedBox(height: AppSpacing.base),

              // ── Payment Summary ─────────────────────────
              _buildInfoCard(
                title: 'Payment Summary',
                children: [
                  _SummaryLine('Subtotal',
                      '${AppStrings.currency}${order.subtotal.toStringAsFixed(2)}'),
                  if (order.discount > 0)
                    _SummaryLine(
                      'Discount${order.promoCode != null ? ' (${order.promoCode})' : ''}',
                      '-${AppStrings.currency}${order.discount.toStringAsFixed(2)}',
                      valueColor: AppColors.accentDark,
                    ),
                  _SummaryLine(
                    'Delivery',
                    order.deliveryFee == 0
                        ? 'FREE'
                        : '${AppStrings.currency}${order.deliveryFee.toStringAsFixed(2)}',
                    valueColor:
                        order.deliveryFee == 0 ? AppColors.primary : null,
                  ),
                  const Padding(
                    padding: EdgeInsets.symmetric(vertical: 8),
                    child: Divider(height: 1),
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('Total',
                          style: AppTypography.h3.copyWith(fontSize: 16)),
                      SuperscriptPrice(
                        price: order.total,
                        size: PriceSize.medium,
                      ),
                    ],
                  ),
                ],
              ),

              // ── Cancel info ───────────────────────────
              if (order.status == OrderStatus.cancelled &&
                  order.cancelReason != null)
                Padding(
                  padding: const EdgeInsets.only(top: AppSpacing.base),
                  child: Container(
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF8D7DA),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.info_outline_rounded,
                            color: Color(0xFF721C24), size: 20),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Cancelled${order.cancelledBy != null ? " by ${order.cancelledBy}" : ""}',
                                style: AppTypography.bodySmall.copyWith(
                                  fontWeight: FontWeight.w600,
                                  color: const Color(0xFF721C24),
                                ),
                              ),
                              Text(
                                order.cancelReason!,
                                style: AppTypography.caption.copyWith(
                                  color: const Color(0xFF721C24),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

              const SizedBox(height: AppSpacing.xl),

              // ── Reorder (delivered) ────────────────────
              if (order.status == OrderStatus.delivered)
                LimeCta(
                  label: 'Reorder',
                  icon: Icons.replay_rounded,
                  onTap: () {
                    ref.read(ordersProvider.notifier).reorder(order);
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Items added to cart')),
                    );
                  },
                ),

              // ── Action buttons (cancel/confirm/contact) ─
              OrderActionButtons(
                order: order,
                onCancelled: () => Navigator.pop(context),
                onConfirmRevision: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (_) =>
                          RevisionConfirmationScreen(orderId: order.id),
                    ),
                  );
                },
              ),

              const SizedBox(height: AppSpacing.xxxl),
            ],
          ),
        ),
      ],
    );
  }

  // ── Timeline ────────────────────────────────────────────────
  Widget _buildTimeline(BuildContext context) {
    final steps = [
      ('Order Placed', OrderStatus.pending, Icons.receipt_long_rounded),
      ('Under Review', OrderStatus.reviewing, Icons.search_rounded),
      (
        'Awaiting Confirmation',
        OrderStatus.awaitingConfirmation,
        Icons.edit_note_rounded
      ),
      ('Confirmed', OrderStatus.confirmed, Icons.check_circle_outline_rounded),
      ('Preparing', OrderStatus.preparing, Icons.restaurant_rounded),
      ('Driver Assigned', OrderStatus.driverAssigned, Icons.person_rounded),
      ('Driver at Store', OrderStatus.driverAtStore, Icons.store_rounded),
      (
        'Out for Delivery',
        OrderStatus.outForDelivery,
        Icons.delivery_dining_rounded
      ),
      ('Arriving', OrderStatus.arriving, Icons.near_me_rounded),
      ('Delivered', OrderStatus.delivered, Icons.home_rounded),
    ];

    final currentIdx = order.status == OrderStatus.cancelled
        ? -1
        : steps.indexWhere((s) => s.$2 == order.status);

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(AppSpacing.cardRadius),
        boxShadow: AppColors.cardShadow,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Order Status', style: AppTypography.h3.copyWith(fontSize: 15)),
          const SizedBox(height: 16),
          if (order.status == OrderStatus.cancelled)
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: const Color(0xFFF8D7DA),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                children: [
                  const Icon(Icons.cancel_outlined,
                      color: Color(0xFF721C24), size: 24),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Order Cancelled',
                            style: AppTypography.bodyMedium.copyWith(
                              fontWeight: FontWeight.w600,
                              color: const Color(0xFF721C24),
                            )),
                        Text(
                          order.cancelReason ?? 'This order has been cancelled',
                          style: AppTypography.caption.copyWith(
                            color: const Color(0xFF721C24),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            )
          else
            ...List.generate(steps.length, (index) {
              final (label, status, icon) = steps[index];
              final isCompleted = index <= currentIdx;
              final isCurrent = index == currentIdx;
              final isLast = index == steps.length - 1;
              final needsAction = isCurrent && status.needsCustomerAction;

              return Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(
                    width: 36,
                    child: Column(
                      children: [
                        Container(
                          width: 32,
                          height: 32,
                          decoration: BoxDecoration(
                            color: isCompleted
                                ? isCurrent
                                    ? needsAction
                                        ? const Color(0xFFF97316)
                                        : AppColors.primary
                                    : AppColors.accent
                                : AppColors.backgroundGrey,
                            shape: BoxShape.circle,
                          ),
                          child: Icon(
                            isCompleted && !isCurrent
                                ? Icons.check_rounded
                                : icon,
                            size: 16,
                            color: isCompleted
                                ? isCurrent
                                    ? AppColors.white
                                    : AppColors.primary
                                : AppColors.textTertiary,
                          ),
                        ),
                        if (!isLast)
                          Container(
                            width: 2,
                            height: 32,
                            color: isCompleted && index < currentIdx
                                ? AppColors.accent
                                : AppColors.divider,
                          ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Padding(
                      padding: EdgeInsets.only(top: 6, bottom: isLast ? 0 : 20),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(label,
                              style: AppTypography.bodyMedium.copyWith(
                                fontWeight: isCurrent
                                    ? FontWeight.w700
                                    : FontWeight.w400,
                                color: isCompleted
                                    ? needsAction
                                        ? const Color(0xFFF97316)
                                        : AppColors.textPrimary
                                    : AppColors.textTertiary,
                              )),
                          if (isCurrent && needsAction)
                            Text('Please review the changes',
                                style: AppTypography.caption.copyWith(
                                  color: const Color(0xFFF97316),
                                  fontWeight: FontWeight.w600,
                                )),
                        ],
                      ),
                    ),
                  ),
                  if (isCompleted)
                    Padding(
                      padding: const EdgeInsets.only(top: 8),
                      child: Text(
                        isCurrent
                            ? needsAction
                                ? 'Action'
                                : 'Now'
                            : '✓',
                        style: AppTypography.caption.copyWith(
                          color: isCurrent
                              ? needsAction
                                  ? const Color(0xFFF97316)
                                  : AppColors.primary
                              : AppColors.accentDark,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                ],
              );
            }),
        ],
      ),
    );
  }

  Widget _buildInfoCard({
    required String title,
    required List<Widget> children,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(AppSpacing.cardRadius),
        boxShadow: AppColors.cardShadow,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: AppTypography.h3.copyWith(fontSize: 15)),
          const SizedBox(height: 12),
          ...children,
        ],
      ),
    );
  }

  String _formatFullDate(DateTime date) {
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
      'Dec',
    ];
    return '${date.day} ${months[date.month - 1]} ${date.year}, '
        '${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}';
  }
}

// ─── Small status chip for app bar ──────────────────────────────
class _StatusChipSmall extends StatelessWidget {
  final OrderStatus status;
  const _StatusChipSmall({required this.status});

  @override
  Widget build(BuildContext context) {
    final (color, bg) = StatusChipData.colors(status);
    final label = StatusChipData.label(status);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(label,
          style: AppTypography.caption.copyWith(
            fontWeight: FontWeight.w700,
            color: color,
            fontSize: 10,
          )),
    );
  }
}

class _InfoRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;

  const _InfoRow({
    required this.icon,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        children: [
          Icon(icon, size: 18, color: AppColors.textTertiary),
          const SizedBox(width: 10),
          SizedBox(
            width: 70,
            child: Text(label, style: AppTypography.caption),
          ),
          Expanded(
            child: Text(
              value,
              style: AppTypography.bodyMedium.copyWith(
                fontWeight: FontWeight.w500,
                fontSize: 13,
              ),
              textAlign: TextAlign.right,
            ),
          ),
        ],
      ),
    );
  }
}

class _SummaryLine extends StatelessWidget {
  final String label;
  final String value;
  final Color? valueColor;

  const _SummaryLine(this.label, this.value, {this.valueColor});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: AppTypography.bodySmall),
          Text(value,
              style: AppTypography.bodySmall.copyWith(
                fontWeight: FontWeight.w600,
                color: valueColor,
              )),
        ],
      ),
    );
  }
}
