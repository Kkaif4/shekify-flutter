import 'package:dio/dio.dart';
import '../../../core/constants/api_endpoints.dart';
import '../../../core/network/api_client.dart';
import '../../../core/services/database.dart' as db;
import '../../player/domain/track.dart';
import '../domain/playlist.dart';

class LibraryRepository {
  final Dio _dio = ApiClient.instance.dio;
  final db.AppDatabase _db;

  LibraryRepository(this._db);

  // Search tracks remotely or fall back to local database
  Future<List<Track>> searchTracks(String query) async {
    try {
      final response = await _dio.get(
        ApiEndpoints.songs,
        queryParameters: {'search': query},
      );
      final List<dynamic> list = response.data['data'] ?? [];
      final tracks = list.map((json) => Track.fromJson(json)).toList();

      // Save searched tracks locally in background to keep local DB populated
      for (final track in tracks) {
        await _db.insertSong(
          db.Song(
            id: track.id,
            title: track.title,
            artist: track.artist,
            album: track.album,
            year: track.year,
            filePath: track.filePath,
            albumArtUrl:
                track.albumArtUrl ?? ApiEndpoints.getCoverUrl(track.id),
          ),
        );
      }
      return tracks;
    } catch (e) {
      print('Network search failed, trying local DB: $e');
      final localSongs = await _db.getAllSongs();
      final filtered = localSongs.where((song) {
        final q = query.toLowerCase();
        return song.title.toLowerCase().contains(q) ||
            (song.artist?.toLowerCase().contains(q) ?? false) ||
            (song.album?.toLowerCase().contains(q) ?? false);
      }).toList();

      return filtered
          .map(
            (song) => Track(
              id: song.id,
              title: song.title,
              artist: song.artist,
              album: song.album,
              year: song.year,
              filePath: song.filePath,
              albumArtUrl: song.albumArtUrl,
            ),
          )
          .toList();
    }
  }

  // Get all playlists (online with local cache backup)
  Future<List<Playlist>> getPlaylists() async {
    try {
      final response = await _dio.get(ApiEndpoints.playlists);
      final List<dynamic> list = response.data;
      final playlists = list.map((json) => Playlist.fromJson(json)).toList();

      // Sync with Drift database
      for (final pl in playlists) {
        await _db.insertPlaylist(db.Playlist(id: pl.id, name: pl.name));
      }
      return playlists;
    } catch (e) {
      print('Network getPlaylists failed, falling back to local DB: $e');
      final localPls = await _db.getAllPlaylists();
      return localPls.map((pl) => Playlist(id: pl.id, name: pl.name)).toList();
    }
  }

  // Get all songs from backend API (used for Home feed), fall back to local DB
  Future<List<Track>> getAllSongs() async {
    try {
      // Fetch from backend API (GET /api/songs without search param)
      final response = await _dio.get(ApiEndpoints.songs);
      final List<dynamic> list = response.data['data'] ?? [];
      final tracks = list.map((json) => Track.fromJson(json)).toList();

      // Save fetched tracks locally in background to keep local DB populated
      for (final track in tracks) {
        await _db.insertSong(
          db.Song(
            id: track.id,
            title: track.title,
            artist: track.artist,
            album: track.album,
            year: track.year,
            filePath: track.filePath,
            albumArtUrl:
                track.albumArtUrl ?? ApiEndpoints.getCoverUrl(track.id),
          ),
        );
      }
      return tracks;
    } catch (e) {
      print('Network getAllSongs failed, falling back to local DB: $e');
      try {
        final localSongs = await _db.getAllSongs();
        return localSongs
            .map(
              (song) => Track(
                id: song.id,
                title: song.title,
                artist: song.artist,
                album: song.album,
                year: song.year,
                filePath: song.filePath,
                albumArtUrl: song.albumArtUrl,
              ),
            )
            .toList();
      } catch (localErr) {
        print('Failed to read local songs: $localErr');
        return [];
      }
    }
  }

  // Get details and tracks for a playlist
  Future<Playlist> getPlaylistDetails(String playlistId) async {
    try {
      final response = await _dio.get('${ApiEndpoints.playlists}/$playlistId');
      final playlist = Playlist.fromJson(response.data);

      // Sync tracks to local db
      if (playlist.tracks != null) {
        int pos = 0;
        for (final track in playlist.tracks!) {
          await _db.insertSong(
            db.Song(
              id: track.id,
              title: track.title,
              artist: track.artist,
              album: track.album,
              year: track.year,
              filePath: track.filePath,
              albumArtUrl:
                  track.albumArtUrl ?? ApiEndpoints.getCoverUrl(track.id),
            ),
          );
          await _db.addSongToPlaylist(playlistId, track.id, pos++);
        }
      }
      return playlist;
    } catch (e) {
      print('Network getPlaylistDetails failed, falling back to local DB: $e');
      final localSongs = await _db.getSongsForPlaylist(playlistId);
      final tracks = localSongs
          .map(
            (song) => Track(
              id: song.id,
              title: song.title,
              artist: song.artist,
              album: song.album,
              year: song.year,
              filePath: song.filePath,
              albumArtUrl: song.albumArtUrl,
            ),
          )
          .toList();

      final plQuery = _db.select(_db.playlists)
        ..where((t) => t.id.equals(playlistId));
      final plInfo = await plQuery.getSingle();

      return Playlist(id: playlistId, name: plInfo.name, tracks: tracks);
    }
  }

  // Create playlist
  Future<Playlist> createPlaylist(String name) async {
    final response = await _dio.post(
      ApiEndpoints.playlists,
      data: {'name': name},
    );
    final playlist = Playlist.fromJson(response.data);

    // Write to local database
    await _db.insertPlaylist(db.Playlist(id: playlist.id, name: playlist.name));

    return playlist;
  }

  // Delete playlist
  Future<void> deletePlaylist(String playlistId) async {
    await _dio.delete('${ApiEndpoints.playlists}/$playlistId');
    await _db.deletePlaylist(playlistId);
  }

  // Add song to playlist
  Future<void> addSongToPlaylist(String playlistId, Track track) async {
    await _dio.post(
      '${ApiEndpoints.playlists}/$playlistId/songs',
      data: {'songId': track.id},
    );

    // Save song first to local DB
    await _db.insertSong(
      db.Song(
        id: track.id,
        title: track.title,
        artist: track.artist,
        album: track.album,
        year: track.year,
        filePath: track.filePath,
        albumArtUrl: track.albumArtUrl ?? ApiEndpoints.getCoverUrl(track.id),
      ),
    );

    final existingSongs = await _db.getSongsForPlaylist(playlistId);
    await _db.addSongToPlaylist(playlistId, track.id, existingSongs.length);
  }

  // Remove song from playlist
  Future<void> removeSongFromPlaylist(String playlistId, String songId) async {
    await _dio.delete('${ApiEndpoints.playlists}/$playlistId/songs/$songId');
    await _db.removeSongFromPlaylist(playlistId, songId);
  }
}
