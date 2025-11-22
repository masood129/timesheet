import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';
import 'package:timesheet/home/component/widget/calculation_summary.dart';
import 'package:timesheet/home/controller/task_controller.dart';

void main() {
  group('CalculationSummary Widget', () {
    late TaskController mockController;

    setUp(() {
      Get.testMode = true;
      mockController = TaskController();
      mockController.summaryReport.value = 'کارکرد: 8 ساعت';
      mockController.presenceDuration.value = 'حضور: 8 ساعت و 30 دقیقه';
      mockController.effectiveWork.value = 'کارکرد موثر: 8 ساعت';
      mockController.taskDetails.value = ['پروژه A: 4 ساعت', 'پروژه B: 4 ساعت'];
      mockController.costDetails.value = ['رفت و برگشت: 10000 تومان'];
    });

    tearDown(() {
      Get.reset();
    });

    testWidgets('renders correctly with data', (WidgetTester tester) async {
      await tester.pumpWidget(
        GetMaterialApp(
          home: Scaffold(body: CalculationSummary(controller: mockController)),
        ),
      );

      expect(find.text('کارکرد: 8 ساعت'), findsOneWidget);
      expect(find.byType(ExpansionTile), findsOneWidget);
    });

    testWidgets('expands and shows details when tapped', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        GetMaterialApp(
          home: Scaffold(body: CalculationSummary(controller: mockController)),
        ),
      );

      expect(find.text('پروژه A: 4 ساعت'), findsNothing);

      await tester.tap(find.byType(ExpansionTile));
      await tester.pumpAndSettle();

      expect(find.text('پروژه A: 4 ساعت'), findsOneWidget);
      expect(find.text('پروژه B: 4 ساعت'), findsOneWidget);
    });

    testWidgets('displays icons correctly', (WidgetTester tester) async {
      await tester.pumpWidget(
        GetMaterialApp(
          home: Scaffold(body: CalculationSummary(controller: mockController)),
        ),
      );

      await tester.tap(find.byType(ExpansionTile));
      await tester.pumpAndSettle();

      expect(find.byIcon(Icons.calculate), findsOneWidget);
      expect(find.byIcon(Icons.access_time), findsOneWidget);
      expect(find.byIcon(Icons.work), findsOneWidget);
    });
  });
}
