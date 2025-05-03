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
    seedColor: Colors.teal,
    brightness: Brightness.light,
  ).copyWith(
    primary: Colors.teal,
    onPrimary: Colors.white,
    secondary: Colors.amber,
    error: Colors.red,
    surface: Colors.white,
    onSurface: Colors.black87,
  ),
  scaffoldBackgroundColor: Colors.grey[100],
  appBarTheme: const AppBarTheme(
    backgroundColor: Colors.teal,
    foregroundColor: Colors.white,
  ),
  cardTheme: CardTheme(
    color: Colors.white,
    elevation: 4,
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
  ),
  switchTheme: SwitchThemeData(
    thumbColor: MaterialStateProperty.all(Colors.amber),
  ),
);


ThemeData darkTheme = ThemeData.dark(useMaterial3: true).copyWith(
  colorScheme: ColorScheme.fromSeed(
    seedColor: Colors.deepOrange,
    brightness: Brightness.dark,
  ).copyWith(
    primary: Colors.deepOrange,
    onPrimary: Colors.white,
    secondary: Colors.amber,
    error: Colors.red,
    surface: Colors.grey[850],
    onSurface: Colors.white70,
  ),
  scaffoldBackgroundColor: Colors.black,
  appBarTheme: const AppBarTheme(
    backgroundColor: Colors.deepOrange,
    foregroundColor: Colors.white,
  ),
  cardTheme: CardTheme(
    color: Colors.grey[850],
    elevation: 2,
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
  ),
  switchTheme: SwitchThemeData(
    thumbColor: MaterialStateProperty.all(Colors.amber),
  ),
);
