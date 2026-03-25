import 'package:flutter/material.dart';
import '../../core/theme/theme.dart';

class ContactUsScreen extends StatefulWidget {
  const ContactUsScreen({super.key});
  @override
  State<ContactUsScreen> createState() => _ContactUsScreenState();
}

class _ContactUsScreenState extends State<ContactUsScreen> {
  final _nameCtrl = TextEditingController();
  final _emailCtrl = TextEditingController();
  final _messageCtrl = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  String _selectedTopic = 'General Enquiry';
  bool _isLoading = false;
  bool _sent = false;

  final _topics = [
    'General Enquiry',
    'Order Issue',
    'Delivery Problem',
    'Payment Issue',
    'Product Feedback',
    'Other'
  ];

  @override
  void dispose() {
    _nameCtrl.dispose();
    _emailCtrl.dispose();
    _messageCtrl.dispose();
    super.dispose();
  }

  void _submit() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _isLoading = true);
    await Future.delayed(const Duration(seconds: 1));
    if (mounted)
      setState(() {
        _isLoading = false;
        _sent = true;
      });
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
                child: Text('Contact Us',
                    style: AppTypography.h3.copyWith(fontSize: 18),
                    textAlign: TextAlign.center)),
            const SizedBox(width: 48),
          ]),
        ),
        Expanded(
          child: _sent ? _buildSuccess() : _buildForm(),
        ),
      ]),
    );
  }

  Widget _buildForm() {
    return ListView(
      padding: const EdgeInsets.all(AppSpacing.screenHorizontal),
      children: [
        // Quick contact cards
        const Row(children: [
          Expanded(
              child: _ContactCard(
                  icon: Icons.email_outlined,
                  label: 'Email',
                  value: 'support@\nammafoodcity.co.uk',
                  color: Color(0xFF1A5276),
                  bg: Color(0xFFD6E9F8))),
          SizedBox(width: 10),
          Expanded(
              child: _ContactCard(
                  icon: Icons.phone_outlined,
                  label: 'Phone',
                  value: '+44 141\n000 0000',
                  color: AppColors.primary,
                  bg: AppColors.accentSubtle)),
        ]),
        const SizedBox(height: 10),
        const Row(children: [
          Expanded(
              child: _ContactCard(
                  icon: Icons.schedule_rounded,
                  label: 'Hours',
                  value: 'Mon-Sun\n9AM - 9PM',
                  color: Color(0xFF856404),
                  bg: Color(0xFFFFF3CD))),
          SizedBox(width: 10),
          Expanded(
              child: _ContactCard(
                  icon: Icons.location_on_outlined,
                  label: 'Visit',
                  value: '3 Clarence St\nPaisley PA1',
                  color: Color(0xFF721C24),
                  bg: Color(0xFFF8D7DA))),
        ]),

        const SizedBox(height: AppSpacing.xxl),

        // Message form
        Text('Send us a message',
            style: AppTypography.h2.copyWith(fontSize: 18)),
        const SizedBox(height: 4),
        const Text('We usually respond within 24 hours',
            style: AppTypography.bodySmall),
        const SizedBox(height: AppSpacing.lg),

        Form(
          key: _formKey,
          child: Column(children: [
            _buildField('Name', _nameCtrl, Icons.person_outline_rounded,
                (v) => v!.isEmpty ? 'Required' : null),
            const SizedBox(height: 12),
            _buildField('Email', _emailCtrl, Icons.email_outlined, (v) {
              if (v!.isEmpty) return 'Required';
              if (!v.contains('@')) return 'Invalid email';
              return null;
            }, keyboardType: TextInputType.emailAddress),
            const SizedBox(height: 12),

            // Topic dropdown
            Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text('Topic',
                  style: AppTypography.label.copyWith(
                      fontWeight: FontWeight.w600,
                      color: AppColors.textPrimary)),
              const SizedBox(height: 6),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 14),
                decoration: BoxDecoration(
                    color: AppColors.white,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: AppColors.divider)),
                child: DropdownButtonHideUnderline(
                  child: DropdownButton<String>(
                    value: _selectedTopic,
                    isExpanded: true,
                    style: AppTypography.bodyMedium,
                    items: _topics
                        .map((t) => DropdownMenuItem(value: t, child: Text(t)))
                        .toList(),
                    onChanged: (v) => setState(() => _selectedTopic = v!),
                  ),
                ),
              ),
            ]),

            const SizedBox(height: 12),

            // Message
            Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text('Message',
                  style: AppTypography.label.copyWith(
                      fontWeight: FontWeight.w600,
                      color: AppColors.textPrimary)),
              const SizedBox(height: 6),
              TextFormField(
                controller: _messageCtrl,
                maxLines: 5,
                validator: (v) =>
                    v!.isEmpty ? 'Please enter your message' : null,
                style: AppTypography.bodyMedium,
                decoration: InputDecoration(
                  hintText: 'Describe your issue or question...',
                  filled: true,
                  fillColor: AppColors.white,
                  contentPadding: const EdgeInsets.all(14),
                  border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: const BorderSide(color: AppColors.divider)),
                  enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: const BorderSide(color: AppColors.divider)),
                  focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: const BorderSide(
                          color: AppColors.primary, width: 1.5)),
                  errorBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: const BorderSide(color: AppColors.error)),
                ),
              ),
            ]),

            const SizedBox(height: AppSpacing.xl),

            SizedBox(
              width: double.infinity,
              height: AppSpacing.buttonHeight,
              child: ElevatedButton(
                onPressed: _isLoading ? null : _submit,
                style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.accent,
                    foregroundColor: AppColors.textOnAccent,
                    shape: RoundedRectangleBorder(
                        borderRadius:
                            BorderRadius.circular(AppSpacing.buttonRadius))),
                child: _isLoading
                    ? const SizedBox(
                        width: 22,
                        height: 22,
                        child: CircularProgressIndicator(
                            strokeWidth: 2.5, color: AppColors.textOnAccent))
                    : const Text('Send Message',
                        style: AppTypography.buttonLarge),
              ),
            ),
          ]),
        ),
        const SizedBox(height: AppSpacing.xxxl),
      ],
    );
  }

  Widget _buildField(String label, TextEditingController ctrl, IconData icon,
      String? Function(String?) validator,
      {TextInputType? keyboardType}) {
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Text(label,
          style: AppTypography.label.copyWith(
              fontWeight: FontWeight.w600, color: AppColors.textPrimary)),
      const SizedBox(height: 6),
      TextFormField(
        controller: ctrl,
        validator: validator,
        keyboardType: keyboardType,
        style: AppTypography.bodyMedium,
        decoration: InputDecoration(
          prefixIcon: Padding(
              padding: const EdgeInsets.only(left: 14, right: 10),
              child: Icon(icon, size: 20, color: AppColors.textTertiary)),
          prefixIconConstraints: const BoxConstraints(minWidth: 0),
          filled: true,
          fillColor: AppColors.white,
          contentPadding:
              const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: AppColors.divider)),
          enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: AppColors.divider)),
          focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide:
                  const BorderSide(color: AppColors.primary, width: 1.5)),
          errorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: AppColors.error)),
        ),
      ),
    ]);
  }

  Widget _buildSuccess() {
    return Center(
      child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(mainAxisSize: MainAxisSize.min, children: [
            Container(
                width: 90,
                height: 90,
                decoration: const BoxDecoration(
                    color: AppColors.accentSubtle, shape: BoxShape.circle),
                child: const Icon(Icons.check_circle_rounded,
                    size: 48, color: AppColors.primary)),
            const SizedBox(height: AppSpacing.xl),
            Text('Message Sent!',
                style: AppTypography.h1.copyWith(
                    fontFamily: AppTypography.fontHeading, fontSize: 24)),
            const SizedBox(height: 8),
            Text("We'll get back to you within 24 hours at\n${_emailCtrl.text}",
                style: AppTypography.bodyMedium
                    .copyWith(color: AppColors.textSecondary, height: 1.5),
                textAlign: TextAlign.center),
            const SizedBox(height: AppSpacing.xxl),
            SizedBox(
              width: double.infinity,
              height: AppSpacing.buttonHeight,
              child: ElevatedButton(
                onPressed: () => Navigator.pop(context),
                style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.accent,
                    foregroundColor: AppColors.textOnAccent,
                    shape: RoundedRectangleBorder(
                        borderRadius:
                            BorderRadius.circular(AppSpacing.buttonRadius))),
                child: const Text('Back to Profile',
                    style: AppTypography.buttonLarge),
              ),
            ),
          ])),
    );
  }
}

class _ContactCard extends StatelessWidget {
  final IconData icon;
  final String label, value;
  final Color color, bg;
  const _ContactCard(
      {required this.icon,
      required this.label,
      required this.value,
      required this.color,
      required this.bg});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration:
          BoxDecoration(color: bg, borderRadius: BorderRadius.circular(14)),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Icon(icon, size: 22, color: color),
        const SizedBox(height: 8),
        Text(label,
            style: AppTypography.caption
                .copyWith(color: color, fontWeight: FontWeight.w600)),
        const SizedBox(height: 2),
        Text(value,
            style: AppTypography.bodySmall.copyWith(
                color: color,
                fontWeight: FontWeight.w500,
                fontSize: 11,
                height: 1.3)),
      ]),
    );
  }
}
