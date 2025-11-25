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