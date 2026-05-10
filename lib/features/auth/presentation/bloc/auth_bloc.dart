import 'package:hydrated_bloc/hydrated_bloc.dart';
import 'package:injectable/injectable.dart';

import '../../domain/repositories/auth_repository.dart';
import '../../domain/usecases/login_usecase.dart';
import 'auth_event.dart';
import 'auth_state.dart';

@singleton
class AuthBloc extends HydratedBloc<AuthEvent, AuthState> {
  final LoginUseCase _loginUseCase;

  AuthBloc(this._loginUseCase) : super(const AuthInitial()) {
    on<LoginRequested>(_onLoginRequested);
    on<LogoutRequested>(_onLogoutRequested);
  }

  Future<void> _onLoginRequested(
    LoginRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(const AuthLoading());
    try {
      await _loginUseCase(event.username, event.password);
      emit(AuthAuthenticated(event.username));
    } on AuthException catch (e) {
      emit(AuthFailure(e.message));
    }
  }

  void _onLogoutRequested(LogoutRequested event, Emitter<AuthState> emit) {
    clear();
    emit(const AuthInitial());
  }

  @override
  AuthState? fromJson(Map<String, dynamic> json) {
    final username = json['username'] as String?;
    if (username != null) return AuthAuthenticated(username);
    return const AuthInitial();
  }

  @override
  Map<String, dynamic>? toJson(AuthState state) {
    if (state is AuthAuthenticated) return {'username': state.username};
    return null;
  }
}
