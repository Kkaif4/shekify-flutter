import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../player/presentation/controllers/player_bloc.dart';
import '../controllers/library_bloc.dart';
import '../widgets/sliver_track_list.dart';
import '../../../../core/services/toast_service.dart';

class PlaylistDetailsScreen extends StatefulWidget {
  final String playlistId;
  final String playlistName;

  const PlaylistDetailsScreen({
    super.key,
    required this.playlistId,
    required this.playlistName,
  });

  @override
  State<PlaylistDetailsScreen> createState() => _PlaylistDetailsScreenState();
}

class _PlaylistDetailsScreenState extends State<PlaylistDetailsScreen> {
  @override
  void initState() {
    super.initState();
    context.read<LibraryBloc>().add(FetchPlaylistDetailsEvent(widget.playlistId));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [AppColors.background, AppColors.secondaryDark],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: SafeArea(
          child: BlocBuilder<LibraryBloc, LibraryState>(
            buildWhen: (prev, current) =>
                current is PlaylistDetailsLoading || current is PlaylistDetailsLoaded,
            builder: (context, state) {
              if (state is PlaylistDetailsLoading) {
                return const Center(child: CircularProgressIndicator(color: AppColors.primary));
              }

              if (state is PlaylistDetailsLoaded) {
                final playlist = state.playlist;
                final tracks = playlist.tracks ?? [];

                return CustomScrollView(
                  slivers: [
                    // Premium Header Banner
                    SliverAppBar(
                      expandedHeight: 200,
                      backgroundColor: Colors.transparent,
                      elevation: 0,
                      leading: IconButton(
                        icon: const Icon(Icons.arrow_back, color: Colors.white),
                        onPressed: () => Navigator.pop(context),
                      ),
                      flexibleSpace: FlexibleSpaceBar(
                        background: Container(
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: [
                                AppColors.primary.withValues(alpha: 0.3),
                                AppColors.background.withValues(alpha: 0.0),
                              ],
                              begin: Alignment.topCenter,
                              end: Alignment.bottomCenter,
                            ),
                          ),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.end,
                            children: [
                              Container(
                                width: 80,
                                height: 80,
                                decoration: BoxDecoration(
                                  color: AppColors.primary.withValues(alpha: 0.2),
                                  borderRadius: BorderRadius.circular(16),
                                  boxShadow: [
                                    BoxShadow(
                                      color: AppColors.primary.withValues(alpha: 0.3),
                                      blurRadius: 20,
                                      spreadRadius: 2,
                                    ),
                                  ],
                                ),
                                child: const Icon(Icons.music_note, size: 40, color: AppColors.accent),
                              ),
                              const SizedBox(height: 12),
                              Text(
                                playlist.name,
                                style: const TextStyle(
                                  fontSize: 24,
                                  fontWeight: FontWeight.bold,
                                  color: AppColors.textPrimary,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                '${tracks.length} tracks',
                                style: const TextStyle(
                                  fontSize: 14,
                                  color: AppColors.textSecondary,
                                ),
                              ),
                              const SizedBox(height: 16),
                            ],
                          ),
                        ),
                      ),
                    ),

                    // Play Playlist CTA bar
                    if (tracks.isNotEmpty)
                      SliverToBoxAdapter(
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.end,
                            children: [
                              ElevatedButton.icon(
                                onPressed: () {
                                  // Play whole playlist (starts queue)
                                  context.read<PlayerBloc>().add(PlayQueueEvent(tracks, 0));
                                },
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: AppColors.primary,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(24),
                                  ),
                                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                                ),
                                icon: const Icon(Icons.play_arrow, color: Colors.white),
                                label: const Text(
                                  'Play All',
                                  style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),

                    // Tracks List
                    SliverTrackList(
                      tracks: tracks,
                      playlistId: playlist.id,
                      onTrackTap: (track) {
                        // Play single track within the playlist context queue
                        final clickedIndex = tracks.indexOf(track);
                        context.read<PlayerBloc>().add(PlayQueueEvent(tracks, clickedIndex == -1 ? 0 : clickedIndex));
                      },
                      onRemoveFromPlaylist: (track) {
                        context.read<LibraryBloc>().add(RemoveSongFromPlaylistEvent(playlist.id, track.id));
                        ToastService.showInfo('Removed ${track.title} from ${playlist.name}', title: 'Track Removed');
                      },
                    ),
                  ],
                );
              }

              return const Center(child: Text('Failed to load playlist', style: TextStyle(color: Colors.white)));
            },
          ),
        ),
      ),
    );
  }
}
