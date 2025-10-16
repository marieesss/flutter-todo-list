// lib/screens/categories/categories_page.dart
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_application_1/screens/todos/todos.dart';

import '../../models/category.dart';
import '../../services/category_service.dart';
import 'add_edit_category_page.dart';
import '../auth/LoginRegister.dart';

class CategoriesPage extends StatelessWidget {
  const CategoriesPage({super.key});

  Future<void> _signOut(BuildContext context) async {
    await FirebaseAuth.instance.signOut();
    if (!context.mounted) return;

    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(builder: (_) => const LoginPage()),
      (route) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Catégories'),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            tooltip: 'Déconnexion',
            onPressed: () => _signOut(context),
          ),
        ],
      ),
      body: StreamBuilder<List<Category>>(
        stream: CategoryService.watchAllCategories(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(child: Text('Erreur : ${snapshot.error}'));
          }

          final categories = snapshot.data ?? [];
          if (categories.isEmpty) {
            return const Center(child: Text('Aucune catégorie'));
          }

          return ListView.separated(
            itemCount: categories.length,
            separatorBuilder: (_, __) => const Divider(height: 1),
            itemBuilder: (context, index) {
              final category = categories[index];

              return ListTile(
                leading: Icon(category.icon, color: category.color),
                title: Text(category.name),
                subtitle: Text(category.description),

                // 👉 clic normal : ouvre la page des todos de la catégorie
                onTap: () => Navigator.of(context).push(
                  MaterialPageRoute<void>(
                    builder: (context) => TodosPage(
                      categoryId: category.id,
                      color: category.color,
                      title: category.name,
                    ),
                  ),
                ),

                trailing: PopupMenuButton<String>(
                  onSelected: (value) async {
                    if (value == 'edit') {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => AddEditCategoryPage(category: category),
                        ),
                      );
                    } else if (value == 'delete') {
                      final confirm = await showDialog<bool>(
                        context: context,
                        builder: (context) => AlertDialog(
                          // ✅ titre & contenu en noir
                          title: const Text(
                            'Supprimer la catégorie',
                            style: TextStyle(color: Colors.black),
                          ),
                          content: Text(
                            'Voulez-vous vraiment supprimer "${category.name}" ?',
                            style: const TextStyle(color: Colors.black),
                          ),
                          actions: [
                            // ✅ boutons en noir
                            TextButton(
                              style: TextButton.styleFrom(
                                foregroundColor: Colors.black,
                              ),
                              onPressed: () => Navigator.pop(context, false),
                              child: const Text('Annuler'),
                            ),
                            TextButton(
                              style: TextButton.styleFrom(
                                foregroundColor: Colors.black,
                              ),
                              onPressed: () => Navigator.pop(context, true),
                              child: const Text('Supprimer'),
                            ),
                          ],
                        ),
                      );
                      if (confirm == true) {
                        await CategoryService.deleteCategory(category.id);
                      }
                    }
                  },
                  itemBuilder: (context) => const [
                    PopupMenuItem(
                      value: 'edit',
                      child: Text(
                        'Modifier',
                        style: TextStyle(color: Colors.black),
                      ),
                    ),
                    PopupMenuItem(
                      value: 'delete',
                      child: Text(
                        'Supprimer',
                        style: TextStyle(color: Colors.black),
                      ),
                    ),
                  ],
                ),
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const AddEditCategoryPage()),
          );
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}