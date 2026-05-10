import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../domain/entities/todo_entity.dart';
import '../bloc/todo_bloc.dart';
import '../bloc/todo_event.dart';

class TodoListItem extends StatelessWidget {
  final TodoEntity todo;

  const TodoListItem({super.key, required this.todo});

  @override
  Widget build(BuildContext context) {
    return Dismissible(
      key: ValueKey(todo.id),
      direction: DismissDirection.endToStart,
      background: Container(
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 16),
        color: Colors.red,
        child: const Icon(Icons.delete, color: Colors.white),
      ),
      confirmDismiss: (_) async {
        return await showDialog<bool>(
          context: context,
          builder: (ctx) => AlertDialog(
            title: const Text('Delete Todo'),
            content: const Text('Are you sure you want to delete this todo?'),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(ctx).pop(false),
                child: const Text('Cancel'),
              ),
              TextButton(
                onPressed: () => Navigator.of(ctx).pop(true),
                child:
                    const Text('Delete', style: TextStyle(color: Colors.red)),
              ),
            ],
          ),
        );
      },
      onDismissed: (_) => context.read<TodoBloc>().add(DeleteTask(todo.id)),
      child: ListTile(
        leading: Checkbox(
          value: todo.completed,
          onChanged: todo.isPendingSync || todo.completed
              ? null
              : (_) => context.read<TodoBloc>().add(CompleteTask(todo.id)),
        ),
        title: Text(
          todo.title,
          style: TextStyle(
            decoration: todo.completed
                ? TextDecoration.lineThrough
                : TextDecoration.none,
            color: todo.completed ? Colors.grey : null,
          ),
        ),
        subtitle: todo.isPendingSync
            ? const Row(
                children: [
                  Icon(Icons.sync, size: 12, color: Colors.orange),
                  SizedBox(width: 4),
                  Text(
                    'Pending sync',
                    style: TextStyle(fontSize: 11, color: Colors.orange),
                  ),
                ],
              )
            : null,
        trailing: IconButton(
          icon: const Icon(Icons.delete_outline, color: Colors.red),
          onPressed: () {
            showDialog<bool>(
              context: context,
              builder: (ctx) => AlertDialog(
                title: const Text('Delete Todo'),
                content:
                    const Text('Are you sure you want to delete this todo?'),
                actions: [
                  TextButton(
                    onPressed: () => Navigator.of(ctx).pop(false),
                    child: const Text('Cancel'),
                  ),
                  TextButton(
                    onPressed: () {
                      Navigator.of(ctx).pop(true);
                      context.read<TodoBloc>().add(DeleteTask(todo.id));
                    },
                    child: const Text('Delete',
                        style: TextStyle(color: Colors.red)),
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}
