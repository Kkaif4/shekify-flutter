import 'package:dio/dio.dart';
import 'package:uuid/uuid.dart';
import '../../../core/constants/api_endpoints.dart';
import '../../../core/network/api_client.dart';
import '../../../core/services/cache_manager.dart';
import '../../../core/services/database.dart';

class PlayerRepository {
  final Dio _dio = ApiClient.instance.dio;
  final CacheManager _cache = CacheManager.instance;
  final AppDatabase _db;
  final Uuid _uuid = const Uuid();

  PlayerRepository(this._db);

  Future<void> logPlayback(String songId) async {
    try {
      final idempotencyKey = _uuid.v4();
      await _dio.post(
        ApiEndpoints.playbackPlay,
        data: {'trackId': songId},
        options: Options(
          headers: {
            'Idempotency-Key': idempotencyKey,
          },
        ),
      );
    } catch (e) {
      print('Failed to log playback for $songId: $e');
    }
  }

  // Pre-caches the track or returns the local filepath if already cached
  Future<String> getAudioSourcePath(String songId) async {
    final streamUrl = ApiEndpoints.getStreamUrl(songId);

    // 1. Check database/cache status
    final isSongCached = await _cache.isCached(songId);
    if (isSongCached) {
      final file = await _cache.getCacheFile(songId);
      return 'file://${file.path}';
    }

    // 2. Fetch track offline path dynamically by checking cache download
    final localPath = await _cache.downloadAndCache(songId, streamUrl);
    if (localPath != null) {
      // Update local Drift DB record with downloaded path
      final song = await _db.getSongById(songId);
      if (song != null) {
        await _db.insertSong(Song(
          id: song.id,
          title: song.title,
          artist: song.artist,
          album: song.album,
          year: song.year,
          filePath: localPath,
          albumArtUrl: song.albumArtUrl,
        ));
      }
      return 'file://$localPath';
    }

    // Fallback to live network stream URL if cache download failed
    return streamUrl;
  }
}
