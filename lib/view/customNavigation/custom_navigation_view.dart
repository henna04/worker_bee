import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:google_nav_bar/google_nav_bar.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:worker_bee/view/addPost/add_post.dart';
import 'package:worker_bee/view/chats/chat_view.dart';
import 'package:worker_bee/view/home/home_view.dart';
import 'package:worker_bee/view/profile/profile_view.dart';
import 'package:worker_bee/view/search/search_view.dart';

class CustomNavigationView extends StatefulWidget {
  const CustomNavigationView({super.key});

  @override
  State<CustomNavigationView> createState() => _CustomNavigationViewState();
}

class _CustomNavigationViewState extends State<CustomNavigationView> {
  var currentIndex = 0;
  bool _isWorkerVerified = false;
  bool _isLoading = true;

  final SupabaseClient _supabase = Supabase.instance.client;

  @override
  void initState() {
    super.initState();
    _checkWorkerVerification();
  }

  Future<void> _checkWorkerVerification() async {
    try {
      final userId = _supabase.auth.currentUser?.id;
      if (userId != null) {
        final response = await _supabase
            .from('users')
            .select('is_verified')
            .eq('id', userId)
            .single();

        setState(() {
          _isWorkerVerified = response['is_verified'] ?? false;
          _isLoading = false;
        });
      }
    } catch (e) {
      log('Error checking worker verification: $e');
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      body: IndexedStack(
        index: currentIndex,
        children: const [
          HomeView(),
          SearchView(),
          PostImageView(),
          ChatView(),
          ProfileView(),
        ],
      ),
      bottomNavigationBar: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: GNav(
          color: theme.colorScheme.primary,
          activeColor: theme.colorScheme.onPrimary,
          tabBackgroundColor: theme.colorScheme.primary,
          gap: 8,
          padding: const EdgeInsets.all(12),
          onTabChange: (newIndex) {
            setState(() {
              currentIndex = newIndex;
            });
          },
          tabs: [
            const GButton(
              icon: Icons.home_filled,
              text: 'Home',
            ),
            const GButton(
              icon: Icons.search,
              text: 'Search',
            ),
            if (_isWorkerVerified) 
              const GButton(
                icon: Icons.add_circle_outline,
                text: 'Add Post',
              ),
            const GButton(
              icon: Icons.chat,
              text: 'Chats',
            ),
            const GButton(
              icon: Icons.person,
              text: 'Account',
            ),
          ],
        ),
      ),
    );
  }
}
