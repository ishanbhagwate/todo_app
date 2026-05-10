sealed class AppException implements Exception {
  final String message;
  const AppException(this.message);

  @override
  String toString() => message;
}

class NetworkException extends AppException {
  const NetworkException([super.message = 'No internet connection']);
}

class ServerException extends AppException {
  final int statusCode;
  const ServerException(this.statusCode, [String message = 'Server error'])
      : super(message);
}

class CacheException extends AppException {
  const CacheException([super.message = 'Cache error']);
}

class UnauthorizedException extends AppException {
  const UnauthorizedException([super.message = 'Unauthorized']);
}

class TimeoutException extends AppException {
  const TimeoutException([super.message = 'Request timed out']);
}

class UnknownException extends AppException {
  const UnknownException([super.message = 'An unexpected error occurred']);
}
