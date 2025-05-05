import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:shamsi_date/shamsi_date.dart';

import '../model/task_model.dart';

class NoteDialog extends StatefulWidget {
  final Jalali date;
  final RxString leaveType;

  const NoteDialog({super.key, required this.date, required this.leaveType});

  @override
  State<NoteDialog> createState() => _NoteDialogState();
}

class _NoteDialogState extends State<NoteDialog> {
  final arrivalTimeController = TextEditingController();
  final leaveTimeController = TextEditingController();
  final personalTimeController = TextEditingController();
  final descriptionController = TextEditingController();
  final goCostController = TextEditingController();
  final returnCostController = TextEditingController();

  final List<Project> availableProjects = [
    Project(code: 'P001', name: 'پروژه الف'),
    Project(code: 'P002', name: 'پروژه ب'),
    Project(code: 'P003', name: 'پروژه ج'),
  ];

  final RxList<Rx<Project?>> selectedProjects = <Rx<Project?>>[].obs;
  final RxList<TextEditingController> durationControllers = <TextEditingController>[].obs;
  final RxList<TextEditingController> descriptionControllers = <TextEditingController>[].obs;

  @override
  void initState() {
    super.initState();
    widget.leaveType.value = 'کاری';  // تنظیم پیش‌فرض
    addTaskRow();
  }

  InputDecoration buildInputDecoration(String label, IconData icon) {
    return InputDecoration(
      labelText: label,
      prefixIcon: Icon(icon),
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
      contentPadding: const EdgeInsets.symmetric(vertical: 10, horizontal: 12),
    );
  }

  Duration? parseTime(String time) {
    try {
      final parts = time.split(':');
      if (parts.length == 2) {
        final hour = int.parse(parts[0]);
        final minute = int.parse(parts[1]);
        return Duration(hours: hour, minutes: minute);
      }
    } catch (_) {}
    return null;
  }

  void calculateAndShowStats(BuildContext context) {
    final arrival = parseTime(arrivalTimeController.text);
    final leave = parseTime(leaveTimeController.text);
    final personal = int.tryParse(personalTimeController.text) ?? 0;
    int totalTaskMinutes = durationControllers.fold(0, (sum, controller) {
      final time = int.tryParse(controller.text) ?? 0;
      return sum + time;
    });

    if (arrival != null && leave != null) {
      final presence = leave - arrival;
      final effective = presence.inMinutes - personal;

      Get.defaultDialog(
        title: 'result'.tr,
        content: Column(
          children: [
            Text('${'presence_duration'.tr}: ${presence.inHours} ${'hour'.tr} ${'and'.tr} ${presence.inMinutes % 60} ${'minute'.tr}'),
            Text('${'effective_work'.tr}: $effective ${'minute'.tr}'),
            Text('${'task_total_time'.tr}: $totalTaskMinutes ${'minute'.tr}'),
          ],
        ),
        confirm: ElevatedButton(onPressed: Get.back, child: Text('ok'.tr)),
      );
    } else {
      Get.snackbar('error'.tr, 'error_arrival_leave'.tr);
    }
  }

  void addTaskRow() {
    selectedProjects.add(Rx<Project?>(null));
    durationControllers.add(TextEditingController());
    descriptionControllers.add(TextEditingController());
  }

