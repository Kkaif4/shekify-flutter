import 'package:drift/drift.dart';
import 'connection/unsupported.dart'
    if (dart.library.html) 'connection/web.dart'
    if (dart.library.io) 'connection/native.dart';

part 'database.g.dart';

// 1. Define Tables
class Songs extends Table {
  TextColumn get id => text()();
  TextColumn get title => text()();
  TextColumn get artist => text().nullable()();
  TextColumn get album => text().nullable()();
  IntColumn get year => integer().nullable()();
  TextColumn get filePath => text().nullable()(); // Local storage path if downloaded
  TextColumn get albumArtUrl => text().nullable()();

  @override
  Set<Column> get primaryKey => {id};
}

class Playlists extends Table {
  TextColumn get id => text()();
  TextColumn get name => text()();

  @override
  Set<Column> get primaryKey => {id};
}

class PlaylistSongs extends Table {
  TextColumn get playlistId => text().references(Playlists, #id, onDelete: KeyAction.cascade)();
  TextColumn get songId => text().references(Songs, #id, onDelete: KeyAction.cascade)();
  IntColumn get position => integer()();

  @override
  Set<Column> get primaryKey => {playlistId, songId};
}

// 2. Database Connection Class
@DriftDatabase(tables: [Songs, Playlists, PlaylistSongs])
class AppDatabase extends _$AppDatabase {
  AppDatabase() : super(openConnection());

  @override
  int get schemaVersion => 1;

  // Song Helpers
  Future<List<Song>> getAllSongs() => select(songs).get();
  Future<Song?> getSongById(String id) => (select(songs)..where((t) => t.id.equals(id))).getSingleOrNull();
  Future<int> insertSong(Song song) => into(songs).insertOnConflictUpdate(song);
  Future<void> deleteSong(String id) => (delete(songs)..where((t) => t.id.equals(id))).go();

  // Playlist Helpers
  Future<List<Playlist>> getAllPlaylists() => select(playlists).get();
  Future<int> insertPlaylist(Playlist playlist) => into(playlists).insertOnConflictUpdate(playlist);
  Future<void> deletePlaylist(String id) => (delete(playlists)..where((t) => t.id.equals(id))).go();

  // PlaylistSongs Helpers
  Future<List<Song>> getSongsForPlaylist(String playlistId) async {
    final query = select(playlistSongs).join([
      innerJoin(songs, songs.id.equalsExp(playlistSongs.songId)),
    ])..where(playlistSongs.playlistId.equals(playlistId))..orderBy([OrderingTerm(expression: playlistSongs.position)]);

    final rows = await query.get();
    return rows.map((row) => row.readTable(songs)).toList();
  }

  Future<void> addSongToPlaylist(String playlistId, String songId, int position) async {
    await into(playlistSongs).insertOnConflictUpdate(
      PlaylistSong(playlistId: playlistId, songId: songId, position: position),
    );
  }

  Future<void> removeSongFromPlaylist(String playlistId, String songId) async {
    await (delete(playlistSongs)
          ..where((t) => t.playlistId.equals(playlistId) & t.songId.equals(songId)))
        .go();
  }
}

