import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';

import '../../../../core/error/app_exception.dart';
import '../entities/todo_entity.dart';
import '../repositories/todo_repository.dart';

@injectable
class GetTodosUseCase {
  final TodoRepository _repository;

  GetTodosUseCase(this._repository);

  Future<Either<AppException, List<TodoEntity>>> call() =>
      _repository.fetchTodos();
}
