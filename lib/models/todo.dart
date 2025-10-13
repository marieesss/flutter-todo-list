// lib/models/todo.dart
import 'package:cloud_firestore/cloud_firestore.dart';

class Todo {
  final String? id;
  final String title;
  final bool isDone;
  final DateTime? dueAt;
  final String categoryId;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  Todo({
    this.id,
    required this.title,
    required this.isDone,
    this.dueAt,
    required this.categoryId,
    this.createdAt,
    this.updatedAt,
  });

  factory Todo.fromMap(String id, Map<String, dynamic> map) => Todo(
    id: id,
    title: map['title'] as String,
    isDone: map['isDone'] as bool,
    dueAt: (map['dueAt'] is Timestamp)
        ? (map['dueAt'] as Timestamp).toDate()
        : null,
    categoryId: (map['categoryId'] as String?) ?? '',
    createdAt: (map['createdAt'] is Timestamp)
        ? (map['createdAt'] as Timestamp).toDate()
        : null,
    updatedAt: (map['updatedAt'] is Timestamp)
        ? (map['updatedAt'] as Timestamp).toDate()
        : null,
  );
}
