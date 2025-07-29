import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:shamsi_date/shamsi_date.dart';
import '../../core/theme/app_styles.dart';
import '../controller/task_controller.dart';
import '../controller/home_controller.dart';
import '../model/project_model.dart';

class NoteDialog extends StatelessWidget {
  final Jalali date;
  final HomeController homeController = Get.find<HomeController>();

  NoteDialog({super.key, required this.date});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(TaskController());
    controller.loadDailyDetail(date, homeController.dailyDetails);
    final colorScheme = Theme.of(context).colorScheme;
    final disabledColor = Theme.of(context).disabledColor;

    Widget buildTimePickerField(
        String labelKey,
        TextEditingController controller,
        IconData icon,
        bool isEnabled,
        ) {
      TimeOfDay getInitialTime() {
        if (controller.text.isNotEmpty &&
            RegExp(r'^\d{2}:\d{2}$').hasMatch(controller.text)) {
          final parts = controller.text.split(':');
          final hours = int.tryParse(parts[0]) ?? 0;
          final minutes = int.tryParse(parts[1]) ?? 0;
          if (hours <= 23 && minutes <= 59) {
            return TimeOfDay(hour: hours, minute: minutes);
          }
        }
        return const TimeOfDay(hour: 0, minute: 0);
      }

      return Tooltip(
        message: isEnabled ? '' : 'غیرفعال برای مرخصی غیرکاری'.tr,
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
          onTap: isEnabled
              ? () async {
            final picked = await showTimePicker(
              context: context,
              initialTime: getInitialTime(),
            );
            if (picked != null) {
              final hours = picked.hour;
              final minutes = picked.minute;
              if (hours <= 23 && minutes <= 59) {
                controller.text =
                '${hours.toString().padLeft(2, '0')}:${minutes.toString().padLeft(2, '0')}';
              } else {
                Get.snackbar('خطا', 'فرمت زمان نامعتبر است'.tr);
              }
            }
          }
              : null,
        ),
      );
    }

    Widget buildDurationField(
        TextEditingController controller,
        bool isEnabled,
        ) {
      TimeOfDay getInitialTime() {
        if (controller.text.isNotEmpty &&
            RegExp(r'^\d{2}:\d{2}$').hasMatch(controller.text)) {
          final parts = controller.text.split(':');
          final hours = int.tryParse(parts[0]) ?? 0;
          final minutes = int.tryParse(parts[1]) ?? 0;
          if (hours <= 23 && minutes <= 59) {
            return TimeOfDay(hour: hours, minute: minutes);
          }
        }
        return const TimeOfDay(hour: 0, minute: 0);
      }

      return Tooltip(
        message: isEnabled ? '' : 'غیرفعال برای مرخصی غیرکاری'.tr,
        child: TextField(
          readOnly: true,
          controller: controller,
          enabled: isEnabled,
          decoration: AppStyles.inputDecoration(
            context,
            'task_duration',
            Icons.timer,
            isEnabled,
          ),
          onTap: isEnabled
              ? () async {
            final picked = await showTimePicker(
              context: context,
              initialTime: getInitialTime(),
            );
            if (picked != null) {
              final hours = picked.hour;
              final minutes = picked.minute;
              if (hours <= 23 && minutes <= 59) {
                controller.text =
                '${hours.toString().padLeft(2, '0')}:${minutes.toString().padLeft(2, '0')}';
              } else {
                Get.snackbar('خطا', 'فرمت زمان نامعتبر است'.tr);
              }
            }
          }
              : null,
        ),
      );
    }

    return SingleChildScrollView(
      child: Container(
        height: Get.height * 0.85,
        width: Get.width,
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(context).viewInsets.bottom,
          right: 15,
          left: 15,
          top: 10,
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
              const SizedBox(height: 10),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    'company_arrival_time'.tr,
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                      color: colorScheme.onSurface,
                    ),
                  ),
                  const SizedBox(width: 6),
                  Text(
                    '08:00',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: colorScheme.primary,
                    ),
                  ),
                  const SizedBox(width: 24),
                  Text(
                    'company_leave_time'.tr,
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                      color: colorScheme.onSurface,
                    ),
                  ),
                  const SizedBox(width: 6),
                  Text(
                    '17:00',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: colorScheme.primary,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),
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
                  const SizedBox(width: 10),
                  Expanded(
                    child: buildTimePickerField(
                      'leave_time_hint',
                      controller.leaveTimeController,
                      Icons.logout,
                      controller.leaveType.value == 'کاری',
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: buildTimePickerField(
                      'personal_time',
                      controller.personalTimeController,
                      Icons.person,
                      controller.leaveType.value == 'کاری',
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              ExpansionTile(
                title: Text(
                  controller.summaryReport.value.isEmpty
                      ? 'محاسبات'.tr
                      : controller.summaryReport.value,
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                    color: colorScheme.primary,
                  ),
                ),
                leading: Icon(
                  Icons.calculate,
                  color: colorScheme.primary,
                  size: 20,
                ),
                backgroundColor: colorScheme.surfaceContainer,
                collapsedBackgroundColor: colorScheme.surfaceContainer,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                collapsedShape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                tilePadding: const EdgeInsets.symmetric(horizontal: 12),
                children: [
                  Padding(
                    padding: const EdgeInsets.all(12),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Divider(
                          color: colorScheme.outlineVariant,
                          height: 16,
                        ),
                        Row(
                          children: [
                            Icon(
                              Icons.access_time,
                              color: colorScheme.secondary,
                              size: 18,
                            ),
                            const SizedBox(width: 8),
                            Text(
                              controller.presenceDuration.value,
                              style: TextStyle(
                                fontSize: 14,
                                color: colorScheme.onSurface,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Row(
                          children: [
                            Icon(
                              Icons.work,
                              color: colorScheme.secondary,
                              size: 18,
                            ),
                            const SizedBox(width: 8),
                            Text(
                              controller.effectiveWork.value,
                              style: TextStyle(
                                fontSize: 14,
                                color: colorScheme.onSurface,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'زمان وظایف به تفکیک:'.tr,
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 14,
                            color: colorScheme.primary,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Obx(
                              () => Column(
                            children: controller.taskDetails.isNotEmpty
                                ? controller.taskDetails
                                .map(
                                  (task) => Padding(
                                padding:
                                const EdgeInsets.only(bottom: 8),
                                child: Row(
                                  children: [
                                    Icon(
                                      Icons.task,
                                      color: colorScheme.secondary,
                                      size: 18,
                                    ),
                                    const SizedBox(width: 8),
                                    Expanded(
                                      child: Text(
                                        task,
                                        style: TextStyle(
                                          fontSize: 14,
                                          color: colorScheme.onSurface,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            )
                                .toList()
                                : [
                              Text(
                                'وظیفه‌ای ثبت نشده است'.tr,
                                style: TextStyle(
                                  fontSize: 14,
                                  color: colorScheme.onSurface,
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'هزینه‌ها به تفکیک:'.tr,
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 14,
                            color: colorScheme.primary,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Obx(
                              () => Column(
                            children: controller.costDetails.isNotEmpty
                                ? controller.costDetails
                                .map(
                                  (cost) => Padding(
                                padding:
                                const EdgeInsets.only(bottom: 8),
                                child: Row(
                                  children: [
                                    Icon(
                                      Icons.monetization_on,
                                      color: colorScheme.secondary,
                                      size: 18,
                                    ),
                                    const SizedBox(width: 8),
                                    Expanded(
                                      child: Text(
                                        cost,
                                        style: TextStyle(
                                          fontSize: 14,
                                          color: colorScheme.onSurface,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            )
                                .toList()
                                : [
                              Text(
                                'هزینه‌ای ثبت نشده است'.tr,
                                style: TextStyle(
                                  fontSize: 14,
                                  color: colorScheme.onSurface,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Divider(color: colorScheme.outlineVariant),
              const SizedBox(height: 10),
              DropdownButtonFormField<String>(
                value: controller.leaveType.value.isEmpty
                    ? null
                    : controller.leaveType.value,
                hint: Text(
                  'نوع مرخصی'.tr,
                  style: TextStyle(color: disabledColor),
                ),
                decoration: AppStyles.inputDecoration(
                  context,
                  'leave_type',
                  Icons.leave_bags_at_home,
                  true,
                ),
                items: ['کاری', 'استحقاقی', 'استعلاجی', 'هدیه']
                    .map(
                      (e) => DropdownMenuItem(
                    value: e,
                    child: Text(
                      e,
                      style: TextStyle(color: colorScheme.onSurface),
                    ),
                  ),
                )
                    .toList(),
                onChanged: (val) {
                  controller.leaveType.value = val ?? '';
                  controller.calculateStats();
                },
              ),
              const SizedBox(height: 10),
              TextField(
                controller: controller.descriptionController,
                maxLines: 1,
                decoration: AppStyles.inputDecoration(
                  context,
                  'note_optional',
                  Icons.note,
                  true,
                ),
              ),
              const SizedBox(height: 10),
              Row(
                children: [
                  Expanded(
                    child: Tooltip(
                      message: controller.leaveType.value == 'کاری'
                          ? ''
                          : 'غیرفعال برای مرخصی غیرکاری'.tr,
                      child: TextField(
                        controller: controller.goCostController,
                        keyboardType: TextInputType.number,
                        inputFormatters: [
                          FilteringTextInputFormatter.digitsOnly,
                          ThousandSeparatorInputFormatter(),
                        ],
                        enabled: controller.leaveType.value == 'کاری',
                        decoration: AppStyles.inputDecoration(
                          context,
                          'go_cost',
                          Icons.directions_bus,
                          controller.leaveType.value == 'کاری',
                        ),
                        onChanged: (value) {
                          controller.calculateStats();
                        },
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Tooltip(
                      message: controller.leaveType.value == 'کاری'
                          ? ''
                          : 'غیرفعال برای مرخصی غیرکاری'.tr,
                      child: TextField(
                        controller: controller.returnCostController,
                        keyboardType: TextInputType.number,
                        inputFormatters: [
                          FilteringTextInputFormatter.digitsOnly,
                          ThousandSeparatorInputFormatter(),
                        ],
                        enabled: controller.leaveType.value == 'کاری',
                        decoration: AppStyles.inputDecoration(
                          context,
                          'return_cost',
                          Icons.directions_bus_filled,
                          controller.leaveType.value == 'کاری',
                        ),
                        onChanged: (value) {
                          controller.calculateStats();
                        },
                      ),
                    ),
                  ),
                ],
              ),
              SizedBox(height: 30, child: Center(child: Divider())),
              Expanded(
                child: ListView(
                  children: [
                    Text(
                      'task'.tr,
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                        color: colorScheme.primary,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Obx(
                          () => Column(
                        children: List.generate(
                            controller.selectedProjects.length, (i) {
                          final isEnabled =
                              controller.leaveType.value == 'کاری';
                          return Padding(
                            padding: const EdgeInsets.symmetric(vertical: 8),
                            child: Column(
                              children: [
                                Row(
                                  children: [
                                    Expanded(
                                      flex: 2,
                                      child: Tooltip(
                                        message: isEnabled
                                            ? ''
                                            : 'غیرفعال برای مرخصی غیرکاری'.tr,
                                        child: Obx(
                                              () => DropdownButtonFormField<Project>(
                                            value: controller
                                                .selectedProjects[i].value,
                                            hint: Text(
                                              'انتخاب پروژه'.tr,
                                              style:
                                              TextStyle(color: disabledColor),
                                            ),
                                            decoration: AppStyles.inputDecoration(
                                              context,
                                              'select_project',
                                              Icons.work,
                                              isEnabled,
                                            ).copyWith(
                                              errorText: controller
                                                  .taskProjectErrors[i].value
                                                  ? 'پروژه الزامی است'.tr
                                                  : null,
                                              errorBorder: OutlineInputBorder(
                                                borderSide: BorderSide(
                                                  color: colorScheme.error,
                                                  width: 1.5,
                                                ),
                                                borderRadius:
                                                BorderRadius.circular(12),
                                              ),
                                              focusedErrorBorder:
                                              OutlineInputBorder(
                                                borderSide: BorderSide(
                                                  color: colorScheme.error,
                                                  width: 1.5,
                                                ),
                                                borderRadius:
                                                BorderRadius.circular(12),
                                              ),
                                            ),
                                            items: controller.projects
                                                .map<DropdownMenuItem<Project>>(
                                                    (project) {
                                                  return DropdownMenuItem<Project>(
                                                    value: project,
                                                    enabled: isEnabled,
                                                    child: Text(
                                                      project.projectName,
                                                      style: TextStyle(
                                                        color: isEnabled
                                                            ? colorScheme.onSurface
                                                            : disabledColor,
                                                      ),
                                                    ),
                                                  );
                                                }).toList(),
                                            onChanged: isEnabled
                                                ? (val) {
                                              controller
                                                  .selectedProjects[i]
                                                  .value = val;
                                              controller
                                                  .taskProjectErrors[i]
                                                  .value = false;
                                              controller.calculateStats();
                                            }
                                                : null,
                                          ),
                                        ),
                                      ),
                                    ),
                                    const SizedBox(width: 10),
                                    Expanded(
                                      flex: 1,
                                      child: buildDurationField(
                                        controller.durationControllers[i],
                                        isEnabled,
                                      ),
                                    ),
                                    IconButton(
                                      icon: Icon(
                                        Icons.delete,
                                        color: isEnabled
                                            ? colorScheme.error
                                            : disabledColor,
                                      ),
                                      onPressed: isEnabled
                                          ? () => controller.removeTaskRow(i)
                                          : null,
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 8),
                                Tooltip(
                                  message: isEnabled
                                      ? ''
                                      : 'غیرفعال برای مرخصی غیرکاری'.tr,
                                  child: TextField(
                                    controller:
                                    controller.descriptionControllers[i],
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
                      ),
                    ),
                    Align(
                      alignment: Alignment.centerRight,
                      child: TextButton.icon(
                        onPressed: controller.leaveType.value == 'کاری'
                            ? controller.addTaskRow
                            : null,
                        icon: Icon(
                          Icons.add,
                          color: controller.leaveType.value == 'کاری'
                              ? colorScheme.primary
                              : disabledColor,
                        ),
                        label: Text(
                          'اضافه کردن وظیفه'.tr,
                          style: TextStyle(
                            color: controller.leaveType.value == 'کاری'
                                ? colorScheme.primary
                                : disabledColor,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 10),
                    Text(
                      'هزینه‌های ماشین شخصی'.tr,
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                        color: colorScheme.primary,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Obx(
                          () => Column(
                        children: List.generate(
                            controller.selectedCarCostProjects.length, (i) {
                          if (i >= controller.carKmControllers.length ||
                              i >= controller.carCostControllers.length ||
                              i >= controller.carCostDescriptionControllers.length ||
                              i >= controller.carCostProjectErrors.length) {
                            return const SizedBox.shrink();
                          }
                          final isEnabled =
                              controller.leaveType.value == 'کاری';
                          return Padding(
                            padding: const EdgeInsets.symmetric(vertical: 8),
                            child: Column(
                              children: [
                                Row(
                                  children: [
                                    Expanded(
                                      flex: 2,
                                      child: Tooltip(
                                        message: isEnabled
                                            ? ''
                                            : 'غیرفعال برای مرخصی غیرکاری'.tr,
                                        child: Obx(
                                              () => DropdownButtonFormField<Project>(
                                            value: controller
                                                .selectedCarCostProjects[i]
                                                .value,
                                            hint: Text(
                                              'انتخاب پروژه'.tr,
                                              style:
                                              TextStyle(color: disabledColor),
                                            ),
                                            decoration: AppStyles.inputDecoration(
                                              context,
                                              'select_project',
                                              Icons.work,
                                              isEnabled,
                                            ).copyWith(
                                              errorText: controller
                                                  .carCostProjectErrors[i]
                                                  .value
                                                  ? 'پروژه الزامی است'.tr
                                                  : null,
                                              errorBorder: OutlineInputBorder(
                                                borderSide: BorderSide(
                                                  color: colorScheme.error,
                                                  width: 1.5,
                                                ),
                                                borderRadius:
                                                BorderRadius.circular(12),
                                              ),
                                              focusedErrorBorder:
                                              OutlineInputBorder(
                                                borderSide: BorderSide(
                                                  color: colorScheme.error,
                                                  width: 1.5,
                                                ),
                                                borderRadius:
                                                BorderRadius.circular(12),
                                              ),
                                            ),
                                            items: controller.projects
                                                .map<DropdownMenuItem<Project>>(
                                                    (project) {
                                                  return DropdownMenuItem<Project>(
                                                    value: project,
                                                    enabled: isEnabled,
                                                    child: Text(
                                                      project.projectName,
                                                      style: TextStyle(
                                                        color: isEnabled
                                                            ? colorScheme.onSurface
                                                            : disabledColor,
                                                        overflow:
                                                        TextOverflow.ellipsis,
                                                      ),
                                                    ),
                                                  );
                                                }).toList(),
                                            isDense: true,
                                            onChanged: isEnabled
                                                ? (val) {
                                              controller
                                                  .selectedCarCostProjects[i]
                                                  .value = val;
                                              controller
                                                  .carCostProjectErrors[i]
                                                  .value = false;
                                              controller.calculateStats();
                                            }
                                                : null,
                                          ),
                                        ),
                                      ),
                                    ),
                                    const SizedBox(width: 10),
                                    Expanded(
                                      flex: 1,
                                      child: Tooltip(
                                        message: isEnabled
                                            ? ''
                                            : 'غیرفعال برای مرخصی غیرکاری'.tr,
                                        child: TextField(
                                          controller:
                                          controller.carKmControllers[i],
                                          keyboardType: TextInputType.number,
                                          inputFormatters: [
                                            FilteringTextInputFormatter
                                                .digitsOnly,
                                            ThousandSeparatorInputFormatter(),
                                          ],
                                          enabled: isEnabled,
                                          decoration: AppStyles.inputDecoration(
                                            context,
                                            'kilometers',
                                            Icons.directions_car,
                                            isEnabled,
                                          ).copyWith(
                                            errorText: int.tryParse(
                                                controller
                                                    .carKmControllers[i]
                                                    .text
                                                    .replaceAll(',', '')) !=
                                                null &&
                                                int.parse(controller
                                                    .carKmControllers[i]
                                                    .text
                                                    .replaceAll(',', '')) <=
                                                    0
                                                ? 'کیلومتر نامعتبر'.tr
                                                : null,
                                          ),
                                          onChanged: (value) {
                                            controller.calculateStats();
                                          },
                                        ),
                                      ),
                                    ),
                                    const SizedBox(width: 10),
                                    Expanded(
                                      flex: 1,
                                      child: TextField(
                                        controller:
                                        controller.carCostControllers[i],
                                        readOnly: true,
                                        enabled: false,
                                        decoration: AppStyles.inputDecoration(
                                          context,
                                          'calculated_cost',
                                          Icons.monetization_on,
                                          false,
                                        ),
                                      ),
                                    ),
                                    IconButton(
                                      icon: Icon(
                                        Icons.delete,
                                        color: isEnabled
                                            ? colorScheme.error
                                            : disabledColor,
                                      ),
                                      onPressed: isEnabled
                                          ? () => controller.removeCarCostRow(i)
                                          : null,
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 8),
                                Tooltip(
                                  message: isEnabled
                                      ? ''
                                      : 'غیرفعال برای مرخصی غیرکاری'.tr,
                                  child: TextField(
                                    controller: controller
                                        .carCostDescriptionControllers[i],
                                    maxLines: 1,
                                    enabled: isEnabled,
                                    decoration: AppStyles.inputDecoration(
                                      context,
                                      'cost_description_optional',
                                      Icons.description,
                                      isEnabled,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          );
                        }),
                      ),
                    ),
                    Align(
                      alignment: Alignment.centerRight,
                      child: TextButton.icon(
                        onPressed: controller.leaveType.value == 'کاری'
                            ? controller.addCarCostRow
                            : null,
                        icon: Icon(
                          Icons.add,
                          color: controller.leaveType.value == 'کاری'
                              ? colorScheme.primary
                              : disabledColor,
                        ),
                        label: Text(
                          'اضافه کردن هزینه ماشین'.tr,
                          style: TextStyle(
                            color: controller.leaveType.value == 'کاری'
                                ? colorScheme.primary
                                : disabledColor,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),
              Row(
                children: [
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: controller.saveDailyDetail,
                      icon: Icon(
                        Icons.save,
                        color: colorScheme.onPrimary,
                        size: 24,
                      ),
                      label: Text(
                        'ذخیره'.tr,
                        style: TextStyle(
                          color: colorScheme.onPrimary,
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: colorScheme.primary,
                        padding: const EdgeInsets.symmetric(
                          vertical: 12,
                          horizontal: 15,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        elevation: 4,
                        shadowColor: colorScheme.primary.withValues(alpha:0.3),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 15),
            ],
          ),
        ),
      ),
    );
  }
}