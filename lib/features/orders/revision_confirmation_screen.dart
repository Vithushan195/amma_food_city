import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/models/app_order.dart';
import '../../../core/models/cart_item.dart';
import '../../../core/providers/order_tracking_providers.dart';
import '../../../core/services/order_service.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_typography.dart';

/// Screen shown when order is in `awaitingConfirmation` status.
/// Customer sees what the store changed and can confirm or decline.
class RevisionConfirmationScreen extends ConsumerStatefulWidget {
  final String orderId;

  const RevisionConfirmationScreen({super.key, required this.orderId});

  @override
  ConsumerState<RevisionConfirmationScreen> createState() =>
      _RevisionConfirmationScreenState();
}

class _RevisionConfirmationScreenState
    extends ConsumerState<RevisionConfirmationScreen> {
  bool _loading = false;

  Future<void> _confirmRevision() async {
    setState(() => _loading = true);
    try {
      await OrderService().confirmRevision(widget.orderId);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Order confirmed!')),
        );
        Navigator.of(context).pop();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e')),
        );
      }
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _declineRevision() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('Cancel Order?'),
        content: const Text(
          'Declining the revised order will cancel your order. Are you sure?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Go Back'),
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

    setState(() => _loading = true);
    try {
      await OrderService().declineRevision(widget.orderId);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Order cancelled')),
        );
        Navigator.of(context).pop();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e')),
        );
      }
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final orderAsync = ref.watch(orderStreamProvider(widget.orderId));

    return Scaffold(
      backgroundColor: AppColors.offWhite,
      appBar: AppBar(
        title: const Text('Review Changes'),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
      ),
      body: orderAsync.when(
        loading: () => const Center(
          child: CircularProgressIndicator(color: AppColors.primary),
        ),
        error: (e, _) => Center(child: Text('Error: $e')),
        data: (order) {
          if (order == null) {
            return const Center(child: Text('Order not found'));
          }
          return _buildBody(order);
        },
      ),
    );
  }

  Widget _buildBody(AppOrder order) {
    return Column(
      children: [
        Expanded(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Info banner
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: const Color(0xFFFFF3CD),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: const Color(0xFFFFD966)),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          const Icon(Icons.info_outline_rounded,
                              color: Color(0xFF856404), size: 20),
                          const SizedBox(width: 8),
                          Text(
                            'Order Updated by Store',
                            style: AppTypography.bodyLarge.copyWith(
                              fontWeight: FontWeight.w700,
                              color: const Color(0xFF856404),
                            ),
                          ),
                        ],
                      ),
                      if (order.revisionNote != null) ...[
                        const SizedBox(height: 8),
                        Text(
                          order.revisionNote!,
                          style: AppTypography.bodyMedium.copyWith(
                            color: const Color(0xFF856404),
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
                const SizedBox(height: 20),

                // Revised items
                Text('Updated Order',
                    style: AppTypography.h3.copyWith(color: AppColors.primary)),
                const SizedBox(height: 12),
                ...order.displayItems.map((item) => _itemRow(item)),

                const Divider(height: 32),

                // Removed items (items in original but not in revised)
                if (order.hasRevision) ...[
                  ..._buildRemovedItems(order),
                ],

                // New totals
                _totalRow('Subtotal',
                    '£${(order.revisedSubtotal ?? order.subtotal).toStringAsFixed(2)}'),
                _totalRow(
                    'Delivery',
                    order.deliveryFee > 0
                        ? '£${order.deliveryFee.toStringAsFixed(2)}'
                        : 'FREE'),
                if (order.discount > 0)
                  _totalRow(
                      'Discount', '-£${order.discount.toStringAsFixed(2)}',
                      color: AppColors.success),
                const SizedBox(height: 8),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('New Total',
                        style: AppTypography.bodyLarge.copyWith(
                          fontWeight: FontWeight.w700,
                          color: AppColors.primary,
                        )),
                    Text('£${order.displayTotal.toStringAsFixed(2)}',
                        style: AppTypography.h2.copyWith(
                          color: AppColors.primary,
                        )),
                  ],
                ),

                if (order.total != order.displayTotal) ...[
                  const SizedBox(height: 4),
                  Text(
                    'Original total: £${order.total.toStringAsFixed(2)}',
                    style: AppTypography.bodySmall.copyWith(
                      decoration: TextDecoration.lineThrough,
                      color: AppColors.textTertiary,
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),

        // Action buttons
        Container(
          padding: const EdgeInsets.all(16),
          decoration: const BoxDecoration(
            color: Colors.white,
            border: Border(top: BorderSide(color: AppColors.divider)),
          ),
          child: SafeArea(
            child: Column(
              children: [
                SizedBox(
                  width: double.infinity,
                  height: 52,
                  child: ElevatedButton(
                    onPressed: _loading ? null : _confirmRevision,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                    ),
                    child: _loading
                        ? const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: Colors.white,
                            ),
                          )
                        : const Text('Confirm Updated Order',
                            style: TextStyle(
                                fontSize: 16, fontWeight: FontWeight.w600)),
                  ),
                ),
                const SizedBox(height: 10),
                SizedBox(
                  width: double.infinity,
                  height: 48,
                  child: OutlinedButton(
                    onPressed: _loading ? null : _declineRevision,
                    style: OutlinedButton.styleFrom(
                      foregroundColor: AppColors.error,
                      side: const BorderSide(color: AppColors.error),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                    ),
                    child: const Text('Decline & Cancel Order',
                        style: TextStyle(
                            fontSize: 14, fontWeight: FontWeight.w600)),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _itemRow(CartItem item) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
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
            child: Text('${item.quantity}×',
                style: AppTypography.caption.copyWith(
                  fontWeight: FontWeight.w700,
                  color: AppColors.primary,
                )),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(item.product.name, style: AppTypography.bodyMedium),
          ),
          Text('£${(item.product.price * item.quantity).toStringAsFixed(2)}',
              style: AppTypography.bodyMedium
                  .copyWith(fontWeight: FontWeight.w600)),
        ],
      ),
    );
  }

  List<Widget> _buildRemovedItems(AppOrder order) {
    final originalIds = order.items.map((i) => i.product.id).toSet();
    final revisedIds =
        (order.revisedItems ?? []).map((i) => i.product.id).toSet();
    final removedIds = originalIds.difference(revisedIds);

    if (removedIds.isEmpty) return [];

    final removed =
        order.items.where((i) => removedIds.contains(i.product.id)).toList();

    return [
      Text('Removed Items',
          style: AppTypography.label.copyWith(color: AppColors.error)),
      const SizedBox(height: 8),
      ...removed.map((item) => Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: Row(
              children: [
                const Icon(Icons.remove_circle_outline,
                    size: 18, color: AppColors.error),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    item.product.name,
                    style: AppTypography.bodyMedium.copyWith(
                      decoration: TextDecoration.lineThrough,
                      color: AppColors.textTertiary,
                    ),
                  ),
                ),
              ],
            ),
          )),
      const SizedBox(height: 16),
    ];
  }

  Widget _totalRow(String label, String value, {Color? color}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: AppTypography.caption),
          Text(value,
              style: AppTypography.bodySmall.copyWith(
                color: color ?? AppColors.textSecondary,
                fontWeight: FontWeight.w500,
              )),
        ],
      ),
    );
  }
}
