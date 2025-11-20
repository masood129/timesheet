import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../core/theme/app_styles.dart';
import '../../../core/theme/snackbar_helper.dart';

class TimePickerField extends StatelessWidget {
  final String labelKey;
  final TextEditingController controller;
  final IconData icon;
  final bool isEnabled;

  const TimePickerField({
    super.key,
    required this.labelKey,
    required this.controller,
    required this.icon,
    required this.isEnabled,
  });

  TimeOfDay _getInitialTime() {
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

  @override
  Widget build(BuildContext context) {
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
        onTap: isEnabled
            ? () async {
          final picked = await showTimePicker(
            context: context,
            initialTime: _getInitialTime(),
          );
          if (picked != null) {
            final hours = picked.hour;
            final minutes = picked.minute;
            if (hours <= 23 && minutes <= 59) {
              controller.text =
              '${hours.toString().padLeft(2, '0')}:${minutes.toString().padLeft(2, '0')}';
            } else {
              ThemedSnackbar.showError('error'.tr, 'invalid_time_format_error'.tr);
            }
          }
        }
            : null,
      ),
    );
  }
}