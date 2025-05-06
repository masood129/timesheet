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

ThemeData mainTheme = ThemeData(
  useMaterial3: true,
  colorScheme: ColorScheme.fromSeed(
    seedColor: Colors.blue[600]!, // آبی ملایم برای حس مدرن
    brightness: Brightness.light,
  ).copyWith(
    primary: Colors.blue[600], // رنگ اصلی
    onPrimary: Colors.white, // متن روی رنگ اصلی
    secondary: Colors.orange[400], // رنگ ثانویه ملایم
    onSecondary: Colors.grey[900], // متن روی رنگ ثانویه
    error: Colors.red[600], // خطا با شدت کمتر
    surface: Colors.grey[50], // پس‌زمینه کارت‌ها و سطوح
    onSurface: Colors.grey[900], // متن روی سطوح
  ),
  disabledColor: Colors.grey[400], // رنگ غیرفعال ملایم‌تر
  scaffoldBackgroundColor: Colors.grey[200], // پس‌زمینه صفحه
  appBarTheme: AppBarTheme(
    backgroundColor: Colors.blue[600],
    foregroundColor: Colors.white,
    elevation: 0, // حذف سایه برای حس مدرن
    titleTextStyle: const TextStyle(
      color: Colors.white,
      fontSize: 20,
      fontWeight: FontWeight.w600,
    ),
  ),
  cardTheme: CardTheme(
    color: Colors.grey[50],
    elevation: 2, // سایه ملایم‌تر
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)), // گوشه‌های نرم‌تر
  ),
  switchTheme: SwitchThemeData(
    thumbColor: WidgetStateProperty.resolveWith((states) =>
    states.contains(WidgetState.selected) ? Colors.orange[400] : Colors.grey[400]),
    trackColor: WidgetStateProperty.resolveWith((states) =>
    states.contains(WidgetState.selected)
        ? Colors.orange[400]!.withOpacity(0.5)
        : Colors.grey[200]),
  ),
  inputDecorationTheme: InputDecorationTheme(
    border: OutlineInputBorder(
      borderRadius: BorderRadius.circular(16), // هماهنگ با کارت‌ها
      borderSide: BorderSide(color: Colors.grey[400]!),
    ),
    enabledBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(16),
      borderSide: BorderSide(color: Colors.grey[400]!),
    ),
    focusedBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(16),
      borderSide: BorderSide(color: Colors.blue[600]!, width: 2),
    ),
    contentPadding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
    filled: true,
    fillColor: Colors.grey[100], // پس‌زمینه ملایم برای ورودی‌ها
    labelStyle: TextStyle(color: Colors.grey[700]),
    hintStyle: TextStyle(color: Colors.grey[500]),
  ),
);

ThemeData darkTheme = ThemeData.dark(useMaterial3: true).copyWith(
  colorScheme: ColorScheme.fromSeed(
    seedColor: Colors.blue[800]!, // آبی تیره برای هماهنگی
    brightness: Brightness.dark,
  ).copyWith(
    primary: Colors.blue[800], // رنگ اصلی تیره
    onPrimary: Colors.white,
    secondary: Colors.orange[700], // نارنجی تیره برای گرما
    onSecondary: Colors.grey[200],
    error: Colors.red[400],
    surface: Colors.grey[900], // سطوح تیره
    onSurface: Colors.grey[200], // متن روی سطوح
  ),
  disabledColor: Colors.grey[600], // رنگ غیرفعال تیره‌تر
  scaffoldBackgroundColor: Colors.grey[950], // پس‌زمینه تیره اما نه مشکی خالص
  appBarTheme: AppBarTheme(
    backgroundColor: Colors.blue[800],
    foregroundColor: Colors.white,
    elevation: 0,
    titleTextStyle: const TextStyle(
      color: Colors.white,
      fontSize: 20,
      fontWeight: FontWeight.w600,
    ),
  ),
  cardTheme: CardTheme(
    color: Colors.grey[900],
    elevation: 2,
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
  ),
  switchTheme: SwitchThemeData(
    thumbColor: WidgetStateProperty.resolveWith((states) =>
    states.contains(WidgetState.selected) ? Colors.orange[700] : Colors.grey[600]),
    trackColor: WidgetStateProperty.resolveWith((states) =>
    states.contains(WidgetState.selected)
        ? Colors.orange[700]!.withOpacity(0.5)
        : Colors.grey[800]),
  ),
  inputDecorationTheme: InputDecorationTheme(
    border: OutlineInputBorder(
      borderRadius: BorderRadius.circular(16),
      borderSide: BorderSide(color: Colors.grey[600]!),
    ),
    enabledBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(16),
      borderSide: BorderSide(color: Colors.grey[600]!),
    ),
    focusedBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(16),
      borderSide: BorderSide(color: Colors.blue[800]!, width: 2),
    ),
    contentPadding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
    filled: true,
    fillColor: Colors.grey[850], // پس‌زمینه تیره برای ورودی‌ها
    labelStyle: TextStyle(color: Colors.grey[400]),
    hintStyle: TextStyle(color: Colors.grey[600]),
  ),
);