import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:shamsi_date/shamsi_date.dart';
import 'package:timesheet/home/model/monthly_report_model.dart';
import 'package:timesheet/manager/controller/manager_controller.dart';
import '../../home/controller/auth_controller.dart';

class ManagerDashboard extends StatelessWidget {
  ManagerDashboard({super.key});

  final AuthController authController = Get.find<AuthController>();
  final ManagerController reportController = Get.put(ManagerController());

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('manager_dashboard'.tr),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () => authController.logout(),
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Obx(
              () => DropdownButtonFormField<int>(
                value: reportController.selectedYear.value,
                decoration: InputDecoration(
                  labelText: 'year'.tr,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                items:
                    List.generate(5, (index) => Jalali.now().year - 2 + index)
                        .map(
                          (year) => DropdownMenuItem(
                            value: year,
                            child: Text(year.toString()),
                          ),
                        )
                        .toList(),
                onChanged:
                    (value) => reportController.selectedYear.value = value!,
              ),
            ),
            const SizedBox(height: 16),
            Obx(
              () => DropdownButtonFormField<int>(
                value: reportController.selectedMonth.value,
                decoration: InputDecoration(
                  labelText: 'month'.tr,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                items:
                    List.generate(12, (index) => index + 1)
                        .map(
                          (month) => DropdownMenuItem(
                            value: month,
                            child: Text(Jalali(2023, month).formatter.mN),
                          ),
                        )
                        .toList(),
                onChanged:
                    (value) => reportController.selectedMonth.value = value!,
              ),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () => reportController.fetchReports(),
              child: Text('fetch_reports'.tr),
            ),
            const SizedBox(height: 16),
            Expanded(
              child: Obx(
                () => ListView.builder(
                  itemCount: reportController.reports.length,
                  itemBuilder: (context, index) {
                    final report = reportController.reports[index];
                    return Card(
                      child: ListTile(
                        title: Text('${'report_by'.tr} ${report.username}'),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              '${'hours'.tr} ${report.totalHours.toString()}',
                            ),
                            Text(
                              '${'gym_cost'.tr} ${report.gymCost.toString()}',
                            ),
                            Text('${'status'.tr} ${report.status}'),
                          ],
                        ),
                        trailing: _buildActionButton(context, report),
                      ),
                    );
                  },
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget? _buildActionButton(BuildContext context, MonthlyReport report) {
    final role = authController.user.value?['Role'];
    final status = report.status;
    if (role == 'group_manager' && status == 'submitted_to_group_manager') {
      return PopupMenuButton<String>(
        onSelected: (value) async {
          final comment = await _showCommentDialog(context);
          if (comment != null) {
            if (value == 'to_general') {
              await reportController.approveGroupManager(
                report.reportId,
                comment,
                true,
              );
            } else {
              await reportController.approveGroupManager(
                report.reportId,
                comment,
                false,
              );
            }
          }
        },
        itemBuilder:
            (context) => [
              PopupMenuItem(
                value: 'to_general',
                child: Text('submit_to_general_manager'.tr),
              ),
              PopupMenuItem(
                value: 'to_finance',
                child: Text('submit_to_finance'.tr),
              ),
            ],
      );
    } else if (role == 'general_manager' &&
        status == 'submitted_to_general_manager') {
      return ElevatedButton(
        onPressed: () async {
          final comment = await _showCommentDialog(context);
          if (comment != null) {
            await reportController.approveGeneralManager(
              report.reportId,
              comment,
            );
          }
        },
        child: Text('approve'.tr),
      );
    } else if (role == 'finance_manager' && status == 'submitted_to_finance') {
      return ElevatedButton(
        onPressed: () async {
          final comment = await _showCommentDialog(context);
          if (comment != null) {
            await reportController.approveFinance(report.reportId, comment);
          }
        },
        child: Text('final_approve'.tr),
      );
    }
    return null;
  }

  Future<String?> _showCommentDialog(BuildContext context) {
    final controller = TextEditingController();
    return showDialog<String>(
      context: context,
      builder:
          (context) => AlertDialog(
            title: Text('enter_comment'.tr),
            content: TextField(
              controller: controller,
              decoration: InputDecoration(labelText: 'comment'.tr),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: Text('cancel'.tr),
              ),
              ElevatedButton(
                onPressed: () => Navigator.pop(context, controller.text),
                child: Text('submit'.tr),
              ),
            ],
          ),
    );
  }
}
