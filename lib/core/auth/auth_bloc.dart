import 'package:flutter_bloc/flutter_bloc.dart';
import 'dart:async';

import 'auth_event.dart';
import 'auth_service.dart';
import 'auth_state.dart';

class AuthBloc extends Bloc<AuthEvent, AuthState> {
  final AuthService _authService;
  late final StreamSubscription<bool> _sessionStateSubscription;

  AuthBloc({required AuthService authService})
      : _authService = authService,
        super(
          authService.isLoggedIn
              ? const AuthState.authenticated()
              : const AuthState.unauthenticated(),
        ) {
    on<AuthLoginRequested>(_onLoginRequested);
    on<AuthLogoutRequested>(_onLogoutRequested);
    on<_AuthSessionChanged>(_onSessionChanged);

    _sessionStateSubscription = _authService.sessionStateChanges.listen((isAuthenticated) {
      add(_AuthSessionChanged(isAuthenticated));
    });
  }

  Future<void> _onLoginRequested(
    AuthLoginRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(const AuthState.loading());
    // Redirect login navigates away from the app. When the user returns,
    // app startup re-evaluates the authentication state.
    try {
      final success = await _authService.login();
      if (!success) {
        emit(const AuthState.error(AuthErrorCode.loginFailed));
      }
    } catch (e) {
      emit(AuthState.error(AuthErrorCode.loginError, errorDetails: e.toString()));
    }
  }

  Future<void> _onLogoutRequested(
    AuthLogoutRequested event,
    Emitter<AuthState> emit,
  ) async {
    // Do not emit unauthenticated here. logoutRedirect() must be allowed to
    // navigate the browser away before Flutter re-renders the login route.
    await _authService.logout();
  }

  void _onSessionChanged(
    _AuthSessionChanged event,
    Emitter<AuthState> emit,
  ) {
    emit(
      event.isAuthenticated
          ? const AuthState.authenticated()
          : const AuthState.unauthenticated(),
    );
  }

  @override
  Future<void> close() async {
    await _sessionStateSubscription.cancel();
    return super.close();
  }
}

class _AuthSessionChanged extends AuthEvent {
  const _AuthSessionChanged(this.isAuthenticated);

  final bool isAuthenticated;

  @override
  List<Object?> get props => [isAuthenticated];
}
