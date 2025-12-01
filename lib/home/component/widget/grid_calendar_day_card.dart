import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:shamsi_date/shamsi_date.dart';
import '../../../model/leavetype_model.dart';
import '../../../model/day_period_status.dart';
import '../../controller/home_controller.dart';

class GridCalendarDayCard extends StatelessWidget {
  final Jalali date;

  const GridCalendarDayCard({super.key, required this.date});

  List<Color> _getAllColorsForDay(
    BuildContext context,
    Map<String, dynamic> cardStatus,
    bool isToday,
    bool isHoliday,
    bool isFriday,
    bool isRemoved,
    bool isAdded,
  ) {
    List<Color> colors = [];
    Set<String> addedColorTypes = {}; // برای جلوگیری از رنگ‌های تکراری

    // 1. روز حذف شده فقط خاکستری (حالت خاص)
    if (isRemoved) {
      colors.add(Colors.grey[500]!);
      return colors;
    }

    // 2. رنگ روز امروز (اولویت اول)
    if (isToday) {
      colors.add(Colors.teal[700]!);
      addedColorTypes.add('teal');
    }

    // 3. رنگ تعطیلی رسمی
    if (isHoliday) {
      colors.add(Colors.red[700]!);
      addedColorTypes.add('red');
    }

    // 4. رنگ جمعه (اگر تعطیل رسمی نباشه)
    if (isFriday && !isHoliday && !addedColorTypes.contains('red')) {
      colors.add(Colors.deepOrange[600]!);
      addedColorTypes.add('deepOrange');
    }

    // 5. رنگ روز اضافه شده از بازه ماهانه
    if (isAdded && !isToday) {
      colors.add(Colors.deepPurple[500]!);
      addedColorTypes.add('deepPurple');
    }

    // 6. رنگ نوع روز (بر اساس leave type)
    final leaveType = cardStatus['leaveType'] as LeaveType?;
    final isComplete = cardStatus['isComplete'] as bool;

    if (leaveType != null) {
      switch (leaveType) {
        case LeaveType.work:
        case LeaveType.mission:
          // روز کاری یا ماموریت
          if (isComplete) {
            if (!addedColorTypes.contains('green')) {
              colors.add(Colors.green[600]!);
              addedColorTypes.add('green');
            }
          } else {
            // روز کاری ناقص: زرد
            if (!addedColorTypes.contains('amber') &&
                !addedColorTypes.contains('yellow')) {
              colors.add(Colors.amber[700]!);
              addedColorTypes.add('amber');
            }
          }
          break;

        case LeaveType.annualLeave:
          // مرخصی استحقاقی
          if (!addedColorTypes.contains('blue')) {
            colors.add(Colors.blue[600]!);
            addedColorTypes.add('blue');
          }
          break;

        case LeaveType.sickLeave:
          // مرخصی استعلاجی
          if (!addedColorTypes.contains('red')) {
            colors.add(Colors.pink[700]!);
            addedColorTypes.add('pink');
          }
          break;

        case LeaveType.giftLeave:
          // مرخصی هدیه
          if (!addedColorTypes.contains('purple') &&
              !addedColorTypes.contains('deepPurple')) {
            colors.add(Colors.purple[600]!);
            addedColorTypes.add('purple');
          }
          break;
      }
    }

    // 7. اگر هیچ رنگی نداشتیم، رنگ پیش‌فرض خاکستری
    if (colors.isEmpty) {
      colors.add(Colors.grey[600]!);
    }

    return colors;
  }

  Color _getPrimaryIconColor(List<Color> colors) {
    return colors.first;
  }

  IconData _getIconForDayType(
    Map<String, dynamic> cardStatus,
    bool isToday,
    bool isRemoved,
  ) {
    if (isRemoved) return Icons.block_rounded;
    if (isToday) return Icons.today_rounded;

    final leaveType = cardStatus['leaveType'] as LeaveType?;
    final isComplete = cardStatus['isComplete'] as bool;

    if (leaveType == LeaveType.work || leaveType == LeaveType.mission) {
      return isComplete ? Icons.check_circle_rounded : Icons.warning_rounded;
    }

    switch (leaveType) {
      case LeaveType.annualLeave:
        return Icons.beach_access_rounded;
      case LeaveType.sickLeave:
        return Icons.local_hospital_rounded;
      case LeaveType.giftLeave:
        return Icons.card_giftcard_rounded;
      case LeaveType.mission:
        return Icons.flight_takeoff_rounded;
      default:
        return Icons.event_note_rounded;
    }
  }

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

