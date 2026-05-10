import 'package:injectable/injectable.dart';

import '../repositories/todo_repository.dart';

@injectable
class QueueCompleteTodoUseCase {
  final TodoRepository _repository;

  QueueCompleteTodoUseCase(this._repository);

  Future<void> call(int id) => _repository.queueCompleteOperation(id);
}
