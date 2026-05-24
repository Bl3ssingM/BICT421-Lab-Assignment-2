import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Holds login credentials entered by the user.
class Credentials {
  final String username;
  final String password;

  Credentials({required this.username, required this.password});
}

/// Manages user authentication state, persisted via SharedPreferences.
class Auth extends ChangeNotifier {
  static const _loggedInKey = 'logged_in';
  static const _usernameKey = 'username';

  // ── Public API ──────────────────────────────────────────────────────────────

  /// Returns [true] when the user has a saved login session.
  Future<bool> get loggedIn async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_loggedInKey) ?? false;
  }

  /// Saved username (displayed on the Account screen).
  Future<String> get savedUsername async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_usernameKey) ?? 'Guest';
  }

  /// Simulates a sign-in request and persists the session.
  Future<void> signIn(String username, String password) async {
    // In a real app you would call your auth API here.
    await Future.delayed(const Duration(milliseconds: 400));
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_loggedInKey, true);
    await prefs.setString(_usernameKey, username);
    notifyListeners();
  }

  /// Clears any saved session without broadcasting a logout event.
  Future<void> clearSavedSession() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_loggedInKey);
    await prefs.remove(_usernameKey);
  }

  /// Clears the persisted session and notifies listeners so GoRouter
  /// can redirect to the login screen.
  Future<void> signOut() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_loggedInKey, false);
    await prefs.remove(_usernameKey);
    notifyListeners();
  }
}