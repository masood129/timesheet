import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import '../../../core/theme/app_styles.dart';
import '../../controller/task_controller.dart';
import 'time_picker_field.dart';

class DailyDetailsTab extends StatelessWidget {
  final TaskController controller;

  const DailyDetailsTab({Key? key, required this.controller}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final disabledColor = Theme.of(context).disabledColor;

    return ListView(
      children: [
        Text(
          'جزئیات روز'.tr,
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 16,
            color: colorScheme.primary,
          ),
        ),
        const SizedBox(height: 8),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text('company_arrival_time'.tr, style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500, color: colorScheme.onSurface)),
            const SizedBox(width: 6),
            Text('08:00', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: colorScheme.primary)),
            const SizedBox(width: 24),
            Text('company_leave_time'.tr, style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500, color: colorScheme.onSurface)),
            const SizedBox(width: 6),
            Text('17:00', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: colorScheme.primary)),
          ],
        ),
        const SizedBox(height: 10),
        Obx(() {
          final isEnabled = controller.leaveType.value == 'کاری';
          return Row(
            children: [
              Expanded(child: TimePickerField(labelKey: 'arrival_time_hint', controller: controller.arrivalTimeController, icon: Icons.login, isEnabled: isEnabled)),
              const SizedBox(width: 10),
              Expanded(child: TimePickerField(labelKey: 'leave_time_hint', controller: controller.leaveTimeController, icon: Icons.logout, isEnabled: isEnabled)),
              const SizedBox(width: 10),
              Expanded(child: TimePickerField(labelKey: 'personal_time', controller: controller.personalTimeController, icon: Icons.person, isEnabled: isEnabled)),
            ],
          );
        }),
        const SizedBox(height: 10),
        Obx(() => DropdownButtonFormField<String>(
          value: controller.leaveType.value.isEmpty ? null : controller.leaveType.value,
          hint: Text('وضعیت روز'.tr, style: TextStyle(color: disabledColor)),
          decoration: AppStyles.inputDecoration(context, 'leave_type', Icons.leave_bags_at_home, true),
          items: ['کاری', 'استحقاقی', 'استعلاجی', 'هدیه'].map((e) => DropdownMenuItem(value: e, child: Text(e, style: TextStyle(color: colorScheme.onSurface)))).toList(),
          onChanged: (val) {
            controller.leaveType.value = val ?? '';
            controller.calculateStats();
          },
        )),
        const SizedBox(height: 10),
        TextField(
          controller: controller.descriptionController,
          maxLines: 1,
          decoration: AppStyles.inputDecoration(context, 'note_optional', Icons.note, true),
        ),
        const SizedBox(height: 10),
        Obx(() {
          final isEnabled = controller.leaveType.value == 'کاری';
          return Row(
            children: [
              Expanded(
                child: Tooltip(
                  message: isEnabled ? '' : 'غیرفعال برای مرخصی غیرکاری'.tr,
                  child: TextField(
                    controller: controller.goCostController,
                    keyboardType: TextInputType.number,
                    inputFormatters: [FilteringTextInputFormatter.digitsOnly, ThousandSeparatorInputFormatter()],
                    enabled: isEnabled,
                    decoration: AppStyles.inputDecoration(context, 'go_cost', Icons.directions_bus, isEnabled),
                    onChanged: (value) => controller.calculateStats(),
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Tooltip(
                  message: isEnabled ? '' : 'غیرفعال برای مرخصی غیرکاری'.tr,
                  child: TextField(
                    controller: controller.returnCostController,
                    keyboardType: TextInputType.number,
                    inputFormatters: [FilteringTextInputFormatter.digitsOnly, ThousandSeparatorInputFormatter()],
                    enabled: isEnabled,
                    decoration: AppStyles.inputDecoration(context, 'return_cost', Icons.directions_bus_filled, isEnabled),
                    onChanged: (value) => controller.calculateStats(),
                  ),
                ),
              ),
            ],
          );
        }),
      ],
    );
  }
}