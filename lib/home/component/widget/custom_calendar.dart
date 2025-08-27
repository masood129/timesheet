import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:shamsi_date/shamsi_date.dart';
import '../../controller/home_controller.dart';
import 'grid_calendar_day_card.dart';

class CustomCalendarWidget extends StatelessWidget {
  final HomeController homeController = Get.find<HomeController>();

  CustomCalendarWidget({super.key});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final year = homeController.currentYear.value;
    final month = homeController.currentMonth.value;
    final daysInMonth = homeController.daysInMonth;

    // Calculate the first day of the month and its weekday
    final firstDayOfMonth = Jalali(year, month, 1);
    final firstWeekday = firstDayOfMonth.weekDay; // 1 (Saturday) to 7 (Friday)

    // Create a list of days including padding for weekday alignment
    final days = List.generate(
      daysInMonth,
      (index) => Jalali(year, month, index + 1),
    );
    final totalSlots =
        daysInMonth + (firstWeekday - 1); // Add padding for empty slots
    final adjustedSlots =
        (totalSlots % 7 == 0) ? totalSlots : totalSlots + (7 - totalSlots % 7);

    return Column(
      children: [
        // Weekday headers
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children:
                [
                  'شنبه',
                  'یک‌شنبه',
                  'دوشنبه',
                  'سه‌شنبه',
                  'چهارشنبه',
                  'پنج‌شنبه',
                  'جمعه',
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
        // Calendar grid
        Expanded(
          child: GridView.builder(
            padding: const EdgeInsets.all(8.0),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 7,
              crossAxisSpacing: 4.0,
              mainAxisSpacing: 4.0,
              childAspectRatio: 0.9, // Adjusted for larger cards
            ),
            itemCount: adjustedSlots,
            itemBuilder: (context, index) {
              if (index < firstWeekday - 1) {
                // Empty slots before the first day
                return Container();
              }
              final dayIndex = index - (firstWeekday - 1);
              if (dayIndex >= daysInMonth) {
                // Empty slots after the last day
                return Container();
              }
              return GridCalendarDayCard(date: days[dayIndex]);
            },
          ),
        ),
        // Button for showing day details
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
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
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
                // Effective Work
                _buildDetailRow(context, 'کار مفید', effectiveWork),
                const SizedBox(height: 8),
                // Holiday Information
                if (holiday != null) ...[
                  _buildHolidaySection(context, holiday),
                  const SizedBox(height: 8),
                ],
                // Note
                if (note != null && note.isNotEmpty)
                  _buildDetailRow(context, 'یادداشت', note),
                // Status
                _buildDetailRow(
                  context,
                  'وضعیت',
                  cardStatus['leaveType'] == 'کاری'
                      ? (cardStatus['isComplete']
                          ? 'روز کاری: کامل'
                          : 'روز کاری: ناقص')
                      : cardStatus['leaveType'] ?? 'بدون اطلاعات',
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
          final additionalDescription = event['additional_description'] as String? ?? '';
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
