// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format width=80

// **************************************************************************
// InjectableConfigGenerator
// **************************************************************************

// ignore_for_file: type=lint
// coverage:ignore-file

// ignore_for_file: no_leading_underscores_for_library_prefixes
import 'package:azodha_assignment/core/di/modules/network_module.dart' as _i887;
import 'package:azodha_assignment/core/network/connectivity_service.dart'
    as _i438;
import 'package:azodha_assignment/core/router/app_router.dart' as _i953;
import 'package:azodha_assignment/features/auth/data/repositories/auth_repository_impl.dart'
    as _i111;
import 'package:azodha_assignment/features/auth/domain/repositories/auth_repository.dart'
    as _i585;
import 'package:azodha_assignment/features/auth/domain/usecases/login_usecase.dart'
    as _i871;
import 'package:azodha_assignment/features/auth/presentation/bloc/auth_bloc.dart'
    as _i383;
import 'package:azodha_assignment/features/todos/data/datasources/todo_local_datasource.dart'
    as _i399;
import 'package:azodha_assignment/features/todos/data/datasources/todo_remote_datasource.dart'
    as _i0;
import 'package:azodha_assignment/features/todos/data/repositories/todo_repository_impl.dart'
    as _i990;
import 'package:azodha_assignment/features/todos/domain/repositories/todo_repository.dart'
    as _i994;
import 'package:azodha_assignment/features/todos/domain/usecases/add_todo_usecase.dart'
    as _i157;
import 'package:azodha_assignment/features/todos/domain/usecases/complete_todo_usecase.dart'
    as _i221;
import 'package:azodha_assignment/features/todos/domain/usecases/delete_todo_usecase.dart'
    as _i957;
import 'package:azodha_assignment/features/todos/domain/usecases/get_cached_todos_usecase.dart'
    as _i251;
import 'package:azodha_assignment/features/todos/domain/usecases/get_todos_usecase.dart'
    as _i618;
import 'package:azodha_assignment/features/todos/domain/usecases/queue_add_todo_usecase.dart'
    as _i416;
import 'package:azodha_assignment/features/todos/domain/usecases/queue_complete_todo_usecase.dart'
    as _i743;
import 'package:azodha_assignment/features/todos/domain/usecases/queue_delete_todo_usecase.dart'
    as _i1011;
import 'package:azodha_assignment/features/todos/domain/usecases/sync_pending_todos_usecase.dart'
    as _i134;
import 'package:azodha_assignment/features/todos/presentation/bloc/todo_bloc.dart'
    as _i901;
import 'package:connectivity_plus/connectivity_plus.dart' as _i895;
import 'package:dio/dio.dart' as _i361;
import 'package:get_it/get_it.dart' as _i174;
import 'package:injectable/injectable.dart' as _i526;

extension GetItInjectableX on _i174.GetIt {
  // initializes the registration of main-scope dependencies inside of GetIt
  _i174.GetIt init({
    String? environment,
    _i526.EnvironmentFilter? environmentFilter,
  }) {
    final gh = _i526.GetItHelper(this, environment, environmentFilter);
    final networkModule = _$NetworkModule();
    gh.factory<_i399.TodoLocalDataSource>(() => _i399.TodoLocalDataSource());
    gh.singleton<_i895.Connectivity>(() => networkModule.connectivity);
    gh.singleton<_i361.Dio>(() => networkModule.dio());
    gh.factory<_i0.TodoRemoteDataSource>(
      () => _i0.TodoRemoteDataSource(gh<_i361.Dio>()),
    );
    gh.factory<_i585.AuthRepository>(() => _i111.AuthRepositoryImpl());
    gh.singleton<_i438.ConnectivityService>(
      () => _i438.ConnectivityService(gh<_i895.Connectivity>()),
    );
    gh.factory<_i871.LoginUseCase>(
      () => _i871.LoginUseCase(gh<_i585.AuthRepository>()),
    );
    gh.singleton<_i383.AuthBloc>(
      () => _i383.AuthBloc(gh<_i871.LoginUseCase>()),
    );
    gh.factory<_i994.TodoRepository>(
      () => _i990.TodoRepositoryImpl(
        gh<_i0.TodoRemoteDataSource>(),
        gh<_i399.TodoLocalDataSource>(),
      ),
    );
    gh.singleton<_i953.AppRouter>(() => _i953.AppRouter(gh<_i383.AuthBloc>()));
    gh.factory<_i157.AddTodoUseCase>(
      () => _i157.AddTodoUseCase(gh<_i994.TodoRepository>()),
    );
    gh.factory<_i221.CompleteTodoUseCase>(
      () => _i221.CompleteTodoUseCase(gh<_i994.TodoRepository>()),
    );
    gh.factory<_i957.DeleteTodoUseCase>(
      () => _i957.DeleteTodoUseCase(gh<_i994.TodoRepository>()),
    );
    gh.factory<_i251.GetCachedTodosUseCase>(
      () => _i251.GetCachedTodosUseCase(gh<_i994.TodoRepository>()),
    );
    gh.factory<_i618.GetTodosUseCase>(
      () => _i618.GetTodosUseCase(gh<_i994.TodoRepository>()),
    );
    gh.factory<_i416.QueueAddTodoUseCase>(
      () => _i416.QueueAddTodoUseCase(gh<_i994.TodoRepository>()),
    );
    gh.factory<_i743.QueueCompleteTodoUseCase>(
      () => _i743.QueueCompleteTodoUseCase(gh<_i994.TodoRepository>()),
    );
    gh.factory<_i1011.QueueDeleteTodoUseCase>(
      () => _i1011.QueueDeleteTodoUseCase(gh<_i994.TodoRepository>()),
    );
    gh.factory<_i134.SyncPendingTodosUseCase>(
      () => _i134.SyncPendingTodosUseCase(gh<_i994.TodoRepository>()),
    );
    gh.factory<_i901.TodoBloc>(
      () => _i901.TodoBloc(
        gh<_i618.GetTodosUseCase>(),
        gh<_i251.GetCachedTodosUseCase>(),
        gh<_i157.AddTodoUseCase>(),
        gh<_i221.CompleteTodoUseCase>(),
        gh<_i957.DeleteTodoUseCase>(),
        gh<_i416.QueueAddTodoUseCase>(),
        gh<_i743.QueueCompleteTodoUseCase>(),
        gh<_i1011.QueueDeleteTodoUseCase>(),
        gh<_i134.SyncPendingTodosUseCase>(),
        gh<_i994.TodoRepository>(),
        gh<_i438.ConnectivityService>(),
      ),
    );
    return this;
  }
}

class _$NetworkModule extends _i887.NetworkModule {}
