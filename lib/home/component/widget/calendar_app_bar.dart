import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:shamsi_date/shamsi_date.dart';
import '../../controller/home_controller.dart';
import '../../controller/task_controller.dart';
import '../../view/monthly_details_view.dart';
import '../note_dialog.dart';

class CalendarAppBar extends StatelessWidget implements PreferredSizeWidget {
  CalendarAppBar({super.key});

  final HomeController homeController = Get.find<HomeController>();
  final TaskController taskController = Get.find<TaskController>();

  void _showTimerDialog(BuildContext context) {
    final today = Jalali.now();
    showDialog(
      context: context,
      builder: (context) {
        final colorScheme = Theme.of(context).colorScheme;
        return AlertDialog(
          title: Text('تایمر پروژه'.tr, style: TextStyle(color: colorScheme.primary)),
          content: Obx(
                () => Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                DropdownButtonFormField(
                  value: taskController.selectedTimerProject.value,
                  hint: Text('انتخاب پروژه'.tr, style: TextStyle(color: colorScheme.onSurface)),
                  decoration: InputDecoration(
                    labelText: 'پروژه'.tr,
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  items: taskController.projects.map((project) => DropdownMenuItem(value: project, child: Text(project.projectName))).toList(),
                  onChanged: (value) => taskController.selectedTimerProject.value = value,
                ),
                const SizedBox(height: 16),
                Text(
                  taskController.isTimerRunning.value ? 'تایمر در حال اجرا: ${taskController.timerDuration.value}' : 'تایمر متوقف است',
                  style: TextStyle(color: colorScheme.onSurface),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(context), child: Text('لغو'.tr, style: TextStyle(color: colorScheme.error))),
            Obx(
                  () => ElevatedButton(
                onPressed: taskController.selectedTimerProject.value == null ? null : () {
                  if (taskController.isTimerRunning.value) {
                    taskController.stopTimer(today);
                    Navigator.pop(context);
                    showModalBottomSheet(
                      useSafeArea: true,
                      enableDrag: false,
                      isScrollControlled: true,
                      context: context,
                      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
                      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
                      builder: (_) => NoteDialog(date: today),
                    );
                  } else {
                    taskController.startTimer();
                    Navigator.pop(context);
                  }
                },
                child: Text(taskController.isTimerRunning.value ? 'توقف تایمر'.tr : 'شروع تایمر'.tr, style: TextStyle(color: colorScheme.onPrimary)),
                style: ElevatedButton.styleFrom(backgroundColor: colorScheme.primary, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
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
      title: Obx(() {
        final year = homeController.currentYear.value;
        final month = homeController.currentMonth.value;
        final monthName = Jalali(year, month).formatter.mN;
        return Text('${'calendar_title'.tr}: $monthName $year');
      }),
      actions: [
        IconButton(icon: const Icon(Icons.arrow_back), onPressed: homeController.previousMonth),
        IconButton(icon: const Icon(Icons.arrow_forward), onPressed: homeController.nextMonth),
        IconButton(icon: const Icon(Icons.list), onPressed: () => Get.to(() => MonthlyDetailsView())),
        IconButton(icon: const Icon(Icons.timer), onPressed: () => _showTimerDialog(context)),
      ],
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}