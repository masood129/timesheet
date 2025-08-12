import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_native_splash/flutter_native_splash.dart';
import 'package:get/get.dart';
import 'package:timezone/data/latest.dart' as tz;

import 'core/theme/theme.dart';
import 'fail_login.dart';
import 'home/api/home_api.dart';
import 'home/view/home.dart';
import 'l10n/massage.dart';

Future<void> main() async {
  WidgetsBinding widgetsBinding = WidgetsFlutterBinding.ensureInitialized();
  FlutterNativeSplash.preserve(widgetsBinding: widgetsBinding);
  tz.initializeTimeZones();

  final username = Uri.base.queryParameters['id']; // 127.0.0.1:80/?id=myUserName
  Get.put(ThemeController());

  // if (username != null && username.isNotEmpty) {
  if (true) {
    await HomeApi().login("user003"); //set username
    runApp(const MyApp());
  } else {
    FlutterNativeSplash.remove();
    runApp(const FailLogin());
  }
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