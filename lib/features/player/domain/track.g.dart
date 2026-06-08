// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'track.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$TrackImpl _$$TrackImplFromJson(Map<String, dynamic> json) => _$TrackImpl(
  id: json['id'] as String,
  title: json['title'] as String,
  artist: json['artist'] as String?,
  album: json['album'] as String?,
  year: (json['year'] as num?)?.toInt(),
  filePath: json['filePath'] as String?,
  albumArtUrl: json['albumArtUrl'] as String?,
);

Map<String, dynamic> _$$TrackImplToJson(_$TrackImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'title': instance.title,
      'artist': instance.artist,
      'album': instance.album,
      'year': instance.year,
      'filePath': instance.filePath,
      'albumArtUrl': instance.albumArtUrl,
    };
