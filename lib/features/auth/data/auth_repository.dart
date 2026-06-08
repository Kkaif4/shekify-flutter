import 'dart:convert';
import 'package:dio/dio.dart';
import '../../../core/constants/api_endpoints.dart';
import '../../../core/network/api_client.dart';
import '../../../core/services/secure_storage.dart';
import '../domain/user.dart';

class AuthRepository {
  final Dio _dio = ApiClient.instance.dio;
  final SecureStorage _storage = SecureStorage.instance;

  Future<User> login(String username, String password) async {
    final response = await _dio.post(
      ApiEndpoints.login,
      data: {
        'username': username,
        'password': password,
      },
    );

    final String accessToken = response.data['accessToken'];
    final String refreshToken = response.data['refreshToken'];
    
    // Server returns user details, but if missing, decode from JWT
    Map<String, dynamic>? userJson = response.data['user'];
    if (userJson == null) {
      final payload = _parseJwt(accessToken);
      userJson = {
        'id': payload['id'] ?? '',
        'username': username,
        'role': payload['role'] ?? 'user',
      };
    }

    await _storage.saveAccessToken(accessToken);
    await _storage.saveRefreshToken(refreshToken);
    await _storage.saveUsername(username);

    return User.fromJson(userJson);
  }

  Future<void> logout() async {
    try {
      final refreshToken = await _storage.getRefreshToken();
      if (refreshToken != null) {
        await _dio.post(
          ApiEndpoints.logout,
          data: {'refreshToken': refreshToken},
        );
      }
    } catch (e) {
      print('Network logout failed: $e');
    } finally {
      await _storage.clearAuthData();
    }
  }

  Future<User?> checkAuthStatus() async {
    try {
      final token = await _storage.getAccessToken();
      final username = await _storage.getUsername();
      if (token == null || username == null) return null;

      // Make a health check or fast API call to verify if the token is still valid.
      // This triggers token refresh if expired.
      await _dio.get(ApiEndpoints.playlists);

      final payload = _parseJwt(token);
      return User(
        id: payload['id'] ?? '',
        username: username,
        role: payload['role'] ?? 'user',
      );
    } catch (e) {
      print('Auth status check failed: $e');
      await _storage.clearAuthData();
      return null;
    }
  }

  Map<String, dynamic> _parseJwt(String token) {
    final parts = token.split('.');
    if (parts.length != 3) {
      throw Exception('Invalid token format');
    }
    final payload = parts[1];
    var normalized = base64Url.normalize(payload);
    var resp = utf8.decode(base64Url.decode(normalized));
    return json.decode(resp);
  }
}
