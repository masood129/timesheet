import 'package:flutter/material.dart';
import 'package:get/get.dart';

class ThemeController extends GetxController {
  var isDark = false.obs;

  ThemeMode get theme => isDark.value ? ThemeMode.dark : ThemeMode.light;

  void toggleTheme(bool value) {
    isDark.value = value;
    Get.changeThemeMode(theme);
  }
}

// Helper function to apply opacity
Color _applyOpacity(Color color, double opacity) {
  return Color.fromARGB(
    (opacity * 255).round(),
    (color.r * 255.0).round() & 0xff,
    (color.g * 255.0).round() & 0xff,
    (color.b * 255.0).round() & 0xff,
  );
}

// --- Light Theme ---
final ColorScheme _lightColorScheme = ColorScheme.fromSeed(
  seedColor: const Color(0xFF26A69A), // Teal 400 - رنگ اصلی سبزآبی ملایم
  brightness: Brightness.light,
).copyWith(
  primary: const Color(0xFF00796B), // Teal 700 - رنگ اصلی تیره‌تر برای تاکید
  onPrimary: Colors.white,
  primaryContainer: const Color(0xFFB2DFDB), // Teal 100
  onPrimaryContainer: const Color(0xFF004D40), // Teal 900
  secondary: const Color(0xFF4DB6AC), // Teal 300
  onSecondary: Colors.black,
  secondaryContainer: const Color(0xFF80CBC4), // Teal 200
  onSecondaryContainer: const Color(0xFF004D40),
  tertiary: const Color(0xFF29B6F6), // Light Blue A400
  onTertiary: Colors.black,
  tertiaryContainer: const Color(0xFFB3E5FC), // Light Blue 100
  onTertiaryContainer: const Color(0xFF01579B),
  error: const Color(0xFFE57373), // Red 300
  onError: Colors.black,
  errorContainer: const Color(0xFFFFCDD2), // Red 100
  onErrorContainer: const Color(0xFFB71C1C),
  surface: Colors.white,
  onSurface: const Color(0xFF1A1A1A),
  surfaceContainerHighest: const Color(0xFFF0F4F8),
  onSurfaceVariant: const Color(0xFF4A4A4A),
  outline: const Color(0xFFB0BEC5), // Blue Grey 200
  outlineVariant: const Color(0xFFCFD8DC), // Blue Grey 100
);

// --- Dark Theme ---
final ColorScheme _darkColorScheme = ColorScheme.fromSeed(
  seedColor: const Color(0xFF1A2A29), // یک سبز بسیار تیره برای پایه تم دارک
  brightness: Brightness.dark,
).copyWith(
  primary: const Color(0xFF4DB6AC), // Teal 300
  onPrimary: Colors.black,
  primaryContainer: const Color(0xFF00695C), // Teal 800
  onPrimaryContainer: const Color(0xFFB2DFDB),
  secondary: const Color(0xFF80CBC4), // Teal 200
  onSecondary: Colors.black,
  secondaryContainer: const Color(0xFF004D40), // Teal 900
  onSecondaryContainer: const Color(0xFFB2DFDB),
  tertiary: const Color(0xFF4FC3F7), // Light Blue A200
  onTertiary: Colors.black,
  tertiaryContainer: const Color(0xFF0277BD), // Light Blue 800
  onTertiaryContainer: const Color(0xFFE1F5FE),
  error: const Color(0xFFEF9A9A), // Red 200
  onError: Colors.black,
  errorContainer: const Color(0xFFC62828), // Red 800
  onErrorContainer: const Color(0xFFFFEBEE),
  surface: const Color(0xFF1E1E1E),
  onSurface: const Color(0xFFE0E0E0),
  surfaceContainerHighest: const Color(0xFF2C2C2C),
  onSurfaceVariant: const Color(0xFFA0A0A0),
  outline: const Color(0xFF546E7A), // Blue Grey 500
  outlineVariant: const Color(0xFF455A64), // Blue Grey 600
);

// --- Custom Colors Extension ---
const Color _lightCompletedStatusColor = Color(0xFF6CDF4B); // سبز فسفری ملایم روشن
const Color _onLightCompletedStatusColor = Colors.black;
const Color _lightIncompleteStatusColor = Color(0xFFFFB300); // Amber 600 - زرد پررنگ
const Color _onLightIncompleteStatusColor = Colors.black;
const Color _lightNoDataStatusColor = Color(0xFF78909C); // Blue Grey 400 - خاکستری آبی پررنگ
const Color _onLightNoDataStatusColor = Colors.white;

const Color _darkCompletedStatusColor = Color(0xFF69F0AE); // سبز فسفری ملایم برای تم تیره
const Color _onDarkCompletedStatusColor = Colors.black;
const Color _darkIncompleteStatusColor = Color(0xFFFFCA28); // Amber 400 - زرد پررنگ
const Color _onDarkIncompleteStatusColor = Colors.black;
const Color _darkNoDataStatusColor = Color(0xFF90A4AE); // Blue Grey 300 - خاکستری آبی پررنگ
const Color _onDarkNoDataStatusColor = Colors.black;

