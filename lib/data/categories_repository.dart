// lib/src/data/categories_repository.dart
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/category.dart';
import 'package:flutter/material.dart' show Icons;

class CategoriesRepository {
  final _db = FirebaseFirestore.instance;

  CollectionReference<Map<String, dynamic>> _col(String uid) =>
      _db.collection('users').doc(uid).collection('categories');

  Stream<List<Category>> watchAll(String uid) => _col(uid)
      .orderBy('order')
      .snapshots()
      .map(
        (s) => s.docs.map((d) {
          final data = d.data();
          final map = {
            'id': d.id,
            'name': data['name'],
            'description': data['description'] ?? '',
            // convertit hex → int pour Color(...)
            'color': _hexToInt(data['color'] as String?),
            // si pas stocké, mets un défaut
            'icon': Icons.category.codePoint,
            // Timestamp → epoch ms pour ton parser actuel
            'createdAt':
                (data['createdAt'] as Timestamp?)?.millisecondsSinceEpoch ??
                DateTime.now().millisecondsSinceEpoch,
            'updatedAt':
                (data['updatedAt'] as Timestamp?)?.millisecondsSinceEpoch ??
                DateTime.now().millisecondsSinceEpoch,
          };
          return Category.fromMap(map);
        }).toList(),
      );

  int? _hexToInt(String? hex) {
    if (hex == null) return null;
    final value = hex.replaceAll('#', '');
    final argb = (value.length == 6) ? 'FF$value' : value;
    return int.tryParse(argb, radix: 16);
  }

  Future<String> create(
    String uid, {
    required String name,
    String? color,
    int? order,
  }) async {
    final doc = await _col(uid).add({
      'name': name,
      'color': color,
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
    String? color,
    int? order,
  }) {
    final patch = <String, dynamic>{};
    if (name != null) patch['name'] = name;
    if (color != null) patch['color'] = color;
    if (order != null) patch['order'] = order;
    patch['updatedAt'] = FieldValue.serverTimestamp();
    return _col(uid).doc(id).update(patch);
  }

  Future<void> delete(String uid, String id) => _col(uid).doc(id).delete();
}
