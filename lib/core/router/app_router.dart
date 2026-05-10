import 'package:azodha_assignment/core/router/route_paths.dart';
import 'package:azodha_assignment/splash_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:injectable/injectable.dart';

import '../../features/auth/presentation/bloc/auth_bloc.dart';
import '../../features/auth/presentation/bloc/auth_state.dart';
import '../../features/auth/presentation/screens/login_screen.dart';
import '../../features/todos/domain/repositories/todo_repository.dart';
import '../../features/todos/domain/usecases/add_todo_usecase.dart';
import '../../features/todos/domain/usecases/complete_todo_usecase.dart';
import '../../features/todos/domain/usecases/delete_todo_usecase.dart';
import '../../features/todos/domain/usecases/get_cached_todos_usecase.dart';
import '../../features/todos/domain/usecases/get_todos_usecase.dart';
import '../../features/todos/domain/usecases/queue_add_todo_usecase.dart';
import '../../features/todos/domain/usecases/queue_complete_todo_usecase.dart';
import '../../features/todos/domain/usecases/queue_delete_todo_usecase.dart';
import '../../features/todos/domain/usecases/sync_pending_todos_usecase.dart';
import '../../features/todos/presentation/bloc/todo_bloc.dart';
import '../../features/todos/presentation/bloc/todo_event.dart';
import '../../features/todos/presentation/screens/add_todo_screen.dart';
import '../../features/todos/presentation/screens/todo_list_screen.dart';
import '../../injection.dart';
import 'go_router_refresh_stream.dart';
import '../network/connectivity_service.dart';

@singleton
class AppRouter {
  final AuthBloc _authBloc;

  AppRouter(this._authBloc);

  late final GoRouter router = GoRouter(
    initialLocation: RoutePaths.splash,
    refreshListenable: GoRouterRefreshStream(_authBloc.stream),
    redirect: (BuildContext context, GoRouterState state) {
      final isAuthenticated = _authBloc.state is AuthAuthenticated;
      final isOnLogin = state.matchedLocation == RoutePaths.login;
      final isOnSplash = state.matchedLocation == RoutePaths.splash;

      if (!isAuthenticated && !isOnLogin) return RoutePaths.splash;
      if (!isAuthenticated && isOnSplash) return RoutePaths.login;
      if (isAuthenticated && isOnLogin) return RoutePaths.todoList;
      return null;
    },
    routes: [
      GoRoute(
        path: RoutePaths.login,
        builder: (context, state) => const LoginScreen(),
      ),
      GoRoute(
        path: RoutePaths.splash,
        builder: (context, state) => const SplashScreen(),
      ),
      ShellRoute(
        builder: (context, state, child) => BlocProvider<TodoBloc>(
          create: (_) => TodoBloc(
            getIt<GetTodosUseCase>(),
            getIt<GetCachedTodosUseCase>(),
            getIt<AddTodoUseCase>(),
            getIt<CompleteTodoUseCase>(),
            getIt<DeleteTodoUseCase>(),
            getIt<QueueAddTodoUseCase>(),
            getIt<QueueCompleteTodoUseCase>(),
            getIt<QueueDeleteTodoUseCase>(),
            getIt<SyncPendingTodosUseCase>(),
            getIt<TodoRepository>(),
            getIt<ConnectivityService>(),
          )..add(const LoadTasks()),
          child: child,
        ),
        routes: [
          GoRoute(
            path: RoutePaths.todoList,
            builder: (context, state) => const TodoListScreen(),
          ),
          GoRoute(
            path: RoutePaths.addTodo,
            builder: (context, state) => const AddTodoScreen(),
          ),
        ],
      ),
    ],
  );
}
