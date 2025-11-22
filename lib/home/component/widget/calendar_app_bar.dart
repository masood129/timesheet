import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:shamsi_date/shamsi_date.dart';
import '../../../model/project_model.dart';
import '../../controller/home_controller.dart';
import '../../controller/task_controller.dart';
import '../../controller/auth_controller.dart';

class CalendarAppBar extends StatelessWidget implements PreferredSizeWidget {
  CalendarAppBar({super.key});

  final HomeController homeController = Get.find<HomeController>();
  final TaskController taskController = Get.find<TaskController>();
  final AuthController authController = Get.find<AuthController>();

  void _showTimerDialog(BuildContext context) {
    final today = Jalali.now();
    showDialog(
      context: context,
      builder: (context) {
        final colorScheme = Theme.of(context).colorScheme;
        return AlertDialog(
          title: Text(
            'project_timer'.tr,
            style: TextStyle(color: colorScheme.primary),
          ),
          content: Obx(
            () => Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                DropdownButtonFormField(
                  value: taskController.selectedTimerProject.value,
                  hint: Text(
                    'select_project'.tr,
                    style: TextStyle(color: colorScheme.onSurface),
                  ),
                  decoration: InputDecoration(
                    labelText: 'projects'.tr,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  items:
                      taskController.projects
                          .map(
                            (project) => DropdownMenuItem(
                              value: project,
                              child: Text(project.projectName),
                            ),
                          )
                          .toList(),
                  onChanged:
                      taskController.isPersonalTimerRunning.value
                          ? null
                          : (value) =>
                              taskController.selectedTimerProject.value =
                                  value as Project?,
                ),
                const SizedBox(height: 16),
                Text(
                  taskController.isTimerRunning.value
                      ? '${'project_timer_running'.tr} ${taskController.timerDuration.value}'
                      : taskController.isPersonalTimerRunning.value
                      ? '${'personal_timer_running'.tr} ${taskController.personalTimerDuration.value}'
                      : 'timer_stopped'.tr,
                  style: TextStyle(color: colorScheme.onSurface),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text(
                'cancel'.tr,
                style: TextStyle(color: colorScheme.error),
              ),
            ),
            Obx(
              () => ElevatedButton(
                onPressed:
                    (taskController.selectedTimerProject.value == null &&
                                !taskController.isTimerRunning.value) ||
                            taskController.isPersonalTimerRunning.value
                        ? null
                        : () async {
                          if (taskController.isTimerRunning.value) {
                            await taskController.stopTimer(today);
                            await taskController.saveDailyDetail();
                          } else {
                            taskController.startTimer();
                            Navigator.pop(context);
                          }
                        },
                style: ElevatedButton.styleFrom(
                  backgroundColor: colorScheme.primary,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: Text(
                  taskController.isTimerRunning.value
                      ? 'stop_project_timer'.tr
                      : 'start_project_timer'.tr,
                  style: TextStyle(color: colorScheme.onPrimary),
                ),
              ),
            ),
            Obx(
              () => ElevatedButton(
                onPressed:
                    taskController.isTimerRunning.value
                        ? null
                        : () async {
                          if (taskController.isPersonalTimerRunning.value) {
                            await taskController.stopPersonalTimer(today);
                            await taskController.saveDailyDetail();
                          } else {
                            taskController.startPersonalTimer();
                            Navigator.pop(context);
                          }
                        },
                style: ElevatedButton.styleFrom(
                  backgroundColor: colorScheme.secondary,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: Text(
                  taskController.isPersonalTimerRunning.value
                      ? 'stop_personal_timer'.tr
                      : 'start_personal_timer'.tr,
                  style: TextStyle(color: colorScheme.onSecondary),
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return AppBar(
      centerTitle: true,
      title: Obx(() {
        if (taskController.isTimerRunning.value &&
            taskController.selectedTimerProject.value != null) {
          final projectName =
              taskController.selectedTimerProject.value!.projectName;
          final timerText = taskController.timerDuration.value;
          return Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Text(
                projectName,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text(
                timerText,
                style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.normal,
                ),
              ),
            ],
          );
        } else if (taskController.isPersonalTimerRunning.value) {
          final timerText = taskController.personalTimerDuration.value;
          return Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Text(
                'personal_timer'.tr,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text(
                timerText,
                style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.normal,
                ),
              ),
            ],
          );
        } else {
          final year = homeController.currentYear.value;
          final month = homeController.currentMonth.value;
          final monthName = Jalali(year, month).formatter.mN;
          final username = authController.user.value?['Username'] ?? '';
          return Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Text('${'calendar_title'.tr}: $monthName $year'),
              if (username.isNotEmpty)
                Text(
                  username,
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.normal,
                  ),
                ),
            ],
          );
        }
      }),
      actions: [
        IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: homeController.previousMonth,
        ),
        IconButton(
          icon: const Icon(Icons.arrow_forward),
          onPressed: homeController.nextMonth,
        ),
        Obx(
          () => IconButton(
            icon: Icon(
              homeController.isListView.value ? Icons.grid_view : Icons.list,
            ),
            onPressed: homeController.toggleView,
          ),
        ),
        IconButton(
          icon: const Icon(Icons.timer),
          onPressed: () => _showTimerDialog(context),
        ),
      ],
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}
