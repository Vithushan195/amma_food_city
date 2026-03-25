import 'package:flutter/material.dart';
import '../../core/theme/theme.dart';

class _Notification {
  final String id, title, body;
  final String type; // order, promo, system
  final DateTime time;
  bool isRead;

  _Notification(
      {required this.id,
      required this.title,
      required this.body,
      required this.type,
      required this.time,
      this.isRead = false});
}

class NotificationsScreen extends StatefulWidget {
  const NotificationsScreen({super.key});
  @override
  State<NotificationsScreen> createState() => _NotificationsScreenState();
}

class _NotificationsScreenState extends State<NotificationsScreen> {
  final List<_Notification> _notifications = [
    _Notification(
        id: 'n1',
        title: 'Order On the Way',
        body:
            'Your order AMF-294817 is being delivered. Arriving in 15 minutes!',
        type: 'order',
        time: DateTime.now().subtract(const Duration(minutes: 12))),
    _Notification(
        id: 'n2',
        title: '20% Off Spices!',
        body: 'Use code AMMA20 for 20% off all spices this weekend.',
        type: 'promo',
        time: DateTime.now().subtract(const Duration(hours: 3))),
    _Notification(
        id: 'n3',
        title: 'Order Delivered',
        body: 'Your order AMF-283916 has been delivered. Enjoy!',
        type: 'order',
        time: DateTime.now().subtract(const Duration(days: 2)),
        isRead: true),
    _Notification(
        id: 'n4',
        title: 'New Products Added',
        body:
            'Check out fresh arrivals — Sri Lankan and Tamil specialties now in stock.',
        type: 'system',
        time: DateTime.now().subtract(const Duration(days: 3)),
        isRead: true),
    _Notification(
        id: 'n5',
        title: 'Free Delivery This Week',
        body: 'Orders over £30 get free delivery all week. Stock up now!',
        type: 'promo',
        time: DateTime.now().subtract(const Duration(days: 5)),
        isRead: true),
  ];

  int get _unreadCount => _notifications.where((n) => !n.isRead).length;

  void _markAllRead() {
    setState(() {
      for (final n in _notifications) {
        n.isRead = true;
      }
    });
  }

  void _deleteNotification(int index) {
    setState(() => _notifications.removeAt(index));
  }

  IconData _iconFor(String type) => switch (type) {
        'order' => Icons.delivery_dining_rounded,
        'promo' => Icons.local_offer_rounded,
        _ => Icons.notifications_rounded,
      };

  Color _colorFor(String type) => switch (type) {
        'order' => const Color(0xFF1A5276),
        'promo' => AppColors.accentDark,
        _ => AppColors.primary,
      };

  Color _bgFor(String type) => switch (type) {
        'order' => const Color(0xFFD6E9F8),
        'promo' => AppColors.accentSubtle,
        _ => AppColors.backgroundGrey,
      };

  String _timeAgo(DateTime time) {
    final diff = DateTime.now().difference(time);
    if (diff.inMinutes < 60) return '${diff.inMinutes}m ago';
    if (diff.inHours < 24) return '${diff.inHours}h ago';
    if (diff.inDays < 7) return '${diff.inDays}d ago';
    return '${time.day}/${time.month}';
  }

