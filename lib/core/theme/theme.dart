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

// Unified Font Configuration - تنظیمات یکپارچه فونت
class FontConfig {
  // Font Families
  static const String persianFont = 'BNazanin';
  static const String englishFont = 'Ubuntu';
  
  // Font Sizes - اندازه فونت‌ها (بزرگ‌تر)
  static const double fontSizeDisplayLarge = 36.0;  // بود: 32
  static const double fontSizeDisplayMedium = 32.0; // بود: 28
  static const double fontSizeDisplaySmall = 28.0;  // بود: 24
  static const double fontSizeHeadlineLarge = 24.0; // بود: 20
  static const double fontSizeHeadlineMedium = 22.0; // بود: 20
  static const double fontSizeHeadlineSmall = 20.0; // بود: 18
  static const double fontSizeTitleLarge = 18.0;    // بود: 16
  static const double fontSizeTitleMedium = 17.0;   // بود: 14
  static const double fontSizeTitleSmall = 16.0;    // بود: 14
  static const double fontSizeBodyLarge = 17.0;     // بود: 14
  static const double fontSizeBodyMedium = 16.0;   // بود: 12
  static const double fontSizeBodySmall = 14.0;     // بود: 11
  static const double fontSizeLabelLarge = 16.0;
  static const double fontSizeLabelMedium = 15.0;
  static const double fontSizeLabelSmall = 14.0;
  
  // Font Weights - وزن فونت‌ها (پررنگ‌تر)
  static const FontWeight fontWeightNormal = FontWeight.w600;    // بود: normal/w400
  static const FontWeight fontWeightMedium = FontWeight.w600;   // بود: w500
  static const FontWeight fontWeightBold = FontWeight.bold;     // بود: w600
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
  primary: const Color(0xFF00796B),
  // Teal 700 - رنگ اصلی تیره‌تر برای تاکید
  onPrimary: Colors.white,
  primaryContainer: const Color(0xFFB2DFDB),
  // Teal 100
  onPrimaryContainer: const Color(0xFF004D40),
  // Teal 900
  secondary: const Color(0xFF4DB6AC),
  // Teal 300
  onSecondary: Colors.black,
  secondaryContainer: const Color(0xFF80CBC4),
  // Teal 200
  onSecondaryContainer: const Color(0xFF004D40),
  tertiary: const Color(0xFF29B6F6),
  // Light Blue A400
  onTertiary: Colors.black,
  tertiaryContainer: const Color(0xFFB3E5FC),
  // Light Blue 100
  onTertiaryContainer: const Color(0xFF01579B),
  error: const Color(0xFFE57373),
  // Red 300
  onError: Colors.black,
  errorContainer: const Color(0xFFFFCDD2),
  // Red 100
  onErrorContainer: const Color(0xFFB71C1C),
  surface: Colors.white,
  onSurface: const Color(0xFF000000),
  surfaceContainerHighest: const Color(0xFFF0F4F8),
  onSurfaceVariant: const Color(0xFF4A4A4A),
  outline: const Color(0xFFB0BEC5),
  // Blue Grey 200
  outlineVariant: const Color(0xFFCFD8DC), // Blue Grey 100
);

// --- Dark Theme ---
final ColorScheme _darkColorScheme = ColorScheme.fromSeed(
  seedColor: const Color(0xFF1A2A29), // یک سبز بسیار تیره برای پایه تم دارک
  brightness: Brightness.dark,
).copyWith(
  primary: const Color(0xFF4DB6AC),
  // Teal 300
  onPrimary: Colors.black,
  primaryContainer: const Color(0xFF00695C),
  // Teal 800
  onPrimaryContainer: const Color(0xFFB2DFDB),
  secondary: const Color(0xFF80CBC4),
  // Teal 200
  onSecondary: Colors.black,
  secondaryContainer: const Color(0xFF004D40),
  // Teal 900
  onSecondaryContainer: const Color(0xFFB2DFDB),
  tertiary: const Color(0xFF4FC3F7),
  // Light Blue A200
  onTertiary: Colors.black,
  tertiaryContainer: const Color(0xFF0277BD),
  // Light Blue 800
  onTertiaryContainer: const Color(0xFFE1F5FE),
  error: const Color(0xFFEF9A9A),
  // Red 200
  onError: Colors.black,
  errorContainer: const Color(0xFFC62828),
  // Red 800
  onErrorContainer: const Color(0xFFFFEBEE),
  surface: const Color(0xFF1E1E1E),
  onSurface: const Color(0xFFE0E0E0),
  surfaceContainerHighest: const Color(0xFF2C2C2C),
  onSurfaceVariant: const Color(0xFFA0A0A0),
  outline: const Color(0xFF546E7A),
  // Blue Grey 500
  outlineVariant: const Color(0xFF455A64), // Blue Grey 600
);

