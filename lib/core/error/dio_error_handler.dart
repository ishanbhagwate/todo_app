import 'package:dio/dio.dart';
import 'app_exception.dart';

class DioErrorHandler {
  static AppException handle(DioException e) {
    switch (e.type) {
      case DioExceptionType.connectionError:
      case DioExceptionType.unknown:
        return const NetworkException();
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.sendTimeout:
      case DioExceptionType.receiveTimeout:
        return const TimeoutException();
      case DioExceptionType.badResponse:
        final statusCode = e.response?.statusCode ?? 0;
        if (statusCode == 401) return const UnauthorizedException();
        return ServerException(statusCode, 'Server error ($statusCode)');
      case DioExceptionType.cancel:
        return const UnknownException('Request cancelled');
      case DioExceptionType.badCertificate:
        return const UnknownException('Certificate error');
    }
  }
}
