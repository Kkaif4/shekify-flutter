import 'package:audio_video_progress_bar/audio_video_progress_bar.dart';
import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';

class PremiumSlider extends StatelessWidget {
  final Duration position;
  final Duration bufferedPosition;
  final Duration duration;
  final ValueChanged<Duration> onSeek;

  const PremiumSlider({
    super.key,
    required this.position,
    required this.bufferedPosition,
    required this.duration,
    required this.onSeek,
  });

  @override
  Widget build(BuildContext context) {
    return ProgressBar(
      progress: position,
      buffered: bufferedPosition,
      total: duration,
      onSeek: onSeek,
      barHeight: 4.0,
      baseBarColor: Colors.white.withValues(alpha: 0.08),
      bufferedBarColor: Colors.white.withValues(alpha: 0.18),
      progressBarColor: AppColors.primary,
      thumbColor: AppColors.accent,
      thumbRadius: 6.0,
      timeLabelTextStyle: const TextStyle(
        color: AppColors.textSecondary,
        fontSize: 12,
        fontWeight: FontWeight.w500,
      ),
      timeLabelPadding: 8.0,
    );
  }
}
