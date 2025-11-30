import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../component/widget/calendar_app_bar.dart';
import '../component/widget/calendar_day_card.dart';
import '../component/widget/custom_calendar.dart';
import '../component/widget/weekly_calendar.dart';
import '../component/widget/main_drawer.dart';
import '../component/widget/timer_dialog.dart';
import '../controller/home_controller.dart';
import '../controller/task_controller.dart';
import '../../core/utils/page_title_manager.dart';

class CalendarView extends StatelessWidget {
  CalendarView({super.key});

  final HomeController homeController = Get.put(HomeController());
  final TaskController taskController = Get.put(TaskController());

  void _openTimerDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => const TimerDialog(),
    );
  }

  @override
  Widget build(BuildContext context) {
    // Set page title when building the widget
    WidgetsBinding.instance.addPostFrameCallback((_) {
      PageTitleManager.setTitle('تقویم');
    });
    return Scaffold(
      appBar: CalendarAppBar(),
      drawer: MainDrawer(),
      body: Obx(() {
        // بررسی نمای هفتگی یا ماهانه
        if (homeController.isWeekView.value) {
          // نمای هفتگی
          return const WeeklyCalendarWidget();
        }

        // نمای ماهانه
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
            return const CustomCalendarWidget();
          }
        });
      }),
      floatingActionButton: Obx(() {
        final isProjectTimerRunning = taskController.isTimerRunning.value;
        final isPersonalTimerRunning = taskController.isPersonalTimerRunning.value;
        final projectDuration = taskController.timerDuration.value;
        final personalDuration = taskController.personalTimerDuration.value;
        final colorScheme = Theme.of(context).colorScheme;
        
        return FloatingActionButton.extended(
          onPressed: () => _openTimerDialog(context),
          icon: Icon(
            isProjectTimerRunning || isPersonalTimerRunning 
                ? Icons.timer 
                : Icons.timer_outlined,
            color: Colors.white,
          ),
          label: Text(
            isProjectTimerRunning 
                ? projectDuration
                : isPersonalTimerRunning
                    ? personalDuration
                    : 'timer'.tr,
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
              fontFeatures: [FontFeature.tabularFigures()],
            ),
          ),
          backgroundColor: isProjectTimerRunning
              ? colorScheme.primary
              : isPersonalTimerRunning
                  ? colorScheme.secondary
                  : colorScheme.primary,
          elevation: 4,
        );
      }),
    );
  }
}
