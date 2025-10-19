// report_details_template.dart (بدون تغییر)
import 'package:flutter/material.dart';
import 'package:shamsi_date/shamsi_date.dart';

import '../../../model/draft_report_model.dart';
import '../../../model/leavetype_model.dart';

// تابع کمکی برای فرمت کردن دقیقه به HH:MM
String formatMinutesToHHMM(int? minutes) {
  if (minutes == null || minutes < 0) return 'نامشخص';
  int hours = minutes ~/ 60;
  int mins = minutes % 60;
  return '${hours.toString().padLeft(2, '0')}:${mins.toString().padLeft(2, '0')}';
}

// تابع کمکی برای فرمت کردن هزینه به صورت سه‌تایی با کاما
String formatCurrency(int? amount) {
  if (amount == null || amount < 0) return 'نامشخص';
  return amount.toString().replaceAllMapped(
    RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
        (Match m) => '${m[1]},',
  );
}

class ReportDetailsCard extends StatelessWidget {
  final DraftReportModel report;
  final List<String> monthNames = [
    'فروردین',
    'اردیبهشت',
    'خرداد',
    'تیر',
    'مرداد',
    'شهریور',
    'مهر',
    'آبان',
    'آذر',
    'دی',
    'بهمن',
    'اسفند',
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
                const Text(
                  'جزئیات گزارش',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
                ),
              ],
            ),
            const SizedBox(height: 16),
            const Divider(color: Colors.grey),
            const SizedBox(height: 8),
            // ردیف‌های ساده جزئیات
            _buildDetailRow('سال', '${report.jalaliYear ?? 'نامشخص'}'),
            _buildDetailRow('ماه', monthNames[(report.jalaliMonth ?? 1) - 1]),
            _buildDetailRow(
              'جمع ساعت کاری کل',
              formatMinutesToHHMM(report.totalHours),
            ),
            _buildDetailRow(
              'هزینه باشگاه',
              '${formatCurrency(report.gymCost)} تومان',
            ),
            _buildDetailRow(
              'هزینه رفت و آمد به شرکت',
              '${formatCurrency(report.totalCommuteCost)} تومان',
            ),
            _buildDetailRow(
              'گروه مربوطه',
              '${report.groupName ?? report.groupId?.toString() ?? 'نامشخص'}',
            ),
            _buildDetailRow(
              'سرگروه مربوطه',
              '${report.managerUsername ?? 'نامشخص'}',
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
            const Text(
              'ساعت صرف‌شده به تفکیک هر پروژه',
              style: TextStyle(fontWeight: FontWeight.w600, fontSize: 14),
            ),
          ],
        ),
        const SizedBox(height: 8),
        if (hours.isEmpty)
          _buildDetailRow('ساعت صرف‌شده به تفکیک هر پروژه', 'هیچ ساعتی ثبت نشده')
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
                final projectId = hour.projectId?.toString() ?? 'نامشخص';
                final totalHours = formatMinutesToHHMM(hour.totalHours);
                return Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [Text('پروژه $projectId'), Text('$totalHours')],
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
            const Text(
              'هزینه ماشین شخصی به تفکیک هر پروژه',
              style: TextStyle(fontWeight: FontWeight.w600, fontSize: 14),
            ),
          ],
        ),
        const SizedBox(height: 8),
        if (costs.isEmpty)
          _buildDetailRow(
            'هزینه ماشین شخصی به تفکیک هر پروژه',
            'هیچ هزینه‌ای ثبت نشده',
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
                final projectId = cost.projectId?.toString() ?? 'نامشخص';
                final costAmount = formatCurrency(cost.cost);
                return Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [Text('پروژه $projectId'), Text('$costAmount تومان')],
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
            const Text(
              'نوع و تعداد مرخصی‌ها',
              style: TextStyle(fontWeight: FontWeight.w600, fontSize: 14),
            ),
          ],
        ),
        const SizedBox(height: 8),
        if (leaveEntries.isEmpty)
          _buildDetailRow('نوع و تعداد مرخصی‌ها', 'هیچ مرخصی‌ای ثبت نشده')
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
                  children: [Text(leaveType), Text('$count روز')],
                );
              },
            ),
          ),
      ],
    );
  }
}