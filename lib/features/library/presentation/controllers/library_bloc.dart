import 'package:flutter_bloc/flutter_bloc.dart';
import '../../data/library_repository.dart';
import '../../domain/playlist.dart';
import '../../../player/domain/track.dart';

// --- Events ---
abstract class LibraryEvent {}

class FetchPlaylists extends LibraryEvent {}

class FetchHomeSongsEvent extends LibraryEvent {
  final bool isRefresh;
  FetchHomeSongsEvent({this.isRefresh = false});
}

class CreatePlaylistEvent extends LibraryEvent {
  final String name;
  CreatePlaylistEvent(this.name);
}

class DeletePlaylistEvent extends LibraryEvent {
  final String id;
  DeletePlaylistEvent(this.id);
}

class FetchPlaylistDetailsEvent extends LibraryEvent {
  final String id;
  FetchPlaylistDetailsEvent(this.id);
}

class SearchSongsEvent extends LibraryEvent {
  final String query;
  SearchSongsEvent(this.query);
}

class AddSongToPlaylistEvent extends LibraryEvent {
  final String playlistId;
  final Track track;
  AddSongToPlaylistEvent(this.playlistId, this.track);
}

class RemoveSongFromPlaylistEvent extends LibraryEvent {
  final String playlistId;
  final String songId;
  RemoveSongFromPlaylistEvent(this.playlistId, this.songId);
}

// --- States ---
abstract class LibraryState {}

class LibraryInitial extends LibraryState {}

class PlaylistsLoading extends LibraryState {}

class PlaylistsLoaded extends LibraryState {
  final List<Playlist> playlists;
  PlaylistsLoaded(this.playlists);
}

class PlaylistDetailsLoading extends LibraryState {}

class PlaylistDetailsLoaded extends LibraryState {
  final Playlist playlist;
  PlaylistDetailsLoaded(this.playlist);
}

class SongSearchLoading extends LibraryState {}

class SongSearchLoaded extends LibraryState {
  final List<Track> tracks;
  SongSearchLoaded(this.tracks);
}

class LibraryError extends LibraryState {
  final String message;
  LibraryError(this.message);
}

class HomeSongsLoaded extends LibraryState {
  final List<Track> tracks;
  final int page;
  final int totalPages;
  final bool isLoadingMore;
  final bool hasReachedMax;

  HomeSongsLoaded({
    required this.tracks,
    required this.page,
    required this.totalPages,
    this.isLoadingMore = false,
    this.hasReachedMax = false,
  });

  HomeSongsLoaded copyWith({
    List<Track>? tracks,
    int? page,
    int? totalPages,
    bool? isLoadingMore,
    bool? hasReachedMax,
  }) {
    return HomeSongsLoaded(
      tracks: tracks ?? this.tracks,
      page: page ?? this.page,
      totalPages: totalPages ?? this.totalPages,
      isLoadingMore: isLoadingMore ?? this.isLoadingMore,
      hasReachedMax: hasReachedMax ?? this.hasReachedMax,
    );
  }
}

// --- BLoC ---
class LibraryBloc extends Bloc<LibraryEvent, LibraryState> {
  final LibraryRepository _libraryRepository;

  LibraryBloc(this._libraryRepository) : super(LibraryInitial()) {
    on<FetchPlaylists>(_onFetchPlaylists);
    on<FetchHomeSongsEvent>(_onFetchHomeSongs);
    on<CreatePlaylistEvent>(_onCreatePlaylist);
    on<DeletePlaylistEvent>(_onDeletePlaylist);
    on<FetchPlaylistDetailsEvent>(_onFetchPlaylistDetails);
    on<SearchSongsEvent>(_onSearchSongs);
    on<AddSongToPlaylistEvent>(_onAddSongToPlaylist);
    on<RemoveSongFromPlaylistEvent>(_onRemoveSongFromPlaylist);
  }

  Future<void> _onFetchPlaylists(
    FetchPlaylists event,
    Emitter<LibraryState> emit,
  ) async {
    emit(PlaylistsLoading());
    try {
      final playlists = await _libraryRepository.getPlaylists();
      emit(PlaylistsLoaded(playlists));
    } catch (e) {
      emit(LibraryError(e.toString()));
    }
  }

  Future<void> _onFetchHomeSongs(
    FetchHomeSongsEvent event,
    Emitter<LibraryState> emit,
  ) async {
    final currentState = state;
    int nextPage = 1;
    List<Track> existingTracks = [];

    if (event.isRefresh) {
      emit(PlaylistsLoading());
    } else if (currentState is HomeSongsLoaded) {
      if (currentState.hasReachedMax || currentState.isLoadingMore) return;
      nextPage = currentState.page + 1;
      existingTracks = currentState.tracks;
      emit(currentState.copyWith(isLoadingMore: true));
    } else {
      emit(PlaylistsLoading());
    }

    try {
      final result = await _libraryRepository.getSongsPaginated(
        page: nextPage,
        limit: 20,
      );

      final allTracks = [...existingTracks, ...result.tracks];
      final hasReachedMax = nextPage >= result.totalPages;

      emit(HomeSongsLoaded(
        tracks: allTracks,
        page: nextPage,
        totalPages: result.totalPages,
        hasReachedMax: hasReachedMax,
      ));
    } catch (e) {
      emit(LibraryError(e.toString()));
    }
  }

  Future<void> _onCreatePlaylist(
    CreatePlaylistEvent event,
    Emitter<LibraryState> emit,
  ) async {
    try {
      await _libraryRepository.createPlaylist(event.name);
      add(FetchPlaylists());
    } catch (e) {
      emit(LibraryError(e.toString()));
    }
  }

  Future<void> _onDeletePlaylist(
    DeletePlaylistEvent event,
    Emitter<LibraryState> emit,
  ) async {
    try {
      await _libraryRepository.deletePlaylist(event.id);
      add(FetchPlaylists());
    } catch (e) {
      emit(LibraryError(e.toString()));
    }
  }

  Future<void> _onFetchPlaylistDetails(
    FetchPlaylistDetailsEvent event,
    Emitter<LibraryState> emit,
  ) async {
    emit(PlaylistDetailsLoading());
    try {
      final playlist = await _libraryRepository.getPlaylistDetails(event.id);
      emit(PlaylistDetailsLoaded(playlist));
    } catch (e) {
      emit(LibraryError(e.toString()));
    }
  }

  Future<void> _onSearchSongs(
    SearchSongsEvent event,
    Emitter<LibraryState> emit,
  ) async {
    if (event.query.isEmpty) {
      emit(SongSearchLoaded(const []));
      return;
    }
    emit(SongSearchLoading());
    try {
      final tracks = await _libraryRepository.searchTracks(event.query);
      emit(SongSearchLoaded(tracks));
    } catch (e) {
      emit(LibraryError(e.toString()));
    }
  }

  Future<void> _onAddSongToPlaylist(
    AddSongToPlaylistEvent event,
    Emitter<LibraryState> emit,
  ) async {
    try {
      await _libraryRepository.addSongToPlaylist(event.playlistId, event.track);
      add(FetchPlaylistDetailsEvent(event.playlistId));
    } catch (e) {
      emit(LibraryError(e.toString()));
    }
  }

  Future<void> _onRemoveSongFromPlaylist(
    RemoveSongFromPlaylistEvent event,
    Emitter<LibraryState> emit,
  ) async {
    try {
      await _libraryRepository.removeSongFromPlaylist(event.playlistId, event.songId);
      add(FetchPlaylistDetailsEvent(event.playlistId));
    } catch (e) {
      emit(LibraryError(e.toString()));
    }
  }
}
