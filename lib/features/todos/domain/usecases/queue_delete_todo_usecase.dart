import 'package:injectable/injectable.dart';

import '../repositories/todo_repository.dart';

@injectable
class QueueDeleteTodoUseCase {
  final TodoRepository _repository;

  QueueDeleteTodoUseCase(this._repository);

  Future<void> call(int id) => _repository.queueDeleteOperation(id);
}
