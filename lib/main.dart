import 'package:flutter/material.dart';
import 'app.dart';
import 'core/services/audio_handler.dart';
import 'core/services/database.dart';

void main() async {
  // Ensure Flutter engine framework bindings are initialized
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize central SQLite database using Drift
  final database = AppDatabase();

  // Initialize native background audio capabilities
  final audioHandler = await initAudioService();

  runApp(
    ShekifyApp(
      database: database,
      audioHandler: audioHandler as ShekifyAudioHandler,
    ),
  );
}
