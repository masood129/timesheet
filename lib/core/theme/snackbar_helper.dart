import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'theme.dart';

/// Helper class for showing themed snackbars
class ThemedSnackbar {
  static const _defaultDuration = Duration(seconds: 3);
  static const _defaultPadding =
      EdgeInsets.symmetric(horizontal: 18, vertical: 16);

  static void showSuccess(String title, String message) {
    final context = Get.context;
    if (context == null) return;

    final colorScheme = Theme.of(context).colorScheme;
    _showBase(
      title: title,
      message: message,
      accent: colorScheme.completedStatus,
      onAccent: colorScheme.onCompletedStatus,
      icon: Icons.check_circle,
      duration: _defaultDuration,
    );
  }

  static void showError(String title, String message) {
    final context = Get.context;
    if (context == null) return;

    final colorScheme = Theme.of(context).colorScheme;
    _showBase(
      title: title,
      message: message,
      accent: colorScheme.errorContainer,
      onAccent: colorScheme.onErrorContainer,
      icon: Icons.error_outline,
      duration: const Duration(seconds: 4),
    );
  }

  static void showInfo(String title, String message) {
    final context = Get.context;
    if (context == null) return;

    final colorScheme = Theme.of(context).colorScheme;
    _showBase(
      title: title,
      message: message,
      accent: colorScheme.primaryContainer,
      onAccent: colorScheme.onPrimaryContainer,
      icon: Icons.info_outline,
      duration: _defaultDuration,
    );
  }

  static void showWarning(String title, String message) {
    final context = Get.context;
    if (context == null) return;

    final colorScheme = Theme.of(context).colorScheme;
    _showBase(
      title: title,
      message: message,
      accent: colorScheme.incompleteStatus,
      onAccent: colorScheme.onIncompleteStatus,
      icon: Icons.warning_amber_rounded,
      duration: _defaultDuration,
    );
  }

  static void showCustom(
    String title,
    String message, {
    Color? backgroundColor,
    Color? textColor,
    IconData? icon,
    Duration? duration,
  }) {
    final context = Get.context;
    if (context == null) return;

    final colorScheme = Theme.of(context).colorScheme;
    _showBase(
      title: title,
      message: message,
      accent: backgroundColor ?? colorScheme.surfaceTint,
      onAccent: textColor ?? colorScheme.onSurface,
      icon: icon ?? Icons.notifications_outlined,
      duration: duration ?? _defaultDuration,
    );
  }

  static void _showBase({
    required String title,
    required String message,
    required Color accent,
    required Color onAccent,
    required IconData icon,
    required Duration duration,
  }) {
    final context = Get.context;
    if (context == null) return;

    final colorScheme = Theme.of(context).colorScheme;
    final surfaceTint = colorScheme.surface;
    final glassColor = surfaceTint.withValues(alpha: 0.22);
    final borderColor = accent.withValues(alpha: 0.28);
    final accentOverlay = accent.withValues(alpha: 0.03);

    Get.rawSnackbar(
      snackPosition: SnackPosition.BOTTOM,
      snackStyle: SnackStyle.FLOATING,
      backgroundColor: Colors.transparent,
      margin: const EdgeInsets.all(16),
      padding: EdgeInsets.zero,
      borderRadius: 18,
      isDismissible: true,
      dismissDirection: DismissDirection.horizontal,
      duration: duration,
      forwardAnimationCurve: Curves.fastOutSlowIn,
      reverseAnimationCurve: Curves.easeInCubic,
      animationDuration: const Duration(milliseconds: 260),
      messageText: ClipRRect(
        borderRadius: BorderRadius.circular(18),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 22, sigmaY: 22),
          child: DecoratedBox(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(18),
              border: Border.all(color: borderColor, width: 0.9),
              color: glassColor,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.18),
                  blurRadius: 26,
                  offset: const Offset(0, 14),
                ),
              ],
            ),
            child: Stack(
              children: [
                Positioned.fill(
                  child: DecoratedBox(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(18),
                      gradient: LinearGradient(
                        colors: [
                          Colors.white.withValues(alpha: 0.02),
                          accentOverlay,
                        ],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                    ),
                  ),
                ),
                Padding(
                  padding: _defaultPadding,
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        width: 38,
                        height: 38,
                        decoration: BoxDecoration(
                          color: accent.withValues(alpha: 0.18),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Icon(icon, color: onAccent),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              title,
                              style: TextStyle(
                                fontFamily: 'BNazanin',
                                fontSize: 16,
                                fontWeight: FontWeight.w700,
                                color: onAccent,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              message,
                              style: TextStyle(
                                fontFamily: 'BNazanin',
                                fontSize: 14,
                                fontWeight: FontWeight.w500,
                                color: onAccent.withValues(alpha: 0.9),
                              ),
                              maxLines: 3,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

