import 'package:dio/dio.dart';
import '../constants/api_endpoints.dart';
import '../services/secure_storage.dart';

class TokenInterceptor extends Interceptor {
  final SecureStorage _storage;
  final Dio _dio;

  TokenInterceptor(this._storage, this._dio);

  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) async {
    final token = await _storage.getAccessToken();
    if (token != null) {
      options.headers['Authorization'] = 'Bearer $token';
    }
    return handler.next(options);
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) async {
    if (err.response?.statusCode == 401) {
      final refreshToken = await _storage.getRefreshToken();
      if (refreshToken != null) {
        try {
          // Use a clean Dio instance for token renewal to prevent interceptor loops
          final refreshDio = Dio(BaseOptions(baseUrl: ApiEndpoints.baseUrl));
          final response = await refreshDio.post(
            ApiEndpoints.refreshToken,
            data: {'refreshToken': refreshToken},
          );

          final newAccessToken = response.data['accessToken'] ?? response.data['token'];
          await _storage.saveAccessToken(newAccessToken);

          // Retry the failed original request with the new access token
          final retryOptions = err.requestOptions;
          retryOptions.headers['Authorization'] = 'Bearer $newAccessToken';

          final clonedRequest = await _dio.fetch(retryOptions);
          return handler.resolve(clonedRequest);
        } catch (e) {
          // Token refresh failed completely; clear auth data and pass error
          await _storage.clearAuthData();
        }
      }
    }
    return handler.next(err);
  }
}
