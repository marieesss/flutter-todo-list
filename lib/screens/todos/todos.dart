import 'package:flutter/material.dart';
import 'package:flutter_application_1/components/row/row.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_application_1/models/todo.dart';
import 'package:flutter_application_1/services/todo_service.dart';

class TodosPage extends StatefulWidget {
  const TodosPage({
    super.key,
    required this.categoryId,
    required this.color,
    required this.title,
  });

  final String categoryId;
  final Color color;
  final String title;

  @override
  State<TodosPage> createState() => _TodosPageState();
}

class _TodosPageState extends State<TodosPage> {
  List<Todo> items = [];
  bool isLoading = true;
  final TextEditingController _controller = TextEditingController();

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
              dueAt: (todo.dueAt is Timestamp)
                  ? (todo.dueAt as Timestamp).toDate()
                  : todo.dueAt,
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
  DateTime? _newItemDueDate;

  void _setAsDone(int index, bool? value) {
    TodoService.updateTodo(
      id: items[index].id ?? '',
      categoryId: items[index].categoryId!,
      isDone: value ?? false,
    );

    _loadTodos();
  }

  void _deleteItem(int index) {
    TodoService.deleteTodo(items[index].id ?? '', widget.categoryId);

    _loadTodos();
  }

  void _addItem(String title) {
    if (title.trim().isEmpty) return;

    TodoService.addTodo(
      Todo(
        title: title,
        dueAt: _newItemDueDate,
        categoryId: widget.categoryId,
        isDone: false,
        createdAt: DateTime.now(),
      ),
    );

    setState(() {
      _newItemTitle = '';
      _newItemDueDate = null;
    });
    _controller.clear();
    _loadTodos();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: widget.color,
        title: Text(widget.title),
        iconTheme: IconThemeData(color: Colors.white),
        titleTextStyle: TextStyle(color: Colors.white, fontSize: 20),
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
                          controller: _controller,
                          cursorColor: widget.color,
                          decoration: InputDecoration(
                            labelText: 'Enter your todo',
                            labelStyle: TextStyle(color: widget.color),
                            focusedBorder: OutlineInputBorder(
                              borderSide: BorderSide(
                                color: widget.color,
                                width: 2,
                              ),
                            ),
                            enabledBorder: OutlineInputBorder(
                              borderSide: BorderSide(
                                color: widget.color.withOpacity(0.5),
                                width: 1,
                              ),
                            ),
                          ),
                          onChanged: (text) {
                            setState(() {
                              _newItemTitle = text;
                            });
                          },
                        ),
                      ),
                      IconButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: _newItemDueDate != null
                              ? Colors.grey
                              : widget.color,
                        ),
                        onPressed: () async {
                          DateTime? pickedDate = await showDatePicker(
                            context: context,
                            initialDate: DateTime.now(),
                            firstDate: DateTime(2000),
                            lastDate: DateTime(2100),

                            builder: (context, child) {
                              return Theme(
                                data: Theme.of(context).copyWith(
                                  colorScheme: ColorScheme.light(
                                    primary: widget.color,
                                    onPrimary: Colors.white,
                                    onSurface: widget.color,
                                    surface: Colors.white,
                                  ),
                                  textButtonTheme: TextButtonThemeData(
                                    style: TextButton.styleFrom(
                                      foregroundColor: widget.color,
                                    ),
                                  ),
                                ),
                                child: child!,
                              );
                            },
                          );

                          if (pickedDate != null) {
                            setState(() {
                              _newItemTitle = _newItemTitle;
                              _newItemDueDate = pickedDate;
                            });
                          }
                        },
                        icon: const Icon(
                          Icons.calendar_month,
                          color: Colors.white,
                        ),
                      ),
                      OutlinedButton(
                        style: OutlinedButton.styleFrom(
                          side: BorderSide(color: widget.color, width: 1),
                          shape: CircleBorder(),
                          padding: const EdgeInsets.all(5),
                        ),
                        onPressed: () {
                          _addItem(_newItemTitle);
                        },
                        child: Icon(Icons.add, color: widget.color),
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
                        dueAt: items[index].dueAt,
                        isDone: items[index].isDone,
                        onChanged: (value) {
                          _setAsDone(index, value);
                        },
                        onDelete: () {
                          _deleteItem(index);
                        },
                        checkColor: widget.color,
                      );
                    },
                  ),
                ),
              ],
            ),
    );
  }
}
