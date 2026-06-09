import 'package:flutter/material.dart';
import 'app_colors.dart';

class AppTheme {
  // Typography tokens (from demo design)
  static const String fontSoraFamily = 'Sora';
  static const String fontPlusJakartaFamily = 'Plus Jakarta Sans';

  // Spacing tokens
  static const double spacingXs = 4.0;
  static const double spacingSm = 8.0;
  static const double spacingMd = 16.0;
  static const double spacingLg = 24.0;
  static const double spacingXl = 40.0;
  static const double spacingMarginMobile = 16.0;
  static const double spacingMarginDesktop = 32.0;

  static ThemeData get darkTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      colorScheme: ColorScheme.dark(
        primary: AppColors.primary,
        secondary: AppColors.secondary,
        tertiary: AppColors.tertiary,
        surface: AppColors.surface,
        surfaceContainer: AppColors.surfaceContainer,
        error: AppColors.error,
        onPrimary: AppColors.onPrimary,
        onSecondary: AppColors.onSecondary,
        onSurface: AppColors.textPrimary,
      ),
      scaffoldBackgroundColor: AppColors.background,
      appBarTheme: const AppBarTheme(
        backgroundColor: AppColors.surface,
        elevation: 0,
        centerTitle: false,
        titleTextStyle: TextStyle(
          color: AppColors.textPrimary,
          fontSize: 20,
          fontWeight: FontWeight.bold,
          fontFamily: fontSoraFamily,
        ),
      ),
      textTheme: const TextTheme(
        displayLarge: TextStyle(
          // display-lg: 48px, lineHeight 1.1, fontWeight 800
          color: AppColors.textPrimary,
          fontSize: 48,
          fontWeight: FontWeight.w800,
          fontFamily: fontSoraFamily,
          height: 1.1,
        ),
        displayMedium: TextStyle(
          // headline-lg: 32px, lineHeight 1.2, fontWeight 700
          color: AppColors.textPrimary,
          fontSize: 32,
          fontWeight: FontWeight.bold,
          fontFamily: fontSoraFamily,
          height: 1.2,
        ),
        displaySmall: TextStyle(
          // headline-lg-mobile: 28px, lineHeight 1.2, fontWeight 700
          color: AppColors.textPrimary,
          fontSize: 28,
          fontWeight: FontWeight.bold,
          fontFamily: fontSoraFamily,
          height: 1.2,
        ),
        headlineMedium: TextStyle(
          // title-md: 20px, lineHeight 1.4, fontWeight 600
          color: AppColors.textPrimary,
          fontSize: 20,
          fontWeight: FontWeight.w600,
          fontFamily: fontSoraFamily,
          height: 1.4,
        ),
        headlineSmall: TextStyle(
          // body-lg: 18px, lineHeight 1.6, fontWeight 400
          color: AppColors.textPrimary,
          fontSize: 18,
          fontWeight: FontWeight.w400,
          fontFamily: fontPlusJakartaFamily,
          height: 1.6,
        ),
        bodyLarge: TextStyle(
          // body-md: 16px, lineHeight 1.6, fontWeight 400
          color: AppColors.textPrimary,
          fontSize: 16,
          fontWeight: FontWeight.w400,
          fontFamily: fontPlusJakartaFamily,
          height: 1.6,
        ),
        bodyMedium: TextStyle(
          color: AppColors.textPrimary,
          fontSize: 14,
          fontFamily: fontPlusJakartaFamily,
        ),
        bodySmall: TextStyle(
          // label-sm: 12px, lineHeight 1, fontWeight 600, letterSpacing 0.05em
          color: AppColors.textSecondary,
          fontSize: 12,
          fontWeight: FontWeight.w600,
          fontFamily: fontPlusJakartaFamily,
          height: 1.0,
          letterSpacing: 0.05 * 12,
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: AppColors.surfaceContainerLowest,
        contentPadding: const EdgeInsets.symmetric(horizontal: spacingMd, vertical: spacingSm),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8.0),
          borderSide: const BorderSide(color: AppColors.outlineVariant),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8.0),
          borderSide: const BorderSide(color: AppColors.outlineVariant),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8.0),
          borderSide: const BorderSide(color: AppColors.primary, width: 2),
        ),
        labelStyle: const TextStyle(color: AppColors.textSecondary, fontFamily: fontPlusJakartaFamily),
        hintStyle: const TextStyle(color: AppColors.textMuted, fontFamily: fontPlusJakartaFamily),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primaryContainer,
          foregroundColor: AppColors.onPrimaryContainer,
          padding: const EdgeInsets.symmetric(horizontal: spacingMd, vertical: spacingMd),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8.0)),
          textStyle: const TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w600,
            fontFamily: fontSoraFamily,
          ),
        ),
      ),
      iconTheme: const IconThemeData(
        color: AppColors.textSecondary,
      ),
    );
  }
}
