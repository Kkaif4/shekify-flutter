import 'dart:html' as html;
import 'package:dio/dio.dart';
import '../network/api_client.dart';

Future<String> resolveUrl(String url, String? token) async {
  try {
    print('DEBUG [WebResolver]: Downloading audio as blob: $url');
    final response = await ApiClient.instance.dio.get<List<int>>(
      url,
      options: Options(
        responseType: ResponseType.bytes,
        headers: {
          if (token != null) 'Authorization': 'Bearer $token',
          'ngrok-skip-browser-warning': 'true',
        },
      ),
    );

    if (response.data == null) {
      throw Exception('Empty audio data received from server');
    }

    final blob = html.Blob([response.data], 'audio/mpeg');
    final blobUrl = html.Url.createObjectUrlFromBlob(blob);
    print('DEBUG [WebResolver]: Successfully created blob URL: $blobUrl');
    return blobUrl;
  } catch (e) {
    print('DEBUG [WebResolver] ERROR: Failed to resolve URL: $e');
    // Fallback to original URL
    return url;
  }
}
