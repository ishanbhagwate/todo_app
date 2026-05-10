import 'package:dartz/dartz.dart';
import 'package:dio/dio.dart';
import 'package:injectable/injectable.dart';

import '../../../../core/error/app_exception.dart';
import '../../../../core/error/dio_error_handler.dart';
import '../../domain/entities/todo_entity.dart';
import '../../domain/repositories/todo_repository.dart';
import '../datasources/todo_local_datasource.dart';
import '../datasources/todo_remote_datasource.dart';
import '../models/todo_model.dart';

@Injectable(as: TodoRepository)
class TodoRepositoryImpl implements TodoRepository {
  final TodoRemoteDataSource _remote;
  final TodoLocalDataSource _local;

  TodoRepositoryImpl(this._remote, this._local);

  @override
  Future<Either<AppException, List<TodoEntity>>> fetchTodos() async {
    try {
      final models = await _remote.fetchTodos();
      await _local.cacheTodos(models);
      return Right(models.map((m) => m.toEntity()).toList());
    } on DioException catch (e) {
      final cached = _local.getCachedTodos();
      if (cached.isNotEmpty) {
        return Right(cached.map((m) => m.toEntity()).toList());
      }
      return Left(DioErrorHandler.handle(e));
    }
  }

  @override
  List<TodoEntity> getCachedTodos() =>
      _local.getCachedTodos().map((m) => m.toEntity()).toList();

  @override
  Future<Either<AppException, TodoEntity>> addTodo(String title) async {
    try {
      final model = await _remote.addTodo(title);
      await _local.upsertTodo(model);
      return Right(model.toEntity());
    } on DioException catch (e) {
      return Left(DioErrorHandler.handle(e));
    }
  }

  @override
  Future<Either<AppException, TodoEntity>> completeTodo(int id) async {
    try {
      final model = await _remote.completeTodo(id);
      await _local.upsertTodo(model);
      return Right(model.toEntity());
    } on DioException catch (e) {
      return Left(DioErrorHandler.handle(e));
    }
  }

  @override
  Future<Either<AppException, Unit>> deleteTodo(int id) async {
    try {
      await _remote.deleteTodo(id);
      await _local.deleteTodoById(id);
      return const Right(unit);
    } on DioException catch (e) {
      return Left(DioErrorHandler.handle(e));
    }
  }

  @override
  Future<void> queueAddOperation(String title, int tempId) async {
    final tempModel = TodoModel(
      id: tempId,
      userId: 1,
      title: title,
      completed: false,
      isPendingSync: true,
    );
    await _local.upsertTodo(tempModel);
    await _local.addSyncOperation({
      'op': 'add',
      'title': title,
      'tempId': tempId,
    });
  }

  @override
  Future<void> queueCompleteOperation(int id) async {
    await _local.addSyncOperation({'op': 'complete', 'id': id});
  }

  @override
  Future<void> queueDeleteOperation(int id) async {
    await _local.addSyncOperation({'op': 'delete', 'id': id});
  }

  @override
  int get pendingSyncCount => _local.getPendingOperations().length;

  @override
  Future<void> syncPendingOperations() async {
    final operations = _local.getPendingOperations();
    for (final entry in operations) {
      final op = Map<String, dynamic>.from(entry.value as Map);
      try {
        switch (op['op'] as String) {
          case 'add':
            final title = op['title'] as String;
            final tempId = op['tempId'] as int;
            final model = await _remote.addTodo(title);
            await _local.deleteTodoById(tempId);
            await _local.upsertTodo(model);
          case 'complete':
            final model = await _remote.completeTodo(op['id'] as int);
            await _local.upsertTodo(model);
          case 'delete':
            await _remote.deleteTodo(op['id'] as int);
            await _local.deleteTodoById(op['id'] as int);
        }
        await _local.removeSyncOperation(entry.key);
      } on DioException {
        // Stop at first failure; remaining operations stay queued
        break;
      }
    }
  }
}
