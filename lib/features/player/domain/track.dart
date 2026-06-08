import 'package:audio_service/audio_service.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

part 'track.freezed.dart';
part 'track.g.dart';

@freezed
class Track with _$Track {
  const factory Track({
    required String id,
    required String title,
    String? artist,
    String? album,
    int? year,
    String? filePath,
    String? albumArtUrl,
  }) = _Track;

  const Track._();

  factory Track.fromJson(Map<String, dynamic> json) => _$TrackFromJson(json);

  MediaItem toMediaItem(String networkStreamUrl) {
    return MediaItem(
      id: id,
      album: album ?? 'Shekify Library',
      title: title,
      artist: artist ?? 'Unknown Artist',
      artUri: albumArtUrl != null && albumArtUrl!.isNotEmpty
          ? Uri.parse(albumArtUrl!)
          : null,
      extras: {
        'url': filePath ?? networkStreamUrl,
      },
    );
  }
}
