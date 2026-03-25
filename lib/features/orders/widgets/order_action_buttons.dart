import 'package:flutter/material.dart';
import '../../../core/models/app_order.dart';
import '../../../core/models/order_status.dart';
import '../../../core/services/order_service.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_typography.dart';
import 'contact_store_card.dart';

/// Shows the appropriate action based on order status:
/// - Before confirmed: Cancel button
/// - awaiting_confirmation: Navigate to revision screen
/// - After confirmed: Contact store card
class OrderActionButtons extends StatefulWidget {
  final AppOrder order;
  final VoidCallback? onCancelled;
  final VoidCallback? onConfirmRevision;

  const OrderActionButtons({
    super.key,
    required this.order,
    this.onCancelled,
    this.onConfirmRevision,
  });

  @override
  State<OrderActionButtons> createState() => _OrderActionButtonsState();
}

class _OrderActionButtonsState extends State<OrderActionButtons> {
  bool _cancelling = false;

  Future<void> _cancelOrder() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('Cancel Order?'),
        content: const Text('Are you sure you want to cancel this order?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Keep Order'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(ctx, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.error,
              foregroundColor: Colors.white,
            ),
            child: const Text('Cancel Order'),
          ),
        ],
      ),
    );

    if (confirm != true) return;

    setState(() => _cancelling = true);
    try {
      await OrderService().cancelOrder(widget.order.id);
      widget.onCancelled?.call();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Order cancelled')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e')),
        );
      }
    } finally {
      if (mounted) setState(() => _cancelling = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final status = widget.order.status;

    // Delivered or cancelled — no actions
    if (status == OrderStatus.delivered || status == OrderStatus.cancelled) {
      return const SizedBox.shrink();
    }

    // Awaiting confirmation — show confirm/decline buttons
    if (status == OrderStatus.awaitingConfirmation) {
      return Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: Column(
          children: [
            SizedBox(
              width: double.infinity,
              height: 52,
              child: ElevatedButton.icon(
                onPressed: widget.onConfirmRevision,
                icon: const Icon(Icons.check_rounded),
                label: const Text('Review & Confirm Changes'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 8),
            SizedBox(
              width: double.infinity,
              height: 44,
              child: OutlinedButton(
                onPressed: _cancelling ? null : _cancelOrder,
                style: OutlinedButton.styleFrom(
                  foregroundColor: AppColors.error,
                  side: const BorderSide(color: AppColors.error),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                ),
                child: const Text('Decline & Cancel'),
              ),
            ),
          ],
        ),
      );
    }

    // Before confirmed — show cancel button
    if (status.canCustomerCancel) {
      return Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: SizedBox(
          width: double.infinity,
          height: 48,
          child: OutlinedButton.icon(
            onPressed: _cancelling ? null : _cancelOrder,
            icon: _cancelling
                ? const SizedBox(
                    width: 16,
                    height: 16,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : const Icon(Icons.cancel_outlined, size: 18),
            label: Text(_cancelling ? 'Cancelling...' : 'Cancel Order'),
            style: OutlinedButton.styleFrom(
              foregroundColor: AppColors.error,
              side: const BorderSide(color: AppColors.error),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(14),
              ),
            ),
          ),
        ),
      );
    }

    // After confirmed — show contact store
    if (status.requiresContactToCancel) {
      return const ContactStoreCard();
    }

    return const SizedBox.shrink();
  }
}
