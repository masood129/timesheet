import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:shamsi_date/shamsi_date.dart';
import 'package:timesheet/home/component/widget/calculation_summary.dart';
import 'package:timesheet/home/component/widget/car_costs_tab.dart';
import 'package:timesheet/home/component/widget/daily_details_tab.dart';
import 'package:timesheet/home/component/widget/tasks_tab.dart';
import '../controller/task_controller.dart';
import '../controller/home_controller.dart';

class NoteDialog extends StatelessWidget {
  final Jalali date;
  final HomeController homeController = Get.find<HomeController>();

  NoteDialog({super.key, required this.date});

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<TaskController>();
    controller.loadDailyDetail(date, homeController.dailyDetails);
    final colorScheme = Theme.of(context).colorScheme;

    return SingleChildScrollView(
      child: Container(
        height: Get.height * 0.85,
        width: Get.width,
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(context).viewInsets.bottom,
          right: 15,
          left: 15,
          top: 10,
        ),
        child: Column(
          children: [
            Center(
              child: Text(
                '${date.formatter.wN} ${date.day} ${date.formatter.mN}',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: colorScheme.primary,
                ),
              ),
            ),
            const SizedBox(height: 10),
            Expanded(
              child: DefaultTabController(
                length: 3,
                child: Column(
                  children: [
                    TabBar(
                      labelColor: colorScheme.primary,
                      unselectedLabelColor: Theme.of(context).disabledColor,
                      indicatorColor: colorScheme.primary,
                      tabs: [
                        Tab(text: 'day_details'.tr),
                        Tab(text: 'task'.tr),
                        Tab(text: 'personal_car_costs'.tr),
                      ],
                    ),
                    Expanded(
                      child: TabBarView(
                        children: [
                          DailyDetailsTab(controller: controller),
                          TasksTab(controller: controller),
                          CarCostsTab(controller: controller),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 10),
            CalculationSummary(controller: controller),
            const SizedBox(height: 20),
            Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: controller.saveDailyDetail,
                    icon: Icon(
                      Icons.save,
                      color: colorScheme.onPrimary,
                      size: 24,
                    ),
                    label: Text(
                      'save'.tr,
                      style: TextStyle(
                        color: colorScheme.onPrimary,
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: colorScheme.primary,
                      padding: const EdgeInsets.symmetric(
                        vertical: 12,
                        horizontal: 15,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      elevation: 4,
                      shadowColor: colorScheme.primary.withOpacity(0.3),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 15),
          ],
        ),
      ),
    );
  }
}
