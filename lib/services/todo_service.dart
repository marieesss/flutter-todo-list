import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_application_1/data/todos_repository.dart';
import 'package:flutter_application_1/models/todo.dart';

class TodoService {
  static final _repo = TodosRepository();
  static final _auth = FirebaseAuth.instance;

  static String get _uid {
    final user = _auth.currentUser;
    if (user == null) throw StateError('Aucun utilisateur connecté.');
    return user.uid;
  }

  // --- Lecture

  static Future<List<Todo>> getAllTodos(String categoryId) async {
    try {
      final stream = _repo.watchByCategory(_uid, categoryId);
      final list = await stream.first;

      return list;
    } catch (e) {
      return [];
    }
  }

  static Future<Todo?> getTodoById(String id, String categoryId) async {
    final list = await getAllTodos(categoryId);
    try {
      return list.firstWhere((t) => t.id == id);
    } catch (_) {
      // Si non trouvé, on retourne null
      return null;
    }
  }

  // --- Écriture

  static Future<void> addTodo(Todo todo) async {
    return _repo.create(
      _uid,
      title: todo.title,
      dueAt: todo.dueAt,
      categoryId: todo.categoryId,
    );
  }

  static Future<void> updateTodo({
    required String id,
    required String categoryId,
    required bool isDone,
  }) {
    return _repo.toggle(_uid, categoryId, id, isDone);
  }

  static Future<void> deleteTodo(String id, String categoryId) {
    return _repo.delete(_uid, id, categoryId);
  }
}
