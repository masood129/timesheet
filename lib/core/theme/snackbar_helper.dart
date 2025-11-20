import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'theme.dart';

/// Helper class for showing themed snackbars
class ThemedSnackbar {
  /// Shows a success snackbar with green theme
  static void showSuccess(String title, String message) {
    final context = Get.context;
    if (context == null) return;
    
    final colorScheme = Theme.of(context).colorScheme;
    
    Get.snackbar(
      title,
      message,
      backgroundColor: colorScheme.completedStatus,
      colorText: colorScheme.onCompletedStatus,
      icon: Icon(
        Icons.check_circle,
        color: colorScheme.onCompletedStatus,
      ),
      snackPosition: SnackPosition.BOTTOM,
      margin: const EdgeInsets.all(16),
      borderRadius: 12,
      duration: const Duration(seconds: 3),
      isDismissible: true,
      dismissDirection: DismissDirection.horizontal,
      forwardAnimationCurve: Curves.easeOutBack,
      reverseAnimationCurve: Curves.easeInBack,
      animationDuration: const Duration(milliseconds: 300),
      titleText: Text(
        title,
        style: TextStyle(
          fontFamily: 'BNazanin',
          color: colorScheme.onCompletedStatus,
          fontSize: 16,
          fontWeight: FontWeight.bold,
        ),
      ),
      messageText: Text(
        message,
        style: TextStyle(
          fontFamily: 'BNazanin',
          color: colorScheme.onCompletedStatus,
          fontSize: 14,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }

  /// Shows an error snackbar with red theme
  static void showError(String title, String message) {
    final context = Get.context;
    if (context == null) return;
    
    final colorScheme = Theme.of(context).colorScheme;
    
    Get.snackbar(
      title,
      message,
      backgroundColor: colorScheme.errorContainer,
      colorText: colorScheme.onErrorContainer,
      icon: Icon(
        Icons.error_outline,
        color: colorScheme.onErrorContainer,
      ),
      snackPosition: SnackPosition.BOTTOM,
      margin: const EdgeInsets.all(16),
      borderRadius: 12,
      duration: const Duration(seconds: 4),
      isDismissible: true,
      dismissDirection: DismissDirection.horizontal,
      forwardAnimationCurve: Curves.easeOutBack,
      reverseAnimationCurve: Curves.easeInBack,
      animationDuration: const Duration(milliseconds: 300),
      titleText: Text(
        title,
        style: TextStyle(
          fontFamily: 'BNazanin',
          color: colorScheme.onErrorContainer,
          fontSize: 16,
          fontWeight: FontWeight.bold,
        ),
      ),
      messageText: Text(
        message,
        style: TextStyle(
          fontFamily: 'BNazanin',
          color: colorScheme.onErrorContainer,
          fontSize: 14,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }

  /// Shows an info snackbar with primary theme
  static void showInfo(String title, String message) {
    final context = Get.context;
    if (context == null) return;
    
    final colorScheme = Theme.of(context).colorScheme;
    
    Get.snackbar(
      title,
      message,
      backgroundColor: colorScheme.primaryContainer,
      colorText: colorScheme.onPrimaryContainer,
      icon: Icon(
        Icons.info_outline,
        color: colorScheme.onPrimaryContainer,
      ),
      snackPosition: SnackPosition.BOTTOM,
      margin: const EdgeInsets.all(16),
      borderRadius: 12,
      duration: const Duration(seconds: 3),
      isDismissible: true,
      dismissDirection: DismissDirection.horizontal,
      forwardAnimationCurve: Curves.easeOutBack,
      reverseAnimationCurve: Curves.easeInBack,
      animationDuration: const Duration(milliseconds: 300),
      titleText: Text(
        title,
        style: TextStyle(
          fontFamily: 'BNazanin',
          color: colorScheme.onPrimaryContainer,
          fontSize: 16,
          fontWeight: FontWeight.bold,
        ),
      ),
      messageText: Text(
        message,
        style: TextStyle(
          fontFamily: 'BNazanin',
          color: colorScheme.onPrimaryContainer,
          fontSize: 14,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }

  /// Shows a warning snackbar with orange/amber theme
  static void showWarning(String title, String message) {
    final context = Get.context;
    if (context == null) return;
    
    final colorScheme = Theme.of(context).colorScheme;
    
    Get.snackbar(
      title,
      message,
      backgroundColor: colorScheme.incompleteStatus,
      colorText: colorScheme.onIncompleteStatus,
      icon: Icon(
        Icons.warning_amber_rounded,
        color: colorScheme.onIncompleteStatus,
      ),
      snackPosition: SnackPosition.BOTTOM,
      margin: const EdgeInsets.all(16),
      borderRadius: 12,
      duration: const Duration(seconds: 3),
      isDismissible: true,
      dismissDirection: DismissDirection.horizontal,
      forwardAnimationCurve: Curves.easeOutBack,
      reverseAnimationCurve: Curves.easeInBack,
      animationDuration: const Duration(milliseconds: 300),
      titleText: Text(
        title,
        style: TextStyle(
          fontFamily: 'BNazanin',
          color: colorScheme.onIncompleteStatus,
          fontSize: 16,
          fontWeight: FontWeight.bold,
        ),
      ),
      messageText: Text(
        message,
        style: TextStyle(
          fontFamily: 'BNazanin',
          color: colorScheme.onIncompleteStatus,
          fontSize: 14,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }

  /// Shows a custom snackbar with specified background color
  static void showCustom(
    String title,
    String message, {
    Color? backgroundColor,
    Color? textColor,
    IconData? icon,
  }) {
    final context = Get.context;
    if (context == null) return;
    
    final colorScheme = Theme.of(context).colorScheme;
    final bgColor = backgroundColor ?? colorScheme.surfaceContainerHighest;
    final txtColor = textColor ?? colorScheme.onSurface;
    final snackIcon = icon ?? Icons.notifications_outlined;
    
    Get.snackbar(
      title,
      message,
      backgroundColor: bgColor,
      colorText: txtColor,
      icon: Icon(
        snackIcon,
        color: txtColor,
      ),
      snackPosition: SnackPosition.BOTTOM,
      margin: const EdgeInsets.all(16),
      borderRadius: 12,
      duration: const Duration(seconds: 3),
      isDismissible: true,
      dismissDirection: DismissDirection.horizontal,
      forwardAnimationCurve: Curves.easeOutBack,
      reverseAnimationCurve: Curves.easeInBack,
      animationDuration: const Duration(milliseconds: 300),
      titleText: Text(
        title,
        style: TextStyle(
          fontFamily: 'BNazanin',
          color: txtColor,
          fontSize: 16,
          fontWeight: FontWeight.bold,
        ),
      ),
      messageText: Text(
        message,
        style: TextStyle(
          fontFamily: 'BNazanin',
          color: txtColor,
          fontSize: 14,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }
}

