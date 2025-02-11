import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:worker_bee/res/components/common/custom_button.dart';
import 'package:worker_bee/view/feedback_screen.dart';
import 'package:worker_bee/view/login/login_view.dart';
import 'package:worker_bee/view/profile/bookings_ecreen.dart';
import 'package:worker_bee/view/profile/report_screen.dart';
import 'package:worker_bee/view/profile/user_profile_screen.dart';
import 'package:worker_bee/view/profile/worker_application_screen.dart';
import 'package:worker_bee/viewmodel/thme_provider.dart';

class ProfileView extends StatefulWidget {
  const ProfileView({super.key});

  @override
  State<ProfileView> createState() => _ProfileViewState();
}

class _ProfileViewState extends State<ProfileView> {
  bool isAvailable = false;
  bool isDarkMode = false;
  bool isVerified = true;
  final supabase = Supabase.instance.client;
  late final ThemeProvider themeProvider;

  @override
  void initState() {
    super.initState();
    _checkVerificationStatus();
    themeProvider = ThemeProvider();
    _loadAvailabilityStatus();
    _loadThemeMode();
  }

  Future<void> _loadAvailabilityStatus() async {
    final userId = supabase.auth.currentUser?.id;
    if (userId != null) {
      try {
        final response = await supabase
            .from('users')
            .select('is_available')
            .eq('id', userId)
            .single();

        setState(() => isAvailable = response['is_available'] ?? false);
      } catch (e) {
        log('Error fetching availability status: $e');
      }
    }
  }

  Future<void> _updateAvailability(bool value) async {
    final userId = supabase.auth.currentUser?.id;
    if (userId != null) {
      try {
        await supabase
            .from('users')
            .update({'is_available': value}).eq('id', userId);

        setState(() => isAvailable = value);

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(value
                ? 'You are now available for work'
                : 'You are now unavailable for work'),
            duration: const Duration(seconds: 2),
          ),
        );
      } catch (e) {
        log('Error updating availability: $e');
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Failed to update availability status'),
            duration: Duration(seconds: 2),
          ),
        );
      }
    }
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

        log("Verification status response: $response");
        setState(() => isVerified = response['is_verified'] ?? false);
      } catch (e) {
        log('Error fetching verification status: $e');
      }
    }
  }

  Future<void> _deleteAccount() async {
    try {
      final user = supabase.auth.currentUser;
      if (user != null) {
        // First delete all related data
        await supabase.from('feedback').delete().eq('user_id', user.id);

        await supabase
            .from('bookings')
            .delete()
            .or('user_id.eq.${user.id},worker_id.eq.${user.id}');

        await supabase
            .from('worker_application')
            .delete()
            .eq('user_id', user.id);

        await supabase.from('favorites').delete().eq('worker_id', user.id);

        await supabase
            .from('messages')
            .delete()
            .or('sender_id.eq.${user.id},receiver_id.eq.${user.id}');

        await supabase.from('reports').delete().eq('user_id', user.id);

        await supabase.from('users').delete().eq('id', user.id);

        // Delete the user's authentication data
        // This requires the user to have a current session
        final response = await supabase.rpc('delete_user');

        // Sign out after deletion
        await supabase.auth.signOut();

        if (mounted) {
          // Clear any stored preferences
          final prefs = await SharedPreferences.getInstance();
          await prefs.clear();

          // Navigate to login screen
          Navigator.pushAndRemoveUntil(
            context,
            MaterialPageRoute(builder: (context) => const LoginView()),
            (route) => false,
          );

          // Show success message
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Account successfully deleted'),
              backgroundColor: Colors.green,
            ),
          );
        }
      }
    } catch (e) {
      log('Error deleting account: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to delete account: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
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
                      builder: (context) => const UserProfileScreen(),
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
              onChanged: _updateAvailability,
              secondary: const Icon(Icons.work),
            ),
          ),
          Card(
            child: SwitchListTile(
              title: const Text("Dark Mode"),
              value: isDarkMode,
              onChanged: (bool value) {
                setState(() {
                  isDarkMode = value;
                });
                _updateThemeMode(value);
              },
              secondary: const Icon(Icons.dark_mode),
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
              leading: const Icon(Icons.delete_forever, color: Colors.red),
              title: const Text(
                'Delete Account',
                style: TextStyle(color: Colors.red),
              ),
              onTap: () {
                showDialog(
                  context: context,
                  builder: (context) => AlertDialog(
                    title: const Text("Delete Account"),
                    content: const Text(
                      "Are you sure you want to delete your account? This action cannot be undone.",
                      style: TextStyle(color: Colors.red),
                    ),
                    actions: [
                      TextButton(
                        onPressed: () => Navigator.pop(context),
                        child: const Text("Cancel"),
                      ),
                      CustomButton(
                        onPressed: () {
                          Navigator.pop(context);
                          showDialog(
                            context: context,
                            builder: (context) => AlertDialog(
                              title: const Text("Final Confirmation"),
                              content: const Text(
                                "This will permanently delete all your data. Are you absolutely sure?",
                                style: TextStyle(color: Colors.red),
                              ),
                              actions: [
                                TextButton(
                                  onPressed: () => Navigator.pop(context),
                                  child: const Text("No, Keep My Account"),
                                ),
                                CustomButton(
                                  onPressed: () {
                                    Navigator.pop(context);
                                    _deleteAccount();
                                  },
                                  btnText: "Yes, Delete My Account",
                                ),
                              ],
                            ),
                          );
                        },
                        btnText: "Delete Account",
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
          Card(
            child: ListTile(
              leading: const Icon(Icons.logout),
              title: const Text('Logout'),
              onTap: () {
                showDialog(
                  context: context,
                  builder: (context) => AlertDialog(
                    title: const Text("Logout"),
                    content: const Text("Are you sure you want to logout?"),
                    actions: [
                      TextButton(
                        onPressed: () {
                          Navigator.pop(context);
                        },
                        child: const Text("Cancel"),
                      ),
                      CustomButton(
                        onPressed: _logout,
                        btnText: "Logout",
                      )
                    ],
                  ),
                );
              },
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

  Future<void> _loadThemeMode() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      isDarkMode = prefs.getBool('theme_mode') ?? false;
    });
  }

  Future<void> _updateThemeMode(bool value) async {
    setState(() => isDarkMode = value);
    await themeProvider.toggleTheme(value);

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Theme updated to ${value ? 'dark' : 'light'} mode'),
        duration: const Duration(seconds: 2),
      ),
    );
  }
}
