// lib/services/auth_service.dart
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  Stream<User?> get authStateChanges => _auth.authStateChanges();
  User? get currentUser => _auth.currentUser;

  Future<void> signIn({
    required String email,
    required String password,
  }) async {
    try {
      final cred = await _auth.signInWithEmailAndPassword(email: email, password: password);

      // S’assurer que le doc users/{uid} existe + maj updatedAt
      final uid = cred.user!.uid;
      final userRef = _db.collection('users').doc(uid);
      final snap = await userRef.get();
      if (!snap.exists) {
        await userRef.set({
          'email': email,
          'name': cred.user!.displayName,        // on remplit si dispo
          'displayName': cred.user!.displayName, // alias pratique
          'photoURL': cred.user!.photoURL,
          'createdAt': FieldValue.serverTimestamp(),
          'updatedAt': FieldValue.serverTimestamp(),
        });
      } else {
        await userRef.update({'updatedAt': FieldValue.serverTimestamp()});
      }
    } on FirebaseAuthException catch (e) {
      throw AuthException(_mapSignInError(e));
    } catch (_) {
      throw AuthException("Erreur de connexion. Réessaie.");
    }
  }

  // 👇 ajout du paramètre name
  Future<void> signUp({
    required String email,
    required String password,
    required String name,
  }) async {
    try {
      final cred = await _auth.createUserWithEmailAndPassword(email: email, password: password);

      // Met à jour le displayName côté Auth
      await cred.user!.updateDisplayName(name);

      final uid = cred.user!.uid;

      // Crée/Merge le doc Firestore users/{uid} avec le champ "name"
      await _db.collection('users').doc(uid).set({
        'email': email,
        'name': name,                            // <= ton champ demandé
        'displayName': name,                     // alias pratique
        'photoURL': cred.user!.photoURL,
        'createdAt': FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));
    } on FirebaseAuthException catch (e) {
      throw AuthException(_mapSignUpError(e));
    } catch (_) {
      throw AuthException("Erreur d'inscription. Réessaie.");
    }
  }

  Future<void> signOut() => _auth.signOut();

  String _mapSignInError(FirebaseAuthException e) {
    switch (e.code) {
      case 'invalid-email': return "Email invalide.";
      case 'user-disabled': return "Ce compte est désactivé.";
      case 'user-not-found':
      case 'wrong-password': return "Email ou mot de passe incorrect.";
      case 'too-many-requests': return "Trop de tentatives. Réessaie plus tard.";
      default: return "Connexion impossible (${e.code}).";
    }
  }

  String _mapSignUpError(FirebaseAuthException e) {
    switch (e.code) {
      case 'email-already-in-use': return "Un compte existe déjà avec cet email.";
      case 'invalid-email': return "Email invalide.";
      case 'operation-not-allowed': return "Inscription par email désactivée sur ce projet.";
      case 'weak-password': return "Mot de passe trop faible.";
      default: return "Inscription impossible (${e.code}).";
    }
  }
}

class AuthException implements Exception {
  final String message;
  AuthException(this.message);
  @override
  String toString() => message;
}