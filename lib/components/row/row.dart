import 'package:flutter/material.dart';

class RowClass extends StatelessWidget {
  const RowClass({
    required this.title,
    required this.isDone,
    required this.onChanged,
    super.key,
  });

  final String title;
  final bool isDone;
  final ValueChanged<bool?> onChanged;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      title: Text(title),
      contentPadding: const EdgeInsets.all(8.0),
      leading: Checkbox(value: isDone, onChanged: onChanged),
    );
  }
}
