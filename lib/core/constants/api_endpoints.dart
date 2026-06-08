class ApiEndpoints {
  // Using the ngrok tunnel configured by the user as the primary base URL
  static const String baseUrl = 'https://demotion-pursuable-turban.ngrok-free.dev';
  static const String localFallbackUrl = 'http://10.0.2.2:4000'; // For Android emulator

  // Authentication Endpoints
  static const String login = '/api/auth/login';
  static const String logout = '/api/auth/logout';
  static const String register = '/api/admin/create-user';
  static const String refreshToken = '/api/auth/refresh';

  // Songs & Playlists Endpoints
  static const String songs = '/api/songs';
  static const String download = '/api/download';
  static const String stream = '/api/stream'; // stream/:songId
  static const String playlists = '/api/playlists';
  static const String playbackPlay = '/api/playback/play';

  static String getStreamUrl(String songId) {
    return '$baseUrl$stream/$songId';
  }

  static String getCoverUrl(String songId) {
    return '$baseUrl$songs/$songId/cover';
  }
}
