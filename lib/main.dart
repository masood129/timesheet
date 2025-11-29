import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_native_splash/flutter_native_splash.dart';
import 'package:get/get.dart';
import 'package:timezone/data/latest.dart' as tz;
import 'core/theme/theme.dart';
import 'core/utils/app_logger.dart';
import 'home/controller/auth_controller.dart';
import 'home/view/fail_login.dart';
import 'home/view/home.dart';
import 'home/view/login_view.dart';
import 'l10n/massage.dart';

Future<void> main() async {
  WidgetsBinding widgetsBinding = WidgetsFlutterBinding.ensureInitialized();
  FlutterNativeSplash.preserve(widgetsBinding: widgetsBinding);
  tz.initializeTimeZones();
  await _loadEnv();

  // Initialize logger
  await AppLogger().init();

  Get.put(ThemeController());
  Get.put(AuthController());

  final authController = Get.find<AuthController>();
  final username =
      Uri.base.queryParameters['id']; // 127.0.0.1:80/?id=user_engineer1

  if (username != null && username.isNotEmpty) {
    final success = await authController.login(username);
    if (success) {
      FlutterNativeSplash.remove();
      runApp(const MyApp());
    } else {
      FlutterNativeSplash.remove();
      runApp(const FailLogin());
    }
  } else {
    FlutterNativeSplash.remove();
    runApp(const MyApp(initialRoute: '/login'));
  }
}

Future<void> _loadEnv() async {
  try {
    await dotenv.load(fileName: ".env");
  } catch (e) {
    debugPrint('Failed to load .env file: $e');
  }
}

class MyApp extends GetView<ThemeController> {
  final String? initialRoute;

  const MyApp({super.key, this.initialRoute});

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
      initialRoute: initialRoute ?? '/home',
      builder: EasyLoading.init(),
      getPages: [
        GetPage(name: '/home', page: () => CalendarView()),
        GetPage(name: '/login', page: () => LoginView()),
      ],
    );
  }
}
