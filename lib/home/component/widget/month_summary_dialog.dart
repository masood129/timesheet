import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:shamsi_date/shamsi_date.dart';
import '../../../core/theme/theme.dart';
import '../../../model/leavetype_model.dart';
import '../../controller/home_controller.dart';
import '../../controller/task_controller.dart';

class MonthSummaryDialog extends StatelessWidget {
  const MonthSummaryDialog({super.key});

  @override
  Widget build(BuildContext context) {
    final homeController = Get.find<HomeController>();
    // بررسی اینکه TaskController registered هست یا نه
    TaskController? taskController;
    try {
      taskController = Get.find<TaskController>();
    } catch (e) {
      taskController = null;
    }
    
    final colorScheme = Theme.of(context).colorScheme;
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;

    // محاسبه اندازه‌های responsive
    final double dialogWidth = screenWidth > 700 ? 650 : screenWidth * 0.95;
    final double titleFontSize = screenWidth > 600 ? 24 : 20;
    final double headerFontSize = screenWidth > 600 ? 18 : 16;
    final double itemFontSize = screenWidth > 600 ? 16 : 15;

    return Dialog(
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
              child: Obx(() {
                final year = homeController.currentYear.value;
                final month = homeController.currentMonth.value;
                final monthName = Jalali(year, month).formatter.mN;
                
                return Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.2),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Icon(
                        Icons.summarize_rounded,
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
                            'خلاصه ماه',
                            style: TextStyle(
                              fontSize: titleFontSize,
                              fontWeight: FontWeight.bold,
                              fontFamily: 'BNazanin',
                              color: colorScheme.onPrimary,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            '$monthName $year',
                            style: TextStyle(
                              fontSize: headerFontSize - 2,
                              fontFamily: 'BNazanin',
                              color: colorScheme.onPrimary.withValues(alpha: 0.9),
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
                );
              }),
            ),

            // محتوای دیالوگ
            Flexible(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(24),
                child: Obx(() {
                  final summary = _calculateMonthSummary(
                    homeController,
                    taskController,
                  );

                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // جمع ساعت‌ها
                      _buildSectionHeader(
                        context,
                        'جمع ساعات',
                        Icons.access_time_rounded,
                        headerFontSize,
                      ),
                      const SizedBox(height: 16),
                      _buildSummaryCard(
                        context,
                        icon: Icons.work_rounded,
                        iconColor: colorScheme.primary,
                        label: 'ساعت کاری پروژه‌ها',
                        value: summary['totalWorkHours'] as String,
                        itemFontSize: itemFontSize,
                      ),
                      const SizedBox(height: 12),
                      _buildSummaryCard(
                        context,
                        icon: Icons.person_rounded,
                        iconColor: colorScheme.secondary,
                        label: 'ساعت کار شخصی',
                        value: summary['totalPersonalHours'] as String,
                        itemFontSize: itemFontSize,
                      ),
                      const SizedBox(height: 12),
                      _buildSummaryCard(
                        context,
                        icon: Icons.schedule_rounded,
                        iconColor: colorScheme.tertiary,
                        label: 'ساعت حضور',
                        value: summary['totalPresenceHours'] as String,
                        itemFontSize: itemFontSize,
                      ),
                      const SizedBox(height: 12),
                      _buildSummaryCard(
                        context,
                        icon: Icons.calendar_today_rounded,
                        iconColor: Colors.green,
                        label: 'روزهای کاری',
                        value: '${summary['workDaysCount']} روز',
                        itemFontSize: itemFontSize,
                      ),

                      const Divider(height: 32, thickness: 1.5),

                      // ساعت کار به تفکیک پروژه
                      _buildSectionHeader(
                        context,
                        'پروژه‌ها',
                        Icons.folder_rounded,
                        headerFontSize,
                      ),
                      const SizedBox(height: 16),
                      ...((summary['projectHours'] as Map<String, int>).entries
                          .toList()
                            ..sort((a, b) => b.value.compareTo(a.value)))
                          .map(
                            (entry) => Padding(
                              padding: const EdgeInsets.only(bottom: 10),
                              child: _buildProjectItem(
                                context,
                                projectName: entry.key,
                                hours: _formatMinutesToHours(entry.value),
                                itemFontSize: itemFontSize,
                              ),
                            ),
                          ),
                      if ((summary['projectHours'] as Map).isEmpty)
                        _buildEmptyState(
                          context,
                          'هنوز پروژه‌ای ثبت نشده',
                          itemFontSize,
                        ),

                      const Divider(height: 32, thickness: 1.5),

                      // مرخصی‌ها به تفکیک نوع
                      _buildSectionHeader(
                        context,
                        'مرخصی‌ها',
                        Icons.event_available_rounded,
                        headerFontSize,
                      ),
                      const SizedBox(height: 16),
                      ...((summary['leaveTypes'] as Map<LeaveType, int>)
                          .entries
                          .toList()
                            ..sort((a, b) => b.value.compareTo(a.value)))
                          .map(
                            (entry) => Padding(
                              padding: const EdgeInsets.only(bottom: 10),
                              child: _buildLeaveItem(
                                context,
                                leaveType: entry.key,
                                count: entry.value,
                                itemFontSize: itemFontSize,
                              ),
                            ),
                          ),
                      if ((summary['leaveTypes'] as Map).isEmpty)
                        _buildEmptyState(
                          context,
                          'مرخصی ثبت نشده',
                          itemFontSize,
                        ),
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
                      fontFamily: 'BNazanin',
                    ),
                  ),
                ),
              ),
            ),
          ],
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
            fontFamily: 'BNazanin',
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
        border: Border.all(
          color: iconColor.withValues(alpha: 0.3),
          width: 1.5,
        ),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: iconColor.withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(
              icon,
              color: iconColor,
              size: 24,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Text(
              label,
              style: TextStyle(
                fontSize: itemFontSize,
                fontFamily: 'BNazanin',
                color: colorScheme.onSurface,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          Text(
            value,
            style: TextStyle(
              fontSize: itemFontSize + 2,
              fontFamily: 'BNazanin',
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
                fontFamily: 'BNazanin',
                color: colorScheme.onSurface,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          Text(
            hours,
            style: TextStyle(
              fontSize: itemFontSize,
              fontFamily: 'BNazanin',
              color: colorScheme.primary,
              fontWeight: FontWeight.bold,
              fontFeatures: const [FontFeature.tabularFigures()],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLeaveItem(
    BuildContext context, {
    required LeaveType leaveType,
    required int count,
    required double itemFontSize,
  }) {
    final colorScheme = Theme.of(context).colorScheme;
    
    // تعیین رنگ و آیکون بر اساس نوع مرخصی
    Color leaveColor;
    IconData leaveIcon;
    
    switch (leaveType) {
      case LeaveType.annualLeave:
        leaveColor = colorScheme.annualLeaveColor;
        leaveIcon = Icons.beach_access_rounded;
        break;
      case LeaveType.sickLeave:
        leaveColor = colorScheme.sickLeaveColor;
        leaveIcon = Icons.local_hospital_rounded;
        break;
      case LeaveType.giftLeave:
        leaveColor = colorScheme.giftLeaveColor;
        leaveIcon = Icons.card_giftcard_rounded;
        break;
      case LeaveType.mission:
        leaveColor = colorScheme.missionColor;
        leaveIcon = Icons.flight_takeoff_rounded;
        break;
      default:
        leaveColor = colorScheme.outline;
        leaveIcon = Icons.event_rounded;
    }
    
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: leaveColor.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(
          color: leaveColor.withValues(alpha: 0.3),
          width: 1,
        ),
      ),
      child: Row(
        children: [
          Icon(
            leaveIcon,
            color: leaveColor,
            size: 22,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              leaveType.displayName,
              style: TextStyle(
                fontSize: itemFontSize,
                fontFamily: 'BNazanin',
                color: colorScheme.onSurface,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          Text(
            '$count روز',
            style: TextStyle(
              fontSize: itemFontSize,
              fontFamily: 'BNazanin',
              color: leaveColor,
              fontWeight: FontWeight.bold,
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
          Icon(
            Icons.info_outline,
            color: colorScheme.outline,
            size: 20,
          ),
          const SizedBox(width: 8),
          Text(
            message,
            style: TextStyle(
              fontSize: itemFontSize - 1,
              fontFamily: 'BNazanin',
              color: colorScheme.outline,
            ),
          ),
        ],
      ),
    );
  }

  Map<String, dynamic> _calculateMonthSummary(
    HomeController homeController,
    TaskController? taskController,
  ) {
    int totalWorkMinutes = 0;
    int totalPersonalMinutes = 0;
    int totalPresenceMinutes = 0;
    int workDaysCount = 0;
    Map<String, int> projectHours = {};
    Map<LeaveType, int> leaveTypes = {};

    final daysInMonth = homeController.daysInCurrentMonth;

    for (final day in daysInMonth) {
      // تبدیل تاریخ شمسی به میلادی برای مقایسه با dailyDetails
      final gregorianDate = day.toGregorian();
      final dateStr = '${gregorianDate.year.toString().padLeft(4, '0')}-${gregorianDate.month.toString().padLeft(2, '0')}-${gregorianDate.day.toString().padLeft(2, '0')}';
      
      final detail = homeController.dailyDetails.firstWhereOrNull(
        (d) => d.date == dateStr,
      );

      if (detail != null) {
        // محاسبه ساعت کاری پروژه‌ها
        for (final task in detail.tasks) {
          if (task.duration != null) {
            totalWorkMinutes += task.duration!;
            
            // گروه‌بندی بر اساس پروژه
            // اگر projectName از بک‌اند آمده باشد، از آن استفاده می‌کنیم
            final projectName = task.projectName ??
                taskController?.projects
                    .firstWhereOrNull(
                      (p) => p.id == task.projectId,
                    )?.projectName ??
                'پروژه حذف شده #${task.projectId}';
            projectHours[projectName] = (projectHours[projectName] ?? 0) + task.duration!;
          }
        }

        // محاسبه ساعت شخصی
        if (detail.personalTime != null) {
          totalPersonalMinutes += detail.personalTime!;
        }

        // محاسبه ساعت حضور
        if (detail.arrivalTime != null && detail.leaveTime != null) {
          try {
            final arrival = _parseTime(detail.arrivalTime!);
            final leave = _parseTime(detail.leaveTime!);
            final presenceMinutes = leave.inMinutes - arrival.inMinutes;
            if (presenceMinutes > 0) {
              totalPresenceMinutes += presenceMinutes;
            }
          } catch (e) {
            // Skip if time parsing fails
          }
        }

        // شمارش روزهای کاری
        if (detail.leaveType == LeaveType.work || 
            detail.leaveType == LeaveType.mission ||
            detail.tasks.isNotEmpty) {
          workDaysCount++;
        }

        // گروه‌بندی مرخصی‌ها
        if (detail.leaveType != null && 
            detail.leaveType != LeaveType.work) {
          leaveTypes[detail.leaveType!] = (leaveTypes[detail.leaveType!] ?? 0) + 1;
        }
      }
    }

    return {
      'totalWorkHours': _formatMinutesToHours(totalWorkMinutes),
      'totalPersonalHours': _formatMinutesToHours(totalPersonalMinutes),
      'totalPresenceHours': _formatMinutesToHours(totalPresenceMinutes),
      'workDaysCount': workDaysCount,
      'projectHours': projectHours,
      'leaveTypes': leaveTypes,
    };
  }

  Duration _parseTime(String timeStr) {
    final parts = timeStr.split(':');
    return Duration(
      hours: int.parse(parts[0]),
      minutes: int.parse(parts[1]),
      seconds: parts.length > 2 ? int.parse(parts[2]) : 0,
    );
  }

  String _formatMinutesToHours(int totalMinutes) {
    if (totalMinutes == 0) return '0:00';
    
    final hours = totalMinutes ~/ 60;
    final minutes = totalMinutes % 60;
    return '$hours:${minutes.toString().padLeft(2, '0')}';
  }
}

