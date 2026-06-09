import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shimmer/shimmer.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../player/domain/track.dart';
import '../../../player/presentation/controllers/player_bloc.dart';

class SliverTrackList extends StatelessWidget {
  final List<Track> tracks;
  final String? playlistId;
  final Function(Track track) onTrackTap;
  final Function(Track track)? onAddToPlaylist;
  final Function(Track track)? onRemoveFromPlaylist;

  const SliverTrackList({
    super.key,
    required this.tracks,
    this.playlistId,
    required this.onTrackTap,
    this.onAddToPlaylist,
    this.onRemoveFromPlaylist,
  });

  @override
  Widget build(BuildContext context) {
    if (tracks.isEmpty) {
      return const SliverToBoxAdapter(
        child: Padding(
          padding: EdgeInsets.symmetric(vertical: 48.0),
          child: Center(
            child: Text(
              'No tracks available',
              style: TextStyle(color: AppColors.textSecondary),
            ),
          ),
        ),
      );
    }

    return BlocBuilder<PlayerBloc, PlayerStatus>(
      builder: (context, playerState) {
        final activeTrackId = playerState.currentTrack?.id;
        final isBuffering = playerState.isBuffering;

        return SliverList(
          delegate: SliverChildBuilderDelegate((context, index) {
            final track = tracks[index];
            final isActive = track.id == activeTrackId;
            final isThisTrackBuffering = isActive && isBuffering;

            return Container(
              margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
              decoration: BoxDecoration(
                color: isActive
                    ? AppColors.primary.withValues(alpha: 0.08)
                    : Colors.white.withValues(alpha: 0.02),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: isActive
                      ? AppColors.primary.withValues(alpha: 0.25)
                      : AppColors.borderTranslucent,
                ),
              ),
              child: ListTile(
                onTap: () => onTrackTap(track),
                leading: ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: SizedBox(
                    width: 50,
                    height: 50,
                    child: Stack(
                      children: [
                        // Album art
                        track.albumArtUrl != null && track.albumArtUrl!.isNotEmpty
                            ? CachedNetworkImage(
                                imageUrl: track.albumArtUrl!,
                                fit: BoxFit.cover,
                                width: 50,
                                height: 50,
                                memCacheHeight: 150,
                                memCacheWidth: 150,
                                placeholder: (context, url) => Shimmer.fromColors(
                                  baseColor: Colors.white.withValues(alpha: 0.05),
                                  highlightColor: Colors.white.withValues(alpha: 0.1),
                                  child: Container(color: Colors.grey),
                                ),
                                errorWidget: (context, url, error) => Container(
                                  color: Colors.white.withValues(alpha: 0.05),
                                  child: const Icon(
                                    Icons.music_note,
                                    color: AppColors.accent,
                                  ),
                                ),
                              )
                            : Container(
                                color: Colors.white.withValues(alpha: 0.05),
                                child: const Icon(
                                  Icons.music_note,
                                  color: AppColors.accent,
                                ),
                              ),
                        // Buffering overlay
                        if (isThisTrackBuffering)
                          Container(
                            width: 50,
                            height: 50,
                            color: Colors.black.withValues(alpha: 0.55),
                            child: const Center(
                              child: SizedBox(
                                width: 22,
                                height: 22,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2.5,
                                  color: AppColors.accent,
                                ),
                              ),
                            ),
                          ),
                        // Playing indicator
                        if (isActive && !isThisTrackBuffering)
                          Container(
                            width: 50,
                            height: 50,
                            color: Colors.black.withValues(alpha: 0.35),
                            child: Icon(
                              playerState.isPlaying
                                  ? Icons.equalizer_rounded
                                  : Icons.pause_rounded,
                              color: AppColors.accent,
                              size: 22,
                            ),
                          ),
                      ],
                    ),
                  ),
                ),
                title: Text(
                  track.title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: isActive ? AppColors.primary : AppColors.textPrimary,
                    fontWeight: FontWeight.w600,
                    fontSize: 15,
                  ),
                ),
                subtitle: Text(
                  track.artist ?? 'Unknown Artist',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: AppColors.textSecondary,
                    fontSize: 13,
                  ),
                ),
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    if (track.filePath != null)
                      const Icon(
                        Icons.offline_pin,
                        color: AppColors.primary,
                        size: 18,
                      ),
                    PopupMenuButton<String>(
                      icon: const Icon(Icons.more_vert, color: AppColors.textMuted),
                      color: AppColors.backgroundCard,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                        side: BorderSide(color: AppColors.borderTranslucent),
                      ),
                      onSelected: (value) {
                        if (value == 'add' && onAddToPlaylist != null) {
                          onAddToPlaylist!(track);
                        } else if (value == 'remove' &&
                            onRemoveFromPlaylist != null) {
                          onRemoveFromPlaylist!(track);
                        }
                      },
                      itemBuilder: (context) => [
                        if (playlistId == null && onAddToPlaylist != null)
                          const PopupMenuItem(
                            value: 'add',
                            child: Text(
                              'Add to Playlist',
                              style: TextStyle(color: Colors.white),
                            ),
                          ),
                        if (playlistId != null && onRemoveFromPlaylist != null)
                          const PopupMenuItem(
                            value: 'remove',
                            child: Text(
                              'Remove from Playlist',
                              style: TextStyle(color: AppColors.error),
                            ),
                          ),
                      ],
                    ),
                  ],
                ),
              ),
            );
          }, childCount: tracks.length),
        );
      },
    );
  }
}
