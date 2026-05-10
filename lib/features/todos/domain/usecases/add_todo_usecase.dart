import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';

import '../../../../core/error/app_exception.dart';
import '../entities/todo_entity.dart';
import '../repositories/todo_repository.dart';

@injectable
class AddTodoUseCase {
  final TodoRepository _repository;

  AddTodoUseCase(this._repository);

  Future<Either<AppException, TodoEntity>> call(String title) =>
      _repository.addTodo(title);
}