// --- Custom Colors Extension ---
const Color _lightCompletedStatusColor = Color(
  0xFF6CDF4B,
); // سبز فسفری ملایم روشن
const Color _onLightCompletedStatusColor = Colors.black;
const Color _lightIncompleteStatusColor = Color(
  0xFFFFB300,
); // Amber 600 - زرد پررنگ
const Color _onLightIncompleteStatusColor = Colors.black;
const Color _lightNoDataStatusColor = Color(
  0xFF78909C,
); // Blue Grey 400 - خاکستری آبی پررنگ
const Color _onLightNoDataStatusColor = Colors.white;

const Color _darkCompletedStatusColor = Color(
  0xFF69F0AE,
); // سبز فسفری ملایم برای تم تیره
const Color _onDarkCompletedStatusColor = Colors.black;
const Color _darkIncompleteStatusColor = Color(
  0xFFFFCA28,
); // Amber 400 - زرد پررنگ
const Color _onDarkIncompleteStatusColor = Colors.black;
const Color _darkNoDataStatusColor = Color(
  0xFF90A4AE,
); // Blue Grey 300 - خاکستری آبی پررنگ
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

  // --- رنگ‌های تقویم ---
  
  // وضعیت روزها
  Color get todayColor => brightness == Brightness.light 
      ? const Color(0xFF00796B) // Teal 700 - همسو با primary
      : const Color(0xFF4DB6AC); // Teal 300
  
  Color get workCompleteColor => brightness == Brightness.light
      ? _lightCompletedStatusColor // سبز فسفری
      : _darkCompletedStatusColor;
  
  Color get workIncompleteColor => brightness == Brightness.light
      ? _lightIncompleteStatusColor // Amber 600
      : _darkIncompleteStatusColor;
  
  Color get holidayColor => error; // استفاده از error theme
  
  Color get fridayColor => brightness == Brightness.light
      ? const Color(0xFFFF6F00) // Deep Orange 800 
      : const Color(0xFFFF9E80); // Deep Orange A100
  
  Color get removedDayColor => brightness == Brightness.light
      ? const Color(0xFFE0E0E0) // Grey 300
      : const Color(0xFF424242); // Grey 800
  
  Color get addedDayColor => brightness == Brightness.light
      ? const Color(0xFFE1BEE7) // Purple 100
      : const Color(0xFF4A148C); // Purple 900
  
  // انواع مرخصی
  Color get annualLeaveColor => brightness == Brightness.light
      ? const Color(0xFF1E88E5) // Blue 600
      : const Color(0xFF64B5F6); // Blue 300
  
  Color get sickLeaveColor => brightness == Brightness.light
      ? const Color(0xFFD81B60) // Pink 600
      : const Color(0xFFF48FB1); // Pink 200
  
  Color get giftLeaveColor => brightness == Brightness.light
      ? const Color(0xFF8E24AA) // Purple 600
      : const Color(0xFFCE93D8); // Purple 200
  
  Color get missionColor => brightness == Brightness.light
      ? const Color(0xFF5E35B1) // Deep Purple 600
      : const Color(0xFF9575CD); // Deep Purple 300
}

