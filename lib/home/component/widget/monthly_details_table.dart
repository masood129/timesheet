import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:shamsi_date/shamsi_date.dart';

import '../../controller/home_controller.dart';
import '../../model/daily_detail_model.dart';
import '../../model/project_model.dart';

class MonthlyDetailsTable extends StatelessWidget {
  final int daysInMonth;
  final List<Project> projects;
  final List<DailyDetail> dailyDetails;

  const MonthlyDetailsTable({
    super.key,
    required this.daysInMonth,
    required this.projects,
    required this.dailyDetails,
  });

  String _formatDuration(int? minutes) {
    if (minutes == null || minutes == 0) return '';
    final hours = minutes ~/ 60;
    final remainingMinutes = minutes % 60;
    return '${hours.toString().padLeft(2, '0')}:${remainingMinutes.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final projectList = projects.isEmpty ? ['no_project'.tr] : projects.map((p) => p.projectName).toList();
    final homeController = Get.find<HomeController>();

    return Container(
      margin: const EdgeInsets.all(8.0),
      decoration: BoxDecoration(
        color: colorScheme.surface,
        borderRadius: BorderRadius.circular(8),
        boxShadow: [BoxShadow(color: colorScheme.onSurface.withOpacity(0.1), blurRadius: 4, offset: const Offset(0, 2))],
      ),
      child: SingleChildScrollView(
        scrollDirection: Axis.vertical,
        physics: const AlwaysScrollableScrollPhysics(),
        child: SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          physics: const AlwaysScrollableScrollPhysics(),
          child: ConstrainedBox(
            constraints: BoxConstraints(minWidth: MediaQuery.of(context).size.width),
            child: DataTable(
              columnSpacing: 10,
              headingRowHeight: 40,
              dataRowHeight: 40,
              dividerThickness: 1,
              border: TableBorder(
                horizontalInside: BorderSide(color: colorScheme.onSurface.withOpacity(0.2), width: 1),
                verticalInside: BorderSide(color: colorScheme.onSurface.withOpacity(0.2), width: 1),
                top: BorderSide(color: colorScheme.onSurface.withOpacity(0.3), width: 1),
                bottom: BorderSide(color: colorScheme.onSurface.withOpacity(0.3), width: 1),
              ),
              headingRowColor: WidgetStateProperty.all(colorScheme.primaryContainer.withOpacity(0.8)),
              dataTextStyle: TextStyle(fontSize: 11, color: colorScheme.onSurface),
              columns: [
                DataColumn(label: Text('تاریخ'.tr, style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12, color: colorScheme.onPrimaryContainer))),
                DataColumn(label: Text('نوع مرخصی'.tr, style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12, color: colorScheme.onPrimaryContainer))),
                DataColumn(label: Text('زمان ورود'.tr, style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12, color: colorScheme.onPrimaryContainer))),
                DataColumn(label: Text('زمان خروج'.tr, style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12, color: colorScheme.onPrimaryContainer))),
                DataColumn(label: Text('زمان شخصی'.tr, style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12, color: colorScheme.onPrimaryContainer))),
                ...projectList.map((project) => DataColumn(
                  label: Container(
                    decoration: BoxDecoration(color: colorScheme.secondary, borderRadius: BorderRadius.circular(4)),
                    padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0),
                    child: Text(project, overflow: TextOverflow.ellipsis, maxLines: 2, style: TextStyle(fontWeight: FontWeight.bold, fontSize: 11, color: colorScheme.onSecondary)),
                  ),
                )),
              ],
              rows: List.generate(daysInMonth, (index) {
                final day = index + 1;
                final date = Jalali(homeController.currentYear.value, homeController.currentMonth.value, day);
                final gregorianDate = date.toGregorian();
                final formattedDate = '${gregorianDate.year}-${gregorianDate.month.toString().padLeft(2, '0')}-${gregorianDate.day.toString().padLeft(2, '0')}';
                final detail = dailyDetails.firstWhereOrNull((d) => d.date == formattedDate);

                final projectDurations = List<String>.filled(projectList.length, '');

                if (detail != null) {
                  for (var task in detail.tasks) {
                    final projectIndex = projects.indexWhere((p) => p.id == task.projectId);
                    if (projectIndex != -1) {
                      projectDurations[projectIndex] = _formatDuration(task.duration);
                    }
                                    }
                }

                return DataRow(
                  color: WidgetStateProperty.all(index % 2 == 0 ? colorScheme.surface : colorScheme.surfaceVariant.withOpacity(0.5)),
                  cells: [
                    DataCell(Text('${date.formatter.wN} ${date.day} ${date.formatter.mN}', style: TextStyle(color: colorScheme.primary, fontWeight: FontWeight.w600))),
                    DataCell(Text(detail?.leaveType ?? '', style: TextStyle(color: colorScheme.onSurface.withOpacity(0.7)))),
                    DataCell(Text(detail?.arrivalTime ?? '')),
                    DataCell(Text(detail?.leaveTime ?? '')),
                    DataCell(Text(detail?.personalTime != null ? _formatDuration(detail!.personalTime) : '')),
                    ...projectDurations.map((duration) => DataCell(Text(duration))),
                  ],
                );
              }),
            ),
          ),
        ),
      ),
    );
  }
}