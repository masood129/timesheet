import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:shamsi_date/shamsi_date.dart';
import '../controller/home_controller.dart';
import '../model/daily_detail_model.dart';

class MonthlyDetailsView extends StatelessWidget {
  MonthlyDetailsView({super.key});

  final HomeController controller = Get.find<HomeController>();

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: Obx(() {
          final year = controller.currentYear.value;
          final month = controller.currentMonth.value;
          final monthName = Jalali(year, month).formatter.mN;
          return Text('${'monthly_details'.tr}: $monthName $year');
        }),
      ),
      body: Obx(() {
        if (controller.dailyDetails.isEmpty) {
          return Center(child: Text('no_details'.tr));
        }
        return ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: controller.dailyDetails.length,
          itemBuilder: (context, index) {
            final detail = controller.dailyDetails[index];
            final date = Jalali.fromDateTime(DateTime.parse(detail.date));
            return Card(
              child: ExpansionTile(
                title: Text(
                  '${date.formatter.wN} ${date.day} ${date.formatter.mN}',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: colorScheme.primary,
                  ),
                ),
                subtitle: Text(
                  detail.leaveType ?? 'no_leave_type'.tr,
                  style: TextStyle(color: colorScheme.onSurface.withOpacity(0.7)),
                ),
                children: [
                  Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        if (detail.arrivalTime != null)
                          Text('${'arrival_time'.tr}: ${detail.arrivalTime}'),
                        if (detail.leaveTime != null)
                          Text('${'leave_time'.tr}: ${detail.leaveTime}'),
                        if (detail.personalTime != null)
                          Text('${'personal_time'.tr}: ${detail.personalTime} ${'minute'.tr}'),
                        if (detail.goCost != null)
                          Text('${'go_cost'.tr}: ${detail.goCost}'),
                        if (detail.returnCost != null)
                          Text('${'return_cost'.tr}: ${detail.returnCost}'),
                        if (detail.personalCarCost != null)
                          Text('${'personal_car_cost'.tr}: ${detail.personalCarCost}'),
                        if (detail.description != null)
                          Text('${'description'.tr}: ${detail.description}'),
                        const SizedBox(height: 16),
                        Text(
                          'tasks'.tr,
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: colorScheme.primary,
                          ),
                        ),
                        ...detail.tasks.map((task) {
                          final project = controller.dailyDetails
                              .firstWhere((d) => d.tasks.any((t) => t.projectId == task.projectId))
                              .tasks
                              .firstWhere((t) => t.projectId == task.projectId);
                          return Padding(
                            padding: const EdgeInsets.symmetric(vertical: 4),
                            child: Text(
                              '- ${project.description ?? 'no_description'.tr} (${task.duration ?? 0} ${'minute'.tr})',
                            ),
                          );
                        }),
                      ],
                    ),
                  ),
                ],
              ),
            );
          },
        );
      }),
    );
  }
}