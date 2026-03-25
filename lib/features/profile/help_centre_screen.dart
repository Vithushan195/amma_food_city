import 'package:flutter/material.dart';
import '../../core/theme/theme.dart';

class _FaqItem {
  final String question, answer, category;
  const _FaqItem(this.question, this.answer, this.category);
}

const _faqs = [
  _FaqItem('How do I place an order?', 'Browse products on the Home screen, add items to your cart using the + button, then go to Cart and tap "Proceed to Checkout". Select your delivery address, time slot, and payment method to complete your order.', 'Orders'),
  _FaqItem('What are the delivery hours?', 'We deliver between 9:00 AM and 9:00 PM, 7 days a week. You can choose your preferred 2-hour delivery slot during checkout.', 'Delivery'),
  _FaqItem('Is there a minimum order value?', 'There is no minimum order value. However, orders under £30 incur a £2.99 delivery fee. Orders over £30 qualify for free delivery.', 'Orders'),
  _FaqItem('How do I use a promo code?', 'In the Cart screen, enter your promo code in the input field and tap "Apply". The discount will be reflected in your order summary. Try AMMA10 for 10% off!', 'Payments'),
  _FaqItem('Can I cancel my order?', 'You can cancel your order while it\'s in "Pending" or "Confirmed" status. Go to Orders > tap your order > Cancel Order. Once preparation has started, cancellation is not available.', 'Orders'),
  _FaqItem('What payment methods do you accept?', 'We accept all major credit and debit cards (Visa, Mastercard, Amex) via Stripe, and Cash on Delivery.', 'Payments'),
  _FaqItem('How do I track my order?', 'Go to the Orders tab and tap on your active order. You\'ll see a real-time status timeline showing the progress from confirmed to delivered.', 'Delivery'),
  _FaqItem('Can I change my delivery address?', 'You can manage your saved addresses in Profile > Saved Addresses. During checkout, you can select any of your saved addresses or add a new one.', 'Delivery'),
  _FaqItem('What if an item is damaged or missing?', 'Contact us within 24 hours via the Contact Us screen or email support@ammafoodcity.co.uk. We\'ll arrange a replacement or refund.', 'Orders'),
  _FaqItem('How do I delete my account?', 'Please contact our support team at support@ammafoodcity.co.uk. Account deletion requests are processed within 48 hours.', 'Account'),
];

class HelpCentreScreen extends StatefulWidget {
  const HelpCentreScreen({super.key});
  @override
  State<HelpCentreScreen> createState() => _HelpCentreScreenState();
}

class _HelpCentreScreenState extends State<HelpCentreScreen> {
  String _searchQuery = '';
  String _selectedCategory = 'All';
  int _expandedIndex = -1;
  final _searchCtrl = TextEditingController();

  final _categories = ['All', 'Orders', 'Delivery', 'Payments', 'Account'];

  List<_FaqItem> get _filteredFaqs {
    return _faqs.where((f) {
      final matchesCategory = _selectedCategory == 'All' || f.category == _selectedCategory;
      final matchesSearch = _searchQuery.isEmpty ||
          f.question.toLowerCase().contains(_searchQuery.toLowerCase()) ||
          f.answer.toLowerCase().contains(_searchQuery.toLowerCase());
      return matchesCategory && matchesSearch;
    }).toList();
  }

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final statusBarHeight = MediaQuery.of(context).padding.top;

