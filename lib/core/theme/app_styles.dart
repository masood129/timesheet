import 'package:flutter/material.dart';
import 'package:get/get.dart';

class AppStyles {
  static InputDecoration inputDecoration(
      BuildContext context,
      String labelKey,
      IconData icon,
      bool isEnabled,
      ) {
    final colorScheme = Theme.of(context).colorScheme;
    final disabledColor = Theme.of(context).disabledColor; // استفاده از disabledColor
    return InputDecoration(
      labelText: labelKey.tr,
      prefixIcon: Icon(
        icon,
        color: isEnabled ? colorScheme.primary : disabledColor,
      ),
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
      contentPadding: const EdgeInsets.symmetric(vertical: 10, horizontal: 12),
      filled: true,
      fillColor: isEnabled ? colorScheme.surface : disabledColor.withOpacity(0.3),
      labelStyle: TextStyle(
        color: isEnabled ? colorScheme.onSurface : disabledColor,
      ),
      hintStyle: TextStyle(
        color: disabledColor,
      ),
    );
  }
}