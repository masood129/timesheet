// grid_calendar_day_card.dart (بروزرسانی شده)
import 'package:flutter/material.dart';
import 'package:get/Get.dart';
import 'package:shamsi_date/shamsi_date.dart';
import '../../../model/leavetype_model.dart';
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
      final isFromOtherMonth = homeController.isDayFromOtherMonth(date);

      return GestureDetector(
        onTap: () {
          homeController.openNoteDialog(context, date);
        },
        child: Card(
          elevation:
              isToday
                  ? 6
                  : isHoliday
                  ? 4
                  : 2,
          shadowColor:
              isToday
                  ? Colors.blue.withOpacity(0.4)
                  : isHoliday
                  ? Colors.red.withOpacity(0.3)
                  : colorScheme.shadow.withOpacity(0.2),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
            side:
                isToday
                    ? BorderSide(color: Colors.amber[300]!, width: 1.5)
                    : isHoliday
                    ? BorderSide(color: Colors.red[300]!, width: 1.5)
                    : BorderSide.none,
          ),
          child: Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(8),
              gradient:
                  isToday
                      ? LinearGradient(
                        colors: [Colors.blue[700]!, Colors.blue[200]!],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      )
                      : isHoliday
                      ? LinearGradient(
                        colors: [Colors.red[600]!, Colors.red[200]!],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      )
                      : null,
              color: isToday || isHoliday 
                  ? null 
                  : isFromOtherMonth 
                  ? colorScheme.surfaceContainerHighest.withOpacity(0.7)
                  : colorScheme.surface,
              border: isFromOtherMonth && !isToday && !isHoliday
                  ? Border.all(
                      color: colorScheme.primary.withOpacity(0.3),
                      width: 1.5,
                      style: BorderStyle.solid,
                    )
                  : null,
            ),
            padding: const EdgeInsets.all(6.0),
            child: Stack(
              children: [
                Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      date.day.toString(),
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                        fontFamily: 'BNazanin',
                        color:
                            isToday || isHoliday
                                ? Colors.white
                                : isFromOtherMonth
                                ? colorScheme.primary.withOpacity(0.7)
                                : isFriday
                                ? colorScheme.error
                                : colorScheme.onSurface,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    Text(
                      isFromOtherMonth 
                          ? '${date.formatter.wN}\n${date.formatter.mN}'
                          : date.formatter.wN,
                      style: TextStyle(
                        fontSize: isFromOtherMonth ? 10 : 12,
                        fontFamily: 'BNazanin',
                        color:
                            isToday || isHoliday
                                ? Colors.white70
                                : isFromOtherMonth
                                ? colorScheme.onSurface.withOpacity(0.5)
                                : isFriday
                                ? colorScheme.error.withOpacity(0.7)
                                : colorScheme.onSurface.withOpacity(0.7),
                      ),
                      textAlign: TextAlign.center,
                      overflow: TextOverflow.ellipsis,
                      maxLines: isFromOtherMonth ? 2 : 1,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      cardStatus['leaveType'] != null &&
                              cardStatus['leaveType'] != LeaveType.work &&
                              cardStatus['leaveType'] != LeaveType.mission
                          ? (cardStatus['leaveType'] as LeaveType).displayName
                          : effectiveWork,
                      style: TextStyle(
                        fontSize: 10,
                        fontFamily: 'BNazanin',
                        color:
                            isToday || isHoliday
                                ? Colors.white70
                                : colorScheme.onSurface.withOpacity(0.6),
                      ),
                      textAlign: TextAlign.center,
                      overflow: TextOverflow.ellipsis,
                      maxLines: 2,
                    ),
                  ],
                ),
                Positioned(
                  top: 4,
                  right: 4,
                  child: Tooltip(
                    message: homeController.getTooltipMessage(date),
                    child: Container(
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(
                          color:
                              isToday || isHoliday
                                  ? Colors.white54
                                  : colorScheme.outline,
                          width: 1,
                        ),
                      ),
                      child: CircleAvatar(
                        radius: 10,
                        backgroundColor:
                            isToday
                                ? Colors.tealAccent[400]
                                : cardStatus['avatarColor'],
                        child: Icon(
                          isToday
                              ? Icons.event_available
                              : cardStatus['avatarIcon'],
                          size: 14,
                          color:
                              isToday
                                  ? Colors.white
                                  : cardStatus['avatarIconColor'],
                        ),
                      ),
                    ),
                  ),
                ),
                if (note != null && note.isNotEmpty)
                  Positioned(
                    bottom: 4,
                    left: 4,
                    child: Icon(
                      Icons.note_alt_outlined,
                      size: 14,
                      color:
                          isToday || isHoliday
                              ? Colors.white70
                              : colorScheme.secondary,
                    ),
                  ),
                Positioned(
                  bottom: 4,
                  right: 4,
                  child: IconButton(
                    icon: Icon(
                      Icons.info_outline,
                      size: 14,
                      color:
                          isToday || isHoliday
                              ? Colors.white70
                              : colorScheme.primary.withOpacity(0.7),
                    ),
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(),
                    onPressed: () {
                      _showDayDetailsDialog(context, date);
                    },
                    tooltip: 'جزئیات روز',
                  ),
                ),
              ],
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
