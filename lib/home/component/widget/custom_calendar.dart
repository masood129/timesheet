import 'package:flutter/material.dart';
import 'package:get/Get.dart';
import '../../controller/home_controller.dart';
import 'grid_calendar_day_card.dart';
import 'month_summary_dialog.dart';

class CustomCalendarWidget extends StatelessWidget {
  const CustomCalendarWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return GetBuilder<HomeController>(
      builder: (homeController) {
        final colorScheme = Theme.of(context).colorScheme;
        final screenWidth = MediaQuery.of(context).size.width;

        // محاسبه اندازه‌های responsive بر اساس عرض صفحه
        final double maxCalendarWidth;
        final double headerFontSize;
        final double horizontalPadding;

        if (screenWidth > 1400) {
          // صفحات خیلی بزرگ (desktop/web)
          maxCalendarWidth = 1400;
          headerFontSize = 16;
          horizontalPadding = 16;
        } else if (screenWidth > 1000) {
          // صفحات متوسط به بزرگ
          maxCalendarWidth = 1200;
          headerFontSize = 15;
          horizontalPadding = 12;
        } else if (screenWidth > 600) {
          // صفحات متوسط (tablets)
          maxCalendarWidth = screenWidth * 0.95;
          headerFontSize = 14;
          horizontalPadding = 8;
        } else {
          // صفحات کوچک (mobile)
          maxCalendarWidth = screenWidth;
          headerFontSize = 13;
          horizontalPadding = 6;
        }

        // نمایش loading indicator هنگام بارگذاری داده‌های ماه جدید
        return Obx(() {
          if (homeController.isLoadingMonthData.value) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircularProgressIndicator(color: colorScheme.primary),
                  const SizedBox(height: 16),
                  Text(
                    'در حال بارگذاری...',
                    style: TextStyle(
                      fontSize: 16,
                      fontFamily: 'BNazanin',
                      color: colorScheme.onSurface,
                    ),
                  ),
                ],
              ),
            );
          }

          // استفاده از تابع جدید که همه روزهای ماه + روزهای اضافه شده رو برمی‌گردونه
          final days = homeController.getCalendarDaysWithStatus();

          if (days.isEmpty) {
            return Center(
              child: Text(
                'روزی برای نمایش وجود ندارد',
                style: TextStyle(
                  fontSize: 16,
                  fontFamily: 'BNazanin',
                  color: colorScheme.onSurface,
                ),
              ),
            );
          }

          // محاسبه اولین روز هفته برای تنظیم offset در grid
          final firstDay = days.first;
          // weekday در Jalali: 1=شنبه, 2=یک‌شنبه, ..., 7=جمعه
          final firstWeekday = firstDay.weekDay;

          // تعداد slot های خالی قبل از اولین روز
          // weekday - 1 چون grid از index 0 شروع می‌شود
          final emptySlotsBefore = firstWeekday - 1;

          // محاسبه تعداد کل slot ها برای grid (شامل روزها + slot های خالی)
          final totalSlots = days.length + emptySlotsBefore;
          // تکمیل آخرین ردیف grid
          final adjustedSlots =
              (totalSlots % 7 == 0)
                  ? totalSlots
                  : totalSlots + (7 - totalSlots % 7);

          return Column(
            children: [
              // Grid تقویم با سایز ثابت و وسط‌چین
              Expanded(
                child: SingleChildScrollView(
                  child: Center(
                    child: ConstrainedBox(
                      constraints: BoxConstraints(
                        maxWidth: maxCalendarWidth, // عرض responsive
                      ),
                      child: Column(
                        children: [
                          // هدر روزهای هفته - با همان ساختار Grid
                          Padding(
                            padding: EdgeInsets.symmetric(
                              horizontal: horizontalPadding,
                              vertical: 4.0,
                            ),
                            child: GridView.count(
                              shrinkWrap: true,
                              physics: const NeverScrollableScrollPhysics(),
                              crossAxisCount: 7,
                              childAspectRatio: 2.5,
                              children:
                                  [
                                    'شنبه', // index 0, weekday 1
                                    'یک‌شنبه', // index 1, weekday 2
                                    'دوشنبه', // index 2, weekday 3
                                    'سه‌شنبه', // index 3, weekday 4
                                    'چهارشنبه', // index 4, weekday 5
                                    'پنج‌شنبه', // index 5, weekday 6
                                    'جمعه', // index 6, weekday 7
                                  ].asMap().entries.map((entry) {
                                    return Center(
                                      child: Text(
                                        entry.value,
                                        textAlign: TextAlign.center,
                                        style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                          fontFamily: 'BNazanin',
                                          color:
                                              entry.key == 6
                                                  ? colorScheme.error
                                                  : colorScheme.onSurface,
                                          fontSize: headerFontSize,
                                        ),
                                      ),
                                    );
                                  }).toList(),
                            ),
                          ),

                          // Grid تقویم با 7 ستون ثابت
                          Padding(
                            padding: EdgeInsets.all(horizontalPadding),
                            child: GridView.builder(
                              shrinkWrap: true,
                              physics: const NeverScrollableScrollPhysics(),
                              gridDelegate:
                                  SliverGridDelegateWithFixedCrossAxisCount(
                                    crossAxisCount:
                                        7, // 7 ستون ثابت برای 7 روز هفته
                                    crossAxisSpacing:
                                        screenWidth > 1000 ? 6.0 : 4.0,
                                    mainAxisSpacing:
                                        screenWidth > 1000 ? 6.0 : 4.0,
                                    childAspectRatio: 1.0, // مربع کردن کارت‌ها
                                  ),
                              itemCount: adjustedSlots,
                              itemBuilder: (context, index) {
                                // اگر در محدوده slot های خالی قبل از اولین روز باشیم
                                if (index < emptySlotsBefore) {
                                  return Container();
                                }

                                // محاسبه index روز در لیست days
                                final dayIndex = index - emptySlotsBefore;

                                // اگر index از تعداد روزها بیشتر باشد، slot خالی
                                if (dayIndex >= days.length) {
                                  return Container();
                                }

                                // نمایش روز
                                return GridCalendarDayCard(
                                  date: days[dayIndex],
                                );
                              },
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),

              // دکمه خلاصه ماه
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Center(
                  child: Tooltip(
                    message: 'مشاهده خلاصه و آمار ماه',
                    child: ElevatedButton(
                      onPressed: () {
                        showDialog(
                          context: context,
                          builder: (context) => const MonthSummaryDialog(),
                        );
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: colorScheme.primary,
                        foregroundColor: colorScheme.onPrimary,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        padding: const EdgeInsets.symmetric(
                          horizontal: 20,
                          vertical: 14,
                        ),
                        elevation: 4,
                        shadowColor: colorScheme.primary.withValues(alpha: 0.3),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.summarize_rounded,
                            color: colorScheme.onPrimary,
                            size: 20,
                          ),
                          const SizedBox(width: 10),
                          Text(
                            'خلاصه ماه',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              fontFamily: 'BNazanin',
                              color: colorScheme.onPrimary,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ],
          );
        });
      },
    );
  }
}
