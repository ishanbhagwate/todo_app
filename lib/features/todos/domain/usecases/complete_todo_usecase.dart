import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';

import '../../../../core/error/app_exception.dart';
import '../entities/todo_entity.dart';
import '../repositories/todo_repository.dart';

@injectable
class CompleteTodoUseCase {
  final TodoRepository _repository;

  CompleteTodoUseCase(this._repository);

  Future<Either<AppException, TodoEntity>> call(int id) =>
      _repository.completeTodo(id);
}
