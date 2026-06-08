import 'package:flutter/material.dart';

class AppColors {
  // Pure dark backgrounds
  static const Color background = Color(0xFF09090B);
  static const Color backgroundSecondary = Color(0xFF121216);
  static const Color cardBackground = Color(0xFF18181F);
  static const Color backgroundCard = Color(0xFF18181F);

  // Brand colors (deep vibrant purples and indigos)
  static const Color primary = Color(0xFF8A2BE2); // BlueViolet
  static const Color primaryLight = Color(0xFFAB60F0);
  static const Color primaryDark = Color(0xFF5D1CA8);

  static const Color secondary = Color(0xFF4B0082); // Indigo
  static const Color secondaryDark = Color(0xFF2C0054);
  static const Color accent = Color(0xFFE0B0FF); // Mauve

  // Functional colors
  static const Color success = Color(0xFF10B981);
  static const Color error = Color(0xFFEF4444);
  static const Color warning = Color(0xFFF59E0B);

  // Text colors
  static const Color textPrimary = Color(0xFFF4F4F5);
  static const Color textSecondary = Color(0xFFA1A1AA);
  static const Color textMuted = Color(0xFF71717A);

  // Translucent border and glass overlays
  static final Color borderTranslucent = Colors.white.withValues(alpha: 0.08);
  static final Color glassOverlay = Colors.white.withValues(alpha: 0.05);
  static final Color glassOverlayActive = Colors.white.withValues(alpha: 0.12);
}
