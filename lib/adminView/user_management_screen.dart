import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class UserManagementScreen extends StatefulWidget {
  const UserManagementScreen({super.key});

  @override
  State<UserManagementScreen> createState() => _UserManagementScreenState();
}

class _UserManagementScreenState extends State<UserManagementScreen> {
  final SupabaseClient _supabase = Supabase.instance.client;
  List<Map<String, dynamic>> _workers = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchWorkers();
  }

  Future<void> _fetchWorkers() async {
    try {
      final response = await _supabase.from('users').select('''
          id, user_name, email, is_banned, image_url
        ''').neq('id', _supabase.auth.currentUser!.id);

      setState(() {
        _workers = response;
        _isLoading = false;
      });
    } catch (e) {
      log('Error fetching workers: $e');
      setState(() => _isLoading = false);
    }
  }

  Future<void> _toggleBanWorker(String workerId, bool isBanned) async {
    try {
      log('Attempting to update user $workerId, current ban status: $isBanned');
      final result = await _supabase
          .from('users')
          .update({'is_banned': !isBanned}).match({'id': workerId});

      log('Update result: $result');

      await _fetchWorkers();

      // Optional: Show a snackbar to confirm action
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content:
              Text('User ${!isBanned ? 'banned' : 'unbanned'} successfully'),
        ),
      );
    } catch (e) {
      log('Error updating worker status: $e');
      log('Detailed error updating worker status: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to update user status: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('User Management'),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _workers.isEmpty
              ? const Center(child: Text('No workers found.'))
              : ListView.builder(
                  itemCount: _workers.length,
                  itemBuilder: (context, index) {
                    final worker = _workers[index];
                    return UserTile(
                      name: worker['user_name'] ?? 'No Name',
                      email: worker['email'] ?? 'No Email',
                      isBanned: worker['is_banned'] ?? false,
                      onBlock: () => _toggleBanWorker(
                        worker['id'],
                        worker['is_banned'],
                      ),
                    );
                  },
                ),
    );
  }
}

class UserTile extends StatelessWidget {
  final String name;
  final String email;
  final bool isBanned;
  final VoidCallback onBlock;

  const UserTile({
    super.key,
    required this.name,
    required this.email,
    required this.isBanned,
    required this.onBlock,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: ListTile(
        leading: CircleAvatar(
          child: Text(name[0].toUpperCase()),
        ),
        title: Text(name),
        subtitle: Text(email),
        trailing: IconButton(
          icon: Icon(
            isBanned ? Icons.lock_open : Icons.block,
            color: isBanned ? Colors.green : Colors.red,
          ),
          onPressed: onBlock,
        ),
      ),
    );
  }
}
