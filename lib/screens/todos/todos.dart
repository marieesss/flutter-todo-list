import 'package:flutter/material.dart';
import 'package:flutter_application_1/components/row/row.dart';

class ListItem {
  String title;
  bool isDone;

  ListItem({required this.title, this.isDone = false});
}

class TodosPage extends StatefulWidget {
  const TodosPage({super.key});

  @override
  State<TodosPage> createState() => _TodosPageState();
}

class _TodosPageState extends State<TodosPage> {
  List<ListItem> items = [
    ListItem(title: 'Marie'),
    ListItem(title: 'Espinosa'),
    ListItem(title: 'Item 3'),
  ];

  String _newItemTitle = '';

  void _setAsDone(int index, bool? value) {
    setState(() {
      items[index].isDone = value ?? false;
    });
  }

  void _addItem(String title) {
    if (title.trim().isEmpty) return; // ignore si vide
    setState(() {
      items.add(ListItem(title: title));
      _newItemTitle = '';
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: const Text('Todos'),
      ),
      body: Column(
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
