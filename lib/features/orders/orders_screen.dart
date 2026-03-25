import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter/material.dart';
import '../../core/theme/theme.dart';
import '../../core/models/models.dart';
import '../../widgets/widgets.dart';
import '../../core/providers/providers.dart';
import 'order_detail_screen.dart';

import 'widgets/status_chip_data.dart';

/// Amma Food City — Orders Screen
///
/// Layout:
/// 1. Curved header with "My Orders" title + filter tabs
/// 2. Order card list with status chips
/// 3. Pull-to-refresh
/// 4. Empty state
class OrdersScreen extends ConsumerStatefulWidget {
  const OrdersScreen({super.key});

  @override
  ConsumerState<OrdersScreen> createState() => _OrdersScreenState();
}

class _OrdersScreenState extends ConsumerState<OrdersScreen> {
  int _selectedFilter = 0; // 0=All, 1=Active, 2=Completed
  final List<String> _filters = ['All', 'Active', 'Completed'];

  List<AppOrder> get _filteredOrders {
    switch (_selectedFilter) {
      case 1: // Active
        return ref
            .watch(ordersProvider)
            .orders
            .where((o) =>
                o.status != OrderStatus.delivered &&
                o.status != OrderStatus.cancelled)
            .toList();
      case 2: // Completed
        return ref
            .watch(ordersProvider)
            .orders
            .where((o) =>
                o.status == OrderStatus.delivered ||
                o.status == OrderStatus.cancelled)
            .toList();
      default:
        return ref.watch(ordersProvider).orders;
    }
  }

  @override
  Widget build(BuildContext context) {
    final statusBarHeight = MediaQuery.of(context).padding.top;

    return Scaffold(
      backgroundColor: AppColors.offWhite,
      body: RefreshIndicator(
        onRefresh: () async {
          await ref.read(ordersProvider.notifier).refresh();
        },
        color: AppColors.primary,
        child: CustomScrollView(
          slivers: [
            // ── HEADER ─────────────────────────────────────────
            SliverToBoxAdapter(
              child: _buildHeader(statusBarHeight),
            ),

            // ── FILTER TABS ────────────────────────────────────
            SliverToBoxAdapter(
              child: _buildFilterTabs(),
            ),

            // ── ORDERS LIST ────────────────────────────────────
            _filteredOrders.isEmpty
                ? SliverFillRemaining(child: _buildEmpty())
                : SliverPadding(
                    padding: const EdgeInsets.fromLTRB(
                      AppSpacing.screenHorizontal,
                      AppSpacing.sm,
                      AppSpacing.screenHorizontal,
                      AppSpacing.xxxl + AppSpacing.xxl,
                    ),
                    sliver: SliverList(
                      delegate: SliverChildBuilderDelegate(
                        (context, index) {
                          return Padding(
                            padding: const EdgeInsets.only(bottom: 12),
                            child: _OrderCard(
                              order: _filteredOrders[index],
                              onTap: () {
                                Navigator.of(context).push(
                                  MaterialPageRoute(
                                    builder: (_) => OrderDetailScreen(
                                      order: _filteredOrders[index],
                                      orderId: _filteredOrders[index].id,
                                    ),
                                  ),
                                );
                              },
                            ),
                          );
                        },
                        childCount: _filteredOrders.length,
                      ),
                    ),
                  ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(double statusBarHeight) {
    return ClipPath(
      clipper: _OrdersHeaderClipper(),
      child: Container(
        width: double.infinity,
        decoration: const BoxDecoration(
          gradient: AppColors.headerGradient,
        ),
        padding: EdgeInsets.fromLTRB(
          AppSpacing.screenHorizontal,
          statusBarHeight + AppSpacing.base,
          AppSpacing.screenHorizontal,
          AppSpacing.xxl + 10,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'My Orders',
                  style: AppTypography.sectionHeaderWhite.copyWith(
                    fontSize: 26,
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 5,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.accent.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    '${ref.watch(ordersProvider).orders.length} orders',
                    style: AppTypography.caption.copyWith(
                      color: AppColors.accentLight,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 4),
            const Text(
              'Track and manage your orders',
              style: AppTypography.sectionSubHeaderWhite,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFilterTabs() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.screenHorizontal,
        0,
        AppSpacing.screenHorizontal,
        AppSpacing.sm,
      ),
      child: Row(
        children: List.generate(_filters.length, (index) {
          final isSelected = index == _selectedFilter;
          return Padding(
            padding: const EdgeInsets.only(right: 8),
            child: GestureDetector(
              onTap: () => setState(() => _selectedFilter = index),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                padding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 9,
                ),
                decoration: BoxDecoration(
                  color: isSelected ? AppColors.primary : AppColors.white,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: isSelected ? AppColors.primary : AppColors.divider,
                  ),
                ),
                child: Text(
                  _filters[index],
                  style: AppTypography.buttonMedium.copyWith(
                    fontSize: 13,
                    color:
                        isSelected ? AppColors.white : AppColors.textSecondary,
                  ),
                ),
              ),
            ),
          );
        }),
      ),
    );
  }

  Widget _buildEmpty() {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 100,
            height: 100,
            decoration: const BoxDecoration(
              color: AppColors.backgroundGrey,
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.receipt_long_outlined,
              size: 48,
              color: AppColors.textTertiary.withOpacity(0.4),
            ),
          ),
          const SizedBox(height: AppSpacing.xl),
          const Text('No orders yet', style: AppTypography.h2),
          const SizedBox(height: AppSpacing.sm),
          const Text(
            'Your orders will appear here',
            style: AppTypography.bodySmall,
          ),
        ],
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════════
// Order Card
// ═══════════════════════════════════════════════════════════════════
class _OrderCard extends ConsumerWidget {
  final AppOrder order;
  final VoidCallback onTap;

  const _OrderCard({required this.order, required this.onTap});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.circular(AppSpacing.cardRadius),
          boxShadow: AppColors.cardShadow,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header row: order number + status chip
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  order.id,
                  style: AppTypography.bodyMedium.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
                ),
                _StatusChip(status: order.status),
              ],
            ),

            const SizedBox(height: 10),

            // Date + items
            Row(
              children: [
                const Icon(Icons.calendar_today_outlined,
                    size: 14, color: AppColors.textTertiary),
                const SizedBox(width: 6),
                Text(
                  _formatDate(order.createdAt),
                  style: AppTypography.caption,
                ),
                const SizedBox(width: 16),
                const Icon(Icons.shopping_bag_outlined,
                    size: 14, color: AppColors.textTertiary),
                const SizedBox(width: 6),
                Text(
                  '${order.itemCount} items',
                  style: AppTypography.caption,
                ),
              ],
            ),

            const SizedBox(height: 12),

            // Item preview row
            SizedBox(
              height: 40,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                itemCount: order.items.length > 4 ? 4 : order.items.length,
                separatorBuilder: (_, __) => const SizedBox(width: 6),
                itemBuilder: (context, index) {
                  if (index == 3 && order.items.length > 4) {
                    return Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        color: AppColors.backgroundGrey,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Center(
                        child: Text(
                          '+${order.items.length - 3}',
                          style: AppTypography.caption.copyWith(
                            fontWeight: FontWeight.w700,
                            color: AppColors.primary,
                          ),
                        ),
                      ),
                    );
                  }
                  return Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: AppColors.backgroundGrey,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Center(
                      child: Icon(
                        Icons.image_outlined,
                        size: 18,
                        color: AppColors.textTertiary,
                      ),
                    ),
                  );
                },
              ),
            ),

