import 'package:dartz/dartz.dart';

import '../../../../core/error/app_exception.dart';
import '../entities/todo_entity.dart';

abstract class TodoRepository {
  // Remote + cache
  Future<Either<AppException, List<TodoEntity>>> fetchTodos();
  List<TodoEntity> getCachedTodos();

  // Mutations (hit network, update cache)
  Future<Either<AppException, TodoEntity>> addTodo(String title);
  Future<Either<AppException, TodoEntity>> completeTodo(int id);
  Future<Either<AppException, Unit>> deleteTodo(int id);

  // Offline queue
  Future<void> queueAddOperation(String title, int tempId);
  Future<void> queueCompleteOperation(int id);
  Future<void> queueDeleteOperation(int id);
  int get pendingSyncCount;

  // Sync
  Future<void> syncPendingOperations();
}
