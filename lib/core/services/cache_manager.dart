import 'dart:io';
import 'package:dio/dio.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as p;
import '../network/api_client.dart';

class CacheManager {
  // Singleton instance
  static final CacheManager instance = CacheManager._internal();

  CacheManager._internal();

  Future<String> get _cacheDirPath async {
    final docDir = await getApplicationDocumentsDirectory();
    final cachePath = p.join(docDir.path, 'audio_cache');
    final dir = Directory(cachePath);
    if (!await dir.exists()) {
      await dir.create(recursive: true);
    }
    return cachePath;
  }

  Future<File> getCacheFile(String songId) async {
    final dir = await _cacheDirPath;
    return File(p.join(dir, '$songId.mp3'));
  }

  Future<bool> isCached(String songId) async {
    final file = await getCacheFile(songId);
    return await file.exists();
  }

  Future<String?> downloadAndCache(String songId, String streamUrl) async {
    try {
      final cacheFile = await getCacheFile(songId);
      if (await cacheFile.exists()) {
        return cacheFile.path;
      }

      // Download the track bytes using the centralized ApiClient
      final tempFile = File('${cacheFile.path}.tmp');
      await ApiClient.instance.dio.download(
        streamUrl,
        tempFile.path,
        options: Options(responseType: ResponseType.bytes),
      );

      // Rename once completed
      await tempFile.rename(cacheFile.path);
      return cacheFile.path;
    } catch (e) {
      print('Error caching track $songId: $e');
      return null;
    }
  }

  Future<void> clearCache() async {
    final dirPath = await _cacheDirPath;
    final dir = Directory(dirPath);
    if (await dir.exists()) {
      await dir.delete(recursive: true);
    }
  }
}
