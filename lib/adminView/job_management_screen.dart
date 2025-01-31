import 'package:flutter/material.dart';

class JobManagementScreen extends StatelessWidget {
  const JobManagementScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Job Management'),
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
          return JobTile(
            title: "painter",
            description: "need worker",
            status: "false",
            onDelete: () {},
          );
        },
      ),
    );
  }
}

class JobTile extends StatelessWidget {
  final String title;
  final String description;
  final String status;
  final VoidCallback onDelete;

  const JobTile({super.key, 
    required this.title,
    required this.description,
    required this.status,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
      child: ListTile(
        title: Text(title),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Description: $description'),
            Text('Status: $status'),
          ],
        ),
        trailing: IconButton(
          icon: const Icon(Icons.delete, color: Colors.red),
          onPressed: onDelete,
        ),
      ),
    );
  }
}
