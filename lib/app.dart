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
import 'features/home/presentation/screens/home_screen.dart';
import 'features/player/data/player_repository.dart';
import 'features/player/presentation/controllers/player_bloc.dart';
import 'features/player/presentation/widgets/glass_player_footer.dart';

import 'core/services/toast_service.dart';

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
        RepositoryProvider<LibraryRepository>(
          create: (_) => LibraryRepository(database),
        ),
        RepositoryProvider<PlayerRepository>(
          create: (_) => PlayerRepository(database),
        ),
      ],
      child: MultiBlocProvider(
        providers: [
          BlocProvider<AuthBloc>(
            create: (ctx) =>
                AuthBloc(ctx.read<AuthRepository>())..add(AuthCheckRequested()),
          ),
          BlocProvider<LibraryBloc>(
            create: (ctx) => LibraryBloc(ctx.read<LibraryRepository>()),
          ),
          BlocProvider<PlayerBloc>(
            create: (ctx) =>
                PlayerBloc(ctx.read<PlayerRepository>(), audioHandler),
          ),
        ],
        child: MaterialApp(
          navigatorKey: navigatorKey,
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

class MainAppShell extends StatefulWidget {
  const MainAppShell({super.key});

  @override
  State<MainAppShell> createState() => _MainAppShellState();
}

class _MainAppShellState extends State<MainAppShell> {
  int _selectedIndex = 0;

  Widget _bodyForIndex(int idx) {
    switch (idx) {
      case 0:
        return const HomeScreen();
      case 1:
        return const LibraryScreen();
      default:
        return const HomeScreen();
    }
  }

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
      drawer: Drawer(
        backgroundColor: AppColors.backgroundSecondary,
        child: SafeArea(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              DrawerHeader(
                decoration: BoxDecoration(color: AppColors.backgroundCard),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: const [
                    Icon(Icons.music_note, size: 36, color: AppColors.accent),
                    SizedBox(height: 8),
                    Text(
                      'Shekify',
                      style: TextStyle(
                        color: AppColors.textPrimary,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
              ListTile(
                leading: const Icon(Icons.home, color: AppColors.textSecondary),
                title: const Text(
                  'Home',
                  style: TextStyle(color: AppColors.textPrimary),
                ),
                selected: _selectedIndex == 0,
                onTap: () {
                  setState(() => _selectedIndex = 0);
                  Navigator.pop(context);
                },
              ),
              ListTile(
                leading: const Icon(
                  Icons.library_music,
                  color: AppColors.textSecondary,
                ),
                title: const Text(
                  'Library',
                  style: TextStyle(color: AppColors.textPrimary),
                ),
                selected: _selectedIndex == 1,
                onTap: () {
                  setState(() => _selectedIndex = 1);
                  Navigator.pop(context);
                },
              ),
              const Spacer(),
              Padding(
                padding: const EdgeInsets.all(12.0),
                child: ElevatedButton.icon(
                  onPressed: () =>
                      context.read<AuthBloc>().add(AuthLogoutRequested()),
                  icon: const Icon(Icons.logout),
                  label: const Text('Sign out'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
      body: Stack(
        children: [
          _bodyForIndex(_selectedIndex),
          const Align(
            alignment: Alignment.bottomCenter,
            child: SafeArea(child: GlassPlayerFooter()),
          ),
        ],
      ),
    );
  }
}