      // دریافت تمام رنگ‌های مرتبط با روز
      final allColors = _getAllColorsForDay(
        context,
        cardStatus,
        isToday,
        isHoliday,
        isFriday,
        isRemoved,
        isAdded,
      );
      final iconColor = _getPrimaryIconColor(allColors);
      final iconData = _getIconForDayType(cardStatus, isToday, isRemoved);

      // آیا چند رنگ داریم؟
      final hasMultipleColors = allColors.length > 1;

      // تعیین رنگ‌ها بر اساس وضعیت
      Color? cardColor;
      LinearGradient? cardGradient;
      BorderSide cardBorderSide;
      double cardOpacity = 1.0;

      if (isRemoved) {
        // روز حذف شده: خاکستری
        cardColor = Colors.grey[200];
        cardOpacity = 0.6;
        cardBorderSide = BorderSide(color: Colors.grey[400]!, width: 2);
      } else if (hasMultipleColors) {
        // چند رنگ: gradient ترکیبی
        cardGradient = LinearGradient(
          colors: allColors.map((c) => c.withValues(alpha: 0.2)).toList(),
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          stops: List.generate(
            allColors.length,
            (i) => i / (allColors.length - 1),
          ),
        );
        cardBorderSide = BorderSide(color: iconColor, width: isToday ? 3 : 2);
      } else {
        // یک رنگ
        cardGradient = LinearGradient(
          colors: [
            iconColor.withValues(alpha: 0.25),
            iconColor.withValues(alpha: 0.1),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        );
        cardBorderSide = BorderSide(color: iconColor, width: isToday ? 3 : 2);
      }

      // تعیین رنگ متن
      Color textColor;
      if (isRemoved) {
        textColor = Colors.grey[600]!;
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
                    ? 8
                    : isHoliday || isAdded
                    ? 4
                    : 2,
            shadowColor: iconColor.withValues(alpha: isToday ? 0.5 : 0.3),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
              side: cardBorderSide,
            ),
            child: Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12),
                gradient: cardGradient,
                color: cardGradient == null ? cardColor : null,
              ),
              padding: const EdgeInsets.all(8.0),
              child: Stack(
                children: [
                  // محتوای اصلی
                  Padding(
                    padding: const EdgeInsets.only(top: 1, bottom: 1),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const SizedBox(height: 14), // فضا برای ایکون بالا
                        // شماره روز
                        Text(
                          date.day.toString(),
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            fontFamily: 'BNazanin',
                            color: textColor,
                            height: 1.0,
                          ),
                          textAlign: TextAlign.center,
                        ),

                        const SizedBox(height: 1),

                        // نام روز هفته
                        Text(
                          date.formatter.wN,
                          style: TextStyle(
                            fontSize: 9,
                            fontFamily: 'BNazanin',
                            fontWeight: FontWeight.w500,
                            color: textColor.withValues(alpha: 0.7),
                            height: 1.0,
                          ),
                          textAlign: TextAlign.center,
                          overflow: TextOverflow.ellipsis,
                          maxLines: 1,
                        ),

                        const SizedBox(height: 2),

                        // کار مفید یا نوع مرخصی
                        if (!isRemoved)
                          Flexible(
                            child: Padding(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 4,
                              ),
                              child: Text(
                                cardStatus['leaveType'] != null &&
                                        cardStatus['leaveType'] !=
                                            LeaveType.work &&
                                        cardStatus['leaveType'] !=
                                            LeaveType.mission
                                    ? (cardStatus['leaveType'] as LeaveType)
                                        .displayName
                                    : effectiveWork,
                                style: TextStyle(
                                  fontSize: 8,
                                  fontFamily: 'BNazanin',
                                  fontWeight: FontWeight.w600,
                                  color: textColor.withValues(alpha: 0.85),
                                  height: 1.1,
                                ),
                                textAlign: TextAlign.center,
                                overflow: TextOverflow.ellipsis,
                                maxLines: 2,
                              ),
                            ),
                          ),

                        // نمایش "خارج از بازه" برای روزهای removed
                        if (isRemoved)
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 4),
                            child: Text(
                              'خارج از بازه',
                              style: TextStyle(
                                fontSize: 8,
                                fontFamily: 'BNazanin',
                                fontWeight: FontWeight.bold,
                                color: textColor,
                                height: 1.0,
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ),
                      ],
                    ),
                  ),

                  // ایکون وضعیت رنگی (گوشه بالا وسط)
                  Positioned(
                    top: 4,
                    left: 0,
                    right: 0,
                    child: Center(
                      child: Tooltip(
                        message: homeController.getTooltipMessage(date),
                        child: Container(
                          width: 32,
                          height: 32,
                          decoration: BoxDecoration(
                            gradient:
                                hasMultipleColors
                                    ? LinearGradient(
                                      colors: allColors,
                                      begin: Alignment.topLeft,
                                      end: Alignment.bottomRight,
                                      stops: List.generate(
                                        allColors.length,
                                        (i) => i / (allColors.length - 1),
                                      ),
                                    )
                                    : LinearGradient(
                                      colors: [
                                        iconColor.withValues(alpha: 0.9),
                                        iconColor.withValues(alpha: 0.7),
                                      ],
                                      begin: Alignment.topLeft,
                                      end: Alignment.bottomRight,
                                    ),
                            shape: BoxShape.circle,
                            boxShadow:
                                hasMultipleColors
                                    ? [
                                      BoxShadow(
                                        color: allColors[0].withValues(
                                          alpha: 0.4,
                                        ),
                                        blurRadius: 6,
                                        offset: const Offset(-1, 1),
                                      ),
                                      if (allColors.length > 1)
                                        BoxShadow(
                                          color: allColors[allColors.length - 1]
                                              .withValues(alpha: 0.4),
                                          blurRadius: 6,
                                          offset: const Offset(1, 3),
                                        ),
                                    ]
                                    : [
                                      BoxShadow(
                                        color: iconColor.withValues(alpha: 0.4),
                                        blurRadius: 6,
                                        offset: const Offset(0, 2),
                                      ),
                                    ],
                          ),
                          child: Icon(iconData, size: 18, color: Colors.white),
                        ),
                      ),
                    ),
                  ),

                  // آیکون یادداشت (گوشه پایین چپ)
                  if (note != null && note.isNotEmpty && !isRemoved)
                    Positioned(
                      bottom: 4,
                      left: 4,
                      child: Container(
                        padding: const EdgeInsets.all(3),
                        decoration: BoxDecoration(
                          color: Colors.amber[600],
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(
                              color: Colors.amber[600]!.withValues(alpha: 0.4),
                              blurRadius: 4,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        child: const Icon(
                          Icons.note_rounded,
                          size: 12,
                          color: Colors.white,
                        ),
                      ),
                    ),

                  // دکمه info (گوشه پایین راست)
                  if (!isRemoved)
                    Positioned(
                      bottom: 2,
                      right: 2,
                      child: InkWell(
                        onTap: () => _showDayDetailsDialog(context, date),
                        borderRadius: BorderRadius.circular(12),
                        child: Container(
                          padding: const EdgeInsets.all(4),
                          child: Icon(
                            Icons.info_outline_rounded,
                            size: 14,
                            color: iconColor.withValues(alpha: 0.7),
                          ),
                        ),
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

        final leaveType = cardStatus['leaveType'] as LeaveType?;

        return SizedBox(
          width: MediaQuery.of(context).size.width * 0.8,
          child: SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.all(16),
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
                    leaveType == LeaveType.work ||
                            leaveType == LeaveType.mission
                        ? (cardStatus['isComplete']
                            ? 'روز کاری: کامل'
                            : 'روز کاری: ناقص')
                        : leaveType?.displayName ?? 'بدون اطلاعات',
                  ),
                ],
              ),
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