  Widget _buildTimePickerField(BuildContext context, String label, TextEditingController controller, IconData icon, bool isEnabled) {
    return TextField(
      readOnly: true,
      controller: controller,
      enabled: isEnabled,
      decoration: buildInputDecoration(label, icon).copyWith(
        filled: true,
        fillColor: isEnabled ? null : Colors.grey[300],
      ),
      onTap: isEnabled ? () async {
        final picked = await showTimePicker(
          context: context,
          initialTime: TimeOfDay.now(),
        );
        if (picked != null) {
          controller.text = '${picked.hour}:${picked.minute.toString().padLeft(2, '0')}';
        }
      } : null,
    );
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

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
                    '${widget.date.formatter.wN} ${widget.date.day} ${widget.date.formatter.mN}',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: colorScheme.primary),
                  ),
                ),
                const SizedBox(height: 24),
                Row(
                  children: [
                    Expanded(child: _buildTimePickerField(context, 'arrival_time_hint'.tr, arrivalTimeController, Icons.login, widget.leaveType.value == 'کاری')),
                    const SizedBox(width: 16),
                    Expanded(child: _buildTimePickerField(context, 'leave_time_hint'.tr, leaveTimeController, Icons.logout, widget.leaveType.value == 'کاری')),
                  ],
                ),
                const SizedBox(height: 24),
                Divider(color: colorScheme.secondary),
                Text('tasks'.tr, style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: colorScheme.primary)),
                const SizedBox(height: 16),
                ...List.generate(selectedProjects.length, (i) {
                  return Padding(
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    child: Column(
                      children: [
                        Row(
                          children: [
                            Expanded(
                              flex: 2,
                              child: DropdownButtonFormField<Project>(
                                value: selectedProjects[i].value,
                                hint: Text('select_project'.tr),
                                decoration: buildInputDecoration('select_project'.tr, Icons.work),
                                items: availableProjects.map((project) {
                                  return DropdownMenuItem(value: project, child: Text(project.toString()));
                                }).toList(),
                                onChanged: widget.leaveType.value == 'کاری' ? (val) => selectedProjects[i].value = val : null,
                              ),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              flex: 1,
                              child: TextField(
                                controller: durationControllers[i],
                                keyboardType: TextInputType.number,
                                enabled: widget.leaveType.value == 'کاری',
                                decoration: buildInputDecoration('task_minutes'.tr, Icons.timer),
                              ),
                            ),
                            IconButton(
                              icon: const Icon(Icons.delete, color: Colors.red),
                              onPressed: () => setState(() {
                                selectedProjects.removeAt(i);
                                durationControllers.removeAt(i);
                                descriptionControllers.removeAt(i);
                              }),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        TextField(
                          controller: descriptionControllers[i],
                          maxLines: 2,
                          enabled: widget.leaveType.value == 'کاری',
                          decoration: buildInputDecoration('task_description_optional'.tr, Icons.description),
                        ),
                      ],
                    ),
                  );
                }),
                Align(
                  alignment: Alignment.centerRight,
                  child: TextButton.icon(
                    onPressed: widget.leaveType.value == 'کاری' ? () => setState(() => addTaskRow()) : null,
                    icon: const Icon(Icons.add),
                    label: Text('add_task'.tr),
                  ),
                ),
                const SizedBox(height: 24),
                TextField(
                  controller: personalTimeController,
                  decoration: buildInputDecoration('personal_time'.tr, Icons.person),
                  keyboardType: TextInputType.number,
                  enabled: widget.leaveType.value == 'کاری',
                ),
                const SizedBox(height: 16),
                DropdownButtonFormField<String>(
                  value: widget.leaveType.value.isEmpty ? null : widget.leaveType.value,
                  hint: Text('leave_type'.tr),
                  decoration: buildInputDecoration('leave_type'.tr, Icons.leave_bags_at_home),
                  items: ['کاری', 'استحقاقی', 'استعلاجی', 'هدیه']
                      .map((e) => DropdownMenuItem(value: e, child: Text(e)))
                      .toList(),
                  onChanged: (val) => widget.leaveType.value = val ?? '',
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: descriptionController,
                  decoration: buildInputDecoration('note_optional'.tr, Icons.note),
                  maxLines: 2,
                  enabled: widget.leaveType.value == 'کاری',
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: goCostController,
                        keyboardType: TextInputType.number,
                        inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                        decoration: buildInputDecoration('go_cost'.tr, Icons.directions_bus),
                        enabled: widget.leaveType.value == 'کاری',
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: TextField(
                        controller: returnCostController,
                        keyboardType: TextInputType.number,
                        inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                        decoration: buildInputDecoration('return_cost'.tr, Icons.directions_bus_filled),
                        enabled: widget.leaveType.value == 'کاری',
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 24),
                Row(
                  children: [
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: () => calculateAndShowStats(context),
                        icon: const Icon(Icons.calculate),
                        label: Text('calculate'.tr),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: () => Navigator.pop(context),
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
