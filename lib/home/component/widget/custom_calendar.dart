import 'package:flutter/material.dart';
import 'package:get/Get.dart';
import 'package:shamsi_date/shamsi_date.dart';
import '../../../model/leavetype_model.dart';
import '../../controller/home_controller.dart';
import 'grid_calendar_day_card.dart';

class CustomCalendarWidget extends StatelessWidget {
  const CustomCalendarWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return GetBuilder<HomeController>(
      builder: (homeController) {
        final colorScheme = Theme.of(context).colorScheme;
        final days = homeController.daysInCurrentMonth;

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
            Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: 8.0,
                vertical: 4.0,
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
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
                      return Expanded(
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
                            fontSize: 12,
                          ),
                        ),
                      );
                    }).toList(),
              ),
            ),
            Expanded(
              child: GridView.builder(
                padding: const EdgeInsets.all(8.0),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 7,
                  crossAxisSpacing: 4.0,
                  mainAxisSpacing: 4.0,
                  childAspectRatio: 0.9,
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
                  return GridCalendarDayCard(date: days[dayIndex]);
                },
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: ElevatedButton(
                onPressed: () {
                  _showDayDetailsDialog(context, Jalali.now());
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: colorScheme.primary,
                  foregroundColor: colorScheme.onPrimary,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 12,
                  ),
                  elevation: 4,
                  shadowColor: colorScheme.primary.withOpacity(0.3),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.info_outline, color: colorScheme.onPrimary),
                    const SizedBox(width: 8),
                    Text(
                      'جزئیات روز',
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
          ],
        );
      },
    );
  }

  void _showDayDetailsDialog(BuildContext context, Jalali date) {
    final colorScheme = Theme.of(context).colorScheme;

    Get.defaultDialog(
      title: 'جزئیات روز ${date.formatter.wN} ${date.day} ${date.formatter.mN}',
      titleStyle: TextStyle(
        fontSize: 18,
        fontWeight: FontWeight.bold,
        fontFamily: 'BNazanin',
        color: colorScheme.primary,
      ),
      content: Obx(() {
        final homeController = Get.find<HomeController>();
        final effectiveWork = homeController.calculateEffectiveWork(date);
        final holiday = homeController.getHolidayForDate(date);
        final cardStatus = homeController.getCardStatus(date, context);
        final note = homeController.getNoteForDate(date);

        return Container(
          width: MediaQuery.of(context).size.width * 0.8,
          padding: const EdgeInsets.all(16),
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                _buildDetailRow(context, 'کار مفید', effectiveWork),
                const SizedBox(height: 8),
                if (holiday != null) ...[
                  _buildHolidaySection(context, holiday),
                  const SizedBox(height: 8),
                ],
                if (note != null && note.isNotEmpty)
                  _buildDetailRow(context, 'یادداشت', note),
                _buildDetailRow(
                  context,
                  'وضعیت',
                  cardStatus['leaveType'] == LeaveType.work ||
                          cardStatus['leaveType'] == LeaveType.mission
                      ? (cardStatus['isComplete']
                          ? 'روز کاری: کامل'
                          : 'روز کاری: ناقص')
                      : cardStatus['leaveType']?.displayName ?? 'بدون اطلاعات',
                ),
              ],
            ),
          ),
        );
      }),
      backgroundColor: colorScheme.surface,
      radius: 12,
      actions: [
        TextButton(
          onPressed: () => Get.back(),
          child: Text(
            'بستن',
            style: TextStyle(
              fontFamily: 'BNazanin',
              color: colorScheme.error,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildDetailRow(BuildContext context, String label, String value) {
    final colorScheme = Theme.of(context).colorScheme;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '$label: ',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontFamily: 'BNazanin',
              color: colorScheme.primary,
              fontSize: 14,
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: TextStyle(
                fontFamily: 'BNazanin',
                color: colorScheme.onSurface,
                fontSize: 14,
              ),
              overflow: TextOverflow.ellipsis,
              maxLines: 2,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHolidaySection(
    BuildContext context,
    Map<String, dynamic> holiday,
  ) {
    final colorScheme = Theme.of(context).colorScheme;
    final events = holiday['events'] as List<dynamic>? ?? [];
    final isHoliday = holiday['isHoliday'] == true;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          isHoliday ? 'تعطیل' : 'رویدادها',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontFamily: 'BNazanin',
            color: isHoliday ? colorScheme.error : colorScheme.primary,
            fontSize: 16,
          ),
        ),
        ...events.map((event) {
          final description = event['description'] as String;
          final additionalDescription =
              event['additional_description'] as String? ?? '';
          final isEventHoliday = event['isHoliday'] == true;
          final isReligious = event['isReligious'] == true;
          return Padding(
            padding: const EdgeInsets.symmetric(vertical: 2),
            child: Text(
              '- $description${additionalDescription.isNotEmpty ? ' ($additionalDescription)' : ''}',
              style: TextStyle(
                fontSize: 14,
                fontFamily: 'BNazanin',
                color:
                    isHoliday
                        ? colorScheme.error
                        : isEventHoliday
                        ? colorScheme.error
                        : isReligious
                        ? colorScheme.secondary
                        : colorScheme.onSurface,
              ),
              overflow: TextOverflow.ellipsis,
              maxLines: 1,
            ),
          );
        }),
      ],
    );
  }
}
