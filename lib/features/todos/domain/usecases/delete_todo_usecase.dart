import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';

import '../../../../core/error/app_exception.dart';
import '../repositories/todo_repository.dart';

@injectable
class DeleteTodoUseCase {
  final TodoRepository _repository;

  DeleteTodoUseCase(this._repository);

  Future<Either<AppException, Unit>> call(int id) =>
      _repository.deleteTodo(id);
}
