import 'package:equatable/equatable.dart';

sealed class TodoEvent extends Equatable {
  const TodoEvent();

  @override
  List<Object?> get props => [];
}

class LoadTasks extends TodoEvent {
  const LoadTasks();
}

class RefreshTasks extends TodoEvent {
  const RefreshTasks();
}

class AddTask extends TodoEvent {
  final String title;

  const AddTask(this.title);

  @override
  List<Object?> get props => [title];
}

class CompleteTask extends TodoEvent {
  final int id;

  const CompleteTask(this.id);

  @override
  List<Object?> get props => [id];
}

class DeleteTask extends TodoEvent {
  final int id;

  const DeleteTask(this.id);

  @override
  List<Object?> get props => [id];
}

class SearchTasks extends TodoEvent {
  final String query;

  const SearchTasks(this.query);

  @override
  List<Object?> get props => [query];
}

// Internal events dispatched only by TodoBloc
class ConnectivityChanged extends TodoEvent {
  final bool isOnline;

  const ConnectivityChanged(this.isOnline);

  @override
  List<Object?> get props => [isOnline];
}

class SyncPendingOperations extends TodoEvent {
  const SyncPendingOperations();
}
