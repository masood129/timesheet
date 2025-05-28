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
    color.red,
    color.green,
    color.blue,
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
  background: const Color(0xFFECEFF1), // Blue Grey 50 - رنگ پس‌زمینه اصلی اسکیم
  onBackground: const Color(0xFF1A1A1A),
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
  background: const Color(0xFF121212), // پس‌زمینه اصلی اسکیم برای تم تیره
  onBackground: const Color(0xFFE0E0E0),
);

// --- Custom Colors Extension ---
const Color _lightCompletedStatusColor = Color(0xFFCCFF90); // سبز فسفری ملایم روشن
const Color _onLightCompletedStatusColor = Colors.black;

const Color _darkCompletedStatusColor = Color(0xFF69F0AE);  // سبز فسفری ملایم برای تم تیره
const Color _onDarkCompletedStatusColor = Colors.black;

extension CustomColorSchemeExtension on ColorScheme {
  Color get completedStatus {
    if (brightness == Brightness.light) {
      return _lightCompletedStatusColor;
    } else {
      return _darkCompletedStatusColor;
    }
  }

  Color get onCompletedStatus {
    if (brightness == Brightness.light) {
      return _onLightCompletedStatusColor;
    } else {
      return _onDarkCompletedStatusColor;
    }
  }
}

// --- ThemeData Definitions ---
ThemeData mainTheme = ThemeData(
  useMaterial3: true,
  colorScheme: _lightColorScheme,
  brightness: Brightness.light,
  disabledColor: _applyOpacity(_lightColorScheme.outline, 0.7),
  scaffoldBackgroundColor: _lightColorScheme.background,
  appBarTheme: AppBarTheme(
    backgroundColor: _lightColorScheme.primary,
    foregroundColor: _lightColorScheme.onPrimary,
    elevation: 1,
    titleTextStyle: TextStyle(
      fontFamily: 'Vazirmatn',
      color: _lightColorScheme.onPrimary,
      fontSize: 20,
      fontWeight: FontWeight.w600,
    ),
  ),
  cardTheme: CardTheme(
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
    labelStyle: TextStyle(color: _lightColorScheme.onSurfaceVariant, fontWeight: FontWeight.w500),
    hintStyle: TextStyle(color: _applyOpacity(_lightColorScheme.onSurfaceVariant, 0.7)),
    errorStyle: TextStyle(color: _lightColorScheme.error),
  ),
  textTheme: const TextTheme().apply(
    bodyColor: _lightColorScheme.onSurface,
    displayColor: _lightColorScheme.onSurface,
    fontFamily: 'Vazirmatn',
  ).copyWith(
    titleLarge: TextStyle(color: _lightColorScheme.primary, fontWeight: FontWeight.bold),
    bodyMedium: TextStyle(color: _applyOpacity(_lightColorScheme.onSurface, 0.85)),
  ),
  elevatedButtonTheme: ElevatedButtonThemeData(
    style: ElevatedButton.styleFrom(
      backgroundColor: _lightColorScheme.primary,
      foregroundColor: _lightColorScheme.onPrimary,
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 20),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      textStyle: const TextStyle(fontFamily: 'Vazirmatn', fontSize: 16, fontWeight: FontWeight.w600),
    ),
  ),
  textButtonTheme: TextButtonThemeData(
    style: TextButton.styleFrom(
      foregroundColor: _lightColorScheme.primary,
      textStyle: const TextStyle(fontFamily: 'Vazirmatn', fontWeight: FontWeight.w600),
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
    states.contains(WidgetState.selected) ? _lightColorScheme.primary : _lightColorScheme.outline),
    trackColor: WidgetStateProperty.resolveWith((states) {
      if (states.contains(WidgetState.selected)) {
        return _applyOpacity(_lightColorScheme.primary, 0.5);
      }
      return _applyOpacity(_lightColorScheme.outline, 0.3);
    }),
    trackOutlineColor: WidgetStateProperty.resolveWith((states) => Colors.transparent),
  ),
);


ThemeData darkTheme = ThemeData(
  useMaterial3: true,
  colorScheme: _darkColorScheme,
  brightness: Brightness.dark,
  disabledColor: _applyOpacity(_darkColorScheme.outline, 0.7),
  scaffoldBackgroundColor: _darkColorScheme.background,
  appBarTheme: AppBarTheme(
    backgroundColor: _darkColorScheme.surface,
    foregroundColor: _darkColorScheme.onSurface,
    elevation: 1,
    titleTextStyle: TextStyle(
      fontFamily: 'Vazirmatn',
      color: _darkColorScheme.onSurface,
      fontSize: 20,
      fontWeight: FontWeight.w600,
    ),
  ),
  cardTheme: CardTheme(
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
    labelStyle: TextStyle(color: _darkColorScheme.onSurfaceVariant, fontWeight: FontWeight.w500),
    hintStyle: TextStyle(color: _applyOpacity(_darkColorScheme.onSurfaceVariant, 0.7)),
    errorStyle: TextStyle(color: _darkColorScheme.error),
  ),
  textTheme: const TextTheme().apply(
    bodyColor: _darkColorScheme.onSurface,
    displayColor: _darkColorScheme.onSurface,
    fontFamily: 'Vazirmatn',
  ).copyWith(
    titleLarge: TextStyle(color: _darkColorScheme.primary, fontWeight: FontWeight.bold),
    bodyMedium: TextStyle(color: _applyOpacity(_darkColorScheme.onSurface, 0.85)),
  ),
  elevatedButtonTheme: ElevatedButtonThemeData(
    style: ElevatedButton.styleFrom(
      backgroundColor: _darkColorScheme.primary,
      foregroundColor: _darkColorScheme.onPrimary,
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 20),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      textStyle: const TextStyle(fontFamily: 'Vazirmatn', fontSize: 16, fontWeight: FontWeight.w600),
    ),
  ),
  textButtonTheme: TextButtonThemeData(
    style: TextButton.styleFrom(
      foregroundColor: _darkColorScheme.primary,
      textStyle: const TextStyle(fontFamily: 'Vazirmatn', fontWeight: FontWeight.w600),
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
    states.contains(WidgetState.selected) ? _darkColorScheme.primary : _darkColorScheme.outline),
    trackColor: WidgetStateProperty.resolveWith((states) {
      if (states.contains(WidgetState.selected)) {
        return _applyOpacity(_darkColorScheme.primary, 0.5);
      }
      return _applyOpacity(_darkColorScheme.outline, 0.3);
    }),
    trackOutlineColor: WidgetStateProperty.resolveWith((states) => Colors.transparent),
  ),
);