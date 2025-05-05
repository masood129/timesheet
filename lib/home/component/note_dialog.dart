import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:shamsi_date/shamsi_date.dart';
import '../controller/task_controller.dart';
import '../model/task_model.dart';

class NoteDialog extends StatelessWidget {
  final Jalali date;

  const NoteDialog({super.key, required this.date});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(TaskController());
    controller.fetchTask(date); // بارگذاری داده‌های وظیفه برای تاریخ

    final colorScheme = Theme.of(context).colorScheme;

    InputDecoration buildInputDecoration(String labelKey, IconData icon) {
      return InputDecoration(
        labelText: labelKey.tr,
        prefixIcon: Icon(icon),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
        contentPadding: const EdgeInsets.symmetric(vertical: 10, horizontal: 12),
      );
    }

    Widget buildTimePickerField(
        String labelKey,
        TextEditingController controller,
        IconData icon,
        bool isEnabled,
        ) {
      return TextField(
        readOnly: true,
        controller: controller,
        enabled: isEnabled,
        decoration: buildInputDecoration(labelKey, icon).copyWith(
          filled: true,
          fillColor: isEnabled ? null : Colors.grey[300],
        ),
        onTap: isEnabled
            ? () async {
          final picked = await showTimePicker(
            context: context,
            initialTime: TimeOfDay.now(),
          );
          if (picked != null) {
            controller.text = '${picked.hour}:${picked.minute.toString().padLeft(2, '0')}';
          }
        }
            : null,
      );
    }

    return DraggableScrollableSheet(
      expand: false,
      initialChildSize: 0.9,
      maxChildSize: 0.95,
      minChildSize: 0.5,
      builder: (_, scrollController) {
        return Padding(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(context).viewInsets.bottom,
            right: 16,
            left: 16,
            top: 16,
          ),
          child: Obx(
                () => ListView(
              controller: scrollController,
              children: [
                Center(
                  child: Text(
                    '${date.formatter.wN} ${date.day} ${date.formatter.mN}',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: colorScheme.primary,
                    ),
                  ),
                ),
                const SizedBox(height: 24),
                Row(
                  children: [
                    Expanded(
                      child: buildTimePickerField(
                        'arrival_time_hint',
                        controller.arrivalTimeController,
                        Icons.login,
                        controller.leaveType.value == 'کاری',
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: buildTimePickerField(
                        'leave_time_hint',
                        controller.leaveTimeController,
                        Icons.logout,
                        controller.leaveType.value == 'کاری',
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 24),
                Divider(color: colorScheme.secondary),
                Text(
                  'tasks'.tr,
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                    color: colorScheme.primary,
                  ),
                ),
                const SizedBox(height: 16),
                ...List.generate(controller.selectedProjects.length, (i) {
                  return Padding(
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    child: Column(
                      children: [
                        Row(
                          children: [
                            Expanded(
                              flex: 2,
                              child: DropdownButtonFormField<Project>(
                                value: controller.selectedProjects[i].value,
                                hint: Text('select_project'.tr),
                                decoration: buildInputDecoration('select_project', Icons.work),
                                items: controller.projects.map((project) {
                                  return DropdownMenuItem(
                                    value: project,
                                    enabled: controller.leaveType.value == 'کاری',
                                    child: Text(project.toString()),
                                  );
                                }).toList(),
                                onChanged: controller.leaveType.value == 'کاری'
                                    ? (val) => controller.selectedProjects[i].value = val
                                    : null,
                              ),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              flex: 1,
                              child: TextField(
                                controller: controller.durationControllers[i],
                                keyboardType: TextInputType.number,
                                enabled: controller.leaveType.value == 'کاری',
                                decoration: buildInputDecoration('task_minutes', Icons.timer),
                              ),
                            ),
                            IconButton(
                              icon: const Icon(Icons.delete, color: Colors.red),
                              onPressed: () {
                                controller.selectedProjects.removeAt(i);
                                controller.durationControllers.removeAt(i);
                                controller.descriptionControllers.removeAt(i);
                              },
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        TextField(
                          controller: controller.descriptionControllers[i],
                          maxLines: 2,
                          enabled: controller.leaveType.value == 'کاری',
                          decoration:
                          buildInputDecoration('task_description_optional', Icons.description),
                        ),
                      ],
                    ),
                  );
                }),
                Align(
                  alignment: Alignment.centerRight,
                  child: TextButton.icon(
                    onPressed:
                    controller.leaveType.value == 'کاری' ? controller.addTaskRow : null,
                    icon: const Icon(Icons.add),
                    label: Text('add_task'.tr),
                  ),
                ),
                const SizedBox(height: 24),
                TextField(
                  controller: controller.personalTimeController,
                  decoration: buildInputDecoration('personal_time', Icons.person),
                  keyboardType: TextInputType.number,
                  enabled: controller.leaveType.value == 'کاری',
                ),
                const SizedBox(height: 16),
                DropdownButtonFormField<String>(
                  value: controller.leaveType.value.isEmpty ? null : controller.leaveType.value,
                  hint: Text('leave_type'.tr),
                  decoration: buildInputDecoration('leave_type', Icons.leave_bags_at_home),
                  items: ['کاری', 'استحقاقی', 'استعلاجی', 'هدیه']
                      .map((e) => DropdownMenuItem(value: e, child: Text(e)))
                      .toList(),
                  onChanged: (val) => controller.leaveType.value = val ?? '',
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: controller.descriptionController,
                  decoration: buildInputDecoration('note_optional', Icons.note),
                  maxLines: 2,
                  enabled: controller.leaveType.value == 'کاری',
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: controller.goCostController,
                        keyboardType: TextInputType.number,
                        inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                        decoration: buildInputDecoration('go_cost', Icons.directions_bus),
                        enabled: controller.leaveType.value == 'کاری',
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: TextField(
                        controller: controller.returnCostController,
                        keyboardType: TextInputType.number,
                        inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                        decoration:
                        buildInputDecoration('return_cost', Icons.directions_bus_filled),
                        enabled: controller.leaveType.value == 'کاری',
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 24),
                Row(
                  children: [
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: controller.calculateStats,
                        icon: const Icon(Icons.calculate),
                        label: Text('calculate'.tr),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: () => controller.saveTask(date),
                        icon: const Icon(Icons.save),
                        label: Text('save'.tr),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 24),
              ],
            ),
          ),
        );
      },
    );
  }
}