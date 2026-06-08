import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../player/presentation/controllers/player_bloc.dart';
import '../controllers/library_bloc.dart';
import '../widgets/sliver_track_list.dart';
import 'playlist_details_screen.dart';
import '../../../../core/services/toast_service.dart';

class LibraryScreen extends StatefulWidget {
  const LibraryScreen({super.key});

  @override
  State<LibraryScreen> createState() => _LibraryScreenState();
}

class _LibraryScreenState extends State<LibraryScreen> {
  final _searchController = TextEditingController();
  bool _isSearching = false;

  @override
  void initState() {
    super.initState();
    context.read<LibraryBloc>().add(FetchPlaylists());
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _showCreatePlaylistDialog() {
    final nameController = TextEditingController();
    showDialog(
      context: context,
      builder: (dialogCtx) => AlertDialog(
        backgroundColor: AppColors.backgroundCard,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: BorderSide(color: AppColors.borderTranslucent),
        ),
        title: const Text(
          'New Playlist',
          style: TextStyle(color: AppColors.textPrimary),
        ),
        content: TextField(
          controller: nameController,
          style: const TextStyle(color: AppColors.textPrimary),
          decoration: const InputDecoration(
            hintText: 'Enter playlist name',
            hintStyle: TextStyle(color: AppColors.textMuted),
            enabledBorder: UnderlineInputBorder(
              borderSide: BorderSide(color: AppColors.textMuted),
            ),
            focusedBorder: UnderlineInputBorder(
              borderSide: BorderSide(color: AppColors.primary),
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogCtx),
            child: const Text(
              'Cancel',
              style: TextStyle(color: AppColors.textSecondary),
            ),
          ),
          ElevatedButton(
            onPressed: () {
              final name = nameController.text.trim();
              if (name.isNotEmpty) {
                context.read<LibraryBloc>().add(CreatePlaylistEvent(name));
                Navigator.pop(dialogCtx);
              }
            },
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.primary),
            child: const Text('Create', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  void _showAddToPlaylistDialog(dynamic track) {
    showDialog(
      context: context,
      builder: (dialogCtx) {
        return BlocBuilder<LibraryBloc, LibraryState>(
          bloc: context.read<LibraryBloc>()..add(FetchPlaylists()),
          builder: (context, state) {
            List<dynamic> playlists = [];
            if (state is PlaylistsLoaded) {
              playlists = state.playlists;
            }

            return AlertDialog(
              backgroundColor: AppColors.backgroundCard,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
                side: BorderSide(color: AppColors.borderTranslucent),
              ),
              title: const Text(
                'Add to Playlist',
                style: TextStyle(color: AppColors.textPrimary),
              ),
              content: playlists.isEmpty
                  ? const Text(
                      'No playlists found. Create one first.',
                      style: TextStyle(color: AppColors.textSecondary),
                    )
                  : SizedBox(
                      width: double.maxFinite,
                      child: ListView.builder(
                        shrinkWrap: true,
                        itemCount: playlists.length,
                        itemBuilder: (ctx, idx) {
                          final pl = playlists[idx];
                          return ListTile(
                            title: Text(
                              pl.name,
                              style: const TextStyle(
                                color: AppColors.textPrimary,
                              ),
                            ),
                            onTap: () {
                              context.read<LibraryBloc>().add(
                                AddSongToPlaylistEvent(pl.id, track),
                              );
                              Navigator.pop(dialogCtx);
                              ToastService.showSuccess('Added to ${pl.name}', title: 'Playlist Updated');
                            },
                          );
                        },
                      ),
                    ),
            );
          },
        );
      },
    );
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
          child: CustomScrollView(
            slivers: [
              // 1. Search Bar Header
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Row(
                    children: [
                      Expanded(
                        child: PremiumGlassContainer(
                          padding: const EdgeInsets.symmetric(horizontal: 12),
                          child: TextField(
                            controller: _searchController,
                            style: const TextStyle(
                              color: AppColors.textPrimary,
                            ),
                            onChanged: (val) {
                              setState(() {
                                _isSearching = val.isNotEmpty;
                              });
                              context.read<LibraryBloc>().add(
                                SearchSongsEvent(val),
                              );
                            },
                            decoration: const InputDecoration(
                              hintText: 'Search songs, artists...',
                              hintStyle: TextStyle(color: AppColors.textMuted),
                              prefixIcon: Icon(
                                Icons.search,
                                color: AppColors.textMuted,
                              ),
                              border: InputBorder.none,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      IconButton(
                        onPressed: _showCreatePlaylistDialog,
                        icon: const Icon(
                          Icons.playlist_add,
                          color: AppColors.accent,
                          size: 28,
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              // 2. Conditional Body content
              if (_isSearching) ...[
                // Song Search Header
                const SliverToBoxAdapter(
                  child: Padding(
                    padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    child: Text(
                      'Search Results',
                      style: TextStyle(
                        color: AppColors.textPrimary,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
                BlocBuilder<LibraryBloc, LibraryState>(
                  builder: (context, state) {
                    if (state is SongSearchLoading) {
                      return const SliverFillRemaining(
                        child: Center(
                          child: CircularProgressIndicator(
                            color: AppColors.primary,
                          ),
                        ),
                      );
                    }
                    if (state is SongSearchLoaded) {
                      return SliverTrackList(
                        tracks: state.tracks,
                        onTrackTap: (track) {
                          context.read<PlayerBloc>().add(PlayTrackEvent(track));
                        },
                        onAddToPlaylist: (track) =>
                            _showAddToPlaylistDialog(track),
                      );
                    }
                    return const SliverToBoxAdapter(child: SizedBox.shrink());
                  },
                ),
              ] else ...[
                // Playlist List
                const SliverToBoxAdapter(
                  child: Padding(
                    padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    child: Text(
                      'My Playlists',
                      style: TextStyle(
                        color: AppColors.textPrimary,
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
                BlocBuilder<LibraryBloc, LibraryState>(
                  buildWhen: (prev, current) =>
                      current is PlaylistsLoading || current is PlaylistsLoaded,
                  builder: (context, state) {
                    if (state is PlaylistsLoading) {
                      return const SliverFillRemaining(
                        child: Center(
                          child: CircularProgressIndicator(
                            color: AppColors.primary,
                          ),
                        ),
                      );
                    }
                    if (state is PlaylistsLoaded) {
                      if (state.playlists.isEmpty) {
                        return const SliverToBoxAdapter(
                          child: Padding(
                            padding: EdgeInsets.symmetric(vertical: 64.0),
                            child: Center(
                              child: Text(
                                'No playlists yet. Create one to get started.',
                                style: TextStyle(
                                  color: AppColors.textSecondary,
                                ),
                              ),
                            ),
                          ),
                        );
                      }

                      return SliverList(
                        delegate: SliverChildBuilderDelegate((context, index) {
                          final playlist = state.playlists[index];
                          return Container(
                            margin: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 6,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.white.withValues(alpha: 0.02),
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(
                                color: AppColors.borderTranslucent,
                              ),
                            ),
                            child: ListTile(
                              leading: Container(
                                width: 48,
                                height: 48,
                                decoration: BoxDecoration(
                                  color: AppColors.primary.withValues(alpha: 0.1),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: const Icon(
                                  Icons.music_note,
                                  color: AppColors.accent,
                                ),
                              ),
                              title: Text(
                                playlist.name,
                                style: const TextStyle(
                                  color: AppColors.textPrimary,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              subtitle: const Text(
                                'Playlist',
                                style: TextStyle(
                                  color: AppColors.textSecondary,
                                ),
                              ),
                              trailing: IconButton(
                                icon: const Icon(
                                  Icons.delete_outline,
                                  color: AppColors.error,
                                ),
                                onPressed: () {
                                  context.read<LibraryBloc>().add(
                                    DeletePlaylistEvent(playlist.id),
                                  );
                                },
                              ),
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (ctx) => PlaylistDetailsScreen(
                                      playlistId: playlist.id,
                                      playlistName: playlist.name,
                                    ),
                                  ),
                                );
                              },
                            ),
                          );
                        }, childCount: state.playlists.length),
                      );
                    }
                    return const SliverToBoxAdapter(child: SizedBox.shrink());
                  },
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
