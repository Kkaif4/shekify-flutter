import 'audio_url_resolver_fallback.dart'
    if (dart.library.html) 'audio_url_resolver_web.dart';

class AudioUrlResolver {
  static Future<String> resolve(String url, String? token) => resolveUrl(url, token);
}
