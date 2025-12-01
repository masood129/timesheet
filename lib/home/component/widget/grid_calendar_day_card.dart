import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:shamsi_date/shamsi_date.dart';
import '../../../model/leavetype_model.dart';
import '../../../model/day_period_status.dart';
import '../../../core/theme/theme.dart';
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

    final colorScheme = Theme.of(context).colorScheme;

    // 1. روز حذف شده - از theme
    if (isRemoved) {
      colors.add(colorScheme.removedDayColor);
      return colors;
    }

    // 2. رنگ روز امروز (اولویت اول) - از theme
    if (isToday) {
      colors.add(colorScheme.todayColor);
      addedColorTypes.add('today');
    }

    // 3. رنگ تعطیلی رسمی - از theme
    if (isHoliday) {
      colors.add(colorScheme.holidayColor);
      addedColorTypes.add('holiday');
    }

    // 4. رنگ جمعه (اگر تعطیل رسمی نباشه) - از theme
    if (isFriday && !isHoliday && !addedColorTypes.contains('holiday')) {
      colors.add(colorScheme.fridayColor);
      addedColorTypes.add('friday');
    }

    // 5. رنگ روز اضافه شده از بازه ماهانه - از theme
    if (isAdded && !isToday) {
      colors.add(colorScheme.addedDayColor);
      addedColorTypes.add('added');
    }

    // 6. رنگ نوع روز (بر اساس leave type) - از theme
    final leaveType = cardStatus['leaveType'] as LeaveType?;
    final isComplete = cardStatus['isComplete'] as bool;

    if (leaveType != null) {
      switch (leaveType) {
        case LeaveType.work:
          // روز کاری - از theme
          if (isComplete) {
            // روز کاری کامل
            if (!addedColorTypes.contains('work')) {
              colors.add(colorScheme.workCompleteColor);
              addedColorTypes.add('work');
            }
          } else {
            // روز کاری ناقص
            if (!addedColorTypes.contains('work')) {
              colors.add(colorScheme.workIncompleteColor);
              addedColorTypes.add('work');
            }
          }
          break;

        case LeaveType.mission:
          // ماموریت - از theme
          if (!addedColorTypes.contains('mission') &&
              !addedColorTypes.contains('added')) {
            colors.add(colorScheme.missionColor);
            addedColorTypes.add('mission');
          }
          break;

        case LeaveType.annualLeave:
          // مرخصی استحقاقی - از theme
          if (!addedColorTypes.contains('annual')) {
            colors.add(colorScheme.annualLeaveColor);
            addedColorTypes.add('annual');
          }
          break;

        case LeaveType.sickLeave:
          // مرخصی استعلاجی - از theme
          if (!addedColorTypes.contains('holiday') &&
              !addedColorTypes.contains('sick')) {
            colors.add(colorScheme.sickLeaveColor);
            addedColorTypes.add('sick');
          }
          break;

        case LeaveType.giftLeave:
          // مرخصی هدیه - از theme
          if (!addedColorTypes.contains('gift') &&
              !addedColorTypes.contains('mission') &&
              !addedColorTypes.contains('added')) {
            colors.add(colorScheme.giftLeaveColor);
            addedColorTypes.add('gift');
          }
          break;
      }
    }

    // 7. اگر هیچ رنگی نداشتیم، رنگ پیش‌فرض (تیره‌تر)
    if (colors.isEmpty) {
      colors.add(colorScheme.onSurface.withValues(alpha: 0.6));
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
    bool isHoliday,
    bool isFriday,
    bool isAdded,
  ) {
    // طبق راهنما
    if (isRemoved) return Icons.remove_circle_outline; // حذف شده
    if (isToday) return Icons.today_rounded; // روز امروز
    if (isHoliday) return Icons.event_busy_rounded; // تعطیل رسمی
    if (isFriday) return Icons.weekend_rounded; // جمعه
    if (isAdded) return Icons.add_circle_outline; // اضافه شده

    final leaveType = cardStatus['leaveType'] as LeaveType?;
    final isComplete = cardStatus['isComplete'] as bool;

    if (leaveType != null) {
      switch (leaveType) {
        case LeaveType.work:
          // روز کاری کامل یا ناقص
          return isComplete
              ? Icons.check_circle_rounded
              : Icons.warning_rounded;

        case LeaveType.mission:
          // ماموریت
          return Icons.flight_takeoff_rounded;

        case LeaveType.annualLeave:
          // مرخصی استحقاقی
          return Icons.beach_access_rounded;

        case LeaveType.sickLeave:
          // مرخصی استعلاجی
          return Icons.local_hospital_rounded;

        case LeaveType.giftLeave:
          // مرخصی هدیه
          return Icons.card_giftcard_rounded;
      }
    }

    // پیش‌فرض
    return Icons.check_circle_outline;
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
      final iconData = _getIconForDayType(
        cardStatus,
        isToday,
        isRemoved,
        isHoliday,
        isFriday,
        isAdded,
      );

      // آیا چند رنگ داریم؟
      final hasMultipleColors = allColors.length > 1;

      // تعیین رنگ‌ها بر اساس وضعیت
      Color? cardColor;
      LinearGradient? cardGradient;
      BorderSide cardBorderSide;
      double cardOpacity = 1.0;

      if (isRemoved) {
        // روز حذف شده - از theme
        cardColor = colorScheme.removedDayColor;
        cardOpacity = 0.85;
        cardBorderSide = BorderSide(
          color: colorScheme.outline.withValues(alpha: 0.7),
          width: 2.5,
        );
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
        // برای روزهای عادی (بدون رنگ خاص) border مشکی
        final borderColor =
            allColors.first == colorScheme.onSurface.withValues(alpha: 0.6)
                ? colorScheme.onSurface.withValues(alpha: 0.5)
                : iconColor;
        cardBorderSide = BorderSide(color: borderColor, width: isToday ? 3 : 2);
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
          child: LayoutBuilder(
            builder: (context, constraints) {
              // محاسبه اندازه‌های responsive بر اساس عرض کارت
              final cardWidth = constraints.maxWidth;
              final cardHeight = constraints.maxHeight;

              // محاسبه سایزهای متناسب
              final dayFontSize = (cardWidth * 0.25).clamp(18.0, 32.0);
              final weekDayFontSize = (cardWidth * 0.10).clamp(9.0, 12.0);
              final detailFontSize = (cardWidth * 0.07).clamp(7.0, 10.0);
              final iconSize = (cardWidth * 0.24).clamp(20.0, 32.0);
              final noteIconSize = (cardWidth * 0.10).clamp(9.0, 12.0);
              final infoIconSize = (cardWidth * 0.12).clamp(10.0, 14.0);

              return Card(
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
                  padding: EdgeInsets.all((cardWidth * 0.08).clamp(5.0, 10.0)),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // بخش چپ: متن‌ها
                      Expanded(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.start,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            // شماره روز
                            Text(
                              date.day.toString(),
                              style: TextStyle(
                                fontSize: dayFontSize,
                                fontWeight: FontWeight.bold,
                                fontFamily: 'BNazanin',
                                color: textColor,
                                height: 0.9,
                              ),
                            ),

                            SizedBox(height: cardHeight * 0.01),

                            // نام روز هفته
                            Text(
                              date.formatter.wN,
                              style: TextStyle(
                                fontSize: weekDayFontSize,
                                fontFamily: 'BNazanin',
                                fontWeight: FontWeight.w600,
                                color: textColor.withValues(alpha: 0.8),
                                height: 1.0,
                              ),
                              overflow: TextOverflow.ellipsis,
                              maxLines: 1,
                            ),

                            SizedBox(height: cardHeight * 0.008),

                            // کار مفید یا نوع مرخصی
                            if (!isRemoved)
                              Flexible(
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
                                    fontSize: detailFontSize,
                                    fontFamily: 'BNazanin',
                                    fontWeight: FontWeight.w500,
                                    color: textColor.withValues(alpha: 0.7),
                                    height: 1.0,
                                  ),
                                  overflow: TextOverflow.ellipsis,
                                  maxLines: 2,
                                ),
                              ),

                            // نمایش "خارج از بازه" برای روزهای removed
                            if (isRemoved)
                              Flexible(
                                child: Text(
                                  'خارج از بازه',
                                  style: TextStyle(
                                    fontSize: detailFontSize,
                                    fontFamily: 'BNazanin',
                                    fontWeight: FontWeight.bold,
                                    color: textColor,
                                    height: 1.0,
                                  ),
                                ),
                              ),
                          ],
                        ),
                      ),

                      SizedBox(width: cardWidth * 0.02),

                      // بخش راست: ایکون‌ها و دکمه‌ها
                      Column(
                        mainAxisAlignment: MainAxisAlignment.start,
                        crossAxisAlignment: CrossAxisAlignment.end,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          // ایکون وضعیت رنگی (بالا)
                          Tooltip(
                            message: homeController.getTooltipMessage(date),
                            child: Container(
                              width: iconSize,
                              height: iconSize,
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
                                            iconColor,
                                            iconColor.withValues(alpha: 0.8),
                                          ],
                                          begin: Alignment.topLeft,
                                          end: Alignment.bottomRight,
                                        ),
                                shape: BoxShape.circle,
                                boxShadow: [
                                  BoxShadow(
                                    color: iconColor.withValues(alpha: 0.3),
                                    blurRadius: 4,
                                    offset: const Offset(0, 2),
                                  ),
                                ],
                              ),
                              child: Icon(
                                iconData,
                                size: iconSize * 0.55,
                                color: Colors.white,
                              ),
                            ),
                          ),

                          SizedBox(height: cardHeight * 0.25),

                          // ردیف پایین: یادداشت و دکمه info
                          Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              // آیکون یادداشت
                              if (note != null && note.isNotEmpty && !isRemoved)
                                Container(
                                  padding: EdgeInsets.all(noteIconSize * 0.2),
                                  decoration: BoxDecoration(
                                    color: Colors.amber[600],
                                    shape: BoxShape.circle,
                                    boxShadow: [
                                      BoxShadow(
                                        color: Colors.amber[600]!.withValues(
                                          alpha: 0.4,
                                        ),
                                        blurRadius: 3,
                                        offset: const Offset(0, 1),
                                      ),
                                    ],
                                  ),
                                  child: Icon(
                                    Icons.note_rounded,
                                    size: noteIconSize,
                                    color: Colors.white,
                                  ),
                                ),

                              if (note != null && note.isNotEmpty && !isRemoved)
                                SizedBox(width: cardWidth * 0.01),

                              // دکمه info
                              if (!isRemoved)
                                InkWell(
                                  onTap:
                                      () =>
                                          _showDayDetailsDialog(context, date),
                                  borderRadius: BorderRadius.circular(12),
                                  child: Container(
                                    padding: EdgeInsets.all(infoIconSize * 0.2),
                                    child: Icon(
                                      Icons.info_outline_rounded,
                                      size: infoIconSize,
                                      color: iconColor.withValues(alpha: 0.7),
                                    ),
                                  ),
                                ),
                            ],
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              );
            },
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
