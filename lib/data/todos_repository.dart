// lib/data/todos_repository.dart
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/todo.dart';

class TodosRepository {
  final _db = FirebaseFirestore.instance;

  CollectionReference<Map<String, dynamic>> _col(
    String uid,
    String categoryId,
  ) => _db
      .collection('users')
      .doc(uid)
      .collection('categories')
      .doc(categoryId)
      .collection('todos');

  Future<void> create(
    String uid, {
    required String title,
    DateTime? dueAt,
    required String categoryId,
  }) {
    return _col(uid, categoryId).add({
      'title': title,
      'isDone': false,
      'dueAt': dueAt == null ? null : Timestamp.fromDate(dueAt),
      'categoryId': categoryId,
      'createdAt': FieldValue.serverTimestamp(),
      'updatedAt': FieldValue.serverTimestamp(),
    });
  }

  Future<void> toggle(String uid, String categoryId, String id, bool value) =>
      _col(uid, categoryId).doc(id).update({
        'isDone': value,
        'updatedAt': FieldValue.serverTimestamp(),
      });

  Future<void> setCategory(String uid, String id, String categoryId) =>
      _col(uid, categoryId).doc(id).update({
        'categoryId': categoryId,
        'updatedAt': FieldValue.serverTimestamp(),
      });

  Future<void> delete(String uid, String id, String categoryId) =>
      _col(uid, categoryId).doc(id).delete();

  // Listes par catégorie
  Stream<List<Todo>> watchByCategory(String uid, String categoryId) {
    final ref = _col(uid, categoryId).orderBy('createdAt', descending: true);

    print(ref);
    return ref.snapshots().map((snapshot) {
      return snapshot.docs
          .map((doc) => Todo.fromMap(doc.id, doc.data()))
          .toList();
    });
  }

  // Non classés
  Stream<List<Todo>> watchUncategorized(String uid, String categoryId) =>
      _col(uid, categoryId)
          .where('categoryId', isNull: true)
          .orderBy('isDone')
          .orderBy('createdAt', descending: true)
          .snapshots()
          .map((s) => s.docs.map((d) => Todo.fromMap(d.id, d.data())).toList());

  // Tous les non terminés (vue “À faire”)
  Stream<List<Todo>> watchAllOpen(String uid, String categoryId) =>
      _col(uid, categoryId)
          .where('isDone', isEqualTo: false)
          .orderBy('dueAt')
          .snapshots()
          .map((s) => s.docs.map((d) => Todo.fromMap(d.id, d.data())).toList());
}
