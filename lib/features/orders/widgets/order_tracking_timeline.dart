import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../../core/models/order_status.dart';
import '../../../core/models/status_history_entry.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_typography.dart';

/// Vertical timeline showing all 10 order statuses with real timestamps.
class OrderTrackingTimeline extends StatelessWidget {
  final OrderStatus currentStatus;
  final List<StatusHistoryEntry> statusHistory;

  const OrderTrackingTimeline({
    super.key,
    required this.currentStatus,
    required this.statusHistory,
  });

  @override
  Widget build(BuildContext context) {
    final statuses = OrderStatus.timelineStatuses;
    final currentIndex = currentStatus.stepIndex;
    final timeFmt = DateFormat('h:mm a');

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: AppColors.cardShadow,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Order Progress',
              style: AppTypography.h3.copyWith(color: AppColors.primary)),
          const SizedBox(height: 20),
          ...List.generate(statuses.length, (index) {
            final step = statuses[index];
            final isCompleted = index <= currentIndex;
            final isCurrent = index == currentIndex;
            final isLast = index == statuses.length - 1;

            final entry = statusHistory
                .cast<StatusHistoryEntry?>()
                .firstWhere((e) => e!.status == step, orElse: () => null);

            return _TimelineStep(
              label: step.label,
              message: isCurrent ? step.customerMessage : null,
              timestamp: entry != null ? timeFmt.format(entry.timestamp) : null,
              isCompleted: isCompleted,
              isCurrent: isCurrent,
              isLast: isLast,
              icon: _iconFor(step),
              needsAction: isCurrent && step.needsCustomerAction,
            );
          }),
        ],
      ),
    );
  }

  IconData _iconFor(OrderStatus s) => switch (s) {
        OrderStatus.pending => Icons.receipt_long_rounded,
        OrderStatus.reviewing => Icons.search_rounded,
        OrderStatus.awaitingConfirmation => Icons.edit_note_rounded,
        OrderStatus.confirmed => Icons.check_circle_rounded,
        OrderStatus.preparing => Icons.restaurant_rounded,
        OrderStatus.dispatched => Icons.local_shipping_rounded,
        OrderStatus.driverAssigned => Icons.person_rounded,
        OrderStatus.driverAtStore => Icons.store_rounded,
        OrderStatus.outForDelivery => Icons.delivery_dining_rounded,
        OrderStatus.arriving => Icons.near_me_rounded,
        OrderStatus.delivered => Icons.done_all_rounded,
        OrderStatus.cancelled => Icons.cancel_rounded,
      };
}

class _TimelineStep extends StatelessWidget {
  final String label;
  final String? message;
  final String? timestamp;
  final bool isCompleted;
  final bool isCurrent;
  final bool isLast;
  final IconData icon;
  final bool needsAction;

  const _TimelineStep({
    required this.label,
    this.message,
    this.timestamp,
    required this.isCompleted,
    required this.isCurrent,
    required this.isLast,
    required this.icon,
    this.needsAction = false,
  });

  @override
  Widget build(BuildContext context) {
    final activeColor = AppColors.primary;
    final doneColor = AppColors.accent;
    final dimColor = AppColors.divider;
    final actionColor = const Color(0xFFF97316); // Orange for needs-action

    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 40,
            child: Column(
              children: [
                AnimatedContainer(
                  duration: const Duration(milliseconds: 400),
                  curve: Curves.easeOut,
                  width: isCurrent ? 36 : 28,
                  height: isCurrent ? 36 : 28,
                  decoration: BoxDecoration(
                    color: isCurrent
                        ? (needsAction ? actionColor : activeColor)
                        : isCompleted
                            ? doneColor
                            : AppColors.white,
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: isCompleted || isCurrent
                          ? (needsAction ? actionColor : activeColor)
                          : dimColor,
                      width: isCurrent ? 3 : 2,
                    ),
                    boxShadow: isCurrent
                        ? [
                            BoxShadow(
                              color: (needsAction ? actionColor : activeColor)
                                  .withOpacity(0.3),
                              blurRadius: 8,
                              spreadRadius: 1,
                            ),
                          ]
                        : null,
                  ),
                  child: Icon(icon,
                      size: isCurrent ? 18 : 14,
                      color: isCurrent
                          ? AppColors.white
                          : isCompleted
                              ? activeColor
                              : dimColor),
                ),
                if (!isLast)
                  Expanded(
                    child: Container(
                      width: 2.5,
                      margin: const EdgeInsets.symmetric(vertical: 4),
                      decoration: BoxDecoration(
                        color: isCompleted ? doneColor : dimColor,
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                  ),
              ],
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Padding(
              padding: EdgeInsets.only(bottom: isLast ? 0 : 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Flexible(
                        child: Text(label,
                            style: AppTypography.bodyMedium.copyWith(
                              fontWeight:
                                  isCurrent ? FontWeight.w700 : FontWeight.w500,
                              color: isCompleted || isCurrent
                                  ? AppColors.textPrimary
                                  : AppColors.textTertiary,
                            )),
                      ),
                      if (timestamp != null)
                        Text(timestamp!, style: AppTypography.caption),
                    ],
                  ),
                  if (message != null && isCurrent) ...[
                    const SizedBox(height: 4),
                    Text(message!,
                        style: AppTypography.bodySmall.copyWith(
                          color: needsAction
                              ? const Color(0xFFF97316)
                              : AppColors.primary.withOpacity(0.7),
                          fontWeight: needsAction ? FontWeight.w600 : null,
                        )),
                  ],
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
