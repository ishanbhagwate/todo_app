import 'package:injectable/injectable.dart';

import '../repositories/todo_repository.dart';

@injectable
class QueueAddTodoUseCase {
  final TodoRepository _repository;

  QueueAddTodoUseCase(this._repository);

  Future<void> call(String title, int tempId) =>
      _repository.queueAddOperation(title, tempId);
}