// --- ThemeData Definitions ---
ThemeData mainTheme = ThemeData(
  fontFamily: FontConfig.persianFont,
  useMaterial3: true,
  colorScheme: _lightColorScheme,
  brightness: Brightness.light,
  disabledColor: _applyOpacity(_lightColorScheme.outline, 0.95),
  // disabledColor: const Color(0xFF3C3C3C),
  scaffoldBackgroundColor: const Color(0xFFECEFF1),
  // Blue Grey 50
  appBarTheme: AppBarTheme(
    backgroundColor: _lightColorScheme.primary,
    foregroundColor: _lightColorScheme.onPrimary,
    elevation: 1,
    titleTextStyle: TextStyle(
      fontFamily: FontConfig.persianFont,
      color: _lightColorScheme.onPrimary,
      fontSize: FontConfig.fontSizeHeadlineLarge,
      fontWeight: FontConfig.fontWeightBold,
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
      fontFamily: FontConfig.persianFont,
      fontSize: FontConfig.fontSizeBodyLarge,
      color: _lightColorScheme.onSurfaceVariant,
      fontWeight: FontConfig.fontWeightNormal,
    ),
    hintStyle: TextStyle(
      fontFamily: FontConfig.persianFont,
      fontSize: FontConfig.fontSizeBodyLarge,
      color: _applyOpacity(_lightColorScheme.onSurfaceVariant, 0.7),
      fontWeight: FontConfig.fontWeightNormal,
    ),
    errorStyle: TextStyle(color: _lightColorScheme.error),
  ),
  textTheme: TextTheme(
    displayLarge: TextStyle(
      fontFamily: FontConfig.persianFont,
      fontSize: FontConfig.fontSizeDisplayLarge,
      fontWeight: FontConfig.fontWeightBold,
      color: _lightColorScheme.onSurface,
    ),
    displayMedium: TextStyle(
      fontFamily: FontConfig.persianFont,
      fontSize: FontConfig.fontSizeDisplayMedium,
      fontWeight: FontConfig.fontWeightBold,
      color: _lightColorScheme.onSurface,
    ),
    displaySmall: TextStyle(
      fontFamily: FontConfig.persianFont,
      fontSize: FontConfig.fontSizeDisplaySmall,
      fontWeight: FontConfig.fontWeightBold,
      color: _lightColorScheme.onSurface,
    ),
    headlineLarge: TextStyle(
      fontFamily: FontConfig.persianFont,
      fontSize: FontConfig.fontSizeHeadlineLarge,
      fontWeight: FontConfig.fontWeightBold,
      color: _lightColorScheme.onSurface,
    ),
    headlineMedium: TextStyle(
      fontFamily: FontConfig.persianFont,
      fontSize: FontConfig.fontSizeHeadlineMedium,
      fontWeight: FontConfig.fontWeightBold,
      color: _lightColorScheme.onSurface,
    ),
    headlineSmall: TextStyle(
      fontFamily: FontConfig.persianFont,
      fontSize: FontConfig.fontSizeHeadlineSmall,
      fontWeight: FontConfig.fontWeightBold,
      color: _lightColorScheme.onSurface,
    ),
    titleLarge: TextStyle(
      fontFamily: FontConfig.persianFont,
      fontSize: FontConfig.fontSizeTitleLarge,
      fontWeight: FontConfig.fontWeightBold,
      color: _lightColorScheme.primary,
    ),
    titleMedium: TextStyle(
      fontFamily: FontConfig.persianFont,
      fontSize: FontConfig.fontSizeTitleMedium,
      fontWeight: FontConfig.fontWeightMedium,
      color: _lightColorScheme.onSurface,
    ),
    titleSmall: TextStyle(
      fontFamily: FontConfig.persianFont,
      fontSize: FontConfig.fontSizeTitleSmall,
      fontWeight: FontConfig.fontWeightMedium,
      color: _lightColorScheme.onSurface,
    ),
    bodyLarge: TextStyle(
      fontFamily: FontConfig.persianFont,
      fontSize: FontConfig.fontSizeBodyLarge,
      fontWeight: FontConfig.fontWeightNormal,
      color: _lightColorScheme.onSurface,
    ),
    bodyMedium: TextStyle(
      fontFamily: FontConfig.persianFont,
      fontSize: FontConfig.fontSizeBodyMedium,
      fontWeight: FontConfig.fontWeightNormal,
      color: _applyOpacity(_lightColorScheme.onSurface, 0.85),
    ),
    bodySmall: TextStyle(
      fontFamily: FontConfig.persianFont,
      fontSize: FontConfig.fontSizeBodySmall,
      fontWeight: FontConfig.fontWeightNormal,
      color: _applyOpacity(_lightColorScheme.onSurface, 0.7),
    ),
    labelLarge: TextStyle(
      fontFamily: FontConfig.persianFont,
      fontSize: FontConfig.fontSizeLabelLarge,
      fontWeight: FontConfig.fontWeightMedium,
      color: _lightColorScheme.onSurface,
    ),
    labelMedium: TextStyle(
      fontFamily: FontConfig.persianFont,
      fontSize: FontConfig.fontSizeLabelMedium,
      fontWeight: FontConfig.fontWeightNormal,
      color: _lightColorScheme.onSurface,
    ),
    labelSmall: TextStyle(
      fontFamily: FontConfig.persianFont,
      fontSize: FontConfig.fontSizeLabelSmall,
      fontWeight: FontConfig.fontWeightNormal,
      color: _applyOpacity(_lightColorScheme.onSurface, 0.7),
    ),
  ),
  elevatedButtonTheme: ElevatedButtonThemeData(
    style: ElevatedButton.styleFrom(
      backgroundColor: _lightColorScheme.primary,
      foregroundColor: _lightColorScheme.onPrimary,
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 20),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      textStyle: TextStyle(
        fontFamily: FontConfig.persianFont,
        fontSize: FontConfig.fontSizeBodyLarge,
        fontWeight: FontConfig.fontWeightMedium,
      ),
    ),
  ),
  textButtonTheme: TextButtonThemeData(
    style: TextButton.styleFrom(
      foregroundColor: _lightColorScheme.primary,
      textStyle: TextStyle(
        fontFamily: FontConfig.persianFont,
        fontSize: FontConfig.fontSizeBodyLarge,
        fontWeight: FontConfig.fontWeightMedium,
      ),
    ),
  ),
  dividerTheme: DividerThemeData(
    color: _lightColorScheme.outlineVariant,
    thickness: 1,
  ),
  iconTheme: IconThemeData(color: _lightColorScheme.primary),
  listTileTheme: ListTileThemeData(
    iconColor: _lightColorScheme.secondary,
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
  ),
  switchTheme: SwitchThemeData(
    thumbColor: WidgetStateProperty.resolveWith(
      (states) =>
          states.contains(WidgetState.selected)
              ? _lightColorScheme.primary
              : _lightColorScheme.outline,
    ),
    trackColor: WidgetStateProperty.resolveWith((states) {
      if (states.contains(WidgetState.selected)) {
        return _applyOpacity(_lightColorScheme.primary, 0.5);
      }
      return _applyOpacity(_lightColorScheme.outline, 0.3);
    }),
    trackOutlineColor: WidgetStateProperty.resolveWith(
      (states) => Colors.transparent,
    ),
  ),
  snackBarTheme: SnackBarThemeData(
    backgroundColor: _lightColorScheme.surfaceContainerHighest,
    contentTextStyle: TextStyle(
      fontFamily: FontConfig.persianFont,
      color: _lightColorScheme.onSurface,
      fontSize: FontConfig.fontSizeBodyLarge,
      fontWeight: FontConfig.fontWeightNormal,
    ),
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
    behavior: SnackBarBehavior.floating,
    elevation: 4,
    actionTextColor: _lightColorScheme.primary,
  ),
);

