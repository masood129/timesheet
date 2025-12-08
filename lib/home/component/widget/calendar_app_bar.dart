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
    final theme = Theme.of(context);
    final textColor = theme.appBarTheme.foregroundColor ?? Colors.white;
    final secondaryTextColor =
        theme.appBarTheme.foregroundColor?.withOpacity(0.7) ?? Colors.white70;
    final badgeColor =
        theme.appBarTheme.foregroundColor?.withOpacity(0.24) ?? Colors.white24;

    return Material(
      elevation: 4,
      borderRadius: const BorderRadius.vertical(bottom: Radius.circular(16)),
      child: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: false,
        automaticallyImplyLeading: false,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(bottom: Radius.circular(16)),
        ),
        flexibleSpace: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [theme.primaryColor, theme.primaryColorDark],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: const BorderRadius.vertical(
              bottom: Radius.circular(16),
            ),
          ),
        ),
        leading: IconButton(
          icon: const Icon(Icons.menu),
          color: textColor,
          padding: const EdgeInsets.all(12),
          tooltip: 'منو',
          onPressed: () {
            Scaffold.of(context).openDrawer();
          },
        ),
        title: Obx(() {
          final year = homeController.currentYear.value;
          final month = homeController.currentMonth.value;
          final monthName = Jalali(year, month).formatter.mN;
          final firstName = authController.user.value?['firstName'] ?? '';
          final lastName = authController.user.value?['lastName'] ?? '';
          final username = authController.user.value?['Username'] ?? '';
          final displayName =
              (firstName.isNotEmpty || lastName.isNotEmpty)
                  ? '$firstName $lastName'.trim()
                  : username;
          final isCustom = homeController.isCurrentMonthPeriodCustom;

          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                children: [
                  Text(
                    '$monthName $year',
                    style: TextStyle(
                      color: textColor,
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  if (isCustom) ...[
                    const SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: badgeColor,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        'ویرایش شده',
                        style: TextStyle(color: textColor, fontSize: 12),
                      ),
                    ),
                  ],
                ],
              ),
              if (displayName.isNotEmpty)
                Text(
                  displayName,
                  style: TextStyle(color: secondaryTextColor, fontSize: 14),
                  overflow: TextOverflow.ellipsis,
                ),
            ],
          );
        }),
        actions: [
          IconButton(
            icon: const Icon(Icons.chevron_left),
            color: textColor,
            padding: const EdgeInsets.all(12),
            tooltip: 'ماه قبل',
            onPressed: homeController.previousMonth,
          ),
          // وضعیت ماه بین دو فلش
          Obx(() {
            final status = homeController.monthStatus.value;
            String statusText = '';
            Color statusColor = Colors.grey;
            switch (status) {
              case 'draft':
                statusText = 'پیش‌نویس';
                statusColor = Colors.orange;
                break;
              case 'submitted_to_general_manager':
                statusText = 'ارسال به مدیر کل';
                statusColor = Colors.blue;
                break;
              case 'approved':
                statusText = 'تایید شده';
                statusColor = Colors.green;
                break;
              case 'submitted_to_group_manager':
                statusText = 'ارسال به مدیر گروه';
                statusColor = Colors.blueAccent;
                break;
              case 'submitted_to_finance':
                statusText = 'ارسال به امور مالی';
                statusColor = Colors.purple;
                break;
            }
            return statusText.isNotEmpty
                ? Container(
                  margin: const EdgeInsets.symmetric(horizontal: 4),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: statusColor.withOpacity(0.15),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    statusText,
                    style: TextStyle(
                      color: statusColor,
                      fontWeight: FontWeight.bold,
                      fontSize: 13,
                    ),
                  ),
                )
                : const SizedBox.shrink();
          }),
          IconButton(
            icon: const Icon(Icons.chevron_right),
            color: textColor,
            padding: const EdgeInsets.all(12),
            tooltip: 'ماه بعد',
            onPressed: homeController.nextMonth,
          ),
          Obx(
            () => IconButton(
              icon: Icon(
                homeController.isWeekView.value
                    ? Icons.view_module
                    : Icons.view_week,
                color: textColor,
              ),
              padding: const EdgeInsets.all(12),
              tooltip:
                  homeController.isWeekView.value
                      ? 'نمای ماهانه'
                      : 'نمای هفتگی',
              onPressed: homeController.toggleWeekMonthView,
            ),
          ),
          Obx(
            () => IconButton(
              icon: Icon(
                homeController.isListView.value ? Icons.grid_view : Icons.list,
                color: textColor,
              ),
              padding: const EdgeInsets.all(12),
              tooltip:
                  homeController.isListView.value
                      ? 'نمای شبکه‌ای'
                      : 'نمای لیست',
              onPressed: homeController.toggleView,
            ),
          ),
          const SizedBox(width: 6),
        ],
      ),
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}
