import 'package:dio/dio.dart';

import '../../auth/auth_service.dart';
import '../../di/injection.dart';

class AuthInterceptor extends Interceptor {
  @override
  Future<void> onRequest(
    RequestOptions options,
    RequestInterceptorHandler handler,
  ) async {
    final authService = getIt<AuthService>();
    final token = await authService.getAccessToken();
    if (token != null) {
      options.headers['Authorization'] = 'Bearer $token';
    }
    handler.next(options);
  }

  @override
  Future<void> onError(DioException err, ErrorInterceptorHandler handler) async {
    if (err.response?.statusCode == 401) {
      final authService = getIt<AuthService>();
      // Yritä uusia token
      final newToken = await authService.getAccessToken();
      if (newToken != null) {
        // Yritä pyyntöä uudelleen uudella tokenilla
        err.requestOptions.headers['Authorization'] = 'Bearer $newToken';
        try {
          final response = await Dio().fetch(err.requestOptions);
          return handler.resolve(response);
        } catch (e) {
          // Uudelleenyritys epäonnistui
        }
      }
    }
    handler.next(err);
  }
}
