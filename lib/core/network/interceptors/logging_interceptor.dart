import 'package:dio/dio.dart';

import '../../config/env_config.dart';

class LoggingInterceptor extends Interceptor {
  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    if (EnvConfig.debugFeaturesEnabled) {
      print('ðŸŒ REQUEST[${options.method}] => ${options.path}');
    }
    handler.next(options);
  }

  @override
  void onResponse(Response response, ResponseInterceptorHandler handler) {
    if (EnvConfig.debugFeaturesEnabled) {
      print('âœ… RESPONSE[${response.statusCode}] => ${response.requestOptions.path}');
    }
    handler.next(response);
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    if (EnvConfig.debugFeaturesEnabled) {
      print('âŒ ERROR[${err.response?.statusCode}] => ${err.requestOptions.path}');
    }
    handler.next(err);
  }
}
