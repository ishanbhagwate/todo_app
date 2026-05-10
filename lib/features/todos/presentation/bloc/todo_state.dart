import 'package:equatable/equatable.dart';

import '../../domain/entities/todo_entity.dart';

enum TodoStatus { initial, loading, success, failure }

class TodoState extends Equatable {
  final List<TodoEntity> todos;
  final List<TodoEntity> filteredTodos;
  final String searchQuery;
  final TodoStatus status;
  final String? errorMessage;
  final bool isOnline;
  final int pendingSyncCount;

  const TodoState({
    required this.todos,
    required this.filteredTodos,
    required this.searchQuery,
    required this.status,
    this.errorMessage,
    required this.isOnline,
    required this.pendingSyncCount,
  });

  factory TodoState.initial() => const TodoState(
        todos: [],
        filteredTodos: [],
        searchQuery: '',
        status: TodoStatus.initial,
        isOnline: true,
        pendingSyncCount: 0,
      );

  TodoState copyWith({
    List<TodoEntity>? todos,
    List<TodoEntity>? filteredTodos,
    String? searchQuery,
    TodoStatus? status,
    String? errorMessage,
    bool clearError = false,
    bool? isOnline,
    int? pendingSyncCount,
  }) {
    return TodoState(
      todos: todos ?? this.todos,
      filteredTodos: filteredTodos ?? this.filteredTodos,
      searchQuery: searchQuery ?? this.searchQuery,
      status: status ?? this.status,
      errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
      isOnline: isOnline ?? this.isOnline,
      pendingSyncCount: pendingSyncCount ?? this.pendingSyncCount,
    );
  }

  @override
  List<Object?> get props => [
        todos,
        filteredTodos,
        searchQuery,
        status,
        errorMessage,
        isOnline,
        pendingSyncCount,
      ];
}
