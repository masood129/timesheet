import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../model/draft_report_model.dart';
import '../../../model/leavetype_model.dart';

// تابع کمکی برای فرمت کردن دقیقه به HH:MM
String formatMinutesToHHMM(int? minutes) {
  if (minutes == null || minutes < 0) return 'unknown'.tr;
  int hours = minutes ~/ 60;
  int mins = minutes % 60;
  return '${hours.toString().padLeft(2, '0')}:${mins.toString().padLeft(2, '0')}';
}

// تابع کمکی برای فرمت کردن هزینه به صورت سه‌تایی با کاما
String formatCurrency(int? amount) {
  if (amount == null || amount < 0) return 'unknown'.tr;
  return amount.toString().replaceAllMapped(
    RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
    (Match m) => '${m[1]},',
  );
}

class ReportDetailsCard extends StatelessWidget {
  final DraftReportModel report;
  final List<String> monthNames = [
    'month_1'.tr,
    'month_2'.tr,
    'month_3'.tr,
    'month_4'.tr,
    'month_5'.tr,
    'month_6'.tr,
    'month_7'.tr,
    'month_8'.tr,
    'month_9'.tr,
    'month_10'.tr,
    'month_11'.tr,
    'month_12'.tr,
  ];

  ReportDetailsCard({super.key, required this.report});

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.info_outline, color: Colors.blue),
                const SizedBox(width: 8),
                Text(
                  'report_details_title'.tr,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 18,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            const Divider(color: Colors.grey),
            const SizedBox(height: 8),
            // ردیف‌های ساده جزئیات
            _buildDetailRow('year'.tr, '${report.jalaliYear ?? 'unknown'.tr}'),
            _buildDetailRow(
              'month'.tr,
              monthNames[(report.jalaliMonth ?? 1) - 1],
            ),
            _buildDetailRow(
              'total_working_hours'.tr,
              formatMinutesToHHMM(report.totalHours),
            ),
            _buildDetailRow(
              'gym_cost'.tr,
              '${formatCurrency(report.gymCost)} ${'toman'.tr}', // Assuming 'toman' key exists or just hardcode if not
            ),
            _buildDetailRow(
              'commute_cost'.tr,
              '${formatCurrency(report.totalCommuteCost)} ${'toman'.tr}',
            ),
            _buildDetailRow(
              'group'.tr,
              '${report.groupName ?? report.groupId?.toString() ?? 'unknown'.tr}',
            ),
            _buildDetailRow(
              'manager'.tr,
              '${report.managerUsername ?? 'unknown'.tr}',
            ),
            const SizedBox(height: 16),
            // بخش لیست ساعت‌های پروژه
            _buildProjectHoursSection(report),
            const SizedBox(height: 16),
            // بخش لیست هزینه‌های ماشین شخصی
            _buildProjectCostsSection(report),
            const SizedBox(height: 16),
            // بخش نوع و تعداد مرخصی‌ها
            _buildLeaveTypesSection(report),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 140,
            child: Text(
              '$label:',
              style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14),
            ),
          ),
          Expanded(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: Colors.grey.withOpacity(0.05),
                borderRadius: BorderRadius.circular(6),
              ),
              child: Text(value, style: const TextStyle(fontSize: 14)),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProjectHoursSection(DraftReportModel report) {
    final hours = report.projectHoursByProject ?? [];
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            const Icon(Icons.access_time, color: Colors.green, size: 20),
            const SizedBox(width: 8),
            Text(
              'project_hours_breakdown'.tr,
              style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14),
            ),
          ],
        ),
        const SizedBox(height: 8),
        if (hours.isEmpty)
          _buildDetailRow('project_hours_breakdown'.tr, 'no_hours_recorded'.tr)
        else
          Container(
            height: 120,
            decoration: BoxDecoration(
              color: Colors.green.withOpacity(0.05),
              borderRadius: BorderRadius.circular(8),
            ),
            child: ListView.separated(
              padding: const EdgeInsets.all(8),
              itemCount: hours.length,
              separatorBuilder: (context, index) => const Divider(height: 1),
              itemBuilder: (context, index) {
                final hour = hours[index];
                final projectId = hour.projectId?.toString() ?? 'unknown'.tr;
                final totalHours = formatMinutesToHHMM(hour.totalHours);
                return Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('${'project'.tr} $projectId'),
                    Text(totalHours),
                  ],
                );
              },
            ),
          ),
      ],
    );
  }

  Widget _buildProjectCostsSection(DraftReportModel report) {
    final costs = report.personalCarCostsByProject ?? [];
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            const Icon(Icons.local_gas_station, color: Colors.orange, size: 20),
            const SizedBox(width: 8),
            Text(
              'personal_car_cost_breakdown'.tr,
              style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14),
            ),
          ],
        ),
        const SizedBox(height: 8),
        if (costs.isEmpty)
          _buildDetailRow(
            'personal_car_cost_breakdown'.tr,
            'no_cost_recorded'.tr,
          )
        else
          Container(
            height: 120,
            decoration: BoxDecoration(
              color: Colors.orange.withOpacity(0.05),
              borderRadius: BorderRadius.circular(8),
            ),
            child: ListView.separated(
              padding: const EdgeInsets.all(8),
              itemCount: costs.length,
              separatorBuilder: (context, index) => const Divider(height: 1),
              itemBuilder: (context, index) {
                final cost = costs[index];
                final projectId = cost.projectId?.toString() ?? 'unknown'.tr;
                final costAmount = formatCurrency(cost.cost);
                return Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('${'project'.tr} $projectId'),
                    Text('$costAmount ${'toman'.tr}'),
                  ],
                );
              },
            ),
          ),
      ],
    );
  }

  Widget _buildLeaveTypesSection(DraftReportModel report) {
    final leaveTypes = report.leaveTypesCount ?? <LeaveType, int>{};
    final leaveEntries = leaveTypes.entries.toList();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            const Icon(Icons.event_busy, color: Colors.purple, size: 20),
            const SizedBox(width: 8),
            Text(
              'leave_types_count'.tr,
              style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14),
            ),
          ],
        ),
        const SizedBox(height: 8),
        if (leaveEntries.isEmpty)
          _buildDetailRow('leave_types_count'.tr, 'no_leave_recorded'.tr)
        else
          Container(
            height: 120,
            decoration: BoxDecoration(
              color: Colors.purple.withOpacity(0.05),
              borderRadius: BorderRadius.circular(8),
            ),
            child: ListView.separated(
              padding: const EdgeInsets.all(8),
              itemCount: leaveEntries.length,
              separatorBuilder: (context, index) => const Divider(height: 1),
              itemBuilder: (context, index) {
                final entry = leaveEntries[index];
                final leaveType = entry.key.displayName;
                final count = entry.value.toString();
                return Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [Text(leaveType), Text('$count ${'day'.tr}')],
                );
              },
            ),
          ),
      ],
    );
  }
}
