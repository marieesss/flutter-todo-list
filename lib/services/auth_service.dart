import 'dart:async';

class AuthService {
  // Simule une base utilisateurs en mémoire
  static final Map<String, String> _users = {
    "demo@demo.com": "Password123!",
  };

  Future<void> signIn({required String email, required String password}) async {
    await Future.delayed(const Duration(milliseconds: 600));
    if (!_users.containsKey(email) || _users[email] != password) {
      throw AuthException("Email ou mot de passe incorrect.");
    }
  }

  Future<void> signUp({required String email, required String password}) async {
    await Future.delayed(const Duration(milliseconds: 600));
    if (_users.containsKey(email)) {
      throw AuthException("Un compte existe déjà avec cet email.");
    }
    _users[email] = password;
  }
}

class AuthException implements Exception {
  final String message;
  AuthException(this.message);
  @override
  String toString() => message;
}