  @override
  Widget build(BuildContext context) {
    final statusBarHeight = MediaQuery.of(context).padding.top;

    return Scaffold(
      backgroundColor: AppColors.offWhite,
      body: Column(children: [
        Container(
          color: AppColors.white,
          padding: EdgeInsets.fromLTRB(8, statusBarHeight + 4, 8, 12),
          child: Row(children: [
            IconButton(
                onPressed: () => Navigator.pop(context),
                icon: const Icon(Icons.arrow_back_rounded)),
            Expanded(
                child:
                    Row(mainAxisAlignment: MainAxisAlignment.center, children: [
              Text('Notifications',
                  style: AppTypography.h3.copyWith(fontSize: 18)),
              if (_unreadCount > 0) ...[
                const SizedBox(width: 8),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
                  decoration: BoxDecoration(
                      color: AppColors.accent,
                      borderRadius: BorderRadius.circular(10)),
                  child: Text('$_unreadCount',
                      style: AppTypography.badge.copyWith(
                          color: AppColors.textOnAccent, fontSize: 11)),
                ),
              ],
            ])),
            if (_unreadCount > 0)
              TextButton(
                  onPressed: _markAllRead,
                  child: Text('Read all',
                      style: AppTypography.bodySmall.copyWith(
                          color: AppColors.primary,
                          fontWeight: FontWeight.w600)))
            else
              const SizedBox(width: 48),
          ]),
        ),
        Expanded(
          child: _notifications.isEmpty
              ? Center(
                  child: Column(mainAxisSize: MainAxisSize.min, children: [
                  Container(
                      width: 100,
                      height: 100,
                      decoration: const BoxDecoration(
                          color: AppColors.backgroundGrey,
                          shape: BoxShape.circle),
                      child: Icon(Icons.notifications_off_rounded,
                          size: 48,
                          color: AppColors.textTertiary.withOpacity(0.4))),
                  const SizedBox(height: AppSpacing.xl),
                  const Text('No notifications', style: AppTypography.h2),
                  const SizedBox(height: 8),
                  const Text("You're all caught up!",
                      style: AppTypography.bodySmall),
                ]))
              : ListView.separated(
                  padding: const EdgeInsets.all(AppSpacing.screenHorizontal),
                  itemCount: _notifications.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 8),
                  itemBuilder: (context, index) {
                    final n = _notifications[index];
                    return Dismissible(
                      key: ValueKey(n.id),
                      direction: DismissDirection.endToStart,
                      onDismissed: (_) => _deleteNotification(index),
                      background: Container(
                        alignment: Alignment.centerRight,
                        padding: const EdgeInsets.only(right: 20),
                        decoration: BoxDecoration(
                            color: AppColors.error,
                            borderRadius: BorderRadius.circular(12)),
                        child: const Icon(Icons.delete_outline_rounded,
                            color: AppColors.white),
                      ),
                      child: GestureDetector(
                        onTap: () => setState(() => n.isRead = true),
                        child: Container(
                          padding: const EdgeInsets.all(14),
                          decoration: BoxDecoration(
                            color: n.isRead
                                ? AppColors.white
                                : AppColors.accentSubtle.withOpacity(0.3),
                            borderRadius: BorderRadius.circular(12),
                            border: !n.isRead
                                ? Border.all(
                                    color: AppColors.accent.withOpacity(0.3))
                                : null,
                            boxShadow: AppColors.cardShadow,
                          ),
                          child: Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Container(
                                  width: 40,
                                  height: 40,
                                  decoration: BoxDecoration(
                                      color: _bgFor(n.type),
                                      borderRadius: BorderRadius.circular(10)),
                                  child: Icon(_iconFor(n.type),
                                      size: 20, color: _colorFor(n.type)),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                    child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                      Row(children: [
                                        Expanded(
                                            child: Text(n.title,
                                                style: AppTypography.bodyMedium
                                                    .copyWith(
                                                        fontWeight: n.isRead
                                                            ? FontWeight.w500
                                                            : FontWeight
                                                                .w700))),
                                        Text(_timeAgo(n.time),
                                            style: AppTypography.caption),
                                      ]),
                                      const SizedBox(height: 4),
                                      Text(n.body,
                                          style: AppTypography.bodySmall
                                              .copyWith(height: 1.4),
                                          maxLines: 2,
                                          overflow: TextOverflow.ellipsis),
                                    ])),
                                if (!n.isRead)
                                  Container(
                                      width: 8,
                                      height: 8,
                                      margin: const EdgeInsets.only(
                                          top: 6, left: 8),
                                      decoration: const BoxDecoration(
                                          color: AppColors.accent,
                                          shape: BoxShape.circle)),
                              ]),
                        ),
                      ),
                    );
                  },
                ),
        ),
      ]),
    );
  }
}
