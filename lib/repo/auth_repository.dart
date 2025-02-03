import 'dart:io';

import 'package:supabase_flutter/supabase_flutter.dart';

class AuthRepository {
  final SupabaseClient _supabaseClient;

  AuthRepository(this._supabaseClient);

  Future<AuthResponse> signInWithEmail({
    required String email,
    required String password,
  }) async {
    try {
      final response = await _supabaseClient.auth.signInWithPassword(
        email: email,
        password: password,
      );
      return response;
    } catch (e) {
      throw Exception('Failed to sign in: $e');
    }
  }

  Future<AuthResponse> signUpWithEmail({
    required String email,
    required String password,
    required String username,
    required String phone,
    required String place,
    required File? profileImage,
  }) async {
    try {
      // 1. Register the user
      final response = await _supabaseClient.auth.signUp(
        email: email,
        password: password,
      );

      if (response.user != null) {
        // 2. Upload profile image if provided
        String? imageUrl;
        if (profileImage != null && profileImage.path.isNotEmpty) {
          final fileExt = profileImage.path.split('.').last;
          final fileName = '${response.user!.id}.$fileExt';

          await _supabaseClient.storage
              .from('user_images')
              .upload(fileName, profileImage);

          imageUrl = _supabaseClient.storage
              .from('user_images')
              .getPublicUrl(fileName);
        }

        // 3. Insert user profile data
        await _supabaseClient.from('profiles').insert({
          'id': response.user!.id,
          'username': username,
          'email': email,
          'phone': phone,
          'place': place,
          'avatar_url': imageUrl,
          'created_at': DateTime.now().toIso8601String(),
          'updated_at': DateTime.now().toIso8601String(),
        });
      }

      return response;
    } catch (e) {
      throw Exception('Failed to sign up: $e');
    }
  }

  Future<void> signInWithGoogle() async {
    // Changed return type to Future<void>
    try {
      await _supabaseClient.auth.signInWithOAuth(
        OAuthProvider.google,
        redirectTo: 'io.supabase.flutterquickstart://login-callback/',
      );
    } catch (e) {
      throw Exception('Failed to sign in with Google: $e');
    }
  }

  Future<void> signOut() async {
    try {
      await _supabaseClient.auth.signOut();
    } catch (e) {
      throw Exception('Failed to sign out: $e');
    }
  }

  Future<void> resetPassword(String email) async {
    try {
      await _supabaseClient.auth.resetPasswordForEmail(email);
    } catch (e) {
      throw Exception('Failed to reset password: $e');
    }
  }

  Stream<AuthState> get authStateChanges =>
      _supabaseClient.auth.onAuthStateChange;
}
