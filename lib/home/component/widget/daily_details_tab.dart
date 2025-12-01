// daily_details_tab.dart (بروزرسانی شده)
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/Get.dart';
import '../../../core/theme/app_styles.dart';
import '../../../core/widgets/searchable_dropdown.dart';
import '../../../model/leavetype_model.dart';
import '../../controller/task_controller.dart';
import 'time_picker_field.dart';

class DailyDetailsTab extends StatefulWidget {
  final TaskController controller;

  const DailyDetailsTab({super.key, required this.controller});

  @override
  State<DailyDetailsTab> createState() => _DailyDetailsTabState();
}

class _DailyDetailsTabState extends State<DailyDetailsTab> {
  @override
  void initState() {
    super.initState();
    // اضافه کردن listener به controllerهای time برای فراخوانی calculateStats هنگام تغییر
    widget.controller.arrivalTimeController.addListener(_onTimeChanged);
    widget.controller.leaveTimeController.addListener(_onTimeChanged);
    widget.controller.personalTimeController.addListener(_onTimeChanged);
    // listener برای description (اختیاری، چون maxLines=1 و ممکنه تغییر کنه)
    widget.controller.descriptionController.addListener(_onTimeChanged);
  }

  @override
  void dispose() {
    // حذف listenerها برای جلوگیری از memory leak
    widget.controller.arrivalTimeController.removeListener(_onTimeChanged);
    widget.controller.leaveTimeController.removeListener(_onTimeChanged);
    widget.controller.personalTimeController.removeListener(_onTimeChanged);
    widget.controller.descriptionController.removeListener(_onTimeChanged);
    super.dispose();
  }

  // متد helper برای فراخوانی calculateStats هنگام تغییر هر فیلد
  void _onTimeChanged() {
    widget.controller.calculateStats();
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return ListView(
      children: [
        //   Text(
        //     'day_details'.tr,
        //     style: TextStyle(
        //       fontWeight: FontWeight.bold,
        //       fontSize: 16,
        //       color: colorScheme.primary,
        //     ),
        //   ),
        const SizedBox(height: 8),
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
        Obx(() {
          final isEnabled =
              widget.controller.leaveType.value == LeaveType.work ||
              widget.controller.leaveType.value == LeaveType.mission;
          final hasError = widget.controller.hasTimeError.value;
          return Row(
            children: [
              Expanded(
                child: TimePickerField(
                  labelKey: 'arrival_time_hint',
                  controller: widget.controller.arrivalTimeController,
                  icon: Icons.login,
                  isEnabled: isEnabled,
                  hasError: hasError,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: TimePickerField(
                  labelKey: 'leave_time_hint',
                  controller: widget.controller.leaveTimeController,
                  icon: Icons.logout,
                  isEnabled: isEnabled,
                  hasError: hasError,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: TimePickerField(
                  labelKey: 'personal_time',
                  controller: widget.controller.personalTimeController,
                  icon: Icons.person,
                  isEnabled: isEnabled,
                ),
              ),
            ],
          );
        }),
        const SizedBox(height: 10),
        Obx(
          () => SearchableDropdown<LeaveType>(
            value: widget.controller.leaveType.value,
            decoration: AppStyles.inputDecoration(
              context,
              'leave_type',
              Icons.leave_bags_at_home,
              true,
            ),
            searchHint: 'جستجوی نوع مرخصی...',
            items:
                LeaveType.values
                    .map(
                      (e) => DropdownMenuItem(
                        value: e,
                        child: Text(
                          e.displayName,
                          style: TextStyle(color: colorScheme.onSurface),
                        ),
                      ),
                    )
                    .toList(),
            onChanged: (val) {
              widget.controller.leaveType.value = val ?? LeaveType.work;
              widget.controller.calculateStats();
            },
          ),
        ),
        const SizedBox(height: 10),
        TextField(
          controller: widget.controller.descriptionController,
          maxLines: 1,
          decoration: AppStyles.inputDecoration(
            context,
            'note_optional',
            Icons.note,
            true,
          ),
        ),
        const SizedBox(height: 10),
        Obx(() {
          final isEnabled =
              widget.controller.leaveType.value == LeaveType.work ||
              widget.controller.leaveType.value == LeaveType.mission;
          return Row(
            children: [
              Expanded(
                child: Tooltip(
                  message: isEnabled ? '' : 'disabled_for_non_working_leave'.tr,
                  child: TextField(
                    controller: widget.controller.goCostController,
                    keyboardType: TextInputType.number,
                    inputFormatters: [
                      FilteringTextInputFormatter.digitsOnly,
                      ThousandSeparatorInputFormatter(),
                    ],
                    enabled: isEnabled,
                    decoration: AppStyles.inputDecoration(
                      context,
                      'go_cost',
                      Icons.directions_bus,
                      isEnabled,
                    ),
                    onChanged: (value) => widget.controller.calculateStats(),
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Tooltip(
                  message: isEnabled ? '' : 'disabled_for_non_working_leave'.tr,
                  child: TextField(
                    controller: widget.controller.returnCostController,
                    keyboardType: TextInputType.number,
                    inputFormatters: [
                      FilteringTextInputFormatter.digitsOnly,
                      ThousandSeparatorInputFormatter(),
                    ],
                    enabled: isEnabled,
                    decoration: AppStyles.inputDecoration(
                      context,
                      'return_cost',
                      Icons.directions_bus_filled,
                      isEnabled,
                    ),
                    onChanged: (value) => widget.controller.calculateStats(),
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
