import 'package:equatable/equatable.dart';

enum AuthStatus { initial, loading, authenticated, unauthenticated, error }

enum AuthErrorCode { loginFailed, loginError }

class AuthState extends Equatable {
  final AuthStatus status;
  final AuthErrorCode? errorCode;
  final String? errorDetails;

  const AuthState({
    this.status = AuthStatus.initial,
    this.errorCode,
    this.errorDetails,
  });

  const AuthState.initial() : this();

  const AuthState.loading() : this(status: AuthStatus.loading);

  const AuthState.authenticated() : this(status: AuthStatus.authenticated);

  const AuthState.unauthenticated() : this(status: AuthStatus.unauthenticated);

  const AuthState.error(
    AuthErrorCode errorCode, {
    String? errorDetails,
  }) : this(
         status: AuthStatus.error,
         errorCode: errorCode,
         errorDetails: errorDetails,
       );

  @override
  List<Object?> get props => [status, errorCode, errorDetails];
}
