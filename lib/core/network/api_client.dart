import 'package:dio/dio.dart';
import '../constants/api_endpoints.dart';
import '../services/secure_storage.dart';
import 'error_interceptor.dart';
import 'token_interceptor.dart';

class ApiClient {
  late final Dio dio;

  // Singleton instance
  static final ApiClient instance = ApiClient._internal();

  ApiClient._internal() {
    dio = Dio(
      BaseOptions(
        baseUrl: ApiEndpoints.baseUrl,
        connectTimeout: const Duration(seconds: 10),
        receiveTimeout: const Duration(seconds: 10),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
          'ngrok-skip-browser-warning': 'true',
        },
      ),
    );

    // Add interceptors
    dio.interceptors.add(LogInterceptor(
      requestBody: true,
      responseBody: true,
    ));
    dio.interceptors.add(
      ErrorInterceptor(),
    );
    dio.interceptors.add(
      TokenInterceptor(SecureStorage.instance, dio),
    );
  }
}
