import 'dart:ui';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/theme/app_colors.dart';
import '../controllers/player_bloc.dart';
import '../widgets/premium_slider.dart';

class FullPlayerScreen extends StatelessWidget {
  const FullPlayerScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<PlayerBloc, PlayerStatus>(
      builder: (context, state) {
        final track = state.currentTrack;
        if (track == null) return const SizedBox.shrink();

        return Container(
          height: MediaQuery.of(context).size.height * 0.94,
          decoration: BoxDecoration(
            color: AppColors.background.withValues(alpha: 0.85),
            borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
            border: Border.all(color: AppColors.borderTranslucent),
          ),
          child: ClipRRect(
            borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 30, sigmaY: 30),
              child: SafeArea(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
                  child: Column(
                    children: [
                      // Collapse handle
                      Center(
                        child: Container(
                          width: 40,
                          height: 4,
                          decoration: BoxDecoration(
                            color: Colors.white.withValues(alpha: 0.2),
                            borderRadius: BorderRadius.circular(2),
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),

                      // Custom Navigation / Title
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          IconButton(
                            icon: const Icon(Icons.keyboard_arrow_down, color: Colors.white, size: 28),
                            onPressed: () => Navigator.pop(context),
                          ),
                          const Text(
                            'NOW PLAYING',
                            style: TextStyle(
                              color: AppColors.textSecondary,
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                              letterSpacing: 1.5,
                            ),
                          ),
                          const SizedBox(width: 48), // Spacer
                        ],
                      ),
                      const Spacer(),

                      // Large album art
                      Container(
                        width: MediaQuery.of(context).size.width * 0.8,
                        height: MediaQuery.of(context).size.width * 0.8,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(20),
                          boxShadow: [
                            BoxShadow(
                              color: AppColors.primary.withValues(alpha: 0.25),
                              blurRadius: 30,
                              spreadRadius: 2,
                            ),
                          ],
                        ),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(20),
                          child: track.albumArtUrl != null && track.albumArtUrl!.isNotEmpty
                              ? CachedNetworkImage(
                                  imageUrl: track.albumArtUrl!,
                                  fit: BoxFit.cover,
                                  errorWidget: (context, url, error) => Container(
                                    color: Colors.white.withValues(alpha: 0.05),
                                    child: const Icon(Icons.music_note, size: 80, color: AppColors.accent),
                                  ),
                                )
                              : Container(
                                  color: Colors.white.withValues(alpha: 0.05),
                                  child: const Icon(Icons.music_note, size: 80, color: AppColors.accent),
                                ),
                        ),
                      ),
                      const Spacer(),

                      // Metadata Info
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  track.title,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: const TextStyle(
                                    color: AppColors.textPrimary,
                                    fontSize: 24,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                const SizedBox(height: 6),
                                Text(
                                  track.artist ?? 'Unknown Artist',
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: const TextStyle(
                                    color: AppColors.textSecondary,
                                    fontSize: 16,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          if (track.filePath != null)
                            const Icon(Icons.offline_pin, color: AppColors.primary, size: 24),
                        ],
                      ),
                      const SizedBox(height: 24),

                      // Premium Progress Slider
                      PremiumSlider(
                        position: state.position,
                        bufferedPosition: state.bufferedPosition,
                        duration: state.duration,
                        onSeek: (newPos) {
                          context.read<PlayerBloc>().add(SeekToEvent(newPos));
                        },
                      ),
                      const SizedBox(height: 24),

                      // Main Playback Controls
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          // Skip Previous
                          IconButton(
                            icon: const Icon(Icons.skip_previous_rounded, color: Colors.white, size: 38),
                            onPressed: () {
                              context.read<PlayerBloc>().add(PreviousTrackEvent());
                            },
                          ),
                          const SizedBox(width: 20),

                          // Play / Pause Circle
                          if (state.isBuffering)
                            const SizedBox(
                              width: 72,
                              height: 72,
                              child: CircularProgressIndicator(color: AppColors.accent),
                            )
                          else
                            GestureDetector(
                              onTap: () {
                                if (state.isPlaying) {
                                  context.read<PlayerBloc>().add(PauseEvent());
                                } else {
                                  context.read<PlayerBloc>().add(ResumeEvent());
                                }
                              },
                              child: Container(
                                width: 72,
                                height: 72,
                                decoration: const BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: AppColors.accent,
                                ),
                                child: Icon(
                                  state.isPlaying ? Icons.pause_rounded : Icons.play_arrow_rounded,
                                  color: Colors.white,
                                  size: 40,
                                ),
                              ),
                            ),
                          const SizedBox(width: 20),

                          // Skip Next
                          IconButton(
                            icon: const Icon(Icons.skip_next_rounded, color: Colors.white, size: 38),
                            onPressed: () {
                              context.read<PlayerBloc>().add(NextTrackEvent());
                            },
                          ),
                        ],
                      ),
                      const Spacer(),
                    ],
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
