import 'package:flutter_bloc/flutter_bloc.dart';

import 'auth_event.dart';
import 'auth_service.dart';
import 'auth_state.dart';

class AuthBloc extends Bloc<AuthEvent, AuthState> {
  final AuthService _authService;

  AuthBloc({required AuthService authService})
      : _authService = authService,
        super(
          authService.isLoggedIn
              ? const AuthState.authenticated()
              : const AuthState.unauthenticated(),
        ) {
    on<AuthLoginRequested>(_onLoginRequested);
    on<AuthLogoutRequested>(_onLogoutRequested);
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
        emit(const AuthState.error('Login failed'));
      }
    } catch (e) {
      emit(AuthState.error('Login error: $e'));
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
}