    return Scaffold(
      backgroundColor: AppColors.offWhite,
      body: Column(children: [
        Container(
          color: AppColors.white,
          padding: EdgeInsets.fromLTRB(8, statusBarHeight + 4, 16, 12),
          child: Column(children: [
            Row(children: [
              IconButton(onPressed: () => Navigator.pop(context), icon: const Icon(Icons.arrow_back_rounded)),
              Expanded(child: Text('Help Centre', style: AppTypography.h3.copyWith(fontSize: 18), textAlign: TextAlign.center)),
              const SizedBox(width: 48),
            ]),
            const SizedBox(height: 8),
            // Search
            Container(
              height: 44,
              decoration: BoxDecoration(color: AppColors.backgroundGrey, borderRadius: BorderRadius.circular(12)),
              child: Row(children: [
                const SizedBox(width: 14),
                const Icon(Icons.search_rounded, size: 20, color: AppColors.textTertiary),
                const SizedBox(width: 8),
                Expanded(child: TextField(
                  controller: _searchCtrl,
                  onChanged: (v) => setState(() => _searchQuery = v),
                  style: AppTypography.bodyMedium,
                  decoration: InputDecoration(
                    hintText: 'Search FAQs...', border: InputBorder.none, isDense: true,
                    contentPadding: EdgeInsets.zero,
                    hintStyle: AppTypography.bodyMedium.copyWith(color: AppColors.textTertiary),
                  ),
                )),
                if (_searchQuery.isNotEmpty)
                  GestureDetector(
                    onTap: () { _searchCtrl.clear(); setState(() => _searchQuery = ''); },
                    child: const Padding(padding: EdgeInsets.all(10), child: Icon(Icons.close_rounded, size: 18, color: AppColors.textTertiary)),
                  ),
                const SizedBox(width: 8),
              ]),
            ),
          ]),
        ),

        // Category chips
        SizedBox(
          height: 48,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.screenHorizontal, vertical: 8),
            itemCount: _categories.length,
            separatorBuilder: (_, __) => const SizedBox(width: 8),
            itemBuilder: (context, index) {
              final cat = _categories[index];
              final sel = cat == _selectedCategory;
              return GestureDetector(
                onTap: () => setState(() { _selectedCategory = cat; _expandedIndex = -1; }),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  decoration: BoxDecoration(
                    color: sel ? AppColors.primary : AppColors.white,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: sel ? AppColors.primary : AppColors.divider),
                  ),
                  child: Center(child: Text(cat, style: AppTypography.buttonMedium.copyWith(
                      fontSize: 12, color: sel ? AppColors.white : AppColors.textSecondary))),
                ),
              );
            },
          ),
        ),

        // FAQs
        Expanded(
          child: _filteredFaqs.isEmpty
              ? Center(child: Column(mainAxisSize: MainAxisSize.min, children: [
                  const Icon(Icons.search_off_rounded, size: 48, color: AppColors.textTertiary),
                  const SizedBox(height: 12),
                  Text('No results found', style: AppTypography.bodyMedium.copyWith(color: AppColors.textSecondary)),
                ]))
              : ListView.separated(
                  padding: const EdgeInsets.all(AppSpacing.screenHorizontal),
                  itemCount: _filteredFaqs.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 8),
                  itemBuilder: (context, index) {
                    final faq = _filteredFaqs[index];
                    final isExpanded = _expandedIndex == index;
                    return GestureDetector(
                      onTap: () => setState(() => _expandedIndex = isExpanded ? -1 : index),
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 200),
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(color: AppColors.white, borderRadius: BorderRadius.circular(12), boxShadow: AppColors.cardShadow),
                        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                          Row(children: [
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                              decoration: BoxDecoration(color: AppColors.accentSubtle, borderRadius: BorderRadius.circular(6)),
                              child: Text(faq.category, style: AppTypography.caption.copyWith(fontSize: 10, fontWeight: FontWeight.w600, color: AppColors.primary)),
                            ),
                            const Spacer(),
                            AnimatedRotation(turns: isExpanded ? 0.5 : 0, duration: const Duration(milliseconds: 200),
                                child: const Icon(Icons.keyboard_arrow_down_rounded, color: AppColors.textSecondary, size: 22)),
                          ]),
                          const SizedBox(height: 8),
                          Text(faq.question, style: AppTypography.bodyMedium.copyWith(fontWeight: FontWeight.w600)),
                          AnimatedCrossFade(
                            firstChild: const SizedBox(width: double.infinity),
                            secondChild: Padding(
                              padding: const EdgeInsets.only(top: 10),
                              child: Text(faq.answer, style: AppTypography.bodySmall.copyWith(color: AppColors.textSecondary, height: 1.6)),
                            ),
                            crossFadeState: isExpanded ? CrossFadeState.showSecond : CrossFadeState.showFirst,
                            duration: const Duration(milliseconds: 200),
                          ),
                        ]),
                      ),
                    );
                  },
                ),
        ),
      ]),
    );
  }
}
