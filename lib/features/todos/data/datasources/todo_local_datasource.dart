import 'package:hive_flutter/hive_flutter.dart';
import 'package:injectable/injectable.dart';

import '../../../../core/constants/hive_constants.dart';
import '../models/todo_model.dart';

@injectable
class TodoLocalDataSource {
  Box<TodoModel> get _todosBox => Hive.box<TodoModel>(HiveConstants.todosBox);
  Box get _syncQueueBox => Hive.box(HiveConstants.syncQueueBox);

  List<TodoModel> getCachedTodos() => _todosBox.values.toList();

  Future<void> cacheTodos(List<TodoModel> todos) async {
    await _todosBox.clear();
    for (final todo in todos) {
      await _todosBox.put(todo.id, todo);
    }
  }

  Future<void> upsertTodo(TodoModel todo) async {
    await _todosBox.put(todo.id, todo);
  }

  Future<void> deleteTodoById(int id) async {
    await _todosBox.delete(id);
  }

  Future<void> addSyncOperation(Map<String, dynamic> operation) async {
    await _syncQueueBox.add(operation);
  }

  List<MapEntry<dynamic, dynamic>> getPendingOperations() =>
      _syncQueueBox.toMap().entries.toList();

  Future<void> removeSyncOperation(dynamic key) async {
    await _syncQueueBox.delete(key);
  }

  Future<void> clearSyncQueue() async {
    await _syncQueueBox.clear();
  }
}
