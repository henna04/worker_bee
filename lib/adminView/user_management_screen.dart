import 'package:flutter/material.dart';


class UserManagementScreen extends StatelessWidget {
  const UserManagementScreen({super.key});


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('User Management')),
      body:  ListView.builder(
            itemCount: 2,
            itemBuilder: (context, index) {
              return UserTile(
                name: "hinas",
                email: "hinas@gmail.com",
                onBlock: () {
                  // Implement block functionality
                },
              );
            },
          ),
    );
  }
}



class UserTile extends StatelessWidget {
  final String name;
  final String email;
  final VoidCallback onBlock;

  const UserTile({super.key, required this.name, required this.email, required this.onBlock});

  @override
  Widget build(BuildContext context) {
    return ListTile(
      title: Text(name),
      subtitle: Text(email),
      trailing: IconButton(
        icon: const Icon(Icons.block),
        onPressed: onBlock,
      ),
    );
  }
}