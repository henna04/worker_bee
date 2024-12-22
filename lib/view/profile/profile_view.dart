import 'package:flutter/material.dart';
import 'package:gap/gap.dart';

class ProfileView extends StatefulWidget {
  const ProfileView({super.key});

  @override
  State<ProfileView> createState() => _ProfileViewState();
}

class _ProfileViewState extends State<ProfileView> {
  bool isAvailable = false;
  bool isVerified = true; // Replace with actual verification status

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      appBar: AppBar(
        title: const Text('Profile'),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Text(
            'Account',
            style: theme.textTheme.titleLarge!.copyWith(
              color: theme.colorScheme.onSurface,
              fontWeight: FontWeight.w600,
            ),
          ),
          const Gap(10),
          Card(
            child: ListTile(
              leading: const Icon(Icons.account_circle),
              title: const Text('Account'),
              onTap: () {
                // Handle account tap
              },
            ),
          ),
          Card(
            child: ListTile(
              leading: const Icon(Icons.verified),
              title: Text(
                  isVerified ? 'Account Verified' : 'Account Not Verified'),
              onTap: () {
                // Handle verification status tap
              },
            ),
          ),
          Card(
            child: SwitchListTile(
              title: const Text("I'm Available for Work"),
              value: isAvailable,
              onChanged: (bool value) {
                setState(() {
                  isAvailable = value;
                });
              },
              secondary: const Icon(Icons.work),
            ),
          ),
          Card(
            child: ListTile(
              leading: const Icon(Icons.notifications),
              title: const Text('Notification'),
              onTap: () {
                // Handle notification tap
              },
            ),
          ),
          const SizedBox(height: 20),
          Text(
            'Support',
            style: theme.textTheme.titleLarge!.copyWith(
              color: theme.colorScheme.onSurface,
              fontWeight: FontWeight.w600,
            ),
          ),
          const Gap(10),
          Card(
            child: ListTile(
              leading: const Icon(Icons.bug_report),
              title: const Text('Report a Bug'),
              onTap: () {
                // Handle report a bug tap
              },
            ),
          ),
          Card(
            child: ListTile(
              leading: const Icon(Icons.feedback),
              title: const Text('Send Feedback'),
              onTap: () {
                // Handle send feedback tap
              },
            ),
          ),
          const SizedBox(height: 20),
          Text(
            'Account Actions',
            style: theme.textTheme.titleLarge!.copyWith(
              color: theme.colorScheme.onSurface,
              fontWeight: FontWeight.w600,
            ),
          ),
          const Gap(10),
          Card(
            child: ListTile(
              leading: const Icon(Icons.logout),
              title: const Text('Logout'),
              onTap: () {
                // Handle logout tap
              },
            ),
          ),
          Card(
            child: ListTile(
              leading: const Icon(Icons.delete),
              title: const Text('Delete Account'),
              onTap: () {
                // Handle delete account tap
              },
            ),
          ),
        ],
      ),
    );
  }
}
