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

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 4.0, vertical: 4.0),
      child: GestureDetector(
        onTap: () {
          homeController.openNoteDialog(context, widget.date);
        },
        child: Card(
          elevation: isToday ? 8 : 4,
          shadowColor: isToday ? Colors.blue.withValues(alpha: 0.3) : null,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
            side:
                isToday
                    ? BorderSide(color: Colors.amber[300]!, width: 1.5)
                    : isHoliday
                    ? BorderSide(color: Colors.red[300]!, width: 1.5)
                    : BorderSide.none,
          ),
          child: Container(
            decoration:
                isToday
                    ? BoxDecoration(
                      borderRadius: BorderRadius.circular(12),
                      gradient: LinearGradient(
                        colors: [Colors.blue[800]!, Colors.blue[200]!],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                    )
                    : isHoliday
                    ? BoxDecoration(
                      borderRadius: BorderRadius.circular(12),
                      gradient: LinearGradient(
                        colors: [Colors.red[600]!, Colors.red[200]!],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                    )
                    : BoxDecoration(
                      color: isFromOtherMonth 
                          ? colorScheme.surfaceContainerHighest.withValues(alpha: 0.7)
                          : colorScheme.surface,
                      borderRadius: BorderRadius.circular(12),
                      border: isFromOtherMonth && !isToday && !isHoliday
                          ? Border.all(
                              color: colorScheme.primary.withValues(alpha: 0.3),
                              width: 1.5,
                            )
                          : null,
                    ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                ListTile(
                  contentPadding: const EdgeInsets.symmetric(horizontal: 8.0),
                  leading: Tooltip(
                    message: homeController.getTooltipMessage(widget.date),
                    child: Container(
                      decoration: BoxDecoration(
                        border: Border.all(
                          color:
                              Theme.of(context).brightness == Brightness.light
                                  ? colorScheme.outline
                                  : colorScheme.outlineVariant,
                          width: 1.5,
                        ),
                        shape: BoxShape.circle,
                      ),
                      child: CircleAvatar(
                        backgroundColor:
                            isToday
                                ? Colors.tealAccent[400]
                                : cardStatus['avatarColor'],
                        child: Icon(
                          isToday
                              ? Icons.event_available
                              : cardStatus['avatarIcon'],
                          color:
                              isToday
                                  ? Colors.white
                                  : cardStatus['avatarIconColor'],
                        ),
                      ),
                    ),
                  ),
                  title: Text(
                    '${widget.date.formatter.wN} ${widget.date.day}${isFromOtherMonth ? ' (${widget.date.formatter.mN})' : ''}',
                    style: TextStyle(
                      fontSize: 14,
                      color:
                          isToday || isHoliday
                              ? Colors.white
                              : isFromOtherMonth
                              ? colorScheme.primary.withValues(alpha: 0.7)
                              : isFriday
                              ? colorScheme.error
                              : null,
                      fontWeight:
                          isToday || isFriday || isHoliday
                              ? FontWeight.bold
                              : FontWeight.normal,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                  subtitle: Text(
                    effectiveWork,
                    style: TextStyle(
                      fontSize: 12,
                      color:
                          isToday || isHoliday
                              ? Colors.white70
                              : colorScheme.onSurface.withValues(alpha: 0.7),
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                  trailing: IconButton(
                    iconSize: 24,
                    icon: Icon(
                      _isExpanded
                          ? Icons.keyboard_arrow_up
                          : Icons.keyboard_arrow_down,
                      color: isToday || isHoliday ? Colors.white : null,
                    ),
                    onPressed: () {
                      setState(() {
                        _isExpanded = !_isExpanded;
                      });
                    },
                  ),
                ),
                if (_isExpanded)
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: _buildExpandedContent(context, widget.date),
                  ),
              ],
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
        '${'personal_car_cost'.tr}: ${detail.personalCarCosts.map((cost) => '${cost.kilometers ?? 0} km: ${cost.cost ?? 0}').join(', ')}',
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
