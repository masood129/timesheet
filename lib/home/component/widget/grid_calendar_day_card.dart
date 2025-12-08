import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:shamsi_date/shamsi_date.dart';
import '../../../model/leavetype_model.dart';
import '../../../model/day_period_status.dart';
import '../../../model/task_model.dart';
import '../../../core/theme/theme.dart';
import '../../controller/home_controller.dart';
import '../../controller/task_controller.dart';

class GridCalendarDayCard extends StatefulWidget {
  final Jalali date;

  const GridCalendarDayCard({super.key, required this.date});

  @override
  State<GridCalendarDayCard> createState() => _GridCalendarDayCardState();
}

class _GridCalendarDayCardState extends State<GridCalendarDayCard>
    with SingleTickerProviderStateMixin {
  late AnimationController _rotationController;
  bool _wasToday = false;

  @override
  void initState() {
    super.initState();
    _rotationController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    );
  }

  @override
  void dispose() {
    _rotationController.dispose();
    super.dispose();
  }

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
      final isFriday = widget.date.weekDay == 7;
      final today = Jalali.now();
      final isToday =
          widget.date.year == today.year &&
          widget.date.month == today.month &&
          widget.date.day == today.day;

      // شروع یا توقف انیمیشن چرخش برای روز امروز
      if (isToday != _wasToday) {
        _wasToday = isToday;
        if (isToday) {
          _rotationController.repeat();
        } else {
          _rotationController.stop();
          _rotationController.reset();
        }
      }
      final holiday = homeController.getHolidayForDate(widget.date);
      final isHoliday = holiday != null && holiday['isHoliday'] == true;
      final cardStatus = homeController.getCardStatus(widget.date, context);
      final effectiveWork = homeController.calculateEffectiveWork(widget.date);
      final note = homeController.getNoteForDate(widget.date);

      // دریافت وضعیت روز در بازه ماهانه
      final periodStatus = homeController.getDayPeriodStatus(widget.date);
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
                    homeController.openNoteDialog(context, widget.date);
                  },
          child: LayoutBuilder(
            builder: (context, constraints) {
              // محاسبه اندازه‌های responsive بر اساس عرض کارت
              final cardWidth = constraints.maxWidth;
              final cardHeight = constraints.maxHeight;

              // محاسبه سایزهای متناسب (بزرگ‌تر شده)
              final dayFontSize = (cardWidth * 0.30).clamp(22.0, 40.0);
              final weekDayFontSize = (cardWidth * 0.12).clamp(11.0, 15.0);
              final detailFontSize = (cardWidth * 0.09).clamp(9.0, 13.0);
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
                              widget.date.day.toString(),
                              style: TextStyle(
                                fontSize: dayFontSize,
                                fontWeight: FontConfig.fontWeightBold,
                                fontFamily: FontConfig.persianFont,
                                color: textColor,
                                height: 0.9,
                              ),
                            ),

                            SizedBox(height: cardHeight * 0.01),

                            // نام روز هفته
                            Text(
                              widget.date.formatter.wN,
                              style: TextStyle(
                                fontSize: weekDayFontSize,
                                fontFamily: FontConfig.persianFont,
                                fontWeight: FontConfig.fontWeightMedium,
                                color: textColor,
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
                                    fontFamily: FontConfig.persianFont,
                                    fontWeight: FontConfig.fontWeightNormal,
                                    color: textColor,
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
                                    fontFamily: FontConfig.persianFont,
                                    fontWeight: FontConfig.fontWeightBold,
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
                            message: homeController.getTooltipMessage(
                              widget.date,
                            ),
                            child:
                                isToday
                                    ? RotationTransition(
                                      turns: _rotationController,
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
                                                      (i) =>
                                                          i /
                                                          (allColors.length -
                                                              1),
                                                    ),
                                                  )
                                                  : LinearGradient(
                                                    colors: [
                                                      iconColor,
                                                      iconColor.withValues(
                                                        alpha: 0.8,
                                                      ),
                                                    ],
                                                    begin: Alignment.topLeft,
                                                    end: Alignment.bottomRight,
                                                  ),
                                          shape: BoxShape.circle,
                                          boxShadow: [
                                            BoxShadow(
                                              color: iconColor.withValues(
                                                alpha: 0.3,
                                              ),
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
                                    )
                                    : Container(
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
                                                    (i) =>
                                                        i /
                                                        (allColors.length - 1),
                                                  ),
                                                )
                                                : LinearGradient(
                                                  colors: [
                                                    iconColor,
                                                    iconColor.withValues(
                                                      alpha: 0.8,
                                                    ),
                                                  ],
                                                  begin: Alignment.topLeft,
                                                  end: Alignment.bottomRight,
                                                ),
                                        shape: BoxShape.circle,
                                        boxShadow: [
                                          BoxShadow(
                                            color: iconColor.withValues(
                                              alpha: 0.3,
                                            ),
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
                                      () => _showDayDetailsDialog(
                                        context,
                                        widget.date,
                                      ),
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
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;

    // محاسبه اندازه‌های responsive
    final double dialogWidth = screenWidth > 700 ? 650 : screenWidth * 0.95;
    final double titleFontSize = screenWidth > 600 ? 24 : 20;
    final double headerFontSize = screenWidth > 600 ? 18 : 16;
    final double itemFontSize = screenWidth > 600 ? 16 : 15;

    showDialog(
      context: context,
      builder:
          (context) => Dialog(
            backgroundColor: colorScheme.surface,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(24),
            ),
            child: Container(
              width: dialogWidth,
              constraints: BoxConstraints(maxHeight: screenHeight * 0.9),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // هدر دیالوگ
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          colorScheme.primary,
                          colorScheme.primary.withValues(alpha: 0.8),
                        ],
                        begin: Alignment.topRight,
                        end: Alignment.bottomLeft,
                      ),
                      borderRadius: const BorderRadius.only(
                        topLeft: Radius.circular(24),
                        topRight: Radius.circular(24),
                      ),
                    ),
                    child: Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: Colors.white.withValues(alpha: 0.2),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Icon(
                            Icons.info_outline_rounded,
                            color: colorScheme.onPrimary,
                            size: 28,
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'جزئیات روز',
                                style: TextStyle(
                                  fontSize: titleFontSize,
                                  fontWeight: FontWeight.bold,
                                  fontFamily: FontConfig.persianFont,
                                  color: colorScheme.onPrimary,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                '${widget.date.formatter.wN} ${widget.date.day} ${widget.date.formatter.mN}',
                                style: TextStyle(
                                  fontSize: headerFontSize - 2,
                                  fontFamily: FontConfig.persianFont,
                                  color: colorScheme.onPrimary.withValues(
                                    alpha: 0.9,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        IconButton(
                          icon: Icon(
                            Icons.close_rounded,
                            color: colorScheme.onPrimary,
                            size: 28,
                          ),
                          onPressed: () => Navigator.of(context).pop(),
                        ),
                      ],
                    ),
                  ),

                  // محتوای دیالوگ
                  Flexible(
                    child: SingleChildScrollView(
                      padding: const EdgeInsets.all(24),
                      child: Obx(() {
                        final homeController = Get.find<HomeController>();

                        // دریافت daily detail
                        final gregorianDate = widget.date.toGregorian();
                        final formattedDate =
                            '${gregorianDate.year}-${gregorianDate.month.toString().padLeft(2, '0')}-${gregorianDate.day.toString().padLeft(2, '0')}';

                        final detail = homeController.dailyDetails
                            .firstWhereOrNull((d) => d.date == formattedDate);

                        // دریافت TaskController برای دسترسی به پروژه‌ها
                        TaskController? taskController;
                        try {
                          taskController = Get.find<TaskController>();
                        } catch (e) {
                          taskController = null;
                        }

                        final totalTaskMinutes = _calculateTotalTaskMinutes(
                          detail?.tasks ?? const [],
                        );
                        final arrivalTimeValue =
                            detail?.arrivalTime != null
                                ? _formatTime(detail!.arrivalTime!)
                                : '-';
                        final leaveTimeValue =
                            detail?.leaveTime != null
                                ? _formatTime(detail!.leaveTime!)
                                : '-';

                        return Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // جمع ساعت کاری
                            _buildSectionHeader(
                              context,
                              'جمع ساعت کاری',
                              Icons.work_rounded,
                              headerFontSize,
                            ),
                            const SizedBox(height: 16),
                            _buildSummaryCard(
                              context,
                              icon: Icons.work_rounded,
                              iconColor: colorScheme.primary,
                              label: 'جمع ساعت کاری',
                              value: _formatMinutesToHours(totalTaskMinutes),
                              itemFontSize: itemFontSize,
                            ),

                            const Divider(height: 32, thickness: 1.5),

                            // ساعت ورود و خروج
                            _buildSectionHeader(
                              context,
                              'ساعت ورود و خروج',
                              Icons.access_time_rounded,
                              headerFontSize,
                            ),
                            const SizedBox(height: 16),
                            Row(
                              children: [
                                Expanded(
                                  child: _buildSummaryCard(
                                    context,
                                    icon: Icons.login_rounded,
                                    iconColor: Colors.blueGrey,
                                    label: 'ساعت ورود',
                                    value: arrivalTimeValue,
                                    itemFontSize: itemFontSize,
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: _buildSummaryCard(
                                    context,
                                    icon: Icons.logout_rounded,
                                    iconColor: Colors.deepOrange,
                                    label: 'ساعت خروج',
                                    value: leaveTimeValue,
                                    itemFontSize: itemFontSize,
                                  ),
                                ),
                              ],
                            ),

                            const Divider(height: 32, thickness: 1.5),

                            // ساعت کار شخصی
                            _buildSectionHeader(
                              context,
                              'ساعت کار شخصی',
                              Icons.person_rounded,
                              headerFontSize,
                            ),
                            const SizedBox(height: 16),
                            _buildSummaryCard(
                              context,
                              icon: Icons.person_rounded,
                              iconColor: colorScheme.secondary,
                              label: 'ساعت کار شخصی',
                              value:
                                  detail?.personalTime != null
                                      ? _formatMinutesToHours(
                                        detail!.personalTime!,
                                      )
                                      : '0:00',
                              itemFontSize: itemFontSize,
                            ),

                            const Divider(height: 32, thickness: 1.5),

                            // دیرکرد
                            if (detail?.arrivalTime != null) ...[
                              _buildSectionHeader(
                                context,
                                'دیرکرد',
                                Icons.schedule_rounded,
                                headerFontSize,
                              ),
                              const SizedBox(height: 16),
                              _buildSummaryCard(
                                context,
                                icon: Icons.schedule_rounded,
                                iconColor:
                                    _calculateDelay(detail!.arrivalTime!) > 0
                                        ? colorScheme.error
                                        : Colors.green,
                                label: 'دیرکرد',
                                value: _formatDelay(
                                  _calculateDelay(detail.arrivalTime!),
                                ),
                                itemFontSize: itemFontSize,
                              ),
                              const Divider(height: 32, thickness: 1.5),
                            ],

                            // پروژه‌ها
                            _buildSectionHeader(
                              context,
                              'پروژه‌ها',
                              Icons.folder_rounded,
                              headerFontSize,
                            ),
                            const SizedBox(height: 16),
                            if (detail?.tasks.isNotEmpty == true) ...[
                              ...detail!.tasks.map((task) {
                                final project = taskController?.projects
                                    .firstWhereOrNull(
                                      (p) => p.id == task.projectId,
                                    );
                                final projectName =
                                    project?.projectName ??
                                    'پروژه #${task.projectId}';
                                return Padding(
                                  padding: const EdgeInsets.only(bottom: 10),
                                  child: _buildProjectItem(
                                    context,
                                    projectName: projectName,
                                    hours:
                                        task.duration != null
                                            ? _formatMinutesToHours(
                                              task.duration!,
                                            )
                                            : '0:00',
                                    itemFontSize: itemFontSize,
                                  ),
                                );
                              }),
                            ] else
                              _buildEmptyState(
                                context,
                                'پروژه‌ای ثبت نشده',
                                itemFontSize,
                              ),

                            const Divider(height: 32, thickness: 1.5),

                            // مرخصی
                          ],
                        );
                      }),
                    ),
                  ),

                  // دکمه بستن
                  Padding(
                    padding: const EdgeInsets.all(24),
                    child: SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: () => Navigator.of(context).pop(),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: colorScheme.primary,
                          foregroundColor: colorScheme.onPrimary,
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          elevation: 2,
                        ),
                        child: Text(
                          'بستن',
                          style: TextStyle(
                            fontSize: itemFontSize,
                            fontWeight: FontWeight.bold,
                            fontFamily: FontConfig.persianFont,
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
    );
  }

  Widget _buildSectionHeader(
    BuildContext context,
    String title,
    IconData icon,
    double fontSize,
  ) {
    final colorScheme = Theme.of(context).colorScheme;
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: colorScheme.primaryContainer,
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(
            icon,
            color: colorScheme.onPrimaryContainer,
            size: fontSize + 2,
          ),
        ),
        const SizedBox(width: 12),
        Text(
          title,
          style: TextStyle(
            fontSize: fontSize,
            fontWeight: FontWeight.bold,
            fontFamily: FontConfig.persianFont,
            color: colorScheme.primary,
          ),
        ),
      ],
    );
  }

  Widget _buildSummaryCard(
    BuildContext context, {
    required IconData icon,
    required Color iconColor,
    required String label,
    required String value,
    required double itemFontSize,
  }) {
    final colorScheme = Theme.of(context).colorScheme;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            iconColor.withValues(alpha: 0.1),
            iconColor.withValues(alpha: 0.05),
          ],
          begin: Alignment.topRight,
          end: Alignment.bottomLeft,
        ),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: iconColor.withValues(alpha: 0.3), width: 1.5),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: iconColor.withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, color: iconColor, size: 24),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Text(
              label,
              style: TextStyle(
                fontSize: itemFontSize,
                fontFamily: FontConfig.persianFont,
                color: colorScheme.onSurface,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          Text(
            value,
            style: TextStyle(
              fontSize: itemFontSize + 2,
              fontFamily: FontConfig.persianFont,
              color: iconColor,
              fontWeight: FontWeight.bold,
              fontFeatures: const [FontFeature.tabularFigures()],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProjectItem(
    BuildContext context, {
    required String projectName,
    required String hours,
    required double itemFontSize,
  }) {
    final colorScheme = Theme.of(context).colorScheme;

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainerHighest.withValues(alpha: 0.5),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(
          color: colorScheme.outline.withValues(alpha: 0.2),
          width: 1,
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 8,
            height: 8,
            decoration: BoxDecoration(
              color: colorScheme.primary,
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              projectName,
              style: TextStyle(
                fontSize: itemFontSize,
                fontFamily: FontConfig.persianFont,
                color: colorScheme.onSurface,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          Text(
            hours,
            style: TextStyle(
              fontSize: itemFontSize,
              fontFamily: FontConfig.persianFont,
              color: colorScheme.primary,
              fontWeight: FontWeight.bold,
              fontFeatures: const [FontFeature.tabularFigures()],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState(
    BuildContext context,
    String message,
    double itemFontSize,
  ) {
    final colorScheme = Theme.of(context).colorScheme;

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainerHighest.withValues(alpha: 0.3),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(
          color: colorScheme.outline.withValues(alpha: 0.2),
          width: 1,
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.info_outline, color: colorScheme.outline, size: 20),
          const SizedBox(width: 8),
          Text(
            message,
            style: TextStyle(
              fontSize: itemFontSize - 1,
              fontFamily: FontConfig.persianFont,
              color: colorScheme.outline,
            ),
          ),
        ],
      ),
    );
  }

  String _formatMinutesToHours(int totalMinutes) {
    if (totalMinutes == 0) return '0:00';

    final hours = totalMinutes ~/ 60;
    final minutes = totalMinutes % 60;
    return '$hours:${minutes.toString().padLeft(2, '0')}';
  }

  int _calculateDelay(String arrivalTime) {
    try {
      // فرض: ساعت شروع کار استاندارد 9:00 صبح است
      // می‌توانید این مقدار را از تنظیمات یا API دریافت کنید
      const int standardWorkStartHour = 9;
      const int standardWorkStartMinute = 0;

      final parts = arrivalTime.split(':');
      if (parts.length < 2) return 0;

      final arrivalHour = int.parse(parts[0]);
      final arrivalMinute = int.parse(parts[1]);

      final arrivalMinutes = arrivalHour * 60 + arrivalMinute;
      final standardMinutes =
          standardWorkStartHour * 60 + standardWorkStartMinute;

      final delay = arrivalMinutes - standardMinutes;
      return delay > 0 ? delay : 0;
    } catch (e) {
      return 0;
    }
  }

  String _formatDelay(int delayMinutes) {
    if (delayMinutes == 0) return 'بدون دیرکرد';

    final hours = delayMinutes ~/ 60;
    final minutes = delayMinutes % 60;

    if (hours > 0 && minutes > 0) {
      return '$hours ساعت و $minutes دقیقه';
    } else if (hours > 0) {
      return '$hours ساعت';
    } else {
      return '$minutes دقیقه';
    }
  }

  int _calculateTotalTaskMinutes(List<Task> tasks) {
    return tasks.fold<int>(0, (sum, task) => sum + (task.duration ?? 0));
  }

  String _formatTime(String timeStr) {
    if (timeStr.isEmpty) return '-';
    final parts = timeStr.split(':');
    if (parts.length < 2) return timeStr;
    return '${parts[0].padLeft(2, '0')}:${parts[1].padLeft(2, '0')}';
  }
}
