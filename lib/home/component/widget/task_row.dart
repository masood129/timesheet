import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../core/theme/app_styles.dart';
import '../../../core/widgets/searchable_dropdown.dart';
import '../../../model/project_model.dart';
import '../../controller/task_controller.dart';
import 'duration_field.dart';

class TaskRow extends StatelessWidget {
  final int index;
  final TaskController controller;
  final bool isEnabled;
  final ColorScheme colorScheme;
  final Color disabledColor;

  const TaskRow({
    super.key,
    required this.index,
    required this.controller,
    required this.isEnabled,
    required this.colorScheme,
    required this.disabledColor,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                flex: 2,
                child: Tooltip(
                  message: isEnabled ? '' : 'غیرفعال برای مرخصی غیرکاری'.tr,
                  child: Obx(
                        () => isEnabled ? SearchableDropdown<Project>(
                      value: controller.selectedProjects[index].value,
                      decoration: AppStyles.inputDecoration(context, 'select_project', Icons.work, isEnabled).copyWith(
                        errorText: controller.taskProjectErrors[index].value ? 'پروژه الزامی است'.tr : null,
                        errorBorder: OutlineInputBorder(borderSide: BorderSide(color: colorScheme.error, width: 1.5), borderRadius: BorderRadius.circular(12)),
                        focusedErrorBorder: OutlineInputBorder(borderSide: BorderSide(color: colorScheme.error, width: 1.5), borderRadius: BorderRadius.circular(12)),
                      ),
                      searchHint: 'جستجوی پروژه...'.tr,
                      items: controller.projects.map<DropdownMenuItem<Project>>((project) {
                        return DropdownMenuItem<Project>(
                          value: project,
                          child: Text(project.projectName, style: TextStyle(color: colorScheme.onSurface)),
                        );
                      }).toList(),
                      onChanged: (val) {
                        controller.selectedProjects[index].value = val;
                        controller.taskProjectErrors[index].value = false;
                        controller.calculateStats();
                      },
                    ) : DropdownButtonFormField<Project>(
                      initialValue: controller.selectedProjects[index].value,
                      hint: Text('انتخاب پروژه'.tr, style: TextStyle(color: disabledColor)),
                      decoration: AppStyles.inputDecoration(context, 'select_project', Icons.work, isEnabled).copyWith(
                        errorText: controller.taskProjectErrors[index].value ? 'پروژه الزامی است'.tr : null,
                        errorBorder: OutlineInputBorder(borderSide: BorderSide(color: colorScheme.error, width: 1.5), borderRadius: BorderRadius.circular(12)),
                        focusedErrorBorder: OutlineInputBorder(borderSide: BorderSide(color: colorScheme.error, width: 1.5), borderRadius: BorderRadius.circular(12)),
                      ),
                      items: controller.projects.map<DropdownMenuItem<Project>>((project) {
                        return DropdownMenuItem<Project>(
                          value: project,
                          enabled: false,
                          child: Text(project.projectName, style: TextStyle(color: disabledColor)),
                        );
                      }).toList(),
                      onChanged: null,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(flex: 1, child: DurationField(controller: controller.durationControllers[index], isEnabled: isEnabled)),
              IconButton(
                icon: Icon(Icons.delete, color: isEnabled ? colorScheme.error : disabledColor),
                onPressed: isEnabled ? () => controller.removeTaskRow(index) : null,
              ),
            ],
          ),
          const SizedBox(height: 8),
          Tooltip(
            message: isEnabled ? '' : 'غیرفعال برای مرخصی غیرکاری'.tr,
            child: TextField(
              controller: controller.descriptionControllers[index],
              maxLines: 1,
              enabled: isEnabled,
              decoration: AppStyles.inputDecoration(context, 'task_description_optional', Icons.description, isEnabled),
            ),
          ),
        ],
      ),
    );
  }
}