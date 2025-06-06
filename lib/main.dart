import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:get/get.dart';
import 'package:timezone/data/latest.dart' as tz;
import 'core/theme/theme.dart';
import 'home/view/home.dart';
import 'l10n/massage.dart';

void main() {
  tz.initializeTimeZones();
  Get.put(ThemeController());
  runApp(const MyApp());
}

class MyApp extends GetView<ThemeController> {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      debugShowCheckedModeBanner: false,
      translations: Messages(),
      locale: const Locale('fa'),
      fallbackLocale: const Locale('en'),
      title: 'app_title'.tr,
      themeMode: controller.theme,
      theme: mainTheme,
      darkTheme: darkTheme,
      localizationsDelegates: const [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: const [Locale('fa'), Locale('en')],
      home: CalendarView(),
    );
  }
}