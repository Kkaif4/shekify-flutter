import 'package:flutter/material.dart';

class AppColors {
  // Primary Colors (from demo design)
  static const Color primary = Color(0xFFC1C1FF); // Light purple-ish blue
  static const Color primaryContainer = Color(0xFF5F5FEE); // Deeper purple
  static const Color primaryFixed = Color(0xFFE1DFFF);
  static const Color onPrimary = Color(0xFF1500A8);
  static const Color onPrimaryContainer = Color(0xFFFBF7FF);
  static const Color inversePrimary = Color(0xFF4A49D9);

  // Secondary Colors
  static const Color secondary = Color(0xFFC7C5D3);
  static const Color secondaryContainer = Color(0xFF494854);
  static const Color secondaryFixed = Color(0xFFE4E1EF);
  static const Color onSecondary = Color(0xFF302F3A);
  static const Color onSecondaryContainer = Color(0xFFB9B7C5);

  // Tertiary Colors (Accent - Cyan)
  static const Color tertiary = Color(0xFF00DCE5); // Bright cyan
  static const Color tertiaryContainer = Color(0xFF007F84);
  static const Color tertiaryFixed = Color(0xFF63F7FF);
  static const Color onTertiary = Color(0xFF003739);
  static const Color onTertiaryContainer = Color(0xFFE3FEFF);

  // Surface Colors
  static const Color background = Color(0xFF0A0B14); // Very dark blue
  static const Color surface = Color(0xFF0F102D); // Dark blue-ish
  static const Color surfaceContainer = Color(0xFF1C1D3A);
  static const Color surfaceContainerLow = Color(0xFF181936);
  static const Color surfaceContainerLowest = Color(0xFF0A0B28);
  static const Color surfaceContainerHigh = Color(0xFF262745);
  static const Color surfaceContainerHighest = Color(0xFF313250);
  static const Color surfaceDim = Color(0xFF0F102D);
  static const Color surfaceBright = Color(0xFF353655);
  static const Color surfaceVariant = Color(0xFF313250);
  static const Color backgroundCard = Color(0xFF1C1D3A);
  static const Color backgroundSecondary = Color(0xFF181936);

  // Text Colors
  static const Color textPrimary = Color(0xFFE1E0FF); // On-surface
  static const Color textSecondary = Color(0xFFC7C4D7); // On-surface-variant
  static const Color textMuted = Color(0xFF908FA0); // Outline

  // Other Colors
  static const Color outline = Color(0xFF908FA0);
  static const Color outlineVariant = Color(0xFF464555);
  static const Color error = Color(0xFFFFB4AB);
  static const Color errorContainer = Color(0xFF93000A);
  static const Color onError = Color(0xFF690005);

  // Border & Accents
  static const Color borderTranslucent = Color(0x0DFFFFFF); // 5% opacity white
  static const Color secondaryDark = Color(0xFF0A0B28);

  // Legacy/Compat
  static const Color accent = tertiary;
}
