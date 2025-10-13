import 'package:flutter/material.dart';
import 'package:flutter_application_1/components/row/row.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_application_1/models/todo.dart';
import 'package:flutter_application_1/services/todo_service.dart';

class TodosPage extends StatefulWidget {
  const TodosPage({super.key, required this.categoryId});

  final String categoryId;

  @override
  State<TodosPage> createState() => _TodosPageState();
}

class _TodosPageState extends State<TodosPage> {
  List<Todo> items = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadTodos();
  }

  @override
  void dispose() {
    items = [];
    super.dispose();
  }

  Future<void> _loadTodos() async {
    final todos = await TodoService.getAllTodos(widget.categoryId);

    setState(() {
      items = todos
          .map(
            (todo) => Todo(
              id: todo.id,
              title: todo.title,
              isDone: todo.isDone,
              dueAt: todo.dueAt,
              categoryId: todo.categoryId,
              createdAt: todo.createdAt,
              updatedAt: todo.updatedAt,
            ),
          )
          .toList();
      isLoading = false;
    });
  }

  String _newItemTitle = '';

  void _setAsDone(int index, bool? value) {
    TodoService.updateTodo(
      id: items[index].id ?? '',
      categoryId: items[index].categoryId!,
      isDone: value ?? false,
    );

    _loadTodos();
  }

  void _addItem(String title) {
    if (title.trim().isEmpty) return;

    TodoService.addTodo(
      Todo(
        title: title,
        dueAt: DateTime.now(),
        categoryId: widget.categoryId,
        isDone: false,
        createdAt: DateTime.now(),
      ),
    );

    _loadTodos();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: const Text('Todos'),
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : Column(
              children: <Widget>[
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Row(
                    children: [
                      Expanded(
                        child: TextField(
                          decoration: const InputDecoration(
                            border: OutlineInputBorder(),
                            labelText: 'Enter your todo',
                          ),
                          onChanged: (text) {
                            setState(() {
                              _newItemTitle = text;
                            });
                          },
                        ),
                      ),
                      const SizedBox(width: 8),
                      ElevatedButton(
                        onPressed: () {
                          _addItem(_newItemTitle);
                        },
                        child: const Text("Add"),
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: ListView.builder(
                    padding: const EdgeInsets.all(8),
                    itemCount: items.length,
                    itemBuilder: (BuildContext context, int index) {
                      return RowClass(
                        title: items[index].title,
                        isDone: items[index].isDone,
                        onChanged: (value) {
                          _setAsDone(index, value);
                        },
                      );
                    },
                  ),
                ),
              ],
            ),
    );
  }
}
