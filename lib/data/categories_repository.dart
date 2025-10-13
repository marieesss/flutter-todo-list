// lib/data/categories_repository.dart
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/category.dart';

class CategoriesRepository {
  final _db = FirebaseFirestore.instance;

  CollectionReference<Map<String, dynamic>> _col(String uid) =>
      _db.collection('users').doc(uid).collection('categories');

  Stream<List<Category>> watchAll(String uid) => _col(uid)
      .orderBy('order')
      .snapshots()
      .map(
        (s) => s.docs
            .map((d) => Category.fromMap({'id': d.id, ...d.data()}))
            .toList(),
      );

  Future<String> create(
    String uid, {
    required String name,
    String description = '',
    String? color, // hex string
    int? icon, // codePoint
    int? order,
  }) async {
    final doc = await _col(uid).add({
      'name': name,
      'description': description,
      'color': color ?? '#6750A4',
      'icon': icon ?? 0xe14d, // codePoint par défaut = Icons.category
      'order': order ?? DateTime.now().millisecondsSinceEpoch,
      'createdAt': FieldValue.serverTimestamp(),
      'updatedAt': FieldValue.serverTimestamp(),
    });
    return doc.id;
  }

  Future<void> update(
    String uid,
    String id, {
    String? name,
    String? description,
    String? color,
    int? icon,
    int? order,
  }) {
    final patch = <String, dynamic>{};
    if (name != null) patch['name'] = name;
    if (description != null) patch['description'] = description;
    if (color != null) patch['color'] = color;
    if (icon != null) patch['icon'] = icon;
    if (order != null) patch['order'] = order;
    patch['updatedAt'] = FieldValue.serverTimestamp();
    return _col(uid).doc(id).update(patch);
  }

  Future<void> delete(String uid, String id) => _col(uid).doc(id).delete();
}
