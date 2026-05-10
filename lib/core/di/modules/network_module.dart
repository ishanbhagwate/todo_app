import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:dio/dio.dart';
import 'package:injectable/injectable.dart';

import '../../constants/api_constants.dart';
import '../../network/network_interceptor.dart';

@module
abstract class NetworkModule {
  @singleton
  Connectivity get connectivity => Connectivity();

  @singleton
  Dio dio() {
    final dio = Dio(
      BaseOptions(
        baseUrl: ApiConstants.baseUrl,
        connectTimeout: const Duration(seconds: 10),
        receiveTimeout: const Duration(seconds: 10),
        headers: {'Content-Type': 'application/json'},
      ),
    );
    dio.interceptors.add(NetworkInterceptor());
    return dio;
  }
}
