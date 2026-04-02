class AppException implements Exception {
  const AppException({this.message, this.statusCode});
  final String? message;
  final int? statusCode;
  
  @override
  String toString() => message ?? 'AppException occurred';
}

class ServerException extends AppException {
  const ServerException({super.message, super.statusCode});
}

class NetworkException extends AppException {
  const NetworkException({super.message});
}

class CacheException extends AppException {
  const CacheException({super.message});
}

class AuthenticationException extends AppException {
  const AuthenticationException({super.message, super.statusCode});
}
