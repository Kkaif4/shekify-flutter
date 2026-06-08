import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_theme.dart';
import '../controllers/player_bloc.dart';
import '../screens/full_player_screen.dart';

class GlassPlayerFooter extends StatelessWidget {
  const GlassPlayerFooter({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<PlayerBloc, PlayerStatus>(
      builder: (context, state) {
        final track = state.currentTrack;
        if (track == null) return const SizedBox.shrink();

        final progressPercent = state.duration.inMilliseconds > 0
            ? state.position.inMilliseconds / state.duration.inMilliseconds
            : 0.0;

        return GestureDetector(
          onTap: () {
            showModalBottomSheet(
              context: context,
              isScrollControlled: true,
              backgroundColor: Colors.transparent,
              builder: (sheetCtx) => const FullPlayerScreen(),
            );
          },
          child: Container(
            margin: const EdgeInsets.all(12),
            child: PremiumGlassContainer(
              padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Row(
                    children: [
                      // Album art
                      ClipRRect(
                        borderRadius: BorderRadius.circular(8),
                        child: SizedBox(
                          width: 48,
                          height: 48,
                          child: track.albumArtUrl != null && track.albumArtUrl!.isNotEmpty
                              ? CachedNetworkImage(
                                  imageUrl: track.albumArtUrl!,
                                  fit: BoxFit.cover,
                                  memCacheHeight: 100,
                                  memCacheWidth: 100,
                                  errorWidget: (context, url, error) => Container(
                                    color: Colors.white.withValues(alpha: 0.05),
                                    child: const Icon(Icons.music_note, color: AppColors.accent),
                                  ),
                                )
                              : Container(
                                  color: Colors.white.withValues(alpha: 0.05),
                                  child: const Icon(Icons.music_note, color: AppColors.accent),
                                ),
                        ),
                      ),
                      const SizedBox(width: 12),

                      // Track details
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              track.title,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(
                                color: AppColors.textPrimary,
                                fontWeight: FontWeight.bold,
                                fontSize: 14,
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              track.artist ?? 'Unknown Artist',
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(
                                color: AppColors.textSecondary,
                                fontSize: 12,
                              ),
                            ),
                          ],
                        ),
                      ),

                      // Controls
                      IconButton(
                        icon: const Icon(Icons.skip_previous, color: AppColors.textPrimary, size: 24),
                        onPressed: () {
                          context.read<PlayerBloc>().add(PreviousTrackEvent());
                        },
                      ),
                      const SizedBox(width: 4),
                      if (state.isBuffering)
                        const SizedBox(
                          width: 24,
                          height: 24,
                          child: CircularProgressIndicator(strokeWidth: 2, color: AppColors.accent),
                        )
                      else
                        IconButton(
                          icon: Icon(
                            state.isPlaying ? Icons.pause_circle_filled : Icons.play_circle_filled,
                            color: AppColors.accent,
                            size: 32,
                          ),
                          onPressed: () {
                            if (state.isPlaying) {
                              context.read<PlayerBloc>().add(PauseEvent());
                            } else {
                              context.read<PlayerBloc>().add(ResumeEvent());
                            }
                          },
                        ),
                      const SizedBox(width: 4),
                      IconButton(
                        icon: const Icon(Icons.skip_next, color: AppColors.textPrimary, size: 24),
                        onPressed: () {
                          context.read<PlayerBloc>().add(NextTrackEvent());
                        },
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),

                  // Linear Progress Bar
                  ClipRRect(
                    borderRadius: BorderRadius.circular(2),
                    child: LinearProgressIndicator(
                      value: progressPercent.clamp(0.0, 1.0),
                      minHeight: 2,
                      backgroundColor: Colors.white.withValues(alpha: 0.08),
                      valueColor: const AlwaysStoppedAnimation<Color>(AppColors.primary),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
