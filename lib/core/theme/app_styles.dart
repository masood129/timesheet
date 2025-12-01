import 'package:flutter/material.dart';
import 'package:get/get.dart';

class AppStyles {
  static InputDecoration inputDecoration(
      BuildContext context,
      String labelKey,
      IconData icon,
      bool isEnabled, {
      bool hasError = false,
      String? errorText,
      }) {
    final colorScheme = Theme.of(context).colorScheme;
    final disabledColor = Theme.of(context).disabledColor; // استفاده از disabledColor
    final errorColor = colorScheme.error;
    
    return InputDecoration(
      labelText: labelKey.tr,
      errorText: hasError ? errorText : null,
      prefixIcon: Icon(
        icon,
        color: hasError ? errorColor : (isEnabled ? colorScheme.primary : disabledColor),
      ),
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(
          color: hasError ? errorColor : colorScheme.outline,
          width: hasError ? 2.0 : 1.0,
        ),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(
          color: hasError ? errorColor : colorScheme.primary,
          width: 2.0,
        ),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(
          color: errorColor,
          width: 2.0,
        ),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(
          color: errorColor,
          width: 2.0,
        ),
      ),
      contentPadding: const EdgeInsets.all(20),
      filled: true,
      fillColor: isEnabled ? colorScheme.surface : disabledColor.withValues(alpha: 0.3),
      labelStyle: TextStyle(
        color: hasError ? errorColor : (isEnabled ? colorScheme.onSurface : disabledColor),
      ),
      hintStyle: TextStyle(
        color: disabledColor,
      ),
    );
  }
}