import 'package:dio/dio.dart';
import '../services/toast_service.dart';

class ErrorInterceptor extends Interceptor {
  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    String errorMessage = 'An unexpected error occurred';
    String? errorTitle = 'Network Error';

    if (err.response?.statusCode == 401) {
      if (err.requestOptions.path.contains('/login')) {
        errorMessage = 'Invalid username or password';
        errorTitle = 'Login Failed';
      } else {
        errorMessage = 'Your session has expired. Please sign in again.';
        errorTitle = 'Session Expired';
      }
    } else if (err.type == DioExceptionType.connectionTimeout ||
        err.type == DioExceptionType.sendTimeout ||
        err.type == DioExceptionType.receiveTimeout) {
      errorMessage = 'Connection timed out. Please verify your connection status.';
      errorTitle = 'Timeout Limit Exceeded';
    } else if (err.type == DioExceptionType.connectionError) {
      errorMessage = 'Could not connect to the remote server. Please check your internet connection.';
      errorTitle = 'Server Connection Failed';
    } else if (err.response != null) {
      final data = err.response?.data;
      if (data is Map && data.containsKey('error')) {
        errorMessage = data['error'].toString();
      } else if (data is Map && data.containsKey('message')) {
        errorMessage = data['message'].toString();
      } else {
        errorMessage = 'Server returned error status code: ${err.response?.statusCode}';
      }
      errorTitle = 'Server Response Error (${err.response?.statusCode})';
    } else {
      errorMessage = err.message ?? 'Unknown request error occurred';
    }

    // Display the error using our premium ToastService
    ToastService.showError(errorMessage, title: errorTitle);

    return handler.next(err);
  }
}
