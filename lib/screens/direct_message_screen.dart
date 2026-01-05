import 'package:flutter/material.dart';
import 'package:grouped_list/grouped_list.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../services/firestore_service.dart';

class DirectMessageScreen extends StatelessWidget {
  const DirectMessageScreen({
    super.key,
    required this.chatId,
    required this.otherUserName,
    required this.otherUserId,
  });

  final String chatId;
  final String otherUserName;
  final String otherUserId;

  static const routeName = '/direct-message';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(otherUserName)),
      body: MessagesScreen(
        chatId: chatId,
        otherUserId: otherUserId,
        otherUserName: otherUserName,
      ),
    );
  }
}

class MessagesScreen extends StatefulWidget {
  const MessagesScreen({
    super.key,
    required this.chatId,
    required this.otherUserId,
    required this.otherUserName,
  });

  final String chatId;
  final String otherUserId;
  final String otherUserName;

  @override
  State<MessagesScreen> createState() => _MessagesScreenState();
}

class _MessagesScreenState extends State<MessagesScreen> {
  final TextEditingController _controller = TextEditingController();

  void _sendMessage() {
    if (_controller.text.trim().isEmpty) return;

    final text = _controller.text.trim();
    _controller.clear();

    final firestore = context.read<FirestoreService>();
    firestore
        .sendMessage(
          chatId: widget.chatId,
          text: text,
          otherUserId: widget.otherUserId,
        )
        .catchError((e) {
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(SnackBar(content: Text('Failed to send: $e')));
        });
  }

  @override
  Widget build(BuildContext context) {
    final firestore = context.read<FirestoreService>();
    final myUid = FirebaseAuth.instance.currentUser?.uid;

    return Column(
      children: [
        Expanded(
          child: StreamBuilder<List<Map<String, dynamic>>>(
            stream: firestore.streamMessages(widget.chatId),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              }
              if (snapshot.hasError) {
                return Center(child: Text('Error: ${snapshot.error}'));
              }

              final messages = snapshot.data ?? [];

              return Column(
                children: [
                  // Listing Header
                  StreamBuilder<DocumentSnapshot<Map<String, dynamic>>>(
                    stream: FirebaseFirestore.instance
                        .collection('chat_rooms')
                        .doc(widget.chatId)
                        .snapshots(),
                    builder: (context, chatSnapshot) {
                      if (!chatSnapshot.hasData || !chatSnapshot.data!.exists) {
                        return const SizedBox.shrink();
                      }
                      final chatData = chatSnapshot.data!.data();
                      final listingTitle = chatData?['listingTitle'] as String?;
                      final listingImageUrl =
                          chatData?['listingImageUrl'] as String?;

                      if (listingTitle == null) return const SizedBox.shrink();

                      return Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Theme.of(
                            context,
                          ).colorScheme.surfaceContainerHighest.withOpacity(
                            0.5,
                          ),
                          border: Border(
                            bottom: BorderSide(
                              color: Theme.of(context).dividerColor,
                            ),
                          ),
                        ),
                        child: Row(
                          children: [
                            if (listingImageUrl != null &&
                                listingImageUrl.isNotEmpty)
                              ClipRRect(
                                borderRadius: BorderRadius.circular(8),
                                child: Image.network(
                                  listingImageUrl,
                                  width: 40,
                                  height: 40,
                                  fit: BoxFit.cover,
                                  errorBuilder: (_, __, ___) => const Icon(
                                    Icons.image_outlined,
                                  ),
                                ),
                              )
                            else
                              const Icon(Icons.image_outlined, size: 40),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Inquiry about:',
                                    style: TextStyle(
                                      fontSize: 10,
                                      color: Colors.grey[600],
                                    ),
                                  ),
                                  Text(
                                    listingTitle,
                                    style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 14,
                                    ),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                  Expanded(
                    child: GroupedListView<Map<String, dynamic>, DateTime>(
                      reverse: false,
                      order: GroupedListOrder.ASC,
                      elements: messages,
                      groupBy: (message) {
                        final date = (message['timestamp'] as dynamic).toDate();
                        return DateTime(date.year, date.month, date.day);
                      },
                      groupHeaderBuilder: (message) {
                        final date = (message['timestamp'] as dynamic).toDate();
                        return SizedBox(
                          height: 40,
                          child: Center(
                            child: Card(
                              color: Theme.of(
                                context,
                              ).colorScheme.surfaceContainerHighest,
                              child: Padding(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 12,
                                  vertical: 4,
                                ),
                                child: Text(
                                  DateFormat.yMMMd().format(date),
                                  style: const TextStyle(fontSize: 12),
                                ),
                              ),
                            ),
                          ),
                        );
                      },
                      itemBuilder: (context, message) {
                        final sentByMe = message['senderId'] == myUid;
                        return Align(
                          alignment: sentByMe
                              ? Alignment.centerRight
                              : Alignment.centerLeft,
                          child: Container(
                            constraints: BoxConstraints(
                              maxWidth: MediaQuery.of(context).size.width * 0.75,
                            ),
                            margin: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 4,
                            ),
                            child: Card(
                              elevation: 1,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.only(
                                  topLeft: const Radius.circular(16),
                                  topRight: const Radius.circular(16),
                                  bottomLeft: sentByMe
                                      ? const Radius.circular(16)
                                      : Radius.zero,
                                  bottomRight: sentByMe
                                      ? Radius.zero
                                      : const Radius.circular(16),
                                ),
                              ),
                              color: sentByMe
                                  ? Theme.of(context).colorScheme.primary
                                  : Theme.of(
                                      context,
                                    ).colorScheme.surfaceContainerHighest,
                              child: Padding(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 16,
                                  vertical: 10,
                                ),
                                child: Text(
                                  message['text'] ?? '',
                                  style: TextStyle(
                                    color: sentByMe
                                        ? Colors.white
                                        : Theme.of(
                                            context,
                                          ).colorScheme.onSurface,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ],
              );
            },
          ),
        ),
        Container(
          padding: const EdgeInsets.all(8.0),
          decoration: BoxDecoration(
            color: Theme.of(context).scaffoldBackgroundColor,
            boxShadow: [
              BoxShadow(
                offset: const Offset(0, -2),
                blurRadius: 4,
                color: Colors.black.withValues(alpha: 0.05),
              ),
            ],
          ),
          child: SafeArea(
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _controller,
                    textCapitalization: TextCapitalization.sentences,
                    decoration: const InputDecoration(
                      hintText: "Type a message...",
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.all(Radius.circular(24)),
                      ),
                      contentPadding: EdgeInsets.symmetric(
                        horizontal: 20,
                        vertical: 10,
                      ),
                    ),
                    onSubmitted: (_) => _sendMessage(),
                  ),
                ),
                const SizedBox(width: 8),
                IconButton.filled(
                  onPressed: _sendMessage,
                  icon: const Icon(Icons.send),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