            const SizedBox(height: 12),

            // Total + action row
            Container(
              padding: const EdgeInsets.only(top: 12),
              decoration: const BoxDecoration(
                border: Border(
                  top: BorderSide(color: AppColors.divider),
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('Total', style: AppTypography.caption),
                      SuperscriptPrice(
                        price: order.total,
                        size: PriceSize.small,
                      ),
                    ],
                  ),
                  Row(
                    children: [
                      if (order.status == OrderStatus.delivered)
                        _ActionButton(
                          label: 'Reorder',
                          icon: Icons.replay_rounded,
                          onTap: () {
                            ref.read(ordersProvider.notifier).reorder(order);
                            ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                    content: Text('Items added to cart')));
                          },
                        ),
                      const SizedBox(width: 8),
                      _ActionButton(
                        label: 'Details',
                        icon: Icons.arrow_forward_rounded,
                        isPrimary: true,
                        onTap: onTap,
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final diff = now.difference(date);
    if (diff.inHours < 1) return '${diff.inMinutes}m ago';
    if (diff.inHours < 24) return '${diff.inHours}h ago';
    if (diff.inDays == 1) return 'Yesterday';
    if (diff.inDays < 7) return '${diff.inDays} days ago';
    return '${date.day}/${date.month}/${date.year}';
  }
}

// ═══════════════════════════════════════════════════════════════════
// Step 7B updated: added new delivery status cases
// ═══════════════════════════════════════════════════════════════════
class _StatusChip extends StatelessWidget {
  final OrderStatus status;
  const _StatusChip({required this.status});

  @override
  Widget build(BuildContext context) {
    final (color, bg) = StatusChipData.colors(status);
    final label = StatusChipData.label(status);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        label,
        style: AppTypography.caption.copyWith(
          fontWeight: FontWeight.w700,
          color: color,
          fontSize: 11,
        ),
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════════
class _ActionButton extends StatelessWidget {
  final String label;
  final IconData icon;
  final VoidCallback onTap;
  final bool isPrimary;

  const _ActionButton({
    required this.label,
    required this.icon,
    required this.onTap,
    this.isPrimary = false,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
        decoration: BoxDecoration(
          color: isPrimary ? AppColors.primary : AppColors.backgroundGrey,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              label,
              style: AppTypography.caption.copyWith(
                fontWeight: FontWeight.w600,
                color: isPrimary ? AppColors.white : AppColors.textSecondary,
              ),
            ),
            const SizedBox(width: 4),
            Icon(
              icon,
              size: 14,
              color: isPrimary ? AppColors.white : AppColors.textSecondary,
            ),
          ],
        ),
      ),
    );
  }
}

class _OrdersHeaderClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    final path = Path();
    path.lineTo(0, size.height - 28);
    path.quadraticBezierTo(
      size.width / 2,
      size.height + 16,
      size.width,
      size.height - 28,
    );
    path.lineTo(size.width, 0);
    path.close();
    return path;
  }

  @override
  bool shouldReclip(covariant CustomClipper<Path> oldClipper) => false;
}
