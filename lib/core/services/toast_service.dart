import 'dart:async';
import 'package:flutter/material.dart';
import '../theme/app_colors.dart';

final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

enum ToastType { success, error, info }

class ToastService {
  static void show({
    required String message,
    String? title,
    ToastType type = ToastType.info,
    Duration duration = const Duration(seconds: 4),
  }) {
    final overlayState = navigatorKey.currentState?.overlay;
    if (overlayState == null) return;

    late OverlayEntry overlayEntry;

    overlayEntry = OverlayEntry(
      builder: (context) => _ToastWidget(
        title: title,
        message: message,
        type: type,
        duration: duration,
        onClose: () {
          overlayEntry.remove();
        },
      ),
    );

    overlayState.insert(overlayEntry);

    // Auto dismiss after duration
    Timer(duration, () {
      try {
        overlayEntry.remove();
      } catch (_) {
        // Already dismissed
      }
    });
  }

  static void showError(String message, {String? title}) {
    show(message: message, title: title ?? 'Error', type: ToastType.error);
  }

  static void showSuccess(String message, {String? title}) {
    show(message: message, title: title ?? 'Success', type: ToastType.success);
  }

  static void showInfo(String message, {String? title}) {
    show(message: message, title: title ?? 'Info', type: ToastType.info);
  }
}

class _ToastWidget extends StatefulWidget {
  final String? title;
  final String message;
  final ToastType type;
  final Duration duration;
  final VoidCallback onClose;

  const _ToastWidget({
    this.title,
    required this.message,
    required this.type,
    required this.duration,
    required this.onClose,
  });

  @override
  State<_ToastWidget> createState() => _ToastWidgetState();
}

class _ToastWidgetState extends State<_ToastWidget>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;
  bool _isDismissing = false;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 350),
    );

    _fadeAnimation = CurvedAnimation(
      parent: _controller,
      curve: Curves.easeOut,
    );
    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, -1.2),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.bounceOut));

    _controller.forward();

    // Schedule dismiss animation
    Future.delayed(widget.duration - const Duration(milliseconds: 350), () {
      if (mounted && !_isDismissing) {
        _dismiss();
      }
    });
  }

  void _dismiss() {
    if (_isDismissing) return;
    setState(() {
      _isDismissing = true;
    });
    _controller.reverse().then((_) {
      widget.onClose();
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    Color primaryColor;
    IconData icon;

    switch (widget.type) {
      case ToastType.success:
        primaryColor = Colors.green;
        icon = Icons.check_circle_outline;
        break;
      case ToastType.error:
        primaryColor = Colors.red;
        icon = Icons.error_outline;
        break;
      case ToastType.info:
        primaryColor = AppColors.primary;
        icon = Icons.info_outline;
        break;
    }

    return SafeArea(
      child: Align(
        alignment: Alignment.topCenter,
        child: Padding(
          padding: const EdgeInsets.only(top: 16.0, left: 16.0, right: 16.0),
          child: SlideTransition(
            position: _slideAnimation,
            child: FadeTransition(
              opacity: _fadeAnimation,
              child: Material(
                color: Colors.transparent,
                child: Container(
                  width: double.infinity,
                  constraints: const BoxConstraints(maxWidth: 400),
                  decoration: BoxDecoration(
                    color: Colors.black.withValues(alpha: 0.85),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: primaryColor.withValues(alpha: 0.3),
                      width: 1.5,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: primaryColor.withValues(alpha: 0.12),
                        blurRadius: 12,
                        spreadRadius: 2,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Padding(
                          padding: const EdgeInsets.all(14.0),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Icon(icon, color: primaryColor, size: 22),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    if (widget.title != null) ...[
                                      Text(
                                        widget.title!,
                                        style: const TextStyle(
                                          color: Colors.white,
                                          fontWeight: FontWeight.bold,
                                          fontSize: 14,
                                        ),
                                      ),
                                      const SizedBox(height: 3),
                                    ],
                                    Text(
                                      widget.message,
                                      style: TextStyle(
                                        color: Colors.white.withValues(alpha: 0.85),
                                        fontSize: 12.5,
                                        height: 1.25,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(width: 8),
                              GestureDetector(
                                onTap: _dismiss,
                                child: Padding(
                                  padding: const EdgeInsets.all(2.0),
                                  child: Icon(
                                    Icons.close,
                                    color: Colors.white.withValues(alpha: 0.4),
                                    size: 16,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        _ToastTimerProgress(
                          duration: widget.duration,
                          color: primaryColor,
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _ToastTimerProgress extends StatefulWidget {
  final Duration duration;
  final Color color;

  const _ToastTimerProgress({required this.duration, required this.color});

  @override
  State<_ToastTimerProgress> createState() => _ToastTimerProgressState();
}

class _ToastTimerProgressState extends State<_ToastTimerProgress>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this, duration: widget.duration);
    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return Container(
          height: 2.5,
          width: double.infinity,
          alignment: Alignment.centerLeft,
          color: Colors.white.withValues(alpha: 0.04),
          child: FractionallySizedBox(
            widthFactor: 1.0 - _controller.value,
            child: Container(color: widget.color),
          ),
        );
      },
    );
  }
}
