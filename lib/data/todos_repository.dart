// lib/data/todos_repository.dart
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/todo.dart';

class TodosRepository {
  final _db = FirebaseFirestore.instance;

  CollectionReference<Map<String, dynamic>> _col(String uid) =>
      _db.collection('users').doc(uid).collection('todos');

  Future<void> create(
    String uid, {
    required String title,
    DateTime? dueAt,
    String? categoryId,
  }) {
    return _col(uid).add({
      'title': title,
      'isDone': false,
      'dueAt': dueAt == null ? null : Timestamp.fromDate(dueAt),
      'categoryId': categoryId,
      'createdAt': FieldValue.serverTimestamp(),
      'updatedAt': FieldValue.serverTimestamp(),
    });
  }

  Future<void> toggle(String uid, String id, bool value) => _col(uid)
      .doc(id)
      .update({'isDone': value, 'updatedAt': FieldValue.serverTimestamp()});

  Future<void> setCategory(String uid, String id, String? categoryId) =>
      _col(uid).doc(id).update({
        'categoryId': categoryId,
        'updatedAt': FieldValue.serverTimestamp(),
      });

  Future<void> delete(String uid, String id) => _col(uid).doc(id).delete();

  // Listes par catégorie
  Stream<List<Todo>> watchByCategory(String uid, String categoryId) => _col(uid)
      .where('categoryId', isEqualTo: categoryId)
      .orderBy('isDone')
      .orderBy('dueAt')
      .snapshots()
      .map((s) => s.docs.map((d) => Todo.fromMap(d.id, d.data())).toList());

  // Non classés
  Stream<List<Todo>> watchUncategorized(String uid) => _col(uid)
      .where('categoryId', isNull: true)
      .orderBy('isDone')
      .orderBy('createdAt', descending: true)
      .snapshots()
      .map((s) => s.docs.map((d) => Todo.fromMap(d.id, d.data())).toList());

  // Tous les non terminés (vue “À faire”)
  Stream<List<Todo>> watchAllOpen(String uid) => _col(uid)
      .where('isDone', isEqualTo: false)
      .orderBy('dueAt')
      .snapshots()
      .map((s) => s.docs.map((d) => Todo.fromMap(d.id, d.data())).toList());
}
