import 'package:flutter/material.dart';

class NotificationsScreen extends StatelessWidget {
  const NotificationsScreen({super.key});

  static const routeName = '/notifications';

  List<_NotificationItem> get _notifications => [
        _NotificationItem(
          title: 'New item added near you',
          subtitle: 'MacBook Air 2022 - Sabancı University',
          icon: Icons.local_offer_outlined,
          timeAgo: '2h ago',
          unread: true,
        ),
        _NotificationItem(
          title: 'New message',
          subtitle: 'Someone is interested in your bike',
          icon: Icons.message_outlined,
          timeAgo: '5h ago',
          unread: true,
        ),
        _NotificationItem(
          title: 'Price drop alert',
          subtitle: 'Engineering Textbooks now ₺250',
          icon: Icons.price_change_outlined,
          timeAgo: '1d ago',
        ),
        _NotificationItem(
          title: 'Item sold',
          subtitle: 'Your Wireless Mouse has been sold',
          icon: Icons.check_circle_outline,
          timeAgo: '2d ago',
        ),
        _NotificationItem(
          title: 'Someone liked your item',
          subtitle: 'Your desk lamp was added to favorites',
          icon: Icons.favorite_border,
          timeAgo: '3d ago',
        ),
      ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Notifications'),
        actions: [
          TextButton(
            onPressed: () {},
            child: const Text('Mark all as read'),
          ),
        ],
      ),
      body: ListView.separated(
        padding: const EdgeInsets.all(16),
        itemBuilder: (context, index) {
          final notification = _notifications[index];
          return ListTile(
            contentPadding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
            tileColor: notification.unread
                ? Theme.of(context).colorScheme.primary.withOpacity(0.06)
                : null,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            leading: CircleAvatar(
              backgroundColor:
                  Theme.of(context).colorScheme.primary.withOpacity(0.1),
              child: Icon(notification.icon,
                  color: Theme.of(context).colorScheme.primary),
            ),
            title: Text(
              notification.title,
              style: const TextStyle(fontWeight: FontWeight.w600),
            ),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 4),
                Text(notification.subtitle),
                const SizedBox(height: 6),
                Text(
                  notification.timeAgo,
                  style: TextStyle(color: Colors.grey.shade600, fontSize: 12),
                ),
              ],
            ),
            trailing: notification.unread
                ? const Icon(Icons.circle, size: 10, color: Colors.blue)
                : null,
            onTap: () {},
          );
        },
        separatorBuilder: (context, index) => const SizedBox(height: 12),
        itemCount: _notifications.length,
      ),
    );
  }
}

class _NotificationItem {
  _NotificationItem({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.timeAgo,
    this.unread = false,
  });

  final String title;
  final String subtitle;
  final IconData icon;
  final String timeAgo;
  final bool unread;
}
