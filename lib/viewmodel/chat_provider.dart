import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:worker_bee/model/chat_model.dart';

class ChatProvider extends ChangeNotifier {
  final _supabase = Supabase.instance.client;
  Map<String, List<ChatMessage>> _conversations = {};

  Map<String, List<ChatMessage>> get conversations => _conversations;

  Future<void> loadConversations() async {
    try {
      final currentUserId = _supabase.auth.currentUser!.id;
      final response = await _supabase
          .from('messages')
          .select()
          .or('sender_id.eq.$currentUserId,receiver_id.eq.$currentUserId')
          .order('created_at');

      final messages =
          response.map((msg) => ChatMessage.fromJson(msg)).toList();

      // Group messages by conversation
      _conversations = {};
      for (var message in messages) {
        final conversationId = message.senderId == currentUserId
            ? message.receiverId
            : message.senderId;

        if (!_conversations.containsKey(conversationId)) {
          _conversations[conversationId] = [];
        }
        _conversations[conversationId]!.add(message);
      }

      notifyListeners();
    } catch (e) {
      debugPrint('Error loading conversations: $e');
    }
  }
}
