import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import '../../../core/theme/app_styles.dart';
import '../../../model/project_model.dart';
import '../../controller/task_controller.dart';

class CarCostRow extends StatelessWidget {
  final int index;
  final TaskController controller;
  final bool isEnabled;
  final ColorScheme colorScheme;
  final Color disabledColor;

  const CarCostRow({
    super.key,
    required this.index,
    required this.controller,
    required this.isEnabled,
    required this.colorScheme,
    required this.disabledColor,
  });

  @override
  Widget build(BuildContext context) {
    if (index >= controller.carKmControllers.length ||
        index >= controller.carCostControllers.length ||
        index >= controller.carCostDescriptionControllers.length ||
        index >= controller.carCostProjectErrors.length) {
      return const SizedBox.shrink();
    }

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
                        () => DropdownButtonFormField<Project>(
                      initialValue: controller.selectedCarCostProjects[index].value,
                      hint: Text('انتخاب پروژه'.tr, style: TextStyle(color: disabledColor)),
                      decoration: AppStyles.inputDecoration(context, 'select_project', Icons.work, isEnabled).copyWith(
                        errorText: controller.carCostProjectErrors[index].value ? 'پروژه الزامی است'.tr : null,
                        errorBorder: OutlineInputBorder(borderSide: BorderSide(color: colorScheme.error, width: 1.5), borderRadius: BorderRadius.circular(12)),
                        focusedErrorBorder: OutlineInputBorder(borderSide: BorderSide(color: colorScheme.error, width: 1.5), borderRadius: BorderRadius.circular(12)),
                      ),
                      items: controller.projects.map<DropdownMenuItem<Project>>((project) {
                        return DropdownMenuItem<Project>(
                          value: project,
                          enabled: isEnabled,
                          child: Text(project.projectName, style: TextStyle(color: isEnabled ? colorScheme.onSurface : disabledColor, overflow: TextOverflow.ellipsis)),
                        );
                      }).toList(),
                      isDense: true,
                      onChanged: isEnabled ? (val) {
                        controller.selectedCarCostProjects[index].value = val;
                        controller.carCostProjectErrors[index].value = false;
                        controller.calculateStats();
                      } : null,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                flex: 1,
                child: Tooltip(
                  message: isEnabled ? '' : 'غیرفعال برای مرخصی غیرکاری'.tr,
                  child: TextField(
                    controller: controller.carKmControllers[index],
                    keyboardType: TextInputType.number,
                    inputFormatters: [FilteringTextInputFormatter.digitsOnly, ThousandSeparatorInputFormatter()],
                    enabled: isEnabled,
                    decoration: AppStyles.inputDecoration(context, 'kilometers', Icons.directions_car, isEnabled).copyWith(
                      errorText: int.tryParse(controller.carKmControllers[index].text.replaceAll(',', '')) != null && int.parse(controller.carKmControllers[index].text.replaceAll(',', '')) <= 0 ? 'کیلومتر نامعتبر'.tr : null,
                    ),
                    onChanged: (value) => controller.calculateStats(),
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                flex: 1,
                child: TextField(
                  controller: controller.carCostControllers[index],
                  readOnly: true,
                  enabled: false,
                  decoration: AppStyles.inputDecoration(context, 'calculated_cost', Icons.monetization_on, false),
                ),
              ),
              IconButton(
                icon: Icon(Icons.delete, color: isEnabled ? colorScheme.error : disabledColor),
                onPressed: isEnabled ? () => controller.removeCarCostRow(index) : null,
              ),
            ],
          ),
          const SizedBox(height: 8),
          Tooltip(
            message: isEnabled ? '' : 'غیرفعال برای مرخصی غیرکاری'.tr,
            child: TextField(
              controller: controller.carCostDescriptionControllers[index],
              maxLines: 1,
              enabled: isEnabled,
              decoration: AppStyles.inputDecoration(context, 'cost_description_optional', Icons.description, isEnabled),
            ),
          ),
        ],
      ),
    );
  }
}