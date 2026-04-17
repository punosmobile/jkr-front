import 'package:dio/dio.dart';

import '../../auth/auth_service.dart';
import '../../di/injection.dart';
import '../dio_client.dart';

class AuthInterceptor extends Interceptor {
  static const String requiresAuthKey = 'requiresAuth';
  static const String _retryAttemptedKey = '_authRetryAttempted';

  @override
  Future<void> onRequest(
    RequestOptions options,
    RequestInterceptorHandler handler,
  ) async {
    final authService = getIt<AuthService>();
    final token = await authService.getAccessTokenSilently();
    if (token != null) {
      options.headers['Authorization'] = 'Bearer $token';
    }
    handler.next(options);
  }

  @override
  Future<void> onError(DioException err, ErrorInterceptorHandler handler) async {
    final requestOptions = err.requestOptions;
    final isProtectedRequest = requestOptions.extra[requiresAuthKey] == true;
    final alreadyRetried = requestOptions.extra[_retryAttemptedKey] == true;

    if (err.response?.statusCode == 401 && isProtectedRequest) {
      final authService = getIt<AuthService>();

      if (alreadyRetried) {
        authService.invalidateSession();
        return handler.next(err);
      }

      // Try a silent token refresh only. Background network activity must not
      // trigger an interactive login flow.
      final newToken = await authService.getAccessTokenSilently();
      if (newToken == null) {
        authService.invalidateSession();
        return handler.next(err);
      }

      requestOptions.headers['Authorization'] = 'Bearer $newToken';
      requestOptions.extra[_retryAttemptedKey] = true;

      try {
        final response = await getIt<DioClient>().dio.fetch(requestOptions);
        return handler.resolve(response);
      } on DioException catch (retryError) {
        if (retryError.response?.statusCode == 401) {
          authService.invalidateSession();
        }
        return handler.next(retryError);
      }
    }

    handler.next(err);
  }
}
