# Implementation Plan - Flutter App Streaming & Caching Architecture

This plan details the design of a Spotify-like audio streaming and caching structure for the Flutter app (`frontend-v2`).

## Proposed Changes

### 1. Instant Playback & Background Caching

Modify `PlayerRepository.getAudioSourcePath` to return the audio source _instantly_ instead of blocking on download:

- **Cache Hit:** If the song file exists locally, return the `file://` URI.
- **Cache Miss:** Return the HTTPS stream URL immediately, and start the download task asynchronously in the background so that it caches without blocking the start of playback.

### 2. Audio Handler Token Injection & Resolution

Update `ShekifyAudioHandler.playMediaItem` in `audio_handler.dart`:

- Automatically resolve the correct playback URI (file path vs HTTPS URL).
- Fetch the active access token from `SecureStorage` and inject the necessary headers (`Authorization: Bearer <token>`, `ngrok-skip-browser-warning: true`) for `just_audio` requests.
- Ensure case-insensitive scheme matching (`file` vs `FILE`).

### 3. Queue Prefetching

Update `PlayerBloc` or the audio service to pre-cache the _next_ track in the queue while the current track is playing:

- Listen to position updates or progress. When the current song reaches 80% completion, start downloading the next track in the queue to memory/disk.

---

## Detailed Proposed Code Changes

### Component: `frontend-v2/lib`

#### [MODIFY] [player_repository.dart](file:///home/kaif/storage/Codes/Fun-projects/Shekify/frontend-v2/lib/features/player/data/player_repository.dart)

```dart
  Future<String> getAudioSourcePath(String songId) async {
    final streamUrl = ApiEndpoints.getStreamUrl(songId);

    if (kIsWeb) {
      return streamUrl;
    }

    // 1. Check if already cached
    final isSongCached = await _cache.isCached(songId);
    if (isSongCached) {
      final file = await _cache.getCacheFile(songId);
      return 'file://${file.path}';
    }

    // 2. Start download in background (non-blocking) and return streamUrl immediately
    _cache.downloadAndCache(songId, streamUrl).then((localPath) async {
      if (localPath != null) {
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
      }
    });

    return streamUrl;
  }
```

#### [MODIFY] [audio_handler.dart](file:///home/kaif/storage/Codes/Fun-projects/Shekify/frontend-v2/lib/core/services/audio_handler.dart)

Ensure scheme matching and dynamic token injection works for any MediaItem:

```dart
  @override
  Future<void> playMediaItem(MediaItem item) async {
    mediaItem.add(item);
    try {
      final urlStr = item.extras?['url'] ?? '';
      final uri = Uri.parse(urlStr);

      if (uri.scheme.toLowerCase() == 'file') {
        await _player.setAudioSource(AudioSource.file(uri.toFilePath()));
      } else {
        final token = await SecureStorage.instance.getAccessToken();
        await _player.setAudioSource(
          AudioSource.uri(
            uri,
            headers: {
              if (token != null) 'Authorization': 'Bearer $token',
              'ngrok-skip-browser-warning': 'true',
            },
          ),
        );
      }
      play();
    } catch (e) {
      print('Error playing media item: $e');
      playbackState.add(playbackState.value.copyWith(
        errorMessage: e.toString(),
      ));
    }
  }
```

---

## Verification Plan

### Automated/Manual Testing

1. Play a song from the Flutter app interface.
2. Verify in logs that streaming starts immediately.
3. Check that future playbacks of the same song load instantly from the cached local file without network requests.
