import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:shamsi_date/shamsi_date.dart';
import '../component/widget/calendar_app_bar.dart';
import '../component/widget/calendar_day_card.dart';
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
        if (homeController.isLoading.value) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const CircularProgressIndicator(),
                const SizedBox(height: 16),
                Text('loading_calendar'.tr),
              ],
            ),
          );
        }

        final year = homeController.currentYear.value;
        final month = homeController.currentMonth.value;
        final daysInMonth = homeController.daysInMonth;

        return ListView.builder(
          itemCount: daysInMonth,
          itemBuilder: (context, index) {
            final day = index + 1;
            final date = Jalali(year, month, day);
            return CalendarDayCard(date: date);
          },
        );
      }),
    );
  }
}