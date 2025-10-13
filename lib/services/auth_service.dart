// lib/services/auth_service.dart
import 'package:firebase_auth/firebase_auth.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  Stream<User?> get authStateChanges => _auth.authStateChanges();
  User? get currentUser => _auth.currentUser;

  Future<void> signIn({
    required String email,
    required String password,
  }) async {
    try {
      await _auth.signInWithEmailAndPassword(email: email, password: password);
    } on FirebaseAuthException catch (e) {
      throw AuthException(_mapSignInError(e));
    } catch (_) {
      throw AuthException("Erreur de connexion. Réessaie.");
    }
  }

  Future<void> signUp({
    required String email,
    required String password,
  }) async {
    try {
      await _auth.createUserWithEmailAndPassword(email: email, password: password);
    } on FirebaseAuthException catch (e) {
      throw AuthException(_mapSignUpError(e));
    } catch (_) {
      throw AuthException("Erreur d'inscription. Réessaie.");
    }
  }

  Future<void> signOut() => _auth.signOut();

  // ---- Helpers messages FR
  String _mapSignInError(FirebaseAuthException e) {
    switch (e.code) {
      case 'invalid-email':
        return "Email invalide.";
      case 'user-disabled':
        return "Ce compte est désactivé.";
      case 'user-not-found':
      case 'wrong-password':
        return "Email ou mot de passe incorrect.";
      case 'too-many-requests':
        return "Trop de tentatives. Réessaie plus tard.";
      default:
        return "Connexion impossible (${e.code}).";
    }
  }

  String _mapSignUpError(FirebaseAuthException e) {
    switch (e.code) {
      case 'email-already-in-use':
        return "Un compte existe déjà avec cet email.";
      case 'invalid-email':
        return "Email invalide.";
      case 'operation-not-allowed':
        return "Inscription par email désactivée sur ce projet.";
      case 'weak-password':
        return "Mot de passe trop faible.";
      default:
        return "Inscription impossible (${e.code}).";
    }
  }
}

class AuthException implements Exception {
  final String message;
  AuthException(this.message);
  @override
  String toString() => message;
}