// lib/services/category_service.dart
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../data/categories_repository.dart';
import '../models/category.dart';

class CategoryService {
  static final _repo = CategoriesRepository();
  static final _auth = FirebaseAuth.instance;

  static String get _uid {
    final user = _auth.currentUser;
    if (user == null) throw StateError('Aucun utilisateur connecté.');
    return user.uid;
  }

  // --- Lecture

  static Future<List<Category>> getAllCategories() =>
      _repo.watchAll(_uid).first;

  static Stream<List<Category>> watchAllCategories() => _repo.watchAll(_uid);

  static Future<Category?> getCategoryById(String id) async {
    final list = await getAllCategories();
    return list.firstWhere((c) => c.id == id, orElse: () => null as Category);
  }

  static Future<bool> categoryNameExists(
    String name, {
    String? excludeId,
  }) async {
    final lower = name.toLowerCase();
    final list = await getAllCategories();
    return list.any(
      (c) => c.name.toLowerCase() == lower && c.id != (excludeId ?? ''),
    );
  }

  static Future<int> getCategoryCount() async =>
      (await getAllCategories()).length;

  // --- Écriture

  static Future<String> addCategory(Category category) async {
    return _repo.create(
      _uid,
      name: category.name,
      description: category.description,
      color:
          '#${category.color.value.toRadixString(16).padLeft(8, '0').substring(2)}',
      icon: category.icon.codePoint,
      order: category.createdAt.millisecondsSinceEpoch,
    );
  }

  static Future<void> updateCategory(String id, Category category) {
    return _repo.update(
      _uid,
      id,
      name: category.name,
      description: category.description,
      color:
          '#${category.color.value.toRadixString(16).padLeft(8, '0').substring(2)}',
      icon: category.icon.codePoint,
      order: category.updatedAt.millisecondsSinceEpoch,
    );
  }

  static Future<void> deleteCategory(String id) => _repo.delete(_uid, id);

  // --- Utils

  static String generateId() =>
      DateTime.now().millisecondsSinceEpoch.toString();
}
