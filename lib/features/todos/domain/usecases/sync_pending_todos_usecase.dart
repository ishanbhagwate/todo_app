import 'package:injectable/injectable.dart';

import '../repositories/todo_repository.dart';

@injectable
class SyncPendingTodosUseCase {
  final TodoRepository _repository;

  SyncPendingTodosUseCase(this._repository);

  Future<void> call() => _repository.syncPendingOperations();
}
