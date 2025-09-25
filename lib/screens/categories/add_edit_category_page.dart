import 'package:flutter/material.dart';
import '../../models/category.dart';
import '../../services/category_service.dart';

class AddEditCategoryPage extends StatefulWidget {
  final Category? category; // null = ajout, non-null = édition

  const AddEditCategoryPage({super.key, this.category});

  @override
  State<AddEditCategoryPage> createState() => _AddEditCategoryPageState();
}

class _AddEditCategoryPageState extends State<AddEditCategoryPage> {
  final _nameController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  Color _selectedColor = Colors.blue;
  IconData _selectedIcon = Icons.category;

  final List<Color> _availableColors = [
    Colors.blue,
    Colors.green,
    Colors.orange,
    Colors.purple,
    Colors.red,
    Colors.teal,
    Colors.pink,
    Colors.indigo,
    Colors.brown,
    Colors.grey,
  ];

  final List<IconData> _availableIcons = [
    Icons.category,
    Icons.work,
    Icons.person,
    Icons.home,
    Icons.school,
    Icons.shopping_cart,
    Icons.local_hospital,
    Icons.restaurant,
    Icons.sports_basketball,
    Icons.travel_explore,
    Icons.book,
    Icons.music_note,
    Icons.fitness_center,
    Icons.pets,
    Icons.car_repair,
  ];

  @override
  void initState() {
    super.initState();
    if (widget.category != null) {
      _nameController.text = widget.category!.name;
      _descriptionController.text = widget.category!.description;
      _selectedColor = widget.category!.color;
      _selectedIcon = widget.category!.icon;
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  void _saveCategory() {
    if (_formKey.currentState!.validate()) {
      final now = DateTime.now();

      // Si création : on définit createdAt=now, updatedAt=now
      // Si édition : on conserve createdAt, on mettra updatedAt=now (le service le force de toute façon)
      final category = Category(
        id: widget.category?.id ?? CategoryService.generateId(),
        name: _nameController.text.trim(),
        description: _descriptionController.text.trim(),
        color: _selectedColor,
        icon: _selectedIcon,
        createdAt: widget.category?.createdAt ?? now,
        updatedAt: now,
      );

      if (widget.category == null) {
        CategoryService.addCategory(category);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Catégorie "${category.name}" ajoutée'),
            backgroundColor: Colors.green,
          ),
        );
      } else {
        CategoryService.updateCategory(widget.category!.id, category);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Catégorie "${category.name}" modifiée'),
            backgroundColor: Colors.blue,
          ),
        );
      }

      Navigator.of(context).pop(true);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isEditing = widget.category != null;

    return Scaffold(
      appBar: AppBar(
        title: Text(isEditing ? 'Modifier la catégorie' : 'Nouvelle catégorie'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        actions: [
          IconButton(
            onPressed: _saveCategory,
            icon: const Icon(Icons.save),
            tooltip: 'Sauvegarder',
          ),
        ],
      ),
      body: Form(
        key: _formKey,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Column(
                  children: [
                    CircleAvatar(
                      radius: 40,
                      backgroundColor: _selectedColor,
                      child: Icon(_selectedIcon, size: 32, color: Colors.white),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      _nameController.text.isEmpty
                          ? 'Nom de la catégorie'
                          : _nameController.text,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 32),
              TextFormField(
                controller: _nameController,
                decoration: const InputDecoration(
                  labelText: 'Nom de la catégorie *',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.label),
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Le nom est obligatoire';
                  }
                  if (CategoryService.categoryNameExists(
                    value.trim(),
                    excludeId: widget.category?.id,
                  )) {
                    return 'Ce nom de catégorie existe déjà';
                  }
                  return null;
                },
                onChanged: (_) => setState(() {}),
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _descriptionController,
                decoration: const InputDecoration(
                  labelText: 'Description (optionnelle)',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.description),
                ),
                maxLines: 3,
              ),
              const SizedBox(height: 24),
              const Text(
                'Couleur',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                children: _availableColors.map((color) {
                  return GestureDetector(
                    onTap: () => setState(() => _selectedColor = color),
                    child: Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        color: color,
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: _selectedColor == color
                              ? Colors.black
                              : Colors.transparent,
                          width: 2,
                        ),
                      ),
                      child: _selectedColor == color
                          ? const Icon(Icons.check, color: Colors.white)
                          : null,
                    ),
                  );
                }).toList(),
              ),
              const SizedBox(height: 24),
              const Text(
                'Icône',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: _availableIcons.map((icon) {
                  return GestureDetector(
                    onTap: () => setState(() => _selectedIcon = icon),
                    child: Container(
                      width: 48,
                      height: 48,
                      decoration: BoxDecoration(
                        color: _selectedIcon == icon
                            ? _selectedColor
                            : Colors.grey[200],
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(
                          color: _selectedIcon == icon
                              ? _selectedColor
                              : Colors.grey[300]!,
                          width: 2,
                        ),
                      ),
                      child: Icon(
                        icon,
                        color: _selectedIcon == icon
                            ? Colors.white
                            : Colors.grey[600],
                      ),
                    ),
                  );
                }).toList(),
              ),
              const SizedBox(height: 32),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _saveCategory,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: _selectedColor,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                  ),
                  child: Text(
                    isEditing ? 'Modifier la catégorie' : 'Ajouter la catégorie',
                    style: const TextStyle(fontSize: 16),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
