// calendar_day_card.dart (بروزرسانی شده)
import 'package:flutter/material.dart';
import 'package:get/Get.dart';
import 'package:shamsi_date/shamsi_date.dart';
import 'package:timesheet/core/theme/theme.dart';
import '../../../model/daily_detail_model.dart';
import '../../../model/leavetype_model.dart';
import '../../controller/home_controller.dart';
import '../../controller/task_controller.dart';

class CalendarDayCard extends StatefulWidget {
  final Jalali date;

  const CalendarDayCard({super.key, required this.date});

  @override
  State<CalendarDayCard> createState() => _CalendarDayCardState();
}

class _CalendarDayCardState extends State<CalendarDayCard>
    with SingleTickerProviderStateMixin {
  final HomeController homeController = Get.find<HomeController>();
  final TaskController taskController = Get.find<TaskController>();
  bool _isExpanded = false;

  List<Color> _getAllColorsForDay(
    BuildContext context,
    Map<String, dynamic> cardStatus,
    bool isToday,
    bool isHoliday,
    bool isFriday,
    bool isFromOtherMonth,
  ) {
    List<Color> colors = [];
    Set<String> addedColorTypes = {}; // برای جلوگیری از رنگ‌های تکراری

    // 1. رنگ روز امروز (اولویت اول)
    if (isToday) {
      colors.add(Colors.teal[700]!);
      addedColorTypes.add('teal');
    }

    // 2. رنگ تعطیلی رسمی
    if (isHoliday) {
      colors.add(Colors.red[700]!);
      addedColorTypes.add('red');
    }

    // 3. رنگ جمعه (اگر تعطیل رسمی نباشه)
    if (isFriday && !isHoliday && !addedColorTypes.contains('red')) {
      colors.add(Colors.deepOrange[600]!);
      addedColorTypes.add('deepOrange');
    }

    // 4. رنگ روز از ماه دیگر
    if (isFromOtherMonth && !isToday) {
      colors.add(Colors.indigo[400]!);
      addedColorTypes.add('indigo');
    }

    // 5. رنگ نوع روز (بر اساس leave type)
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
          if (!addedColorTypes.contains('purple')) {
            colors.add(Colors.purple[600]!);
            addedColorTypes.add('purple');
          }
          break;
      }
    }

    // 6. اگر هیچ رنگی نداشتیم، رنگ پیش‌فرض خاکستری
    if (colors.isEmpty) {
      colors.add(Colors.grey[600]!);
    }

    return colors;
  }

  Color _getPrimaryIconColor(List<Color> colors) {
    return colors.first;
  }

  IconData _getIconForDayType(Map<String, dynamic> cardStatus, bool isToday) {
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
    final isFriday = widget.date.weekDay == 7;
    final today = Jalali.now();
    final isToday =
        widget.date.year == today.year &&
        widget.date.month == today.month &&
        widget.date.day == today.day;
    final holiday = homeController.getHolidayForDate(widget.date);
    final isHoliday = holiday != null && holiday['isHoliday'] == true;
    final cardStatus = homeController.getCardStatus(widget.date, context);
    final effectiveWork = homeController.calculateEffectiveWork(widget.date);
    final isFromOtherMonth = homeController.isDayFromOtherMonth(widget.date);

    // دریافت تمام رنگ‌های مرتبط با روز
    final allColors = _getAllColorsForDay(
      context,
      cardStatus,
      isToday,
      isHoliday,
      isFriday,
      isFromOtherMonth,
    );
    final iconColor = _getPrimaryIconColor(allColors);
    final iconData = _getIconForDayType(cardStatus, isToday);

    // ساخت gradient ترکیبی
    final hasMultipleColors = allColors.length > 1;
    final cardGradient =
        hasMultipleColors
            ? LinearGradient(
              colors: allColors.map((c) => c.withValues(alpha: 0.15)).toList(),
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              stops: List.generate(
                allColors.length,
                (i) => i / (allColors.length - 1),
              ),
            )
            : null;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 6.0, vertical: 6.0),
      child: GestureDetector(
        onTap: () {
          homeController.openNoteDialog(context, widget.date);
        },
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeInOut,
          child: Card(
            elevation:
                isToday
                    ? 12
                    : hasMultipleColors
                    ? 8
                    : 6,
            shadowColor: iconColor.withValues(alpha: isToday ? 0.5 : 0.35),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
              side:
                  hasMultipleColors
                      ? BorderSide(width: isToday ? 2.5 : 2, color: iconColor)
                      : isToday
                      ? BorderSide(color: iconColor, width: 2.5)
                      : BorderSide.none,
            ),
            child: Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(16),
                gradient: cardGradient,
                color:
                    cardGradient == null
                        ? (isFromOtherMonth
                            ? colorScheme.surfaceContainerHighest.withValues(
                              alpha: 0.5,
                            )
                            : colorScheme.surface)
                        : null,
                border:
                    !hasMultipleColors && isFromOtherMonth
                        ? Border.all(
                          color: colorScheme.outline.withValues(alpha: 0.3),
                          width: 1,
                        )
                        : null,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  ListTile(
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 12.0,
                      vertical: 4.0,
                    ),
                    leading: Tooltip(
                      message: homeController.getTooltipMessage(widget.date),
                      child: Container(
                        width: 56,
                        height: 56,
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
                                  ? allColors
                                      .map(
                                        (c) => BoxShadow(
                                          color: c.withValues(alpha: 0.3),
                                          blurRadius: 6,
                                          offset: const Offset(0, 3),
                                        ),
                                      )
                                      .toList()
                                  : [
                                    BoxShadow(
                                      color: iconColor.withValues(alpha: 0.4),
                                      blurRadius: 8,
                                      offset: const Offset(0, 4),
                                    ),
                                  ],
                        ),
                        child: Icon(iconData, color: Colors.white, size: 28),
                      ),
                    ),
                    title: Text(
                      '${widget.date.formatter.wN} ${widget.date.day}${isFromOtherMonth ? ' (${widget.date.formatter.mN})' : ''}',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color:
                            isFromOtherMonth
                                ? colorScheme.onSurface.withValues(alpha: 0.6)
                                : isFriday
                                ? colorScheme.error
                                : colorScheme.onSurface,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                    subtitle: Text(
                      effectiveWork,
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w500,
                        color: colorScheme.onSurface.withValues(alpha: 0.7),
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                    trailing: IconButton(
                      iconSize: 28,
                      icon: AnimatedRotation(
                        turns: _isExpanded ? 0.5 : 0,
                        duration: const Duration(milliseconds: 300),
                        child: Icon(
                          Icons.expand_more_rounded,
                          color: colorScheme.primary,
                        ),
                      ),
                      onPressed: () {
                        setState(() {
                          _isExpanded = !_isExpanded;
                        });
                      },
                    ),
                  ),
                  AnimatedSize(
                    duration: const Duration(milliseconds: 300),
                    curve: Curves.easeInOut,
                    child:
                        _isExpanded
                            ? Padding(
                              padding: const EdgeInsets.fromLTRB(
                                12.0,
                                0,
                                12.0,
                                12.0,
                              ),
                              child: _buildExpandedContent(
                                context,
                                widget.date,
                              ),
                            )
                            : const SizedBox.shrink(),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildExpandedContent(BuildContext context, Jalali date) {
    final colorScheme = Theme.of(context).colorScheme;
    final gregorianDate = date.toGregorian();
    final formattedDate =
        '${gregorianDate.year}-${gregorianDate.month.toString().padLeft(2, '0')}-${gregorianDate.day.toString().padLeft(2, '0')}';
    final detail = homeController.dailyDetails.firstWhereOrNull(
      (d) => d.date == formattedDate,
    );
    final holiday = homeController.getHolidayForDate(date);
    final note = homeController.getNoteForDate(date);
    final cardStatus = homeController.getCardStatus(date, context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (holiday != null) ...[
          _buildHolidaySection(context, holiday),
          const SizedBox(height: 8),
        ],
        if (note != null && note.isNotEmpty) ...[
          Text(
            '${'note'.tr}: $note',
            style: TextStyle(fontSize: 12, color: colorScheme.onSurface),
            overflow: TextOverflow.ellipsis,
            maxLines: 2,
          ),
          const SizedBox(height: 8),
        ],
        if (cardStatus['leaveType'] != null) ...[
          _buildStatusText(context, cardStatus),
          const SizedBox(height: 8),
        ],
        if (detail != null) ...[
          _buildDetailRow(context, 'arrival_time'.tr, detail.arrivalTime),
          _buildDetailRow(context, 'leave_time'.tr, detail.leaveTime),
          _buildDetailRow(
            context,
            'personal_time'.tr,
            '${detail.personalTime ?? 0} ${'minute'.tr}',
          ),
          _buildDetailRow(context, 'go_cost'.tr, detail.goCost?.toString()),
          _buildDetailRow(
            context,
            'return_cost'.tr,
            detail.returnCost?.toString(),
          ),
          _buildCarCostsRow(context, detail),
          _buildDetailRow(context, 'description'.tr, detail.description),
          _buildTaskSection(context, detail),
        ] else ...[
          Text('no_details'.tr, style: TextStyle(color: colorScheme.onSurface)),
        ],
      ],
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
          isHoliday ? 'holiday'.tr : 'events'.tr,
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: isHoliday ? colorScheme.onError : colorScheme.primary,
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
                color:
                    isHoliday
                        ? colorScheme.onError
                        : isEventHoliday
                        ? colorScheme.onError
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

  Widget _buildStatusText(
    BuildContext context,
    Map<String, dynamic> cardStatus,
  ) {
    final colorScheme = Theme.of(context).colorScheme;
    final leaveType = cardStatus['leaveType'] as LeaveType?;
    if (leaveType == LeaveType.work || leaveType == LeaveType.mission) {
      return Text(
        cardStatus['isComplete']
            ? 'working_day_complete'.tr
            : 'working_day_incomplete'.tr,
        style: TextStyle(
          fontSize: 12,
          color:
              cardStatus['isComplete']
                  ? colorScheme.completedStatus
                  : colorScheme.incompleteStatus,
        ),
        overflow: TextOverflow.ellipsis,
      );
    }
    return Text(
      '${'leave_type'.tr}: ${leaveType?.displayName ?? ''}',
      style: TextStyle(fontSize: 12, color: colorScheme.onSurface),
      overflow: TextOverflow.ellipsis,
    );
  }

  Widget _buildDetailRow(BuildContext context, String label, String? value) {
    if (value == null || value.isEmpty || value == '0 minute') {
      return const SizedBox.shrink();
    }
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Text(
        '$label: $value',
        style: TextStyle(
          fontSize: 12,
          color: Theme.of(context).colorScheme.onSurface,
        ),
        overflow: TextOverflow.ellipsis,
        maxLines: 1,
      ),
    );
  }

  Widget _buildCarCostsRow(BuildContext context, DailyDetail detail) {
    if (detail.personalCarCosts.isEmpty) {
      return const SizedBox.shrink();
    }
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Text(
        '${'personal_car_cost'.tr}: ${detail.personalCarCosts.map((cost) => '${cost.kilometers ?? 0} ${'kilometers'.tr}: ${cost.cost ?? 0}').join(', ')}',
        style: TextStyle(
          fontSize: 12,
          color: Theme.of(context).colorScheme.onSurface,
        ),
        overflow: TextOverflow.ellipsis,
        maxLines: 1,
      ),
    );
  }

  Widget _buildTaskSection(BuildContext context, DailyDetail detail) {
    final colorScheme = Theme.of(context).colorScheme;
    if (detail.tasks.isEmpty) {
      return const SizedBox.shrink();
    }
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 8),
        Text(
          'tasks'.tr,
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: colorScheme.primary,
            fontSize: 14,
          ),
        ),
        ...detail.tasks.map((task) {
          return Padding(
            padding: const EdgeInsets.symmetric(vertical: 2),
            child: Text(
              '- ${task.description ?? 'no_description'.tr} (${task.duration ?? 0} ${'minute'.tr})',
              style: TextStyle(fontSize: 12),
              overflow: TextOverflow.ellipsis,
              maxLines: 1,
            ),
          );
        }),
      ],
    );
  }
}
