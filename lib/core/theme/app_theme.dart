import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'app_colors.dart';

class AppTheme {
  static ThemeData get darkTheme {
    return ThemeData(
      brightness: Brightness.dark,
      primaryColor: AppColors.primary,
      scaffoldBackgroundColor: AppColors.background,
      colorScheme: const ColorScheme.dark(
        primary: AppColors.primary,
        secondary: AppColors.secondary,
        surface: AppColors.backgroundSecondary,
        error: AppColors.error,
      ),
      textTheme: GoogleFonts.outfitTextTheme(ThemeData.dark().textTheme)
          .copyWith(
            bodyLarge: const TextStyle(color: AppColors.textPrimary),
            bodyMedium: const TextStyle(color: AppColors.textSecondary),
          ),
      appBarTheme: const AppBarTheme(
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        iconTheme: IconThemeData(color: AppColors.textPrimary),
      ),
      cardTheme: CardThemeData(
        color: AppColors.cardBackground,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: BorderSide(color: AppColors.borderTranslucent, width: 1),
        ),
      ),
      sliderTheme: SliderThemeData(
        activeTrackColor: AppColors.primary,
        inactiveTrackColor: Colors.white24,
        thumbColor: AppColors.primary,
        overlayColor: AppColors.primary.withValues(alpha: 0.2),
        trackHeight: 4,
      ),
    );
  }
}

class AppDecorations {
  static final glassPanel = BoxDecoration(
    color: AppColors.backgroundSecondary.withValues(alpha: 0.65),
    borderRadius: BorderRadius.circular(20),
    border: Border.all(color: AppColors.borderTranslucent, width: 1),
  );

  static final glassCard = BoxDecoration(
    color: Colors.white.withValues(alpha: 0.04),
    borderRadius: BorderRadius.circular(16),
    border: Border.all(color: AppColors.borderTranslucent, width: 0.8),
  );
}

class PremiumGlassContainer extends StatelessWidget {
  final Widget child;
  final double blurX;
  final double blurY;
  final BorderRadius? borderRadius;
  final EdgeInsetsGeometry? padding;
  final BoxDecoration? decoration;

  const PremiumGlassContainer({
    super.key,
    required this.child,
    this.blurX = 15,
    this.blurY = 15,
    this.borderRadius,
    this.padding,
    this.decoration,
  });

  @override
  Widget build(BuildContext context) {
    final defaultBorderRadius = borderRadius ?? BorderRadius.circular(20);
    return ClipRRect(
      borderRadius: defaultBorderRadius,
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: blurX, sigmaY: blurY),
        child: Container(
          padding: padding,
          decoration:
              decoration ??
              AppDecorations.glassPanel.copyWith(
                borderRadius: defaultBorderRadius,
              ),
          child: child,
        ),
      ),
    );
  }
}
