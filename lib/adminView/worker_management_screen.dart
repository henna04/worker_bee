import 'package:flutter/material.dart';

class WorkerManagementScreen extends StatelessWidget {
  const WorkerManagementScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Worker Management'),
        actions: [
          IconButton(
            icon: const Icon(Icons.search),
            onPressed: () {
              // Implement search functionality
            },
          ),
        ],
      ),
      body: ListView.builder(
        itemCount: 2,
        itemBuilder: (context, index) {
          return WorkerTile(
            name: "worker1",
            skills: "Flutter",
            isVerified: true,
            onVerify: () {},
            onBlock: () {},
          );
        },
      ),
    );
  }
}

class WorkerTile extends StatelessWidget {
  final String name;
  final String skills;
  final bool isVerified;
  final VoidCallback onVerify;
  final VoidCallback onBlock;

  const WorkerTile({super.key, 
    required this.name,
    required this.skills,
    required this.isVerified,
    required this.onVerify,
    required this.onBlock,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
      child: ListTile(
        title: Text(name),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Skills: $skills'),
            Text('Status: ${isVerified ? 'Verified' : 'Not Verified'}'),
          ],
        ),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            IconButton(
              icon: Icon(Icons.verified,
                  color: isVerified ? Colors.green : Colors.grey),
              onPressed: onVerify,
            ),
            IconButton(
              icon: const Icon(Icons.block, color: Colors.red),
              onPressed: onBlock,
            ),
          ],
        ),
      ),
    );
  }
}
