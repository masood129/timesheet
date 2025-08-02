import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../controller/task_controller.dart';
import 'task_row.dart';

class TasksTab extends StatelessWidget {
  final TaskController controller;

  const TasksTab({Key? key, required this.controller}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final disabledColor = Theme.of(context).disabledColor;

    return ListView(
      children: [
        Text('تسک‌ها'.tr, style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: colorScheme.primary)),
        const SizedBox(height: 8),
        Obx(() {
          final isEnabled = controller.leaveType.value == 'کاری';
          return Column(
            children: List.generate(
              controller.selectedProjects.length,
                  (i) => TaskRow(
                index: i,
                controller: controller,
                isEnabled: isEnabled,
                colorScheme: colorScheme,
                disabledColor: disabledColor,
              ),
            ),
          );
        }),
        Obx(() {
          final isEnabled = controller.leaveType.value == 'کاری';
          return Align(
            alignment: Alignment.centerRight,
            child: TextButton.icon(
              onPressed: isEnabled ? controller.addTaskRow : null,
              icon: Icon(Icons.add, color: isEnabled ? colorScheme.primary : disabledColor),
              label: Text('اضافه کردن وظیفه'.tr, style: TextStyle(color: isEnabled ? colorScheme.primary : disabledColor)),
            ),
          );
        }),
      ],
    );
  }
}