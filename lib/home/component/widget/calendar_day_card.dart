import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:shamsi_date/shamsi_date.dart';
import 'package:timesheet/core/theme/theme.dart';

import '../../controller/home_controller.dart';
import '../../controller/task_controller.dart';
import '../note_dialog.dart';

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
    final cardStatus = homeController.getCardStatus(widget.date, context);
    final effectiveWork = homeController.calculateEffectiveWork(widget.date);
    final today = Jalali.now();
    final isToday = widget.date.year == today.year &&
        widget.date.month == today.month &&
        widget.date.day == today.day;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 6),
      child: GestureDetector(
        onTap: () {
          taskController.loadDailyDetail(widget.date, homeController.dailyDetails);
          showModalBottomSheet(
            useSafeArea: true,
            enableDrag: false,
            isScrollControlled: true,
            context: context,
            backgroundColor: Theme.of(context).scaffoldBackgroundColor,
            shape: const RoundedRectangleBorder(
                borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
            builder: (_) => NoteDialog(date: widget.date),
          );
        },
        child: Card(
          elevation: isToday ? 8 : 4,
          shadowColor: isToday ? Colors.blue.withOpacity(0.3) : null,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
            side: isToday
                ? BorderSide(color: Colors.amber[300]!, width: 1.5)
                : BorderSide.none,
          ),
          child: Container(
            decoration: isToday
                ? BoxDecoration(
              borderRadius: BorderRadius.circular(12),
              gradient: LinearGradient(
                colors: [Colors.blue[800]!, Colors.blue[200]!],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            )
                : BoxDecoration(
                color: colorScheme.surface,
                borderRadius: BorderRadius.circular(12)),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                ListTile(
                  leading: Container(
                    decoration: BoxDecoration(
                      border: Border.all(
                        color: Theme.of(context).brightness == Brightness.light
                            ? colorScheme.outline
                            : colorScheme.outlineVariant,
                        width: 1.5,
                      ),
                      shape: BoxShape.circle,
                    ),
                    child: CircleAvatar(
                      backgroundColor:
                      isToday ? Colors.tealAccent[400] : cardStatus['avatarColor'],
                      child: Icon(
                        isToday ? Icons.event_available : cardStatus['avatarIcon'],
                        color: isToday ? Colors.white : cardStatus['avatarIconColor'],
                      ),
                    ),
                  ),
                  title: Text(
                    '${widget.date.formatter.wN} ${widget.date.day} ${widget.date.formatter.mN} ${widget.date.year}',
                    style: TextStyle(
                      color: isToday
                          ? Colors.white
                          : isFriday
                          ? colorScheme.error
                          : null,
                      fontWeight: isToday || isFriday ? FontWeight.bold : FontWeight.normal,
                    ),
                  ),
                  subtitle: Text(
                    effectiveWork.isNotEmpty ? effectiveWork : 'no_effective_work'.tr,
                    style: TextStyle(
                        color: isToday
                            ? Colors.white70
                            : colorScheme.onSurface.withOpacity(0.7)),
                  ),
                  trailing: IconButton(
                    iconSize: 35,
                    icon: Icon(
                      _isExpanded ? Icons.keyboard_arrow_up : Icons.keyboard_arrow_down,
                      color: isToday ? Colors.white : null,
                    ),
                    onPressed: () {
                      setState(() {
                        _isExpanded = !_isExpanded;
                      });
                    },
                  ),
                ),
                AnimatedCrossFade(
                  firstChild: const SizedBox.shrink(),
                  secondChild: ClipRect(
                    child: Container(
                      decoration: BoxDecoration(
                        borderRadius: const BorderRadius.vertical(bottom: Radius.circular(12)),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: _buildDayDetails(context, widget.date, cardStatus),
                      ),
                    ),
                  ),
                  crossFadeState:
                  _isExpanded ? CrossFadeState.showSecond : CrossFadeState.showFirst,
                  duration: const Duration(milliseconds: 300),
                  firstCurve: Curves.easeInOut,
                  secondCurve: Curves.easeInOut,
                  sizeCurve: Curves.easeInOut,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildDayDetails(BuildContext context, Jalali date, Map<String, dynamic> cardStatus) {
    final colorScheme = Theme.of(context).colorScheme;
    final gregorianDate = date.toGregorian();
    final formattedDate =
        '${gregorianDate.year}-${gregorianDate.month.toString().padLeft(2, '0')}-${gregorianDate.day.toString().padLeft(2, '0')}';
    final detail = homeController.dailyDetails.firstWhereOrNull((d) => d.date == formattedDate);

    if (detail == null) {
      return Text('no_details'.tr, style: TextStyle(color: colorScheme.onSurface));
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (cardStatus['leaveType'] != null) ...[
          _buildStatusText(context, cardStatus),
        ],
        const SizedBox(height: 8),
        _buildDetailRow(context, 'arrival_time'.tr, detail.arrivalTime),
        _buildDetailRow(context, 'leave_time'.tr, detail.leaveTime),
        _buildDetailRow(context, 'personal_time'.tr, '${detail.personalTime ?? 0} ${'minute'.tr}'),
        _buildDetailRow(context, 'go_cost'.tr, detail.goCost?.toString()),
        _buildDetailRow(context, 'return_cost'.tr, detail.returnCost?.toString()),
        _buildCarCostsRow(context, detail),
        _buildDetailRow(context, 'description'.tr, detail.description),
        _buildTaskSection(context, detail),
      ],
    );
  }

  Widget _buildStatusText(BuildContext context, Map<String, dynamic> cardStatus) {
    final colorScheme = Theme.of(context).colorScheme;
    final leaveType = cardStatus['leaveType'];
    if (leaveType == 'کاری') {
      return Text(
        cardStatus['isComplete'] ? 'وضعیت: کامل'.tr : 'وضعیت: ناقص'.tr,
        style: TextStyle(
            color: cardStatus['isComplete']
                ? colorScheme.completedStatus
                : colorScheme.incompleteStatus),
      );
    }
    return Text('وضعیت روز: $leaveType'.tr);
  }

  Widget _buildDetailRow(BuildContext context, String label, String? value) {
    if (value == null || value.isEmpty || value == '0 minute') {
      return const SizedBox.shrink();
    }
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Text('$label: $value',
          style: TextStyle(color: Theme.of(context).colorScheme.onSurface)),
    );
  }

  Widget _buildCarCostsRow(BuildContext context, detail) {
    if (detail.personalCarCosts.isEmpty) {
      return const SizedBox.shrink();
    }
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Text(
        '${'personal_car_cost'.tr}: ${detail.personalCarCosts.map((cost) => '${cost.kilometers ?? 0} km: ${cost.cost ?? 0}').join(', ')}',
        style: TextStyle(color: Theme.of(context).colorScheme.onSurface),
      ),
    );
  }

  Widget _buildTaskSection(BuildContext context, detail) {
    final colorScheme = Theme.of(context).colorScheme;
    if (detail.tasks.isEmpty) {
      return const SizedBox.shrink();
    }
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 16),
        Text('tasks'.tr, style: TextStyle(fontWeight: FontWeight.bold, color: colorScheme.primary)),
        ...detail.tasks.map((task) {
          return Padding(
            padding: const EdgeInsets.symmetric(vertical: 4),
            child: Text('- ${task.description ?? 'no_description'.tr} (${task.duration ?? 0} ${'minute'.tr})'),
          );
        }),
      ],
    );
  }
}