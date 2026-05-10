import 'dart:async';

import 'package:bloc_concurrency/bloc_concurrency.dart';
import 'package:hydrated_bloc/hydrated_bloc.dart';
import 'package:injectable/injectable.dart';

import '../../../../core/network/connectivity_service.dart';
import '../../domain/entities/todo_entity.dart';
import '../../domain/repositories/todo_repository.dart';
import '../../domain/usecases/add_todo_usecase.dart';
import '../../domain/usecases/complete_todo_usecase.dart';
import '../../domain/usecases/delete_todo_usecase.dart';
import '../../domain/usecases/get_cached_todos_usecase.dart';
import '../../domain/usecases/get_todos_usecase.dart';
import '../../domain/usecases/queue_add_todo_usecase.dart';
import '../../domain/usecases/queue_complete_todo_usecase.dart';
import '../../domain/usecases/queue_delete_todo_usecase.dart';
import '../../domain/usecases/sync_pending_todos_usecase.dart';
import 'todo_event.dart';
import 'todo_state.dart';

@injectable
class TodoBloc extends HydratedBloc<TodoEvent, TodoState> {
  final GetTodosUseCase _getTodos;
  final GetCachedTodosUseCase _getCachedTodos;
  final AddTodoUseCase _addTodo;
  final CompleteTodoUseCase _completeTodo;
  final DeleteTodoUseCase _deleteTodo;
  final QueueAddTodoUseCase _queueAdd;
  final QueueCompleteTodoUseCase _queueComplete;
  final QueueDeleteTodoUseCase _queueDelete;
  final SyncPendingTodosUseCase _syncPending;
  final TodoRepository _repository;
  final ConnectivityService _connectivity;

  late final StreamSubscription<bool> _connectivitySubscription;
  bool _wasOnline = true;

  TodoBloc(
    this._getTodos,
    this._getCachedTodos,
    this._addTodo,
    this._completeTodo,
    this._deleteTodo,
    this._queueAdd,
    this._queueComplete,
    this._queueDelete,
    this._syncPending,
    this._repository,
    this._connectivity,
  ) : super(TodoState.initial()) {
    on<LoadTasks>(_onLoadTasks, transformer: droppable());
    on<RefreshTasks>(_onRefreshTasks);
    on<AddTask>(_onAddTask);
    on<CompleteTask>(_onCompleteTask);
    on<DeleteTask>(_onDeleteTask);
    on<SearchTasks>(_onSearchTasks);
    on<ConnectivityChanged>(_onConnectivityChanged);
    on<SyncPendingOperations>(_onSyncPendingOperations);

    _connectivitySubscription = _connectivity.onConnectivityChanged.listen((
      isOnline,
    ) {
      add(ConnectivityChanged(isOnline));
    });
  }

  List<TodoEntity> _filtered(List<TodoEntity> todos, String query) {
    if (query.isEmpty) return todos;
    return todos
        .where((t) => t.title.toLowerCase().contains(query.toLowerCase()))
        .toList();
  }

  Future<void> _onLoadTasks(LoadTasks event, Emitter<TodoState> emit) async {
    emit(state.copyWith(status: TodoStatus.loading, clearError: true));

    final cached = _getCachedTodos();
    if (cached.isNotEmpty) {
      emit(
        state.copyWith(
          todos: cached,
          filteredTodos: _filtered(cached, state.searchQuery),
          status: TodoStatus.success,
        ),
      );
    }

    final isOnline = await _connectivity.isConnected;
    if (!isOnline) {
      emit(state.copyWith(isOnline: false));
      if (cached.isEmpty) {
        emit(
          state.copyWith(
            status: TodoStatus.failure,
            errorMessage: 'No internet connection and no cached data',
          ),
        );
      }
      return;
    }

    final result = await _getTodos();
    result.fold(
      (failure) {
        if (state.todos.isEmpty) {
          emit(
            state.copyWith(
              status: TodoStatus.failure,
              errorMessage: failure.message,
            ),
          );
        }
      },
      (todos) => emit(
        state.copyWith(
          todos: todos,
          filteredTodos: _filtered(todos, state.searchQuery),
          status: TodoStatus.success,
          isOnline: true,
          pendingSyncCount: _repository.pendingSyncCount,
        ),
      ),
    );
  }

  Future<void> _onRefreshTasks(
    RefreshTasks event,
    Emitter<TodoState> emit,
  ) async {
    emit(state.copyWith(status: TodoStatus.loading, clearError: true));
    final isOnline = await _connectivity.isConnected;
    if (!isOnline) {
      emit(
        state.copyWith(
          status: TodoStatus.failure,
          errorMessage: 'No internet connection',
          isOnline: false,
        ),
      );
      return;
    }

    final result = await _getTodos();
    result.fold(
      (failure) => emit(
        state.copyWith(
          status: TodoStatus.failure,
          errorMessage: failure.message,
        ),
      ),
      (todos) => emit(
        state.copyWith(
          todos: todos,
          filteredTodos: _filtered(todos, state.searchQuery),
          status: TodoStatus.success,
          isOnline: true,
        ),
      ),
    );
  }

