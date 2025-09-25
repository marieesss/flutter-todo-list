import 'package:flutter/material.dart';
import '../models/category.dart';

class CategoryService {
  // Liste statique (mock DB)
  static List<Category> _categories = [
    Category(
      id: '1',
      name: 'Personnel',
      description: 'Tâches personnelles et vie privée',
      color: Colors.blue,
      icon: Icons.person,
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    ),
    Category(
      id: '2',
      name: 'Travail',
      description: 'Tâches professionnelles',
      color: Colors.orange,
      icon: Icons.work,
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    ),
    Category(
      id: '3',
      name: 'Santé',
      description: 'Rendez-vous médicaux et bien-être',
      color: Colors.green,
      icon: Icons.local_hospital,
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    ),
    Category(
      id: '4',
      name: 'Shopping',
      description: 'Achats et courses',
      color: Colors.purple,
      icon: Icons.shopping_cart,
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    ),
  ];

  static List<Category> getAllCategories() {
    return List.from(_categories);
  }

  static Category? getCategoryById(String id) {
    try {
      return _categories.firstWhere((c) => c.id == id);
    } catch (_) {
      return null;
    }
  }

  // Ajout : garantit les timestamps
  static void addCategory(Category category) {
    final now = DateTime.now();
    final toInsert = category.copyWith(
      createdAt: category.createdAt, // si déjà fixé en amont, on respecte
      updatedAt: category.updatedAt,
    );

    _categories.add(
      toInsert.copyWith(
        createdAt: toInsert.createdAt == toInsert.updatedAt
            ? now
            : (toInsert.createdAt),
        updatedAt: now,
      ),
    );
  }

  // Mise à jour : conserve createdAt et rafraîchit updatedAt
  static bool updateCategory(String id, Category updatedCategory) {
    final index = _categories.indexWhere((c) => c.id == id);
    if (index == -1) return false;

    final existing = _categories[index];
    _categories[index] = updatedCategory.copyWith(
      id: existing.id,
      createdAt: existing.createdAt,
      updatedAt: DateTime.now(),
    );
    return true;
  }

  static bool deleteCategory(String id) {
    final index = _categories.indexWhere((c) => c.id == id);
    if (index != -1) {
      _categories.removeAt(index);
      return true;
    }
    return false;
  }

  static String generateId() {
    return DateTime.now().millisecondsSinceEpoch.toString();
  }

  static bool categoryNameExists(String name, {String? excludeId}) {
    return _categories.any((c) =>
    c.name.toLowerCase() == name.toLowerCase() && c.id != excludeId);
  }

  static int getCategoryCount() {
    return _categories.length;
  }

  static List<Category> searchCategories(String query) {
    if (query.isEmpty) return getAllCategories();
    final q = query.toLowerCase();
    return _categories
        .where((c) =>
    c.name.toLowerCase().contains(q) ||
        c.description.toLowerCase().contains(q))
        .toList();
  }
}
