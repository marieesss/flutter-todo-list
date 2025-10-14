import 'package:flutter/material.dart';

class RowClass extends StatelessWidget {
  const RowClass({
    required this.title,
    required this.isDone,
    required this.onChanged,
    required this.onDelete,
    required this.checkColor,
    this.dueAt,
    super.key,
  });

  final String title;
  final bool isDone;
  final Color checkColor;
  final ValueChanged<bool?> onChanged;
  final VoidCallback onDelete;
  final DateTime? dueAt;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      title: Text(title),
      contentPadding: const EdgeInsets.all(8.0),
      leading: Checkbox(
        value: isDone,
        onChanged: onChanged,
        activeColor: checkColor,
        side: const BorderSide(color: Colors.white),
      ),
      subtitle: Text(
        dueAt != null
            ? "Due: ${dueAt!.day}/${dueAt!.month}/${dueAt!.year}"
            : "No due date",
        style: TextStyle(
          color:
              dueAt != null &&
                  dueAt!.isBefore(DateTime.now().add(const Duration(hours: 24)))
              ? Colors.red
              : null,
        ),
      ),
      trailing: IconButton(
        icon: Icon(Icons.delete, color: checkColor),
        onPressed: onDelete,
      ),
    );
  }
}
