import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:shamsi_date/shamsi_date.dart';
import '../../core/theme/app_styles.dart';
import '../controller/task_controller.dart';
import '../model/project_model.dart';

class NoteDialog extends StatelessWidget {
  final Jalali date;

  const NoteDialog({super.key, required this.date});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(TaskController());
    controller.loadDailyDetail(date); // Load data for the selected date
    final colorScheme = Theme.of(context).colorScheme;
    final disabledColor = Theme.of(context).disabledColor;

    Widget buildTimePickerField(
        String labelKey,
        TextEditingController controller,
        IconData icon,
        bool isEnabled,
        ) {
      return Tooltip(
        message: isEnabled ? '' : 'disabled_for_non_working_leave'.tr,
        child: TextField(
          readOnly: true,
          controller: controller,
          enabled: isEnabled,
          decoration: AppStyles.inputDecoration(
            context,
            labelKey,
            icon,
            isEnabled,
          ),
          onTap:
          isEnabled
              ? () async {
            final picked = await showTimePicker(
              context: context,
              initialTime: TimeOfDay.now(),
            );
            if (picked != null) {
              controller.text =
              '${picked.hour}:${picked.minute.toString().padLeft(2, '0')}';
            }
          }
              : null,
        ),
      );
    }

    return SingleChildScrollView(
      child: Container(
        height: Get.height * .85,
        width: Get.width,
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(context).viewInsets.bottom,
          right: 16,
          left: 16,
          top: 16,
        ),
        child: Obx(
              () => Column(
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
                  Expanded(
                    child: ListView(
                                children: [
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
                      final isEnabled = controller.leaveType.value == 'کاری';
                      return Padding(
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        child: Column(
                          children: [
                            Row(
                              children: [
                                Expanded(
                                  flex: 2,
                                  child: Tooltip(
                                    message:
                                    isEnabled
                                        ? ''
                                        : 'disabled_for_non_working_leave'.tr,
                                    child: DropdownButtonFormField<Project>(
                                      value: controller.selectedProjects[i].value,
                                      hint: Text(
                                        'select_project'.tr,
                                        style: TextStyle(color: disabledColor),
                                      ),
                                      decoration: AppStyles.inputDecoration(
                                        context,
                                        'select_project',
                                        Icons.work,
                                        isEnabled,
                                      ),
                                      items:
                                      controller.projects
                                          .map<DropdownMenuItem<Project>>((
                                          project,
                                          ) {
                                        return DropdownMenuItem<Project>(
                                          value: project,
                                          enabled: isEnabled,
                                          child: Text(
                                            project.projectName,
                                            style: TextStyle(
                                              color:
                                              isEnabled
                                                  ? colorScheme.onSurface
                                                  : disabledColor,
                                            ),
                                          ),
                                        );
                                      })
                                          .toList(),
                                      onChanged:
                                      isEnabled
                                          ? (val) =>
                                      controller
                                          .selectedProjects[i]
                                          .value = val
                                          : null,
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 16),
                                Expanded(
                                  flex: 1,
                                  child: Tooltip(
                                    message:
                                    isEnabled
                                        ? ''
                                        : 'disabled_for_non_working_leave'.tr,
                                    child: TextField(
                                      controller: controller.durationControllers[i],
                                      keyboardType: TextInputType.number,
                                      enabled: isEnabled,
                                      decoration: AppStyles.inputDecoration(
                                        context,
                                        'task_minutes',
                                        Icons.timer,
                                        isEnabled,
                                      ),
                                    ),
                                  ),
                                ),
                                IconButton(
                                  icon: Icon(
                                    Icons.delete,
                                    color: isEnabled ? Colors.red : disabledColor,
                                  ),
                                  onPressed:
                                  isEnabled
                                      ? () {
                                    controller.selectedProjects.removeAt(i);
                                    controller.durationControllers.removeAt(
                                      i,
                                    );
                                    controller.descriptionControllers
                                        .removeAt(i);
                                  }
                                      : null,
                                ),
                              ],
                            ),
                            const SizedBox(height: 16),
                            Tooltip(
                              message:
                              isEnabled
                                  ? ''
                                  : 'disabled_for_non_working_leave'.tr,
                              child: TextField(
                                controller: controller.descriptionControllers[i],
                                maxLines: 1,
                                enabled: isEnabled,
                                decoration: AppStyles.inputDecoration(
                                  context,
                                  'task_description_optional',
                                  Icons.description,
                                  isEnabled,
                                ),
                              ),
                            ),
                          ],
                        ),
                      );
                    }),
                    Align(
                      alignment: Alignment.centerRight,
                      child: TextButton.icon(
                        onPressed:
                        controller.leaveType.value == 'کاری'
                            ? controller.addTaskRow
                            : null,
                        icon: Icon(
                          Icons.add,
                          color:
                          controller.leaveType.value == 'کاری'
                              ? colorScheme.primary
                              : disabledColor,
                        ),
                        label: Text(
                          'add_task'.tr,
                          style: TextStyle(
                            color:
                            controller.leaveType.value == 'کاری'
                                ? colorScheme.primary
                                : disabledColor,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),
                    Tooltip(
                      message:
                      controller.leaveType.value == 'کاری'
                          ? ''
                          : 'disabled_for_non_working_leave'.tr,
                      child: TextField(
                        controller: controller.personalTimeController,
                        keyboardType: TextInputType.number,
                        enabled: controller.leaveType.value == 'کاری',
                        decoration: AppStyles.inputDecoration(
                          context,
                          'personal_time',
                          Icons.person,
                          controller.leaveType.value == 'کاری',
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    DropdownButtonFormField<String>(
                      value:
                      controller.leaveType.value.isEmpty
                          ? null
                          : controller.leaveType.value,
                      hint: Text(
                        'leave_type'.tr,
                        style: TextStyle(color: disabledColor),
                      ),
                      decoration: AppStyles.inputDecoration(
                        context,
                        'leave_type',
                        Icons.leave_bags_at_home,
                        true,
                      ),
                      items:
                      ['کاری', 'استحقاقی', 'استعلاجی', 'هدیه'].map((e) {
                        return DropdownMenuItem(
                          value: e,
                          child: Text(
                            e,
                            style: TextStyle(color: colorScheme.onSurface),
                          ),
                        );
                      }).toList(),
                      onChanged: (val) => controller.leaveType.value = val ?? '',
                    ),
                    const SizedBox(height: 16),
                    Tooltip(
                      message:
                      controller.leaveType.value == 'کاری'
                          ? ''
                          : 'disabled_for_non_working_leave'.tr,
                      child: TextField(
                        controller: controller.descriptionController,
                        maxLines: 2,
                        enabled: controller.leaveType.value == 'کاری',
                        decoration: AppStyles.inputDecoration(
                          context,
                          'note_optional',
                          Icons.note,
                          controller.leaveType.value == 'کاری',
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        Expanded(
                          child: Tooltip(
                            message:
                            controller.leaveType.value == 'کاری'
                                ? ''
                                : 'disabled_for_non_working_leave'.tr,
                            child: TextField(
                              controller: controller.goCostController,
                              keyboardType: TextInputType.number,
                              inputFormatters: [
                                FilteringTextInputFormatter.digitsOnly,
                              ],
                              enabled: controller.leaveType.value == 'کاری',
                              decoration: AppStyles.inputDecoration(
                                context,
                                'go_cost',
                                Icons.directions_bus,
                                controller.leaveType.value == 'کاری',
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Tooltip(
                            message:
                            controller.leaveType.value == 'کاری'
                                ? ''
                                : 'disabled_for_non_working_leave'.tr,
                            child: TextField(
                              controller: controller.returnCostController,
                              keyboardType: TextInputType.number,
                              inputFormatters: [
                                FilteringTextInputFormatter.digitsOnly,
                              ],
                              enabled: controller.leaveType.value == 'کاری',
                              decoration: AppStyles.inputDecoration(
                                context,
                                'return_cost',
                                Icons.directions_bus_filled,
                                controller.leaveType.value == 'کاری',
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    Tooltip(
                      message:
                      controller.leaveType.value == 'کاری'
                          ? ''
                          : 'disabled_for_non_working_leave'.tr,
                      child: TextField(
                        controller: controller.personalCarCostController,
                        keyboardType: TextInputType.number,
                        inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                        enabled: controller.leaveType.value == 'کاری',
                        decoration: AppStyles.inputDecoration(
                          context,
                          'personal_car_cost',
                          Icons.directions_car,
                          controller.leaveType.value == 'کاری',
                        ).copyWith(
                          errorText:
                          int.tryParse(
                            controller.personalCarCostController.text,
                          ) !=
                              null &&
                              int.parse(
                                controller.personalCarCostController.text,
                              ) <
                                  0
                              ? 'invalid_cost'.tr
                              : null,
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),
                    Row(
                      children: [
                        Expanded(
                          child: ElevatedButton.icon(
                            onPressed: controller.calculateStats,
                            icon: Icon(Icons.calculate, color: colorScheme.onPrimary),
                            label: Text(
                              'calculate'.tr,
                              style: TextStyle(color: colorScheme.onPrimary),
                            ),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: colorScheme.primary,
                            ),
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: ElevatedButton.icon(
                            onPressed: controller.saveDailyDetail,
                            icon: Icon(Icons.save, color: colorScheme.onPrimary),
                            label: Text(
                              'save'.tr,
                              style: TextStyle(color: colorScheme.onPrimary),
                            ),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: colorScheme.primary,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 24),
                                ],
                              ),
                  ),
                ],
              ),
        ),
      ),
    );
  }
}
