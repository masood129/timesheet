import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:shamsi_date/shamsi_date.dart';
import '../../controller/home_controller.dart';
import '../../controller/auth_controller.dart';

class CalendarAppBar extends StatelessWidget implements PreferredSizeWidget {
  CalendarAppBar({super.key});

  final HomeController homeController = Get.find<HomeController>();
  final AuthController authController = Get.find<AuthController>();

  @override
  Widget build(BuildContext context) {
    return AppBar(
      centerTitle: true,
      title: Obx(() {
        final year = homeController.currentYear.value;
        final month = homeController.currentMonth.value;
        final monthName = Jalali(year, month).formatter.mN;
        final username = authController.user.value?['Username'] ?? '';
        final isCustom = homeController.isCurrentMonthPeriodCustom;
        return Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Text(
              '${'calendar_title'.tr}: $monthName $year${isCustom ? ' (ویرایش شده)' : ''}',
            ),
            if (username.isNotEmpty)
              Text(
                username,
                style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.normal,
                ),
              ),
          ],
        );
      }),
      actions: [
        IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: homeController.previousMonth,
        ),
        IconButton(
          icon: const Icon(Icons.arrow_forward),
          onPressed: homeController.nextMonth,
        ),
        Obx(
          () => IconButton(
            icon: Icon(
              homeController.isWeekView.value
                  ? Icons.view_module
                  : Icons.view_week,
            ),
            onPressed: homeController.toggleWeekMonthView,
            tooltip:
                homeController.isWeekView.value ? 'نمای ماهانه' : 'نمای هفتگی',
          ),
        ),
        Obx(
          () => IconButton(
            icon: Icon(
              homeController.isListView.value ? Icons.grid_view : Icons.list,
            ),
            onPressed: homeController.toggleView,
            tooltip:
                homeController.isListView.value ? 'نمای شبکه‌ای' : 'نمای لیست',
          ),
        ),
      ],
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}
