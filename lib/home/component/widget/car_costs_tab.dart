import 'package:flutter/material.dart';
import 'package:get/Get.dart';
import '../../controller/task_controller.dart';
import '../../model/leavetype_model.dart';
import 'car_cost_row.dart';

class CarCostsTab extends StatelessWidget {
  final TaskController controller;

  const CarCostsTab({super.key, required this.controller});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final disabledColor = Theme.of(context).disabledColor;

    return ListView(
      children: [
        Text('هزینه‌های ماشین شخصی'.tr, style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: colorScheme.primary)),
        const SizedBox(height: 8),
        Obx(() {
          final isEnabled = controller.leaveType.value == LeaveType.work || controller.leaveType.value == LeaveType.mission;          return Column(
            children: List.generate(
              controller.selectedCarCostProjects.length,
                  (i) => CarCostRow(
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
          final isEnabled = controller.leaveType.value == LeaveType.work || controller.leaveType.value == LeaveType.mission;          return Align(
            alignment: Alignment.centerRight,
            child: TextButton.icon(
              onPressed: isEnabled ? controller.addCarCostRow : null,
              icon: Icon(Icons.add, color: isEnabled ? colorScheme.primary : disabledColor),
              label: Text('اضافه کردن هزینه ماشین'.tr, style: TextStyle(color: isEnabled ? colorScheme.primary : disabledColor)),
            ),
          );
        }),
      ],
    );
  }
}