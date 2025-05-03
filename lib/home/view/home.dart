import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:shamsi_date/shamsi_date.dart';
import 'package:persian_datetime_picker/persian_datetime_picker.dart';
import '../../core/theme/theme.dart';
import '../controller/home_controller.dart';

class CalendarView extends StatelessWidget {
  CalendarView({super.key});

  final calendarController = Get.put(CalendarController());
  final themeController = Get.find<ThemeController>();

  final weekDays = ['ش', 'ی', 'د', 'س', 'چ', 'پ', 'ج'];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Obx(() {
          final year = calendarController.currentYear.value;
          final month = calendarController.currentMonth.value;
          final monthName = Jalali(year, month).formatter.mN;
          return Text('${'calendar_title'.tr}: $monthName $year');
        }),
        actions: [
          IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: calendarController.previousMonth,
          ),
          IconButton(
            icon: const Icon(Icons.arrow_forward),
            onPressed: calendarController.nextMonth,
          ),
          Obx(
            () => Switch(
              value: themeController.isDark.value,
              onChanged: themeController.toggleTheme,
              activeColor: Theme.of(context).colorScheme.secondary,
            ),
          ),
          IconButton(
            icon: const Icon(Icons.language),
            onPressed: () {
              final newLocale =
                  Get.locale!.languageCode == 'fa'
                      ? const Locale('en')
                      : const Locale('fa');
              Get.updateLocale(newLocale);
            },
          ),
        ],
      ),
      body: Obx(() {
        final year = calendarController.currentYear.value;
        final month = calendarController.currentMonth.value;
        final daysInMonth = calendarController.daysInMonth;

        return Column(
          children: [
            Expanded(
              child: ListView.builder(
                itemCount: daysInMonth,
                itemBuilder: (context, index) {
                  final day = index + 1;
                  final date = Jalali(year, month, day);
                  final note =
                      calendarController.getNoteForDate(date) ?? 'no_note'.tr;
                  final isFriday = date.weekDay == 7;

                  return Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12.0,
                      vertical: 6,
                    ),
                    child: Card(
                      child: ListTile(
                        title: Text(
                          '${date.formatter.wN} ${date.day} ${date.formatter.mN} ${date.year}',
                          style: TextStyle(
                            color:
                                isFriday
                                    ? Theme.of(context).colorScheme.error
                                    : null,
                            fontWeight:
                                isFriday ? FontWeight.bold : FontWeight.normal,
                          ),
                        ),
                        subtitle: Text(
                          note,
                          style: TextStyle(
                            color: Theme.of(
                              context,
                            ).colorScheme.onSurface.withOpacity(0.7),
                          ),
                        ),
                        onTap: () => _showNoteDialog(context, date),
                        leading: CircleAvatar(
                          backgroundColor: Theme.of(
                            context,
                          ).colorScheme.primary.withOpacity(0.8),
                          child: Text(
                            '$day',
                            style: TextStyle(
                              color: Theme.of(context).colorScheme.onPrimary,
                            ),
                          ),
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        );
      }),
    );
  }

  void _showNoteDialog(BuildContext context, Jalali date) {
    final arrivalTimeController = TextEditingController();
    final leaveTimeController = TextEditingController();
    final personalTimeController = TextEditingController();
    final descriptionController = TextEditingController();

    final RxString leaveType = ''.obs;

    final List<TextEditingController> taskControllers = [
      TextEditingController(),
    ];
    final List<TextEditingController> durationControllers = [
      TextEditingController(),
    ];

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

    void calculateAndShowStats() {
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
              Text(
                '${'presence_duration'.tr}: ${presence.inHours} ${'hour'.tr} ${'and'.tr} ${presence.inMinutes % 60} ${'minute'.tr}',
              ),
              Text('${'effective_work'.tr}: $effective ${'minute'.tr}'),
              Text('${'task_total_time'.tr}: $totalTaskMinutes ${'minute'.tr}'),
            ],
          ),
          confirm: ElevatedButton(
            onPressed: () => Get.back(),
            child: Text('ok'.tr),
          ),
        );
      } else {
        Get.snackbar('error'.tr, 'error_arrival_leave'.tr);
      }
    }

    showModalBottomSheet(
      isScrollControlled: true,
      context: context,
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
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
              child: StatefulBuilder(
                builder: (context, setState) {
                  return ListView(
                    controller: scrollController,
                    children: [
                      Text(
                        '${date.formatter.wN} ${date.day} ${date.formatter.mN}',
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 12),
                      TextField(
                        readOnly: true,
                        controller: arrivalTimeController,
                        decoration: InputDecoration(
                          labelText: 'arrival_time_hint'.tr,
                        ),
                        onTap: () async {
                          final picked = await showTimePicker(
                            context: context,
                            initialTime: TimeOfDay.now(),
                          );
                          if (picked != null) {
                            final formattedTime =
                                '${picked.hour}:${picked.minute.toString().padLeft(2, '0')}';
                            arrivalTimeController.text = formattedTime;
                          }
                        },
                      ),

                      TextField(
                        readOnly: true,
                        controller: leaveTimeController,
                        decoration: InputDecoration(
                          labelText: 'leave_time_hint'.tr,
                        ),
                        onTap: () async {
                          final picked = await showTimePicker(
                            context: context,
                            initialTime: TimeOfDay.now(),
                          );
                          if (picked != null) {
                            final formattedTime =
                                '${picked.hour}:${picked.minute.toString().padLeft(2, '0')}';
                            leaveTimeController.text = formattedTime;
                          }
                        },
                      ),
                      const SizedBox(height: 12),
                      Text(
                        'tasks'.tr,
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 8),
                      ...List.generate(taskControllers.length, (i) {
                        return Padding(
                          padding: const EdgeInsets.symmetric(vertical: 4.0),
                          child: Row(
                            children: [
                              Expanded(
                                flex: 2,
                                child: TextField(
                                  controller: taskControllers[i],
                                  decoration: InputDecoration(
                                    hintText: '${'task_name'.tr} ${i + 1}',
                                  ),
                                ),
                              ),
                              const SizedBox(width: 8),
                              Expanded(
                                flex: 1,
                                child: TextField(
                                  controller: durationControllers[i],
                                  keyboardType: TextInputType.number,
                                  decoration: InputDecoration(
                                    hintText: 'task_minutes'.tr,
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
                          onPressed: () {
                            setState(() {
                              taskControllers.add(TextEditingController());
                              durationControllers.add(TextEditingController());
                            });
                          },
                          icon: const Icon(Icons.add),
                          label: Text('add_task'.tr),
                        ),
                      ),
                      TextField(
                        controller: personalTimeController,
                        decoration: InputDecoration(
                          labelText: 'personal_time'.tr,
                        ),
                        keyboardType: TextInputType.number,
                      ),
                      const SizedBox(height: 8),
                      Obx(
                        () => DropdownButtonFormField<String>(
                          value:
                              leaveType.value.isEmpty ? null : leaveType.value,
                          hint: Text('leave_type'.tr),
                          items:
                              ['کاری', 'استحقاقی', 'استعلاجی', 'هدیه']
                                  .map(
                                    (e) => DropdownMenuItem(
                                      value: e,
                                      child: Text(e),
                                    ),
                                  )
                                  .toList(),
                          onChanged: (val) => leaveType.value = val ?? '',
                        ),
                      ),
                      TextField(
                        controller: descriptionController,
                        decoration: InputDecoration(
                          labelText: 'note_optional'.tr,
                        ),
                        maxLines: 2,
                      ),
                      const SizedBox(height: 16),
                      ElevatedButton.icon(
                        onPressed: calculateAndShowStats,
                        icon: const Icon(Icons.calculate),
                        label: Text('calculate'.tr),
                        style: ElevatedButton.styleFrom(
                          backgroundColor:
                              Theme.of(context).colorScheme.primary,
                          foregroundColor:
                              Theme.of(context).colorScheme.onPrimary,
                        ),
                      ),
                      const SizedBox(height: 8),
                      ElevatedButton.icon(
                        onPressed: () {
                          Navigator.pop(context);
                        },
                        icon: const Icon(Icons.save),
                        label: Text('save'.tr),
                        style: ElevatedButton.styleFrom(
                          backgroundColor:
                              Theme.of(context).colorScheme.primary,
                          foregroundColor:
                              Theme.of(context).colorScheme.onPrimary,
                        ),
                      ),
                    ],
                  );
                },
              ),
            );
          },
        );
      },
    );
  }
}