extension CustomColorSchemeExtension on ColorScheme {
  Color get completedStatus {
    return brightness == Brightness.light
        ? _lightCompletedStatusColor
        : _darkCompletedStatusColor;
  }

  Color get onCompletedStatus {
    return brightness == Brightness.light
        ? _onLightCompletedStatusColor
        : _onDarkCompletedStatusColor;
  }

  Color get incompleteStatus {
    return brightness == Brightness.light
        ? _lightIncompleteStatusColor
        : _darkIncompleteStatusColor;
  }

  Color get onIncompleteStatus {
    return brightness == Brightness.light
        ? _onLightIncompleteStatusColor
        : _onDarkIncompleteStatusColor;
  }

  Color get noDataStatus {
    return brightness == Brightness.light
        ? _lightNoDataStatusColor
        : _darkNoDataStatusColor;
  }

  Color get onNoDataStatus {
    return brightness == Brightness.light
        ? _onLightNoDataStatusColor
        : _onDarkNoDataStatusColor;
  }
}

// --- ThemeData Definitions ---
ThemeData mainTheme = ThemeData(
  fontFamily: 'BNazanin',
  useMaterial3: true,
  colorScheme: _lightColorScheme,
  brightness: Brightness.light,
  disabledColor: _applyOpacity(_lightColorScheme.outline, 0.7),
  scaffoldBackgroundColor: const Color(0xFFECEFF1), // Blue Grey 50
  appBarTheme: AppBarTheme(
    backgroundColor: _lightColorScheme.primary,
    foregroundColor: _lightColorScheme.onPrimary,
    elevation: 1,
    titleTextStyle: TextStyle(
      fontFamily: 'BNazanin',
      color: _lightColorScheme.onPrimary,
      fontSize: 20,
      fontWeight: FontWeight.w600,
    ),
  ),
  cardTheme: CardThemeData(
    color: _lightColorScheme.surface,
    elevation: 2,
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
    margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
  ),
  inputDecorationTheme: InputDecorationTheme(
    filled: true,
    fillColor: _lightColorScheme.surfaceContainerHighest,
    contentPadding: const EdgeInsets.symmetric(vertical: 14, horizontal: 16),
    border: OutlineInputBorder(
      borderRadius: BorderRadius.circular(10),
      borderSide: BorderSide(color: _lightColorScheme.outline),
    ),
    enabledBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(10),
      borderSide: BorderSide(color: _lightColorScheme.outline),
    ),
    focusedBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(10),
      borderSide: BorderSide(color: _lightColorScheme.primary, width: 2),
    ),
    labelStyle: TextStyle(
        color: _lightColorScheme.onSurfaceVariant,
        fontWeight: FontWeight.w500),
    hintStyle:
    TextStyle(color: _applyOpacity(_lightColorScheme.onSurfaceVariant, 0.7)),
    errorStyle: TextStyle(color: _lightColorScheme.error),
  ),
  textTheme: const TextTheme().apply(
    bodyColor: _lightColorScheme.onSurface,
    displayColor: _lightColorScheme.onSurface,
    fontFamily: 'BNazanin',
  ).copyWith(
    titleLarge:
    TextStyle(color: _lightColorScheme.primary, fontWeight: FontWeight.bold),
    bodyMedium:
    TextStyle(color: _applyOpacity(_lightColorScheme.onSurface, 0.85)),
  ),
  elevatedButtonTheme: ElevatedButtonThemeData(
    style: ElevatedButton.styleFrom(
      backgroundColor: _lightColorScheme.primary,
      foregroundColor: _lightColorScheme.onPrimary,
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 20),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      textStyle: const TextStyle(
          fontFamily: 'BNazanin', fontSize: 16, fontWeight: FontWeight.w600),
    ),
  ),
  textButtonTheme: TextButtonThemeData(
    style: TextButton.styleFrom(
      foregroundColor: _lightColorScheme.primary,
      textStyle:
      const TextStyle(fontFamily: 'BNazanin', fontWeight: FontWeight.w600),
    ),
  ),
  dividerTheme: DividerThemeData(
    color: _lightColorScheme.outlineVariant,
    thickness: 1,
  ),
  iconTheme: IconThemeData(
    color: _lightColorScheme.primary,
  ),
  listTileTheme: ListTileThemeData(
    iconColor: _lightColorScheme.secondary,
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
  ),
  switchTheme: SwitchThemeData(
    thumbColor: WidgetStateProperty.resolveWith((states) =>
    states.contains(WidgetState.selected)
        ? _lightColorScheme.primary
        : _lightColorScheme.outline),
    trackColor: WidgetStateProperty.resolveWith((states) {
      if (states.contains(WidgetState.selected)) {
        return _applyOpacity(_lightColorScheme.primary, 0.5);
      }
      return _applyOpacity(_lightColorScheme.outline, 0.3);
    }),
    trackOutlineColor:
    WidgetStateProperty.resolveWith((states) => Colors.transparent),
  ),
  snackBarTheme: SnackBarThemeData(
    backgroundColor: _lightColorScheme.surfaceContainerHighest,
    contentTextStyle: TextStyle(
      fontFamily: 'BNazanin',
      color: _lightColorScheme.onSurface,
      fontSize: 14,
      fontWeight: FontWeight.w500,
    ),
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(12),
    ),
    behavior: SnackBarBehavior.floating,
    elevation: 4,
    actionTextColor: _lightColorScheme.primary,
  ),
);

