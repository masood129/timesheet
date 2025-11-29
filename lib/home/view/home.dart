import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../component/widget/calendar_app_bar.dart';
import '../component/widget/calendar_day_card.dart';
import '../component/widget/custom_calendar.dart';
import '../component/widget/main_drawer.dart';
import '../controller/home_controller.dart';
import '../controller/task_controller.dart';

class CalendarView extends StatelessWidget {
  CalendarView({super.key});

  final HomeController homeController = Get.put(HomeController());
  final TaskController taskController = Get.put(TaskController());

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CalendarAppBar(),
      drawer: MainDrawer(),
      body: Obx(() {
        // استفاده از daysInCurrentMonth که بازه سفارشی را در نظر می‌گیرد
        final days = homeController.daysInCurrentMonth;

        return Obx(() {
          if (homeController.isListView.value) {
            return ListView.builder(
              padding: const EdgeInsets.all(8.0),
              itemCount: days.length,
              itemBuilder: (context, index) {
                return CalendarDayCard(date: days[index]);
              },
            );
          } else {
            return CustomCalendarWidget();
          }
        });
      }),
    );
  }
}