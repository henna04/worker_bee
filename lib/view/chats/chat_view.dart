import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:worker_bee/view/chatDetails/chat_details_view.dart';

class ChatView extends StatefulWidget {
  const ChatView({super.key});

  @override
  State<ChatView> createState() => _ChatViewState();
}

class _ChatViewState extends State<ChatView> {
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';
  final _supabase = Supabase.instance.client;
  late final String _currentUserId;

  @override
  void initState() {
    super.initState();
    _currentUserId = _supabase.auth.currentUser!.id;
  }

  Stream<List<Map<String, dynamic>>> _getConversationsStream() {
    return _supabase
        .from('messages')
        .stream(primaryKey: ['id'])
        .order('created_at')
        .map((List<Map<String, dynamic>> messages) {
          // Filter messages for current user
          final userMessages = messages
              .where((message) =>
                  message['sender_id'] == _currentUserId ||
                  message['receiver_id'] == _currentUserId)
              .toList();

          final Map<String, Map<String, dynamic>> conversations = {};

          // Sort messages by date (newest first)
          userMessages.sort((a, b) => DateTime.parse(b['created_at'])
              .compareTo(DateTime.parse(a['created_at'])));

          for (final message in userMessages) {
            final otherUserId = message['sender_id'] == _currentUserId
                ? message['receiver_id']
                : message['sender_id'];

            if (!conversations.containsKey(otherUserId) ||
                DateTime.parse(message['created_at']).isAfter(
                    DateTime.parse(conversations[otherUserId]!['timestamp']))) {
              conversations[otherUserId] = {
                'last_message': message['message'],
                'timestamp': message['created_at'],
                'other_user_id': otherUserId,
                'is_sender': message['sender_id'] == _currentUserId,
              };
            }
          }

          final sortedConversations = conversations.values.toList()
            ..sort((a, b) => DateTime.parse(b['timestamp'])
                .compareTo(DateTime.parse(a['timestamp'])));

          return sortedConversations;
        });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Chats'),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'Search chats...',
                prefixIcon: const Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                filled: true,
                fillColor: theme.colorScheme.surface,
                contentPadding: const EdgeInsets.symmetric(horizontal: 16),
                suffixIcon: _searchQuery.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear),
                        onPressed: () {
                          setState(() {
                            _searchController.clear();
                            _searchQuery = '';
                          });
                        },
                      )
                    : null,
              ),
              onChanged: (value) {
                setState(() {
                  _searchQuery = value.toLowerCase();
                });
              },
            ),
          ),
          Expanded(
            child: StreamBuilder<List<Map<String, dynamic>>>(
              stream: _getConversationsStream(),
              builder: (context, snapshot) {
                if (snapshot.hasError) {
                  return Center(child: Text('Error: ${snapshot.error}'));
                }

                if (!snapshot.hasData) {
                  return const Center(child: CircularProgressIndicator());
                }

                final conversations = snapshot.data!;

                if (conversations.isEmpty) {
                  return const Center(child: Text('No conversations yet'));
                }

                return ListView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  itemCount: conversations.length,
                  itemBuilder: (context, index) {
                    final conversation = conversations[index];

                    return FutureBuilder<Map<String, dynamic>>(
                      future: _supabase
                          .from('users')
                          .select()
                          .eq('id', conversation['other_user_id'])
                          .single(),
                      builder: (context, userSnapshot) {
                        if (!userSnapshot.hasData) {
                          return const SizedBox.shrink();
                        }

                        final user = userSnapshot.data!;
                        final userName = user['user_name'] ?? 'Unknown User';

                        // Filter based on search query
                        if (_searchQuery.isNotEmpty &&
                            !userName
                                .toLowerCase()
                                .contains(_searchQuery.toLowerCase()) &&
                            !conversation['last_message']
                                .toString()
                                .toLowerCase()
                                .contains(_searchQuery.toLowerCase())) {
                          return const SizedBox.shrink();
                        }

                        return Card(
                          margin: const EdgeInsets.only(bottom: 8),
                          child: ListTile(
                            leading: CircleAvatar(
                              backgroundImage:
                                  NetworkImage(user['image_url'] ?? ''),
                              backgroundColor: Colors.grey[300],
                            ),
                            title: Text(userName),
                            subtitle: Row(
                              children: [
                                if (conversation['is_sender'])
                                  const Padding(
                                    padding: EdgeInsets.only(right: 4),
                                    child: Icon(Icons.done, size: 16),
                                  ),
                                Expanded(
                                  child: Text(
                                    conversation['last_message'] ?? '',
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                              ],
                            ),
                            trailing: Text(
                              _formatTimestamp(conversation['timestamp']),
                              style: TextStyle(
                                color: theme.textTheme.bodySmall?.color,
                                fontSize: 12,
                              ),
                            ),
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => ChatDetailsView(
                                    workerId: conversation['other_user_id'],
                                    workerName: userName,
                                    workerImage: user['image_url'],
                                  ),
                                ),
                              );
                            },
                          ),
                        );
                      },
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  String _formatTimestamp(String timestamp) {
    final now = DateTime.now();
    final messageTime = DateTime.parse(timestamp).toLocal();

    if (now.difference(messageTime).inDays == 0) {
      // Today - show time
      return '${messageTime.hour.toString().padLeft(2, '0')}:${messageTime.minute.toString().padLeft(2, '0')}';
    } else if (now.difference(messageTime).inDays == 1) {
      // Yesterday
      return 'Yesterday';
    } else if (now.difference(messageTime).inDays < 7) {
      // Within last week - show day name
      final weekdays = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
      return weekdays[messageTime.weekday - 1];
    } else {
      // Older - show date
      return '${messageTime.day}/${messageTime.month}';
    }
  }
}
