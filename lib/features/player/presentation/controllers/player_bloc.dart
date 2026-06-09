import 'dart:async';
import 'package:audio_service/audio_service.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/constants/api_endpoints.dart';
import '../../../../core/services/audio_handler.dart';
import '../../data/player_repository.dart';
import '../../domain/track.dart';

// --- Events ---
abstract class PlayerEvent {}

class PlayTrackEvent extends PlayerEvent {
  final Track track;
  PlayTrackEvent(this.track);
}

class PlayQueueEvent extends PlayerEvent {
  final List<Track> queue;
  final int startIndex;
  PlayQueueEvent(this.queue, this.startIndex);
}

class PauseEvent extends PlayerEvent {}

class ResumeEvent extends PlayerEvent {}

class SeekToEvent extends PlayerEvent {
  final Duration position;
  SeekToEvent(this.position);
}

class NextTrackEvent extends PlayerEvent {}

class PreviousTrackEvent extends PlayerEvent {}

class ToggleShuffleEvent extends PlayerEvent {}

class ToggleAutoplayEvent extends PlayerEvent {}

class PlaybackStateChangedEvent extends PlayerEvent {
  final PlaybackState state;
  PlaybackStateChangedEvent(this.state);
}

class CurrentMediaItemChangedEvent extends PlayerEvent {
  final MediaItem? item;
  CurrentMediaItemChangedEvent(this.item);
}

class PlayerPositionChangedEvent extends PlayerEvent {
  final Duration position;
  PlayerPositionChangedEvent(this.position);
}

class PlayerDurationChangedEvent extends PlayerEvent {
  final Duration? duration;
  PlayerDurationChangedEvent(this.duration);
}

// --- State ---
class PlayerStatus {
  final Track? currentTrack;
  final List<Track> queue;
  final bool isPlaying;
  final bool isBuffering;
  final Duration position;
  final Duration bufferedPosition;
  final Duration duration;
  final String? errorMessage;
  final bool isShuffle;
  final bool isAutoplay;

  PlayerStatus({
    this.currentTrack,
    this.queue = const [],
    this.isPlaying = false,
    this.isBuffering = false,
    this.position = Duration.zero,
    this.bufferedPosition = Duration.zero,
    this.duration = Duration.zero,
    this.errorMessage,
    this.isShuffle = false,
    this.isAutoplay = true,
  });

  PlayerStatus copyWith({
    Track? Function()? currentTrack,
    List<Track>? queue,
    bool? isPlaying,
    bool? isBuffering,
    Duration? position,
    Duration? bufferedPosition,
    Duration? duration,
    String? Function()? errorMessage,
    bool? isShuffle,
    bool? isAutoplay,
  }) {
    return PlayerStatus(
      currentTrack: currentTrack != null ? currentTrack() : this.currentTrack,
      queue: queue ?? this.queue,
      isPlaying: isPlaying ?? this.isPlaying,
      isBuffering: isBuffering ?? this.isBuffering,
      position: position ?? this.position,
      bufferedPosition: bufferedPosition ?? this.bufferedPosition,
      duration: duration ?? this.duration,
      errorMessage: errorMessage != null ? errorMessage() : this.errorMessage,
      isShuffle: isShuffle ?? this.isShuffle,
      isAutoplay: isAutoplay ?? this.isAutoplay,
    );
  }
}

// --- BLoC ---
class PlayerBloc extends Bloc<PlayerEvent, PlayerStatus> {
  final PlayerRepository _playerRepository;
  final ShekifyAudioHandler _audioHandler;
  late final List<StreamSubscription> _subscriptions;
  String? _prefetchedSongId;

  PlayerBloc(this._playerRepository, this._audioHandler) : super(PlayerStatus()) {
    on<PlayTrackEvent>(_onPlayTrack);
    on<PlayQueueEvent>(_onPlayQueue);
    on<PauseEvent>(_onPause);
    on<ResumeEvent>(_onResume);
    on<SeekToEvent>(_onSeekTo);
    on<NextTrackEvent>(_onNextTrack);
    on<PreviousTrackEvent>(_onPreviousTrack);
    on<PlaybackStateChangedEvent>(_onPlaybackStateChanged);
    on<CurrentMediaItemChangedEvent>(_onCurrentMediaItemChanged);
    on<PlayerPositionChangedEvent>(_onPlayerPositionChanged);
    on<PlayerDurationChangedEvent>(_onPlayerDurationChanged);
    on<ToggleShuffleEvent>(_onToggleShuffle);
    on<ToggleAutoplayEvent>(_onToggleAutoplay);

    // Subscribe to ShekifyAudioHandler streams to keep BLoC in sync
    _subscriptions = [
      _audioHandler.playbackState.listen((state) {
        add(PlaybackStateChangedEvent(state));
      }),
      _audioHandler.mediaItem.listen((item) {
        add(CurrentMediaItemChangedEvent(item));
      }),
      _audioHandler.player.positionStream.listen((pos) {
        add(PlayerPositionChangedEvent(pos));
      }),
      _audioHandler.player.durationStream.listen((dur) {
        add(PlayerDurationChangedEvent(dur));
      }),
    ];
  }

