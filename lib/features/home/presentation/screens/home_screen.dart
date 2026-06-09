import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../player/presentation/controllers/player_bloc.dart';
import '../../../library/presentation/widgets/sliver_track_list.dart';
import '../../../library/presentation/controllers/library_bloc.dart';
import '../../../library/data/library_repository.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  @override
  void initState() {
    super.initState();
    context.read<LibraryBloc>().add(FetchPlaylists());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
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
              const SliverToBoxAdapter(
                child: Padding(
                  padding: EdgeInsets.all(16.0),
                  child: Text(
                    'Home Feed',
                    style: TextStyle(
                      color: AppColors.textPrimary,
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),

              BlocBuilder<LibraryBloc, LibraryState>(
                buildWhen: (prev, current) =>
                    current is SongSearchLoaded || current is PlaylistsLoaded,
                builder: (context, state) {
                  if (state is SongSearchLoaded && state.tracks.isNotEmpty) {
                    return SliverTrackList(
                      tracks: state.tracks,
                      onTrackTap: (track) =>
                          context.read<PlayerBloc>().add(PlayTrackEvent(track)),
                      onAddToPlaylist: (track) => _showAddDialog(track),
                    );
                  }

                  return FutureBuilder<List<dynamic>>(
                    future: RepositoryProvider.of<LibraryRepository>(
                      context,
                    ).getAllSongs(),
                    builder: (ctx, snap) {
                      if (snap.connectionState == ConnectionState.waiting) {
                        return const SliverToBoxAdapter(
                          child: Padding(
                            padding: EdgeInsets.symmetric(vertical: 48.0),
                            child: Center(
                              child: CircularProgressIndicator(
                                color: AppColors.primary,
                              ),
                            ),
                          ),
                        );
                      }

                      final tracks = snap.data ?? [];
                      return SliverTrackList(
                        tracks: tracks.cast(),
                        onTrackTap: (track) => context.read<PlayerBloc>().add(
                          PlayTrackEvent(track),
                        ),
                        onAddToPlaylist: (track) => _showAddDialog(track),
                      );
                    },
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showAddDialog(track) {
    final libraryBloc = context.read<LibraryBloc>();
    showDialog(
      context: context,
      builder: (dialogCtx) => BlocBuilder<LibraryBloc, LibraryState>(
        bloc: libraryBloc..add(FetchPlaylists()),
        builder: (context, state) {
          List playlists = [];
          if (state is PlaylistsLoaded) playlists = state.playlists;
          return AlertDialog(
            backgroundColor: AppColors.backgroundCard,
            title: const Text(
              'Add to Playlist',
              style: TextStyle(color: AppColors.textPrimary),
            ),
            content: playlists.isEmpty
                ? const Text(
                    'No playlists found.',
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
                            libraryBloc.add(
                              AddSongToPlaylistEvent(pl.id, track),
                            );
                            Navigator.pop(dialogCtx);
                          },
                        );
                      },
                    ),
                  ),
          );
        },
      ),
    );
  }
}