ThemeData darkTheme = ThemeData(
  fontFamily: 'BNazanin',
  useMaterial3: true,
  colorScheme: _darkColorScheme,
  brightness: Brightness.dark,
  disabledColor: _applyOpacity(_darkColorScheme.outline, 0.7),
  scaffoldBackgroundColor: const Color(0xFF121212),
  appBarTheme: AppBarTheme(
    backgroundColor: _darkColorScheme.surface,
    foregroundColor: _darkColorScheme.onSurface,
    elevation: 1,
    titleTextStyle: TextStyle(
      fontFamily: 'BNazanin',
      color: _darkColorScheme.onSurface,
      fontSize: 20,
      fontWeight: FontWeight.w600,
    ),
  ),
  cardTheme: CardThemeData(
    color: _darkColorScheme.surfaceContainerHighest,
    elevation: 2,
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
    margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
  ),
  inputDecorationTheme: InputDecorationTheme(
    filled: true,
    fillColor: _darkColorScheme.surfaceContainerHighest,
    contentPadding: const EdgeInsets.symmetric(vertical: 14, horizontal: 16),
    border: OutlineInputBorder(
      borderRadius: BorderRadius.circular(10),
      borderSide: BorderSide(color: _darkColorScheme.outline),
    ),
    enabledBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(10),
      borderSide: BorderSide(color: _darkColorScheme.outline),
    ),
    focusedBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(10),
      borderSide: BorderSide(color: _darkColorScheme.primary, width: 2),
    ),
    labelStyle: TextStyle(
        color: _darkColorScheme.onSurfaceVariant, fontWeight: FontWeight.w500),
    hintStyle:
    TextStyle(color: _applyOpacity(_darkColorScheme.onSurfaceVariant, 0.7)),
    errorStyle: TextStyle(color: _darkColorScheme.error),
  ),
  textTheme: const TextTheme().apply(
    bodyColor: _darkColorScheme.onSurface,
    displayColor: _darkColorScheme.onSurface,
    fontFamily: 'BNazanin',
  ).copyWith(
    titleLarge:
    TextStyle(color: _darkColorScheme.primary, fontWeight: FontWeight.bold),
    bodyMedium:
    TextStyle(color: _applyOpacity(_darkColorScheme.onSurface, 0.85)),
  ),
  elevatedButtonTheme: ElevatedButtonThemeData(
    style: ElevatedButton.styleFrom(
      backgroundColor: _darkColorScheme.primary,
      foregroundColor: _darkColorScheme.onPrimary,
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 20),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      textStyle: const TextStyle(
          fontFamily: 'BNazanin', fontSize: 16, fontWeight: FontWeight.w600),
    ),
  ),
  textButtonTheme: TextButtonThemeData(
    style: TextButton.styleFrom(
      foregroundColor: _darkColorScheme.primary,
      textStyle:
      const TextStyle(fontFamily: 'BNazanin', fontWeight: FontWeight.w600),
    ),
  ),
  dividerTheme: DividerThemeData(
    color: _darkColorScheme.outlineVariant,
    thickness: 1,
  ),
  iconTheme: IconThemeData(
    color: _darkColorScheme.primary,
  ),
  listTileTheme: ListTileThemeData(
    iconColor: _darkColorScheme.secondary,
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
  ),
  switchTheme: SwitchThemeData(
    thumbColor: WidgetStateProperty.resolveWith((states) =>
    states.contains(WidgetState.selected)
        ? _darkColorScheme.primary
        : _darkColorScheme.outline),
    trackColor: WidgetStateProperty.resolveWith((states) {
      if (states.contains(WidgetState.selected)) {
        return _applyOpacity(_darkColorScheme.primary, 0.5);
      }
      return _applyOpacity(_darkColorScheme.outline, 0.3);
    }),
    trackOutlineColor:
    WidgetStateProperty.resolveWith((states) => Colors.transparent),
  ),
  snackBarTheme: SnackBarThemeData(
    backgroundColor: _darkColorScheme.surfaceContainerHighest,
    contentTextStyle: TextStyle(
      fontFamily: 'BNazanin',
      color: _darkColorScheme.onSurface,
      fontSize: 14,
      fontWeight: FontWeight.w500,
    ),
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(12),
    ),
    behavior: SnackBarBehavior.floating,
    elevation: 4,
    actionTextColor: _darkColorScheme.primary,
  ),
);