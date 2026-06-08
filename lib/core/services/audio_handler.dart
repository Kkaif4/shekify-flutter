import 'package:audio_service/audio_service.dart';
import 'package:just_audio/just_audio.dart';
import 'secure_storage.dart';
import 'cache_manager.dart';

Future<AudioHandler> initAudioService() async {
  return await AudioService.init(
    builder: () => ShekifyAudioHandler(),
    config: const AudioServiceConfig(
      androidNotificationChannelId: 'com.kaif.shekify.channel.audio',
      androidNotificationChannelName: 'Shekify Playback',
      androidNotificationOngoing: true,
      androidShowNotificationBadge: true,
    ),
  );
}

class ShekifyAudioHandler extends BaseAudioHandler with QueueHandler, SeekHandler {
  final AudioPlayer _player = AudioPlayer();

  ShekifyAudioHandler() {
    _initStreams();
  }

  AudioPlayer get player => _player;

  void _initStreams() {
    // 1. Forward playback events to audio_service
    _player.playbackEventStream.map(_transformEvent).pipe(playbackState);

    // 2. Listen for track completions to automatically skip next
    _player.processingStateStream.listen((state) {
      if (state == ProcessingState.completed) {
        skipToNext();
      }
    });
  }

  @override
  Future<void> play() => _player.play();

  @override
  Future<void> pause() => _player.pause();

  @override
  Future<void> seek(Duration position) => _player.seek(position);

  @override
  Future<void> stop() async {
    await _player.stop();
    await playbackState.firstWhere((state) => state.processingState == AudioProcessingState.idle);
  }

  @override
  Future<void> skipToNext() async {
    // Handled by our BLoC coordinating the queues, or we can handle it directly if we populate queue
    // Since BLoC coordinates the queue and sends commands to play the next song, we can also dispatch events here.
    // If there is an active queue in audio_handler, let's skip inside it:
    final currentMediaItem = mediaItem.value;
    if (currentMediaItem == null) return;
    final currentIdx = queue.value.indexWhere((item) => item.id == currentMediaItem.id);
    if (currentIdx != -1 && currentIdx < queue.value.length - 1) {
      final nextItem = queue.value[currentIdx + 1];
      await playMediaItem(nextItem);
    }
  }

  @override
  Future<void> skipToPrevious() async {
    final currentMediaItem = mediaItem.value;
    if (currentMediaItem == null) return;
    final currentIdx = queue.value.indexWhere((item) => item.id == currentMediaItem.id);
    if (currentIdx > 0) {
      final prevItem = queue.value[currentIdx - 1];
      await playMediaItem(prevItem);
    }
  }

  @override
  Future<void> playMediaItem(MediaItem item) async {
    print('DEBUG: ShekifyAudioHandler.playMediaItem starting for track: ${item.id}');
    mediaItem.add(item);
    try {
      String urlStr = item.extras?['url'] ?? '';
      print('DEBUG: Original URL in mediaItem: $urlStr');
      
      // Check if the track has been cached locally (skip web as caching is disabled there)
      final uri = Uri.parse(urlStr);
      if (!uri.scheme.toLowerCase().startsWith('file')) {
        final isCached = await CacheManager.instance.isCached(item.id);
        print('DEBUG: Cache check for ${item.id}: isCached = $isCached');
        if (isCached) {
          final file = await CacheManager.instance.getCacheFile(item.id);
          urlStr = 'file://${file.path}';
          print('DEBUG: Found in cache, resolved to: $urlStr');
        }
      }

      final finalUri = Uri.parse(urlStr);
      print('DEBUG: Resolved playback URI: $finalUri');
      if (finalUri.scheme.toLowerCase() == 'file') {
        print('DEBUG: Loading local file source: ${finalUri.toFilePath()}');
        await _player.setAudioSource(AudioSource.file(finalUri.toFilePath()));
      } else {
        final token = await SecureStorage.instance.getAccessToken();
        print('DEBUG: Loading remote URI source with auth header. Token present: ${token != null}');
        await _player.setAudioSource(
          AudioSource.uri(
            finalUri,
            headers: {
              if (token != null) 'Authorization': 'Bearer $token',
              'ngrok-skip-browser-warning': 'true',
            },
          ),
        );
      }
      print('DEBUG: setAudioSource completed successfully. Calling play()...');
      await play();
      print('DEBUG: play() called successfully.');
    } catch (e, stackTrace) {
      print('DEBUG ERROR: Exception in playMediaItem: $e');
      print('DEBUG STACKTRACE: $stackTrace');
      playbackState.add(playbackState.value.copyWith(
        errorMessage: e.toString(),
      ));
    }
  }

  @override
  Future<void> updateQueue(List<MediaItem> newQueue) async {
    queue.add(newQueue);
  }

  PlaybackState _transformEvent(PlaybackEvent event) {
    return PlaybackState(
      controls: [
        MediaControl.skipToPrevious,
        if (_player.playing) MediaControl.pause else MediaControl.play,
        MediaControl.stop,
        MediaControl.skipToNext,
      ],
      systemActions: const {
        MediaAction.seek,
        MediaAction.seekForward,
        MediaAction.seekBackward,
      },
      androidCompactActionIndices: const [0, 1, 3],
      processingState: const {
        ProcessingState.idle: AudioProcessingState.idle,
        ProcessingState.loading: AudioProcessingState.loading,
        ProcessingState.buffering: AudioProcessingState.buffering,
        ProcessingState.ready: AudioProcessingState.ready,
        ProcessingState.completed: AudioProcessingState.completed,
      }[_player.processingState]!,
      playing: _player.playing,
      updatePosition: event.updatePosition,
      bufferedPosition: event.bufferedPosition,
      speed: _player.speed,
      queueIndex: event.currentIndex,
    );
  }
}
