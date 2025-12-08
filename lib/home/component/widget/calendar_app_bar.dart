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
        final firstName = authController.user.value?['firstName'] ?? '';
        final lastName = authController.user.value?['lastName'] ?? '';
        final username = authController.user.value?['Username'] ?? '';
        final displayName = (firstName.isNotEmpty || lastName.isNotEmpty)
            ? '$firstName $lastName'.trim()
            : username;
        final isCustom = homeController.isCurrentMonthPeriodCustom;
        return Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Text(
              '${'calendar_title'.tr}: $monthName $year${isCustom ? ' (ویرایش شده)' : ''}',
            ),
            if (displayName.isNotEmpty)
              Text(
                displayName,
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
          iconSize: 22,
          padding: const EdgeInsets.all(8),
          constraints: const BoxConstraints(),
          onPressed: homeController.previousMonth,
        ),
        IconButton(
          icon: const Icon(Icons.arrow_forward),
          iconSize: 22,
          padding: const EdgeInsets.all(8),
          constraints: const BoxConstraints(),
          onPressed: homeController.nextMonth,
        ),
        Obx(
          () => IconButton(
            icon: Icon(
              homeController.isWeekView.value
                  ? Icons.view_module
                  : Icons.view_week,
            ),
            iconSize: 22,
            padding: const EdgeInsets.all(8),
            constraints: const BoxConstraints(),
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
            iconSize: 22,
            padding: const EdgeInsets.all(8),
            constraints: const BoxConstraints(),
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
