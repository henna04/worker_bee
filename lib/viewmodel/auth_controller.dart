import 'dart:io';

import 'package:flutter/material.dart';
import 'package:worker_bee/repo/auth_repository.dart';

class AuthController extends ChangeNotifier {
  final AuthRepository _authRepository;
  bool isLoading = false;
  String? error;

  AuthController(this._authRepository);

  Future<bool> registerWithEmail({
    required String email,
    required String password,
    required String username,
    required String phone,
    required String place,
    required File? profileImage,
  }) async {
    try {
      isLoading = true;
      error = null;
      notifyListeners();

      await _authRepository.signUpWithEmail(
        email: email,
        password: password,
        username: username,
        phone: phone,
        place: place,
        profileImage: profileImage,
      );

      return true;
    } catch (e) {
      error = e.toString();
      return false;
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> signInWithEmail(String email, String password) async {
    try {
      isLoading = true;
      error = null;
      notifyListeners();

      await _authRepository.signInWithEmail(
        email: email,
        password: password,
      );

      return true;
    } catch (e) {
      error = e.toString();
      return false;
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> signInWithGoogle() async {
    try {
      isLoading = true;
      error = null;
      notifyListeners();

      await _authRepository.signInWithGoogle(); // No return value needed
      return true; // Return true on success
    } catch (e) {
      error = e.toString();
      return false;
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }
}
