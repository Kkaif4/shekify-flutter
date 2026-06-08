import 'package:flutter_bloc/flutter_bloc.dart';
import '../../data/library_repository.dart';
import '../../domain/playlist.dart';
import '../../../player/domain/track.dart';

// --- Events ---
abstract class LibraryEvent {}

class FetchPlaylists extends LibraryEvent {}

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

// --- BLoC ---
class LibraryBloc extends Bloc<LibraryEvent, LibraryState> {
  final LibraryRepository _libraryRepository;

  LibraryBloc(this._libraryRepository) : super(LibraryInitial()) {
    on<FetchPlaylists>(_onFetchPlaylists);
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
