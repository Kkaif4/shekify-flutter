import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../player/presentation/controllers/player_bloc.dart';
import '../../../library/presentation/widgets/sliver_track_list.dart';
import '../../../library/presentation/controllers/library_bloc.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    // Fetch the first page of songs
    context.read<LibraryBloc>().add(FetchHomeSongsEvent(isRefresh: true));
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (_isNearBottom) {
      context.read<LibraryBloc>().add(FetchHomeSongsEvent());
    }
  }

  bool get _isNearBottom {
    if (!_scrollController.hasClients) return false;
    final maxScroll = _scrollController.position.maxScrollExtent;
    final currentScroll = _scrollController.offset;
    // Trigger at 85% depth
    return currentScroll >= maxScroll * 0.85;
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
            controller: _scrollController,
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
                    current is HomeSongsLoaded ||
                    current is PlaylistsLoading ||
                    current is SongSearchLoaded,
                builder: (context, state) {
                  // If search results are showing, use those
                  if (state is SongSearchLoaded && state.tracks.isNotEmpty) {
                    return SliverTrackList(
                      tracks: state.tracks,
                      onTrackTap: (track) =>
                          context.read<PlayerBloc>().add(PlayTrackEvent(track)),
                      onAddToPlaylist: (track) => _showAddDialog(track),
                    );
                  }

                  // Initial loading state
                  if (state is PlaylistsLoading) {
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

                  // Paginated song list
                  if (state is HomeSongsLoaded) {
                    return SliverTrackList(
                      tracks: state.tracks,
                      onTrackTap: (track) =>
                          context.read<PlayerBloc>().add(PlayTrackEvent(track)),
                      onAddToPlaylist: (track) => _showAddDialog(track),
                    );
                  }

                  return const SliverToBoxAdapter(child: SizedBox.shrink());
                },
              ),

              // Bottom loading indicator for pagination
              BlocBuilder<LibraryBloc, LibraryState>(
                buildWhen: (prev, current) => current is HomeSongsLoaded,
                builder: (context, state) {
                  if (state is HomeSongsLoaded && state.isLoadingMore) {
                    return const SliverToBoxAdapter(
                      child: Padding(
                        padding: EdgeInsets.symmetric(vertical: 24.0),
                        child: Center(
                          child: SizedBox(
                            width: 28,
                            height: 28,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: AppColors.accent,
                            ),
                          ),
                        ),
                      ),
                    );
                  }
                  return const SliverToBoxAdapter(child: SizedBox.shrink());
                },
              ),

              // Bottom padding so player footer doesn't cover last items
              const SliverToBoxAdapter(
                child: SizedBox(height: 100),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showAddDialog(dynamic track) {
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
