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

  void _setAsDone(int index, bool? value) {
    setState(() {
      items[index].isDone = value ?? false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
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