  Future<void> _onAddTask(AddTask event, Emitter<TodoState> emit) async {
    final tempId = -DateTime.now().millisecondsSinceEpoch;
    final tempTodo = TodoEntity(
      id: tempId,
      userId: 1,
      title: event.title,
      completed: false,
      isPendingSync: true,
    );
    final optimistic = [tempTodo, ...state.todos];
    emit(
      state.copyWith(
        todos: optimistic,
        filteredTodos: _filtered(optimistic, state.searchQuery),
        status: TodoStatus.success,
      ),
    );

    final isOnline = await _connectivity.isConnected;
    if (!isOnline) {
      await _queueAdd(event.title, tempId);
      emit(
        state.copyWith(
          pendingSyncCount: _repository.pendingSyncCount,
          isOnline: false,
        ),
      );
      return;
    }

    final result = await _addTodo(event.title);
    result.fold(
      (failure) {
        final rolled = state.todos.where((t) => t.id != tempId).toList();
        emit(
          state.copyWith(
            todos: rolled,
            filteredTodos: _filtered(rolled, state.searchQuery),
            status: TodoStatus.failure,
            errorMessage: failure.message,
          ),
        );
      },
      (saved) {
        final updated = state.todos
            .map((t) => t.id == tempId ? saved : t)
            .toList();
        emit(
          state.copyWith(
            todos: updated,
            filteredTodos: _filtered(updated, state.searchQuery),
            status: TodoStatus.success,
          ),
        );
      },
    );
  }

  Future<void> _onCompleteTask(
    CompleteTask event,
    Emitter<TodoState> emit,
  ) async {
    final previous = state.todos;
    final optimistic = state.todos
        .map((t) => t.id == event.id ? t.copyWith(completed: true) : t)
        .toList();
    emit(
      state.copyWith(
        todos: optimistic,
        filteredTodos: _filtered(optimistic, state.searchQuery),
      ),
    );

    final isOnline = await _connectivity.isConnected;
    if (!isOnline) {
      await _queueComplete(event.id);
      emit(
        state.copyWith(
          pendingSyncCount: _repository.pendingSyncCount,
          isOnline: false,
        ),
      );
      return;
    }

    final result = await _completeTodo(event.id);
    result.fold(
      (failure) => emit(
        state.copyWith(
          todos: previous,
          filteredTodos: _filtered(previous, state.searchQuery),
          status: TodoStatus.failure,
          errorMessage: failure.message,
        ),
      ),
      (_) => null, // optimistic state is already correct
    );
  }

  Future<void> _onDeleteTask(DeleteTask event, Emitter<TodoState> emit) async {
    final deletedIndex = state.todos.indexWhere((t) => t.id == event.id);
    final deletedTodo = deletedIndex != -1 ? state.todos[deletedIndex] : null;
    final optimistic = state.todos.where((t) => t.id != event.id).toList();
    emit(
      state.copyWith(
        todos: optimistic,
        filteredTodos: _filtered(optimistic, state.searchQuery),
      ),
    );

    final isOnline = await _connectivity.isConnected;
    if (!isOnline) {
      await _queueDelete(event.id);
      emit(
        state.copyWith(
          pendingSyncCount: _repository.pendingSyncCount,
          isOnline: false,
        ),
      );
      return;
    }

    final result = await _deleteTodo(event.id);
    result.fold(
      (failure) {
        final restored = List<TodoEntity>.from(state.todos);
        if (deletedTodo != null) restored.insert(deletedIndex, deletedTodo);
        emit(
          state.copyWith(
            todos: restored,
            filteredTodos: _filtered(restored, state.searchQuery),
            status: TodoStatus.failure,
            errorMessage: failure.message,
          ),
        );
      },
      (_) => null, // optimistic state is already correct
    );
  }

  void _onSearchTasks(SearchTasks event, Emitter<TodoState> emit) {
    emit(
      state.copyWith(
        searchQuery: event.query,
        filteredTodos: _filtered(state.todos, event.query),
      ),
    );
  }

  Future<void> _onConnectivityChanged(
    ConnectivityChanged event,
    Emitter<TodoState> emit,
  ) async {
    emit(state.copyWith(isOnline: event.isOnline));
    if (!_wasOnline && event.isOnline) add(const SyncPendingOperations());
    _wasOnline = event.isOnline;
  }

  Future<void> _onSyncPendingOperations(
    SyncPendingOperations event,
    Emitter<TodoState> emit,
  ) async {
    try {
      await _syncPending();
    } on Exception {
      // Partial failure is fine — remaining ops stay queued
    }
    emit(state.copyWith(pendingSyncCount: _repository.pendingSyncCount));
    add(const LoadTasks());
  }

  @override
  Future<void> close() {
    _connectivitySubscription.cancel();
    return super.close();
  }

  @override
  TodoState? fromJson(Map<String, dynamic> json) {
    try {
      final todosJson = json['todos'] as List?;
      if (todosJson == null) return TodoState.initial();
      final todos = todosJson
          .map((e) => TodoEntity.fromJson(Map<String, dynamic>.from(e as Map)))
          .toList();
      return TodoState.initial().copyWith(todos: todos, filteredTodos: todos);
    } catch (_) {
      return TodoState.initial();
    }
  }

  @override
  Map<String, dynamic>? toJson(TodoState state) => {
    'todos': state.todos.map((t) => t.toJson()).toList(),
  };
}
