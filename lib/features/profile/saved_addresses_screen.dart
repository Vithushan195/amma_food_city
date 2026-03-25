import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/theme/theme.dart';
import '../../core/models/models.dart';
import '../../widgets/widgets.dart';

class SavedAddressesScreen extends ConsumerStatefulWidget {
  const SavedAddressesScreen({super.key});
  @override
  ConsumerState<SavedAddressesScreen> createState() =>
      _SavedAddressesScreenState();
}

class _SavedAddressesScreenState extends ConsumerState<SavedAddressesScreen> {
  // Mock addresses — will be from Firestore userAddressesProvider in production
  final List<DeliveryAddress> _addresses =
      List.from(DeliveryAddress.mockAddresses);

  void _deleteAddress(int index) {
    final removed = _addresses[index];
    setState(() => _addresses.removeAt(index));
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('${removed.label} address deleted'),
        action: SnackBarAction(
            label: 'UNDO',
            textColor: AppColors.accent,
            onPressed: () => setState(() => _addresses.insert(index, removed))),
      ),
    );
  }

  void _setDefault(int index) {
    setState(() {
      for (int i = 0; i < _addresses.length; i++) {
        _addresses[i] = DeliveryAddress(
          id: _addresses[i].id,
          label: _addresses[i].label,
          line1: _addresses[i].line1,
          line2: _addresses[i].line2,
          city: _addresses[i].city,
          postcode: _addresses[i].postcode,
          isDefault: i == index,
        );
      }
    });
  }

  void _showAddEditSheet({DeliveryAddress? existing, int? index}) {
    final labelCtrl = TextEditingController(text: existing?.label ?? '');
    final line1Ctrl = TextEditingController(text: existing?.line1 ?? '');
    final line2Ctrl = TextEditingController(text: existing?.line2 ?? '');
    final cityCtrl = TextEditingController(text: existing?.city ?? '');
    final postcodeCtrl = TextEditingController(text: existing?.postcode ?? '');
    final formKey = GlobalKey<FormState>();
    final isEdit = existing != null;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (ctx) {
        return Padding(
          padding: EdgeInsets.fromLTRB(
              20, 16, 20, MediaQuery.of(ctx).viewInsets.bottom + 20),
          child: Form(
            key: formKey,
            child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Center(
                      child: Container(
                          width: 40,
                          height: 4,
                          decoration: BoxDecoration(
                              color: AppColors.divider,
                              borderRadius: BorderRadius.circular(2)))),
                  const SizedBox(height: 16),
                  Text(isEdit ? 'Edit Address' : 'Add New Address',
                      style: AppTypography.h2.copyWith(fontSize: 20)),
                  const SizedBox(height: 16),
                  _sheetField('Label (e.g. Home, Work)', labelCtrl,
                      (v) => v!.isEmpty ? 'Required' : null),
                  const SizedBox(height: 10),
                  _sheetField('Address Line 1', line1Ctrl,
                      (v) => v!.isEmpty ? 'Required' : null),
                  const SizedBox(height: 10),
                  _sheetField('Address Line 2 (optional)', line2Ctrl, null),
                  const SizedBox(height: 10),
                  Row(children: [
                    Expanded(
                        child: _sheetField('City', cityCtrl,
                            (v) => v!.isEmpty ? 'Required' : null)),
                    const SizedBox(width: 10),
                    Expanded(
                        child: _sheetField('Postcode', postcodeCtrl,
                            (v) => v!.isEmpty ? 'Required' : null)),
                  ]),
                  const SizedBox(height: 20),
                  SizedBox(
                    width: double.infinity,
                    height: AppSpacing.buttonHeight,
                    child: ElevatedButton(
                      onPressed: () {
                        if (!formKey.currentState!.validate()) return;
                        final addr = DeliveryAddress(
                          id: existing?.id ??
                              'addr_${DateTime.now().millisecondsSinceEpoch}',
                          label: labelCtrl.text.trim(),
                          line1: line1Ctrl.text.trim(),
                          line2: line2Ctrl.text.trim().isEmpty
                              ? null
                              : line2Ctrl.text.trim(),
                          city: cityCtrl.text.trim(),
                          postcode: postcodeCtrl.text.trim().toUpperCase(),
                          isDefault: existing?.isDefault ?? _addresses.isEmpty,
                        );
                        setState(() {
                          if (isEdit && index != null) {
                            _addresses[index] = addr;
                          } else {
                            _addresses.add(addr);
                          }
                        });
                        Navigator.pop(ctx);
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                              content: Text(isEdit
                                  ? 'Address updated'
                                  : 'Address added')),
                        );
                      },
                      style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.accent,
                          foregroundColor: AppColors.textOnAccent,
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(
                                  AppSpacing.buttonRadius))),
                      child: Text(isEdit ? 'Update' : 'Add Address',
                          style: AppTypography.buttonLarge),
                    ),
                  ),
                ]),
          ),
        );
      },
    );
  }

  TextFormField _sheetField(String hint, TextEditingController ctrl,
      String? Function(String?)? validator) {
    return TextFormField(
      controller: ctrl,
      validator: validator,
      style: AppTypography.bodyMedium,
      decoration: InputDecoration(
        hintText: hint,
        filled: true,
        fillColor: AppColors.backgroundGrey,
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: BorderSide.none),
        errorBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: const BorderSide(color: AppColors.error)),
      ),
    );
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
          child: Row(children: [
            IconButton(
                onPressed: () => Navigator.pop(context),
                icon: const Icon(Icons.arrow_back_rounded)),
            Expanded(
                child: Text('Saved Addresses',
                    style: AppTypography.h3.copyWith(fontSize: 18),
                    textAlign: TextAlign.center)),
            const SizedBox(width: 48),
          ]),
        ),
        Expanded(
          child: _addresses.isEmpty
              ? _buildEmpty()
              : ListView.separated(
                  padding: const EdgeInsets.all(AppSpacing.screenHorizontal),
                  itemCount: _addresses.length + 1, // +1 for add button
                  separatorBuilder: (_, __) => const SizedBox(height: 10),
                  itemBuilder: (context, index) {
                    if (index == _addresses.length) return _buildAddButton();
                    return _buildAddressCard(index);
                  },
                ),
        ),
      ]),
    );
  }

  Widget _buildAddressCard(int index) {
    final addr = _addresses[index];
    return Dismissible(
      key: ValueKey(addr.id),
      direction: DismissDirection.endToStart,
      onDismissed: (_) => _deleteAddress(index),
      background: Container(
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 20),
        decoration: BoxDecoration(
            color: AppColors.error, borderRadius: BorderRadius.circular(12)),
        child: const Icon(Icons.delete_outline_rounded,
            color: AppColors.white, size: 24),
      ),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.circular(12),
          border: addr.isDefault
              ? Border.all(color: AppColors.primary, width: 1.5)
              : null,
          boxShadow: AppColors.cardShadow,
        ),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Row(children: [
            Container(
              width: 38,
              height: 38,
              decoration: BoxDecoration(
                  color: addr.isDefault
                      ? AppColors.accentSubtle
                      : AppColors.backgroundGrey,
                  borderRadius: BorderRadius.circular(10)),
              child: Icon(
                  addr.label.toLowerCase() == 'home'
                      ? Icons.home_rounded
                      : Icons.business_rounded,
                  size: 20,
                  color: addr.isDefault
                      ? AppColors.primary
                      : AppColors.textTertiary),
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
            PopupMenuButton<String>(
              onSelected: (v) {
                if (v == 'edit')
                  _showAddEditSheet(existing: addr, index: index);
                if (v == 'default') _setDefault(index);
                if (v == 'delete') _deleteAddress(index);
              },
              itemBuilder: (_) => [
                const PopupMenuItem(value: 'edit', child: Text('Edit')),
                if (!addr.isDefault)
                  const PopupMenuItem(
                      value: 'default', child: Text('Set as Default')),
                const PopupMenuItem(value: 'delete', child: Text('Delete')),
              ],
              child: const Icon(Icons.more_vert_rounded,
                  color: AppColors.textTertiary, size: 20),
            ),
          ]),
        ]),
      ),
    );
  }

  Widget _buildAddButton() {
    return GestureDetector(
      onTap: _addresses.length >= 5
          ? () => ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Maximum 5 addresses allowed')))
          : () => _showAddEditSheet(),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
            color: AppColors.white,
            borderRadius: BorderRadius.circular(12),
            border:
                Border.all(color: AppColors.divider, style: BorderStyle.solid)),
        child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [
          const Icon(Icons.add_rounded, color: AppColors.primary, size: 20),
          const SizedBox(width: 8),
          Text('Add New Address',
              style: AppTypography.buttonMedium
                  .copyWith(color: AppColors.primary)),
        ]),
      ),
    );
  }

  Widget _buildEmpty() {
    return Center(
      child: Column(mainAxisSize: MainAxisSize.min, children: [
        Container(
            width: 100,
            height: 100,
            decoration: const BoxDecoration(
                color: AppColors.backgroundGrey, shape: BoxShape.circle),
            child: Icon(Icons.location_off_rounded,
                size: 48, color: AppColors.textTertiary.withOpacity(0.4))),
        const SizedBox(height: AppSpacing.xl),
        const Text('No saved addresses', style: AppTypography.h2),
        const SizedBox(height: 8),
        const Text('Add an address for quick checkout',
            style: AppTypography.bodySmall),
        const SizedBox(height: AppSpacing.xl),
        LimeCta.small(
            label: 'Add Address',
            icon: Icons.add_rounded,
            onTap: () => _showAddEditSheet()),
      ]),
    );
  }
}
