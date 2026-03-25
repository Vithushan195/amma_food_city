import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../core/theme/theme.dart';
import '../core/constants/app_constants.dart';
import '../core/providers/providers.dart';
import 'home/home_screen.dart';
import 'categories/categories_screen.dart';
import 'cart/cart_screen.dart';
import 'orders/orders_screen.dart';
import 'profile/profile_screen.dart';

class AppShell extends ConsumerStatefulWidget {
  const AppShell({super.key});
  @override
  ConsumerState<AppShell> createState() => _AppShellState();
}

class _AppShellState extends ConsumerState<AppShell> {
  int _currentIndex = 0;
  List<Widget> get _screens => [
        HomeScreen(
            onSwitchTab: (index) => setState(() => _currentIndex = index)),
        const CategoriesScreen(),
        const CartScreen(),
        const OrdersScreen(),
        const ProfileScreen(),
      ];

  @override
  Widget build(BuildContext context) {
    final cartCount = ref.watch(cartItemCountProvider);
    return Scaffold(
      body: IndexedStack(index: _currentIndex, children: _screens),
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
            color: AppColors.white, boxShadow: AppColors.bottomNavShadow),
        child: SafeArea(
          child: SizedBox(
            height: AppSpacing.bottomNavHeight,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _NavItem(
                    icon: Icons.home_outlined,
                    activeIcon: Icons.home_rounded,
                    label: AppStrings.navHome,
                    isActive: _currentIndex == 0,
                    onTap: () => setState(() => _currentIndex = 0)),
                _NavItem(
                    icon: Icons.grid_view_outlined,
                    activeIcon: Icons.grid_view_rounded,
                    label: AppStrings.navCategories,
                    isActive: _currentIndex == 1,
                    onTap: () => setState(() => _currentIndex = 1)),
                _NavItem(
                    icon: Icons.shopping_bag_outlined,
                    activeIcon: Icons.shopping_bag_rounded,
                    label: AppStrings.navCart,
                    isActive: _currentIndex == 2,
                    onTap: () => setState(() => _currentIndex = 2),
                    badgeCount: cartCount),
                _NavItem(
                    icon: Icons.receipt_long_outlined,
                    activeIcon: Icons.receipt_long_rounded,
                    label: AppStrings.navOrders,
                    isActive: _currentIndex == 3,
                    onTap: () => setState(() => _currentIndex = 3)),
                _NavItem(
                    icon: Icons.person_outline_rounded,
                    activeIcon: Icons.person_rounded,
                    label: AppStrings.navProfile,
                    isActive: _currentIndex == 4,
                    onTap: () => setState(() => _currentIndex = 4)),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _NavItem extends StatelessWidget {
  final IconData icon, activeIcon;
  final String label;
  final bool isActive;
  final VoidCallback onTap;
  final int badgeCount;
  const _NavItem(
      {required this.icon,
      required this.activeIcon,
      required this.label,
      required this.isActive,
      required this.onTap,
      this.badgeCount = 0});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: SizedBox(
        width: 64,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                height: 3,
                width: isActive ? 20 : 0,
                margin: const EdgeInsets.only(bottom: 6),
                decoration: BoxDecoration(
                    color: AppColors.accent,
                    borderRadius: BorderRadius.circular(2))),
            Stack(clipBehavior: Clip.none, children: [
              Icon(isActive ? activeIcon : icon,
                  size: AppSpacing.bottomNavIconSize,
                  color: isActive ? AppColors.primary : AppColors.textTertiary),
              if (badgeCount > 0)
                Positioned(
                    top: -4,
                    right: -8,
                    child: Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 4, vertical: 1),
                        constraints: const BoxConstraints(minWidth: 16),
                        decoration: BoxDecoration(
                            color: AppColors.accent,
                            borderRadius: BorderRadius.circular(8)),
                        child: Text('$badgeCount',
                            style: AppTypography.badge
                                .copyWith(color: AppColors.textOnAccent),
                            textAlign: TextAlign.center))),
            ]),
            const SizedBox(height: 4),
            Text(label,
                style: AppTypography.navLabel.copyWith(
                    color:
                        isActive ? AppColors.primary : AppColors.textTertiary,
                    fontWeight: isActive ? FontWeight.w600 : FontWeight.w400)),
          ],
        ),
      ),
    );
  }
}
