import 'package:flutter/material.dart';
import 'package:worker_bee/view/chatDetails/chat_details_view.dart';

class ChatView extends StatelessWidget {
  const ChatView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Chats'),
      ),
      body: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: 10, // Replace with the actual number of chat items
        itemBuilder: (context, index) {
          return Card(
            child: ListTile(
              leading: const CircleAvatar(
                backgroundImage: NetworkImage(
                    'https://plus.unsplash.com/premium_photo-1689568126014-06fea9d5d341?q=80&w=2070&auto=format&fit=crop&ixlib=rb-4.0.3&ixid=M3wxMjA3fDB8MHxwaG90by1wYWdlfHx8fGVufDB8fHx8fA%3D%3D'), // Replace with the actual image URL
              ),
              title: Text('User $index'), // Replace with the actual user name
              subtitle: Text(
                  'Last message from user $index'), // Replace with the actual last message
              trailing: const Text('12:00 PM'), // Replace with the actual time
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => ChatDetailsView(
                        userName: 'User $index'), // Pass the actual user name
                  ),
                );
              },
            ),
          );
        },
      ),
    );
  }
}
