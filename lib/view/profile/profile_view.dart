import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:worker_bee/view/feedback_screen.dart';
import 'package:worker_bee/view/login/login_view.dart';
import 'package:worker_bee/view/profile/bookings_ecreen.dart';
import 'package:worker_bee/view/profile/report_screen.dart';
import 'package:worker_bee/view/profile/user_profile_screen.dart';
import 'package:worker_bee/view/profile/worker_application_screen.dart';

class ProfileView extends StatefulWidget {
  const ProfileView({super.key});

  @override
  State<ProfileView> createState() => _ProfileViewState();
}

class _ProfileViewState extends State<ProfileView> {
  bool isAvailable = false;
  bool isVerified = true;
  final supabase = Supabase.instance.client;
  @override
  void initState() {
    super.initState();
    _checkVerificationStatus();
  }

  Future<void> _checkVerificationStatus() async {
    final userId = supabase.auth.currentUser?.id;
    if (userId != null) {
      try {
        final response = await supabase
            .from('users')
            .select('is_verified')
            .eq('id', userId)
            .single();

        log("ddd" + response.toString());

        setState(() => isVerified = response['is_verified'] ?? false);
      } catch (e) {
        print('Error fetching verification status: $e');
      }
    }
  }

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
                Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => UserProfileScreen(),
                    ));
              },
            ),
          ),
          Card(
            child: ListTile(
              leading: const Icon(Icons.book_online),
              title: const Text('Bookings'),
              onTap: () {
                Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const BookedWorkersScreen(),
                    ));
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
            child: ListTile(
              leading: const Icon(Icons.settings_applications),
              title: const Text("Worker Application"),
              onTap: () {
                Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const WorkerApplicationScreen(),
                    ));
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
            child: SwitchListTile(
              title: const Text("Dark Mode"),
              value: isAvailable,
              onChanged: (bool value) {
                setState(() {
                  isAvailable = value;
                });
              },
              secondary: const Icon(Icons.work),
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
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const ReportScreen()),
                );
              },
            ),
          ),
          Card(
            child: ListTile(
              leading: const Icon(Icons.feedback),
              title: const Text('Send Feedback'),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => const FeedbackScreen()),
                );
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
              onTap: _logout,
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _logout() async {
    await supabase.auth.signOut().then(
          (value) => Navigator.pushAndRemoveUntil(
            context,
            MaterialPageRoute(
              builder: (context) => const LoginView(),
            ),
            (route) => false,
          ),
        );
  }
}
