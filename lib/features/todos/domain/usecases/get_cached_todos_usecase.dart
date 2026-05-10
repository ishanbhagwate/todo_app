import 'package:injectable/injectable.dart';

import '../entities/todo_entity.dart';
import '../repositories/todo_repository.dart';

@injectable
class GetCachedTodosUseCase {
  final TodoRepository _repository;

  GetCachedTodosUseCase(this._repository);

  List<TodoEntity> call() => _repository.getCachedTodos();
}