  @override
  Future<void> close() {
    for (final sub in _subscriptions) {
      sub.cancel();
    }
    return super.close();
  }

  Future<void> _onPlayTrack(
    PlayTrackEvent event,
    Emitter<PlayerStatus> emit,
  ) async {
    final track = event.track;
    emit(state.copyWith(
      currentTrack: () => track,
      queue: [track],
    ));

    final streamUrl = ApiEndpoints.getStreamUrl(track.id);
    final mediaItem = track.toMediaItem(streamUrl);
    
    await _audioHandler.updateQueue([mediaItem]);
    await _audioHandler.playMediaItem(mediaItem);
    await _playerRepository.logPlayback(track.id);
  }

  Future<void> _onPlayQueue(
    PlayQueueEvent event,
    Emitter<PlayerStatus> emit,
  ) async {
    emit(state.copyWith(
      queue: event.queue,
    ));

    final mediaItems = <MediaItem>[];
    for (final track in event.queue) {
      final streamUrl = ApiEndpoints.getStreamUrl(track.id);
      mediaItems.add(track.toMediaItem(streamUrl));
    }
    await _audioHandler.updateQueue(mediaItems);

    final startTrack = event.queue[event.startIndex];
    final startMediaItem = mediaItems[event.startIndex];

    await _audioHandler.playMediaItem(startMediaItem);
    await _playerRepository.logPlayback(startTrack.id);
  }

  Future<void> _onPause(PauseEvent event, Emitter<PlayerStatus> emit) async {
    await _audioHandler.pause();
  }

  Future<void> _onResume(ResumeEvent event, Emitter<PlayerStatus> emit) async {
    await _audioHandler.play();
  }

  Future<void> _onSeekTo(SeekToEvent event, Emitter<PlayerStatus> emit) async {
    await _audioHandler.seek(event.position);
  }

  Future<void> _onNextTrack(NextTrackEvent event, Emitter<PlayerStatus> emit) async {
    await _audioHandler.skipToNext();
  }

  Future<void> _onPreviousTrack(PreviousTrackEvent event, Emitter<PlayerStatus> emit) async {
    await _audioHandler.skipToPrevious();
  }

  void _onPlaybackStateChanged(
    PlaybackStateChangedEvent event,
    Emitter<PlayerStatus> emit,
  ) {
    emit(state.copyWith(
      isPlaying: event.state.playing,
      isBuffering: event.state.processingState == AudioProcessingState.buffering ||
          event.state.processingState == AudioProcessingState.loading,
      bufferedPosition: event.state.bufferedPosition,
      errorMessage: () => event.state.errorMessage,
    ));
  }

  void _onCurrentMediaItemChanged(
    CurrentMediaItemChangedEvent event,
    Emitter<PlayerStatus> emit,
  ) {
    _prefetchedSongId = null;
    final mediaItem = event.item;
    if (mediaItem == null) {
      emit(state.copyWith(currentTrack: () => null));
      return;
    }

    // Attempt to map back current Track from current queue
    final track = state.queue.firstWhere(
      (t) => t.id == mediaItem.id,
      orElse: () => Track(
        id: mediaItem.id,
        title: mediaItem.title,
        artist: mediaItem.artist,
        album: mediaItem.album,
        albumArtUrl: mediaItem.artUri?.toString(),
      ),
    );

    emit(state.copyWith(currentTrack: () => track));
    
    // Log playback for analytics when the active track rotates
    _playerRepository.logPlayback(track.id);
  }

  void _onPlayerPositionChanged(
    PlayerPositionChangedEvent event,
    Emitter<PlayerStatus> emit,
  ) {
    emit(state.copyWith(position: event.position));

    final duration = state.duration;
    final currentTrack = state.currentTrack;
    if (duration != Duration.zero && currentTrack != null) {
      final progress = event.position.inMilliseconds / duration.inMilliseconds;
      if (progress >= 0.8) {
        final currentIdx = state.queue.indexWhere((t) => t.id == currentTrack.id);
        if (currentIdx != -1 && currentIdx < state.queue.length - 1) {
          final nextTrack = state.queue[currentIdx + 1];
          if (_prefetchedSongId != nextTrack.id) {
            _prefetchedSongId = nextTrack.id;
            _playerRepository.getAudioSourcePath(nextTrack.id);
          }
        }
      }
    }
  }

  void _onPlayerDurationChanged(
    PlayerDurationChangedEvent event,
    Emitter<PlayerStatus> emit,
  ) {
    emit(state.copyWith(duration: event.duration ?? Duration.zero));
  }

  void _onToggleShuffle(
    ToggleShuffleEvent event,
    Emitter<PlayerStatus> emit,
  ) {
    final newVal = !state.isShuffle;
    _audioHandler.isShuffle = newVal;
    emit(state.copyWith(isShuffle: newVal));
  }

  void _onToggleAutoplay(
    ToggleAutoplayEvent event,
    Emitter<PlayerStatus> emit,
  ) {
    final newVal = !state.isAutoplay;
    _audioHandler.isAutoplay = newVal;
    emit(state.copyWith(isAutoplay: newVal));
  }
}
