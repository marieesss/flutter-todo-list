// lib/screens/categories/add_edit_category_page.dart
import 'package:flutter/material.dart';
import '../../models/category.dart';
import '../../services/category_service.dart';

class AddEditCategoryPage extends StatefulWidget {
  final Category? category;
  const AddEditCategoryPage({super.key, this.category});

  @override
  State<AddEditCategoryPage> createState() => _AddEditCategoryPageState();
}

class _AddEditCategoryPageState extends State<AddEditCategoryPage> {
  final _formKey = GlobalKey<FormState>();
  final _nameCtrl = TextEditingController();
  final _descCtrl = TextEditingController();

  // Etat local simple pour la couleur & l’icône
  Color _color = Colors.blue;
  IconData _icon = Icons.category;

  bool _saving = false;

  @override
  void initState() {
    super.initState();
    if (widget.category != null) {
      _nameCtrl.text = widget.category!.name;
      _descCtrl.text = widget.category!.description;
      _color = widget.category!.color;
      _icon = widget.category!.icon;
    }
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _descCtrl.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    // 1) validations synchrones
    if (!_formKey.currentState!.validate()) return;

    setState(() => _saving = true);
    try {
      final name = _nameCtrl.text.trim();
      final desc = _descCtrl.text.trim();

      // 2) validation asynchrone (unicité du nom) — ICI on peut await
      final exists = await CategoryService.categoryNameExists(
        name,
        excludeId: widget.category?.id,
      );
      if (exists) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Ce nom de catégorie existe déjà')),
        );
        return; // on arrête ici sans planter le validator
      }

      // 3) construire l’objet Category pour le service
      final now = DateTime.now();
      final category = Category(
        id:
            widget.category?.id ??
            '', // ignoré par addCategory (Firestore génère)
        name: name,
        description: desc,
        color: _color,
        icon: _icon,
        createdAt: widget.category?.createdAt ?? now,
        updatedAt: now,
      );

      if (widget.category == null) {
        await CategoryService.addCategory(category);
      } else {
        await CategoryService.updateCategory(widget.category!.id, category);
      }

      if (!mounted) return;
      Navigator.pop(context);
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Erreur: $e')));
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isEdit = widget.category != null;

    return Scaffold(
      appBar: AppBar(
        title: Text(isEdit ? 'Modifier une catégorie' : 'Nouvelle catégorie'),
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            TextFormField(
              controller: _nameCtrl,
              decoration: const InputDecoration(
                labelText: 'Nom',
                hintText: 'Ex: Travail, Personnel…',
              ),
              textInputAction: TextInputAction.next,
              validator: (v) {
                if (v == null || v.trim().isEmpty) {
                  return 'Le nom est requis';
                }
                if (v.trim().length > 60) {
                  return 'Nom trop long';
                }
                // ⚠️ Surtout pas d’async ici !
                return null;
              },
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: _descCtrl,
              decoration: const InputDecoration(
                labelText: 'Description (optionnelle)',
              ),
              maxLines: 2,
            ),
            const SizedBox(height: 16),

            // Sélecteur de couleur simple
            Text('Couleur', style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                _ColorDot(
                  color: Colors.blue,
                  selected: _color == Colors.blue,
                  onTap: () => setState(() => _color = Colors.blue),
                ),
                _ColorDot(
                  color: Colors.orange,
                  selected: _color == Colors.orange,
                  onTap: () => setState(() => _color = Colors.orange),
                ),
                _ColorDot(
                  color: Colors.green,
                  selected: _color == Colors.green,
                  onTap: () => setState(() => _color = Colors.green),
                ),
                _ColorDot(
                  color: Colors.purple,
                  selected: _color == Colors.purple,
                  onTap: () => setState(() => _color = Colors.purple),
                ),
                _ColorDot(
                  color: Colors.red,
                  selected: _color == Colors.red,
                  onTap: () => setState(() => _color = Colors.red),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // Sélecteur d’icône minimal
            Text('Icône', style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              children: [
                _IconChoice(
                  color: _icon == Icons.category ? _color : Colors.grey,

                  icon: Icons.category,
                  selected: _icon == Icons.category,
                  onTap: () => setState(() => _icon = Icons.category),
                ),
                _IconChoice(
                  color: _icon == Icons.work ? _color : Colors.grey,
                  selected: _icon == Icons.work,
                  icon: Icons.work,
                  onTap: () => setState(() => _icon = Icons.work),
                ),
                _IconChoice(
                  color: _icon == Icons.person ? _color : Colors.grey,
                  icon: Icons.person,
                  selected: _icon == Icons.person,
                  onTap: () => setState(() => _icon = Icons.person),
                ),
                _IconChoice(
                  color: _icon == Icons.shopping_cart ? _color : Colors.grey,

                  icon: Icons.shopping_cart,
                  selected: _icon == Icons.shopping_cart,
                  onTap: () => setState(() => _icon = Icons.shopping_cart),
                ),
                _IconChoice(
                  color: _icon == Icons.local_hospital ? _color : Colors.grey,
                  icon: Icons.local_hospital,
                  selected: _icon == Icons.local_hospital,
                  onTap: () => setState(() => _icon = Icons.local_hospital),
                ),
              ],
            ),
            const SizedBox(height: 24),

            FilledButton.icon(
              onPressed: _saving
                  ? null
                  : _save, // <- onPressed est async via _save()
              icon: _saving
                  ? const SizedBox(
                      height: 18,
                      width: 18,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Icon(Icons.check),
              label: Text(isEdit ? 'Enregistrer' : 'Créer'),
            ),
          ],
        ),
      ),
    );
  }
}

class _ColorDot extends StatelessWidget {
  final Color color;
  final bool selected;
  final VoidCallback onTap;
  const _ColorDot({
    required this.color,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkResponse(
      onTap: onTap,
      radius: 24,
      child: Container(
        width: 30,
        height: 30,
        decoration: BoxDecoration(
          color: color,
          shape: BoxShape.circle,
          border: Border.all(
            color: selected ? Colors.white : Colors.transparent,
            width: 2,
          ),
        ),
      ),
    );
  }
}

class _IconChoice extends StatelessWidget {
  final IconData icon;
  final bool selected;
  final VoidCallback onTap;
  final Color color;
  const _IconChoice({
    required this.icon,
    required this.selected,
    required this.onTap,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return ChoiceChip(
      label: Icon(icon, color: Colors.white),
      selected: selected,
      checkmarkColor: Colors.white,
      color: MaterialStateProperty.all(color),
      onSelected: (_) => onTap(),
    );
  }
}