ThemeData darkTheme = ThemeData(
  fontFamily: FontConfig.persianFont,
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
      fontFamily: FontConfig.persianFont,
      color: _darkColorScheme.onSurface,
      fontSize: FontConfig.fontSizeHeadlineLarge,
      fontWeight: FontConfig.fontWeightBold,
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
      fontFamily: FontConfig.persianFont,
      fontSize: FontConfig.fontSizeBodyLarge,
      color: _darkColorScheme.onSurfaceVariant,
      fontWeight: FontConfig.fontWeightNormal,
    ),
    hintStyle: TextStyle(
      fontFamily: FontConfig.persianFont,
      fontSize: FontConfig.fontSizeBodyLarge,
      color: _applyOpacity(_darkColorScheme.onSurfaceVariant, 0.7),
      fontWeight: FontConfig.fontWeightNormal,
    ),
    errorStyle: TextStyle(color: _darkColorScheme.error),
  ),
  textTheme: TextTheme(
    displayLarge: TextStyle(
      fontFamily: FontConfig.persianFont,
      fontSize: FontConfig.fontSizeDisplayLarge,
      fontWeight: FontConfig.fontWeightBold,
      color: _darkColorScheme.onSurface,
    ),
    displayMedium: TextStyle(
      fontFamily: FontConfig.persianFont,
      fontSize: FontConfig.fontSizeDisplayMedium,
      fontWeight: FontConfig.fontWeightBold,
      color: _darkColorScheme.onSurface,
    ),
    displaySmall: TextStyle(
      fontFamily: FontConfig.persianFont,
      fontSize: FontConfig.fontSizeDisplaySmall,
      fontWeight: FontConfig.fontWeightBold,
      color: _darkColorScheme.onSurface,
    ),
    headlineLarge: TextStyle(
      fontFamily: FontConfig.persianFont,
      fontSize: FontConfig.fontSizeHeadlineLarge,
      fontWeight: FontConfig.fontWeightBold,
      color: _darkColorScheme.onSurface,
    ),
    headlineMedium: TextStyle(
      fontFamily: FontConfig.persianFont,
      fontSize: FontConfig.fontSizeHeadlineMedium,
      fontWeight: FontConfig.fontWeightBold,
      color: _darkColorScheme.onSurface,
    ),
    headlineSmall: TextStyle(
      fontFamily: FontConfig.persianFont,
      fontSize: FontConfig.fontSizeHeadlineSmall,
      fontWeight: FontConfig.fontWeightBold,
      color: _darkColorScheme.onSurface,
    ),
    titleLarge: TextStyle(
      fontFamily: FontConfig.persianFont,
      fontSize: FontConfig.fontSizeTitleLarge,
      fontWeight: FontConfig.fontWeightBold,
      color: _darkColorScheme.primary,
    ),
    titleMedium: TextStyle(
      fontFamily: FontConfig.persianFont,
      fontSize: FontConfig.fontSizeTitleMedium,
      fontWeight: FontConfig.fontWeightMedium,
      color: _darkColorScheme.onSurface,
    ),
    titleSmall: TextStyle(
      fontFamily: FontConfig.persianFont,
      fontSize: FontConfig.fontSizeTitleSmall,
      fontWeight: FontConfig.fontWeightMedium,
      color: _darkColorScheme.onSurface,
    ),
    bodyLarge: TextStyle(
      fontFamily: FontConfig.persianFont,
      fontSize: FontConfig.fontSizeBodyLarge,
      fontWeight: FontConfig.fontWeightNormal,
      color: _darkColorScheme.onSurface,
    ),
    bodyMedium: TextStyle(
      fontFamily: FontConfig.persianFont,
      fontSize: FontConfig.fontSizeBodyMedium,
      fontWeight: FontConfig.fontWeightNormal,
      color: _applyOpacity(_darkColorScheme.onSurface, 0.85),
    ),
    bodySmall: TextStyle(
      fontFamily: FontConfig.persianFont,
      fontSize: FontConfig.fontSizeBodySmall,
      fontWeight: FontConfig.fontWeightNormal,
      color: _applyOpacity(_darkColorScheme.onSurface, 0.7),
    ),
    labelLarge: TextStyle(
      fontFamily: FontConfig.persianFont,
      fontSize: FontConfig.fontSizeLabelLarge,
      fontWeight: FontConfig.fontWeightMedium,
      color: _darkColorScheme.onSurface,
    ),
    labelMedium: TextStyle(
      fontFamily: FontConfig.persianFont,
      fontSize: FontConfig.fontSizeLabelMedium,
      fontWeight: FontConfig.fontWeightNormal,
      color: _darkColorScheme.onSurface,
    ),
    labelSmall: TextStyle(
      fontFamily: FontConfig.persianFont,
      fontSize: FontConfig.fontSizeLabelSmall,
      fontWeight: FontConfig.fontWeightNormal,
      color: _applyOpacity(_darkColorScheme.onSurface, 0.7),
    ),
  ),
  elevatedButtonTheme: ElevatedButtonThemeData(
    style: ElevatedButton.styleFrom(
      backgroundColor: _darkColorScheme.primary,
      foregroundColor: _darkColorScheme.onPrimary,
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 20),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      textStyle: TextStyle(
        fontFamily: FontConfig.persianFont,
        fontSize: FontConfig.fontSizeBodyLarge,
        fontWeight: FontConfig.fontWeightMedium,
      ),
    ),
  ),
  textButtonTheme: TextButtonThemeData(
    style: TextButton.styleFrom(
      foregroundColor: _darkColorScheme.primary,
      textStyle: TextStyle(
        fontFamily: FontConfig.persianFont,
        fontSize: FontConfig.fontSizeBodyLarge,
        fontWeight: FontConfig.fontWeightMedium,
      ),
    ),
  ),
  dividerTheme: DividerThemeData(
    color: _darkColorScheme.outlineVariant,
    thickness: 1,
  ),
  iconTheme: IconThemeData(color: _darkColorScheme.primary),
  listTileTheme: ListTileThemeData(
    iconColor: _darkColorScheme.secondary,
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
  ),
  switchTheme: SwitchThemeData(
    thumbColor: WidgetStateProperty.resolveWith(
      (states) =>
          states.contains(WidgetState.selected)
              ? _darkColorScheme.primary
              : _darkColorScheme.outline,
    ),
    trackColor: WidgetStateProperty.resolveWith((states) {
      if (states.contains(WidgetState.selected)) {
        return _applyOpacity(_darkColorScheme.primary, 0.5);
      }
      return _applyOpacity(_darkColorScheme.outline, 0.3);
    }),
    trackOutlineColor: WidgetStateProperty.resolveWith(
      (states) => Colors.transparent,
    ),
  ),
  snackBarTheme: SnackBarThemeData(
    backgroundColor: _darkColorScheme.surfaceContainerHighest,
    contentTextStyle: TextStyle(
      fontFamily: FontConfig.persianFont,
      color: _darkColorScheme.onSurface,
      fontSize: FontConfig.fontSizeBodyLarge,
      fontWeight: FontConfig.fontWeightNormal,
    ),
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
    behavior: SnackBarBehavior.floating,
    elevation: 4,
    actionTextColor: _darkColorScheme.primary,
  ),
);
