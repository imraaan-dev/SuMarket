import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:intl/intl.dart';
import '../services/firestore_service.dart';
import 'direct_message_screen.dart';

class AllMessagesScreen extends StatelessWidget {
  const AllMessagesScreen({super.key});
  static const routeName = '/main/all-messages';

  String _formatTime(DateTime timestamp) {
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

  @override
  Widget build(BuildContext context) {
    final firestoreService =
        Provider.of<FirestoreService>(context, listen: false);
    final textTheme = Theme.of(context).textTheme;

    return Scaffold(
      appBar: AppBar(title: const Text("Messages")),
      body: StreamBuilder<List<Map<String, dynamic>>>(
        stream: firestoreService.streamChatRooms(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }

          final chatRooms = snapshot.data ?? [];

          if (chatRooms.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.chat_bubble_outline,
                      size: 64, color: Colors.grey[400]),
                  const SizedBox(height: 16),
                  Text(
                    'No messages yet',
                    style: TextStyle(color: Colors.grey[600], fontSize: 16),
                  ),
                ],
              ),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.all(8),
            itemCount: chatRooms.length,
            itemBuilder: (context, index) {
              final chat = chatRooms[index];
              final participants =
                  Map<String, dynamic>.from(chat['participantNames'] ?? {});
              final myUid = FirebaseAuth.instance.currentUser?.uid;

              // Find the OTHER user's name
              String otherUserName = 'User';
              String otherUserId = '';
              participants.forEach((uid, name) {
                if (uid != myUid) {
                  otherUserName = name;
                  otherUserId = uid;
                }
              });

              final lastMessage = chat['lastMessage'] ?? '';
              final time = (chat['lastMessageTime'] as dynamic)?.toDate() ??
                  DateTime.now();

              return Card(
                margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                child: ListTile(
                  leading: CircleAvatar(
                    child: Text(otherUserName.isNotEmpty
                        ? otherUserName[0].toUpperCase()
                        : '?'),
                  ),
                  title: Row(
                    children: [
                      Expanded(
                        child: Text(
                          otherUserName,
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                      ),
                      if (chat['listingTitle'] != null)
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 2,
                          ),
                          decoration: BoxDecoration(
                            color: Theme.of(
                              context,
                            ).colorScheme.primaryContainer,
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Text(
                            chat['listingTitle'],
                            style: TextStyle(
                              fontSize: 10,
                              color: Theme.of(
                                context,
                              ).colorScheme.onPrimaryContainer,
                            ),
                          ),
                        ),
                    ],
                  ),
                  subtitle: Text(
                    lastMessage,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  trailing: Text(
                    _formatTime(time),
                    style: TextStyle(color: Colors.grey[600], fontSize: 12),
                  ),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => DirectMessageScreen(
                          chatId: chat['id'],
                          otherUserName: otherUserName,
                          otherUserId: otherUserId,
                        ),
                      ),
                    );
                  },
                ),
              );
            },
          );
        },
      ),
    );
  }
}
