import 'package:dio/dio.dart';
import 'package:injectable/injectable.dart';

import 'dio_client.dart';
import 'interceptors/auth_interceptor.dart';

@lazySingleton
class ProtectedApiClient {
  ProtectedApiClient(this._dioClient);

  final DioClient _dioClient;

  Dio get _dio => _dioClient.dio;

  Future<Response<T>> get<T>(
    String path, {
    Map<String, dynamic>? queryParameters,
    Options? options,
    CancelToken? cancelToken,
    ProgressCallback? onReceiveProgress,
  }) {
    return _dio.get<T>(
      path,
      queryParameters: queryParameters,
      options: _protectedOptions(options),
      cancelToken: cancelToken,
      onReceiveProgress: onReceiveProgress,
    );
  }

  Future<Response<T>> post<T>(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
    CancelToken? cancelToken,
    ProgressCallback? onSendProgress,
    ProgressCallback? onReceiveProgress,
  }) {
    return _dio.post<T>(
      path,
      data: data,
      queryParameters: queryParameters,
      options: _protectedOptions(options),
      cancelToken: cancelToken,
      onSendProgress: onSendProgress,
      onReceiveProgress: onReceiveProgress,
    );
  }

  Future<Response<T>> delete<T>(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
    CancelToken? cancelToken,
  }) {
    return _dio.delete<T>(
      path,
      data: data,
      queryParameters: queryParameters,
      options: _protectedOptions(options),
      cancelToken: cancelToken,
    );
  }

  Options _protectedOptions(Options? options) {
    final currentOptions = options ?? Options();
    return currentOptions.copyWith(
      extra: {
        ...?currentOptions.extra,
        AuthInterceptor.requiresAuthKey: true,
      },
    );
  }
}