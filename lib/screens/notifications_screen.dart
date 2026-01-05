import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../services/firestore_service.dart';
import 'direct_message_screen.dart';

class NotificationsScreen extends StatelessWidget {
  const NotificationsScreen({super.key});

  static const routeName = '/notifications';

  String _formatTimeAgo(DateTime timestamp) {
    final now = DateTime.now();
    final difference = now.difference(timestamp);

    if (difference.inDays > 7) {
      return DateFormat('MMM d').format(timestamp);
    } else if (difference.inDays >= 1) {
      return '${difference.inDays}d ago';
    } else if (difference.inHours >= 1) {
      return '${difference.inHours}h ago';
    } else if (difference.inMinutes >= 1) {
      return '${difference.inMinutes}m ago';
    } else {
      return 'Just now';
    }
  }

  IconData _getIconForType(String type) {
    switch (type) {
      case 'favorite':
        return Icons.favorite_border;
      case 'message':
        return Icons.message_outlined;
      case 'price_drop':
        return Icons.price_change_outlined;
      case 'sold':
        return Icons.check_circle_outline;
      default:
        return Icons.notifications_none;
    }
  }

  @override
  Widget build(BuildContext context) {
    final firestoreService = FirestoreService();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Notifications'),
        // actions: [
        //   TextButton(
        //     onPressed: () {},
        //     child: const Text('Mark all as read'),
        //   ),
        // ],
      ),
      body: StreamBuilder<List<Map<String, dynamic>>>(
        stream: firestoreService.streamNotifications(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }

          final notifications = snapshot.data ?? [];

          if (notifications.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.notifications_off_outlined,
                      size: 64, color: Colors.grey[400]),
                  const SizedBox(height: 16),
                  Text(
                    'No notifications yet',
                    style: TextStyle(color: Colors.grey[600], fontSize: 16),
                  ),
                ],
              ),
            );
          }

          return ListView.separated(
            padding: const EdgeInsets.all(16),
            itemCount: notifications.length,
            separatorBuilder: (context, index) => const SizedBox(height: 12),
            itemBuilder: (context, index) {
              final notification = notifications[index];
              final timestamp = (notification['timestamp'] as dynamic).toDate();
              final isRead = notification['isRead'] ?? false;
              final type = notification['type'] ?? 'system';

              return ListTile(
                contentPadding:
                    const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
                tileColor: !isRead
                    ? Theme.of(context)
                        .colorScheme
                        .primary
                        .withOpacity(0.06)
                    : null,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                leading: CircleAvatar(
                  backgroundColor: Theme.of(context)
                      .colorScheme
                      .primary
                      .withOpacity(0.1),
                  child: Icon(_getIconForType(type),
                      color: Theme.of(context).colorScheme.primary),
                ),
                title: Text(
                  notification['title'] ?? '',
                  style: const TextStyle(fontWeight: FontWeight.w600),
                ),
                subtitle: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 4),
                    Text(notification['body'] ?? ''),
                    const SizedBox(height: 6),
                    Text(
                      _formatTimeAgo(timestamp),
                      style:
                          TextStyle(color: Colors.grey.shade600, fontSize: 12),
                    ),
                  ],
                ),
                trailing: !isRead
                    ? const Icon(Icons.circle, size: 10, color: Colors.blue)
                    : null,
                onTap: () {
                  if (!isRead) {
                    firestoreService.markNotificationAsRead(notification['id']);
                  }

                  if (type == 'message' &&
                      notification['relatedItemId'] != null) {
                    final chatId = notification['relatedItemId'] as String;
                    final otherUserId = notification['senderId'] as String?;
                    final otherUserName = notification['senderName'] as String?;

                    if (otherUserId != null && otherUserName != null) {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => DirectMessageScreen(
                            chatId: chatId,
                            otherUserName: otherUserName,
                            otherUserId: otherUserId,
                          ),
                        ),
                      );
                    }
                  }
                },
              );
            },
          );
        },
      ),
    );
  }
}
