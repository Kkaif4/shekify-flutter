import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'core/services/audio_handler.dart';
import 'core/services/database.dart';
import 'core/theme/app_colors.dart';
import 'core/theme/app_theme.dart';
import 'features/auth/data/auth_repository.dart';
import 'features/auth/presentation/controllers/auth_bloc.dart';
import 'features/auth/presentation/screens/login_screen.dart';
import 'features/library/data/library_repository.dart';
import 'features/library/presentation/controllers/library_bloc.dart';
import 'features/library/presentation/screens/library_screen.dart';
import 'features/player/data/player_repository.dart';
import 'features/player/presentation/controllers/player_bloc.dart';
import 'features/player/presentation/widgets/glass_player_footer.dart';

class ShekifyApp extends StatelessWidget {
  final AppDatabase database;
  final ShekifyAudioHandler audioHandler;

  const ShekifyApp({
    super.key,
    required this.database,
    required this.audioHandler,
  });

  @override
  Widget build(BuildContext context) {
    return MultiRepositoryProvider(
      providers: [
        RepositoryProvider<AuthRepository>(create: (_) => AuthRepository()),
        RepositoryProvider<LibraryRepository>(create: (_) => LibraryRepository(database)),
        RepositoryProvider<PlayerRepository>(create: (_) => PlayerRepository(database)),
      ],
      child: MultiBlocProvider(
        providers: [
          BlocProvider<AuthBloc>(
            create: (ctx) => AuthBloc(ctx.read<AuthRepository>())..add(AuthCheckRequested()),
          ),
          BlocProvider<LibraryBloc>(
            create: (ctx) => LibraryBloc(ctx.read<LibraryRepository>()),
          ),
          BlocProvider<PlayerBloc>(
            create: (ctx) => PlayerBloc(
              ctx.read<PlayerRepository>(),
              audioHandler,
            ),
          ),
        ],
        child: MaterialApp(
          title: 'Shekify',
          theme: AppTheme.darkTheme,
          debugShowCheckedModeBanner: false,
          home: const AppRootNavigator(),
        ),
      ),
    );
  }
}

class AppRootNavigator extends StatelessWidget {
  const AppRootNavigator({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AuthBloc, AuthState>(
      builder: (context, state) {
        if (state is AuthInitial || state is AuthLoading) {
          return const Scaffold(
            backgroundColor: AppColors.background,
            body: Center(
              child: CircularProgressIndicator(color: AppColors.primary),
            ),
          );
        }

        if (state is Authenticated) {
          return const MainAppShell();
        }

        return const LoginScreen();
      },
    );
  }
}

class MainAppShell extends StatelessWidget {
  const MainAppShell({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'SHEKIFY',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            letterSpacing: 1.5,
            fontSize: 18,
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout, color: AppColors.textSecondary),
            onPressed: () {
              context.read<AuthBloc>().add(AuthLogoutRequested());
            },
          ),
        ],
      ),
      body: Stack(
        children: [
          // Primary screen body
          const LibraryScreen(),

          // Floating glass footer player (stays fixed on screen bottom)
          const Align(
            alignment: Alignment.bottomCenter,
            child: SafeArea(
              child: GlassPlayerFooter(),
            ),
          ),
        ],
      ),
    );
  }
}
