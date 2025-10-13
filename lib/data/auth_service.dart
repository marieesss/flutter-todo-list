// lib/data/auth_service.dart
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AuthService {
  final _auth = FirebaseAuth.instance;
  final _db = FirebaseFirestore.instance;

  Stream<User?> authState() => _auth.authStateChanges();

  Future<UserCredential> signIn(String email, String password) =>
      _auth.signInWithEmailAndPassword(email: email, password: password);

  Future<UserCredential> signUp(String email, String password) async {
    final cred = await _auth.createUserWithEmailAndPassword(
      email: email,
      password: password,
    );

    final uid = cred.user!.uid;
    await _db.collection('users').doc(uid).set({
      'displayName': email.split('@').first,
      'createdAt': FieldValue.serverTimestamp(),
    });

    // Catégories par défaut
    final cats = _db.collection('users').doc(uid).collection('categories');
    await cats.add({
      'name': 'Travail',
      'description': '',
      'color': '#6750A4',
      'icon': 0xe491,
      'order': 1,
      'createdAt': FieldValue.serverTimestamp(),
      'updatedAt': FieldValue.serverTimestamp(),
    });
    await cats.add({
      'name': 'Perso',
      'description': '',
      'color': '#386A20',
      'icon': 0xe491,
      'order': 2,
      'createdAt': FieldValue.serverTimestamp(),
      'updatedAt': FieldValue.serverTimestamp(),
    });

    return cred;
  }

  Future<void> signOut() => _auth.signOut();
}
