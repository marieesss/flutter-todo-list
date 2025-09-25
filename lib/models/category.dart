import 'package:flutter/material.dart';

class Category {
  final String id;                // Identifiant unique de la catégorie
  final String name;              // Nom de la catégorie (ex: "Travail", "Personnel")
  final String description;       // Description optionnelle
  final Color color;              // Couleur pour identifier visuellement la catégorie
  final IconData icon;            // Icône pour la catégorie
  final DateTime createdAt;       // Date de création
  final DateTime updatedAt;       // Date de dernière modification

  const Category({
    required this.id,
    required this.name,
    required this.description,
    required this.color,
    required this.icon,
    required this.createdAt,
    required this.updatedAt,
  });

  // Conversion en Map (idéal pour persistance)
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'color': color.value,
      'icon': icon.codePoint,
      'createdAt': createdAt.millisecondsSinceEpoch,
      'updatedAt': updatedAt.millisecondsSinceEpoch,
    };
  }

  // Création depuis Map
  factory Category.fromMap(Map<String, dynamic> map) {
    return Category(
      id: map['id'] ?? '',
      name: map['name'] ?? '',
      description: map['description'] ?? '',
      color: Color(map['color'] ?? Colors.blue.value),
      icon: IconData(
        map['icon'] ?? Icons.category.codePoint,
        fontFamily: 'MaterialIcons',
      ),
      createdAt: _parseDate(map['createdAt']),
      updatedAt: _parseDate(map['updatedAt']),
    );
  }

  static DateTime _parseDate(dynamic v) {
    if (v is int) return DateTime.fromMillisecondsSinceEpoch(v);
    if (v is String) {
      // Si jamais tu stockes en ISO string ailleurs
      return DateTime.tryParse(v) ?? DateTime.now();
    }
    return DateTime.now();
  }

  // Copie modifiée
  Category copyWith({
    String? id,
    String? name,
    String? description,
    Color? color,
    IconData? icon,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return Category(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      color: color ?? this.color,
      icon: icon ?? this.icon,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  String toString() {
    return 'Category(id: $id, name: $name, description: $description, createdAt: $createdAt, updatedAt: $updatedAt)';
  }
}
