import 'package:flutter/material.dart';
import 'package:get/Get.dart';
import 'package:shamsi_date/shamsi_date.dart';
import '../../../model/leavetype_model.dart';
import '../../../model/day_period_status.dart';
import '../../controller/home_controller.dart';
import 'grid_calendar_day_card.dart';

class WeeklyCalendarWidget extends StatelessWidget {
  const WeeklyCalendarWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return GetBuilder<HomeController>(
      builder: (homeController) {
        final colorScheme = Theme.of(context).colorScheme;
        final weekDays = homeController.getCurrentWeekDays();

        return Column(
          children: [
            // راهنمای رنگ‌ها
            if (homeController.isCurrentMonthPeriodCustom)
              _buildColorLegend(context),
            
            // اطلاعات هفته
            Container(
              padding: const EdgeInsets.all(12),
              margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: colorScheme.primaryContainer,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'هفته: ${weekDays.first.formatter.d} تا ${weekDays.last.formatter.d}',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      fontFamily: 'BNazanin',
                      color: colorScheme.onPrimaryContainer,
                    ),
                  ),
                  Row(
                    children: [
                      IconButton(
                        icon: Icon(
                          Icons.arrow_back_ios,
                          color: colorScheme.onPrimaryContainer,
                          size: 18,
                        ),
                        onPressed: homeController.previousWeek,
                        tooltip: 'هفته قبل',
                      ),
                      IconButton(
                        icon: Icon(
                          Icons.today,
                          color: colorScheme.onPrimaryContainer,
                          size: 18,
                        ),
                        onPressed: () {
                          homeController.currentWeekStartDate.value = Jalali.now();
                          homeController.update();
                        },
                        tooltip: 'هفته جاری',
                      ),
                      IconButton(
                        icon: Icon(
                          Icons.arrow_forward_ios,
                          color: colorScheme.onPrimaryContainer,
                          size: 18,
                        ),
                        onPressed: homeController.nextWeek,
                        tooltip: 'هفته بعد',
                      ),
                    ],
                  ),
                ],
              ),
            ),
            
            // Grid هفتگی
            Expanded(
              child: GridView.builder(
                padding: const EdgeInsets.all(8.0),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 7,
                  crossAxisSpacing: 6.0,
                  mainAxisSpacing: 6.0,
                  childAspectRatio: 1.2, // کمی کوتاه‌تر از نمای ماهانه
                ),
                itemCount: 7,
                itemBuilder: (context, index) {
                  return GridCalendarDayCard(date: weekDays[index]);
                },
              ),
            ),
            
            // دکمه جزئیات روز امروز
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
                  shadowColor: colorScheme.primary.withValues(alpha: 0.3),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.info_outline, color: colorScheme.onPrimary),
                    const SizedBox(width: 8),
                    Text(
                      'جزئیات روز امروز',
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

  /// راهنمای رنگ‌ها برای ماه‌های با بازه سفارشی
  Widget _buildColorLegend(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: colorScheme.surface,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: colorScheme.outline.withValues(alpha: 0.3),
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          _buildLegendItem(
            context,
            color: colorScheme.surface,
            label: 'روز عادی',
            icon: Icons.check_circle_outline,
          ),
          _buildLegendItem(
            context,
            color: Colors.purple[100]!,
            label: 'اضافه شده',
            icon: Icons.add_circle_outline,
          ),
          _buildLegendItem(
            context,
            color: Colors.grey[300]!,
            label: 'حذف شده',
            icon: Icons.remove_circle_outline,
          ),
        ],
      ),
    );
  }

  Widget _buildLegendItem(
    BuildContext context, {
    required Color color,
    required String label,
    required IconData icon,
  }) {
    final colorScheme = Theme.of(context).colorScheme;
    
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 20,
          height: 20,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(4),
            border: Border.all(
              color: colorScheme.outline.withValues(alpha: 0.5),
            ),
          ),
          child: Icon(icon, size: 14, color: colorScheme.primary),
        ),
        const SizedBox(width: 4),
        Text(
          label,
          style: TextStyle(
            fontSize: 11,
            fontFamily: 'BNazanin',
            color: colorScheme.onSurface,
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
        final periodStatus = homeController.getDayPeriodStatus(date);

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
                if (homeController.isCurrentMonthPeriodCustom)
                  _buildDetailRow(
                    context,
                    'وضعیت بازه',
                    periodStatus.displayName,
                  ),
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

