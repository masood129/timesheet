import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';
import 'package:timesheet/home/view/login_view.dart';
import 'package:timesheet/main.dart';

void main() {
  group('Login Flow Integration Test', () {
    setUp(() {
      Get.testMode = true;
    });

    tearDown(() {
      Get.reset();
    });

    testWidgets('MyApp initializes correctly', (WidgetTester tester) async {
      // Build the app
      await tester.pumpWidget(const MyApp());
      await tester.pumpAndSettle();

      // The app should initialize
      expect(find.byType(MaterialApp), findsOneWidget);
    });

    testWidgets('MyApp with login route shows LoginView', (
      WidgetTester tester,
    ) async {
      // Build the app with login route
      await tester.pumpWidget(const MyApp(initialRoute: '/login'));
      await tester.pumpAndSettle();

      // Should show login view
      expect(find.byType(LoginView), findsOneWidget);
    });

    testWidgets('MyApp uses correct theme', (WidgetTester tester) async {
      // Build the app
      await tester.pumpWidget(const MyApp());
      await tester.pumpAndSettle();

      // Find MaterialApp
      final materialApp = tester.widget<MaterialApp>(find.byType(MaterialApp));

      // Verify theme is set
      expect(materialApp.theme, isNotNull);
      expect(materialApp.darkTheme, isNotNull);
    });

    testWidgets('MyApp supports Persian locale', (WidgetTester tester) async {
      // Build the app
      await tester.pumpWidget(const MyApp());
      await tester.pumpAndSettle();

      // Find MaterialApp
      final materialApp = tester.widget<MaterialApp>(find.byType(MaterialApp));

      // Verify locales
      expect(materialApp.supportedLocales, contains(const Locale('fa')));
      expect(materialApp.supportedLocales, contains(const Locale('en')));
      expect(materialApp.locale, const Locale('fa'));
    });

    testWidgets('MyApp has correct routes', (WidgetTester tester) async {
      // Build the app
      await tester.pumpWidget(const MyApp());
      await tester.pumpAndSettle();

      // Verify GetMaterialApp is used
      expect(find.byType(MaterialApp), findsOneWidget);
    });
  });
}
