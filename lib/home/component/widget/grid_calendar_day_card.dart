import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:shamsi_date/shamsi_date.dart';
import '../../../model/leavetype_model.dart';
import '../../../model/day_period_status.dart';
import '../../controller/home_controller.dart';

class GridCalendarDayCard extends StatelessWidget {
  final Jalali date;

  const GridCalendarDayCard({super.key, required this.date});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final homeController = Get.find<HomeController>();

    return Obx(() {
      final isFriday = date.weekDay == 7;
      final today = Jalali.now();
      final isToday =
          date.year == today.year &&
          date.month == today.month &&
          date.day == today.day;
      final holiday = homeController.getHolidayForDate(date);
      final isHoliday = holiday != null && holiday['isHoliday'] == true;
      final cardStatus = homeController.getCardStatus(date, context);
      final effectiveWork = homeController.calculateEffectiveWork(date);
      final note = homeController.getNoteForDate(date);

      // دریافت وضعیت روز در بازه ماهانه
      final periodStatus = homeController.getDayPeriodStatus(date);
      final isRemoved = periodStatus == DayPeriodStatus.removed;
      final isAdded = periodStatus == DayPeriodStatus.added;

      // تعیین رنگ‌ها بر اساس وضعیت
      Color? cardColor;
      LinearGradient? cardGradient;
      BorderSide? cardBorderSide;
      Border? cardBorder;
      double cardOpacity = 1.0;

      if (isRemoved) {
        // روز حذف شده: خاکستری
        cardColor = Colors.grey[300];
        cardOpacity = 0.5;
        cardBorder = Border.all(color: Colors.grey[400]!, width: 1.5);
      } else if (isToday) {
        // روز امروز: آبی با gradient
        cardGradient = LinearGradient(
          colors: [Colors.blue[700]!, Colors.blue[200]!],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        );
        cardBorderSide = BorderSide(color: Colors.amber[300]!, width: 2);
      } else if (isHoliday) {
        // تعطیل: قرمز با gradient
        cardGradient = LinearGradient(
          colors: [Colors.red[600]!, Colors.red[200]!],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        );
        cardBorderSide = BorderSide(color: Colors.red[300]!, width: 1.5);
      } else if (isAdded) {
        // روز اضافه شده: بنفش
        cardGradient = LinearGradient(
          colors: [
            Colors.purple[400]!.withValues(alpha: 0.7),
            Colors.purple[100]!.withValues(alpha: 0.5),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        );
        cardBorder = Border.all(color: Colors.purple[400]!, width: 2);
      } else {
        // روز عادی
        cardColor = colorScheme.surface;
      }

      // تعیین رنگ متن
      Color textColor;
      if (isRemoved) {
        textColor = Colors.grey[600]!;
      } else if (isToday || isHoliday) {
        textColor = Colors.white;
      } else if (isAdded) {
        textColor = Colors.purple[900]!;
      } else if (isFriday) {
        textColor = colorScheme.error;
      } else {
        textColor = colorScheme.onSurface;
      }

      return Opacity(
        opacity: cardOpacity,
        child: GestureDetector(
          onTap:
              isRemoved
                  ? null
                  : () {
                    homeController.openNoteDialog(context, date);
                  },
          child: Card(
            elevation:
                isToday
                    ? 6
                    : isHoliday
                    ? 4
                    : isAdded
                    ? 3
                    : 2,
            shadowColor:
                isToday
                    ? Colors.blue.withValues(alpha: 0.4)
                    : isHoliday
                    ? Colors.red.withValues(alpha: 0.3)
                    : isAdded
                    ? Colors.purple.withValues(alpha: 0.3)
                    : colorScheme.shadow.withValues(alpha: 0.2),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
              side: cardBorderSide ?? BorderSide.none,
            ),
            child: Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(8),
                gradient: cardGradient,
                color: cardGradient == null ? cardColor : null,
                border: cardBorder is Border ? cardBorder : null,
              ),
              padding: const EdgeInsets.all(6.0),
              child: Stack(
                children: [
                  // محتوای اصلی
                  Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      // شماره روز
                      Text(
                        date.day.toString(),
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                          fontFamily: 'BNazanin',
                          color: textColor,
                        ),
                        textAlign: TextAlign.center,
                      ),

                      // نام روز هفته
                      Text(
                        date.formatter.wN,
                        style: TextStyle(
                          fontSize: 10,
                          fontFamily: 'BNazanin',
                          color: textColor.withValues(alpha: 0.7),
                        ),
                        textAlign: TextAlign.center,
                        overflow: TextOverflow.ellipsis,
                        maxLines: 1,
                      ),

                      const SizedBox(height: 4),

                      // کار مفید یا نوع مرخصی
                      if (!isRemoved)
                        Text(
                          cardStatus['leaveType'] != null &&
                                  cardStatus['leaveType'] != LeaveType.work &&
                                  cardStatus['leaveType'] != LeaveType.mission
                              ? (cardStatus['leaveType'] as LeaveType)
                                  .displayName
                              : effectiveWork,
                          style: TextStyle(
                            fontSize: 9,
                            fontFamily: 'BNazanin',
                            fontWeight: FontWeight.w500,
                            color: textColor.withValues(alpha: 0.8),
                          ),
                          textAlign: TextAlign.center,
                          overflow: TextOverflow.ellipsis,
                          maxLines: 2,
                        ),

                      // نمایش "حذف شده" برای روزهای removed
                      if (isRemoved)
                        Text(
                          'خارج از بازه',
                          style: TextStyle(
                            fontSize: 9,
                            fontFamily: 'BNazanin',
                            fontWeight: FontWeight.bold,
                            color: textColor,
                          ),
                          textAlign: TextAlign.center,
                        ),
                    ],
                  ),

                  // آیکون وضعیت (گوشه بالا راست)
                  if (!isRemoved)
                    Positioned(
                      top: 2,
                      right: 2,
                      child: Tooltip(
                        message: homeController.getTooltipMessage(date),
                        child: Container(
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            border: Border.all(
                              color:
                                  isToday || isHoliday || isAdded
                                      ? Colors.white54
                                      : colorScheme.outline,
                              width: 1,
                            ),
                          ),
                          child: CircleAvatar(
                            radius: 8,
                            backgroundColor:
                                isToday
                                    ? Colors.tealAccent[400]
                                    : cardStatus['avatarColor'],
                            child: Icon(
                              isToday
                                  ? Icons.event_available
                                  : cardStatus['avatarIcon'],
                              size: 11,
                              color:
                                  isToday
                                      ? Colors.white
                                      : cardStatus['avatarIconColor'],
                            ),
                          ),
                        ),
                      ),
                    ),

                  // آیکون یادداشت (گوشه پایین چپ)
                  if (note != null && note.isNotEmpty && !isRemoved)
                    Positioned(
                      bottom: 2,
                      left: 2,
                      child: Icon(
                        Icons.note_alt_outlined,
                        size: 12,
                        color:
                            isToday || isHoliday || isAdded
                                ? Colors.white70
                                : colorScheme.secondary,
                      ),
                    ),

                  // دکمه info (گوشه پایین راست)
                  if (!isRemoved)
                    Positioned(
                      bottom: 0,
                      right: 0,
                      child: IconButton(
                        icon: Icon(
                          Icons.info_outline,
                          size: 12,
                          color:
                              isToday || isHoliday || isAdded
                                  ? Colors.white70
                                  : colorScheme.primary.withValues(alpha: 0.7),
                        ),
                        padding: EdgeInsets.zero,
                        constraints: const BoxConstraints(),
                        onPressed: () {
                          _showDayDetailsDialog(context, date);
                        },
                        tooltip: 'جزئیات روز',
                      ),
                    ),

                  // آیکون قفل برای روزهای حذف شده
                  if (isRemoved)
                    Positioned(
                      top: 2,
                      right: 2,
                      child: Icon(
                        Icons.lock_outline,
                        size: 12,
                        color: Colors.grey[600],
                      ),
                    ),
                ],
              ),
            ),
          ),
        ),
      );
    });
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
