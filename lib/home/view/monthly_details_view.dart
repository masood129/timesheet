import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:shamsi_date/shamsi_date.dart';
import 'package:timesheet/home/controller/home_controller.dart';
import 'package:timesheet/home/controller/monthly_details_controller.dart';
import '../component/widget/monthly_details_table.dart';
import '../../core/utils/page_title_manager.dart';

class MonthlyDetailsView extends StatelessWidget {
  MonthlyDetailsView({super.key});

  final HomeController homeController = Get.find<HomeController>();
  final MonthlyDetailsController controller = Get.put(MonthlyDetailsController());

  @override
  Widget build(BuildContext context) {
    // Set page title when building the widget
    WidgetsBinding.instance.addPostFrameCallback((_) {
      PageTitleManager.setTitle('جزئیات ماهانه');
    });
    
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: Obx(() {
          final year = homeController.currentYear.value;
          final month = homeController.currentMonth.value;
          final monthName = Jalali(year, month).formatter.mN;
          return Text('${'monthly_details'.tr}: $monthName $year');
        }),
        backgroundColor: colorScheme.primaryContainer,
        elevation: 2,
        actions: [
          IconButton(
            icon: Icon(Icons.download, color: colorScheme.onPrimaryContainer),
            tooltip: 'export_to_excel'.tr,
            onPressed: controller.exportToExcel,
          ),
        ],
      ),
      body: Obx(() {
        if (controller.isLoading.value) {
          return const Center(child: CircularProgressIndicator());
        }
        if (controller.projects.isEmpty && !controller.isLoading.value) {
          return Center(child: Text('no_projects'.tr));
        }
        final daysInMonth = homeController.daysInMonth;
        if (daysInMonth == 0) {
          return Center(child: Text('no_details'.tr));
        }
        return MonthlyDetailsTable(
          daysInMonth: daysInMonth,
          projects: controller.projects.toList(),
          dailyDetails: homeController.dailyDetails.toList(),
        );
      }),
    );
  }
}