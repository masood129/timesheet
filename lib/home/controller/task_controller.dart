import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:shamsi_date/shamsi_date.dart';
import 'package:timesheet/home/api/home_api.dart';
import 'package:timesheet/home/model/daily_detail_model.dart';
import 'package:timesheet/home/model/project_model.dart';
import 'package:timezone/timezone.dart' as tz;
import '../model/personal_car_cost_model.dart';
import '../model/task_model.dart';
import 'home_controller.dart';

class ThousandSeparatorInputFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
      TextEditingValue oldValue,
      TextEditingValue newValue,
      ) {
    if (newValue.text.isEmpty) {
      return newValue;
    }

    String newText = newValue.text.replaceAll(RegExp(r'[^0-9]'), '');

    try {
      final number = int.parse(newText);
      final formatted = _formatNumber(number);
      return newValue.copyWith(
        text: formatted,
        selection: TextSelection.collapsed(offset: formatted.length),
      );
    } catch (e) {
      return oldValue;
    }
  }

  String _formatNumber(int number) {
    String numStr = number.toString();
    String result = '';
    int len = numStr.length;

    for (int i = 0; i < len; i++) {
      result += numStr[i];
      if ((len - i - 1) % 3 == 0 && i < len - 1) {
        result += ',';
      }
    }
    return result;
  }
}

class TaskController extends GetxController {
  final RxList<Project> projects = <Project>[].obs;
  final Rx<DailyDetail?> currentDetail = Rx<DailyDetail?>(null);
  final RxString leaveType = 'کاری'.obs;

  final arrivalTimeController = TextEditingController();
  final leaveTimeController = TextEditingController();
  final personalTimeController = TextEditingController();
  final descriptionController = TextEditingController();
  final goCostController = TextEditingController();
  final returnCostController = TextEditingController();

  final RxList<Rx<Project?>> selectedProjects = <Rx<Project?>>[].obs;
  final RxList<TextEditingController> durationControllers =
      <TextEditingController>[].obs;
  final RxList<TextEditingController> descriptionControllers =
      <TextEditingController>[].obs;

  final RxList<Rx<Project?>> selectedCarCostProjects = <Rx<Project?>>[].obs;
  final RxList<TextEditingController> carCostControllers =
      <TextEditingController>[].obs;
  final RxList<TextEditingController> carCostDescriptionControllers =
      <TextEditingController>[].obs;

  Jalali? currentDate;

  @override
  void onInit() {
    super.onInit();
    fetchProjects();
  }

  Future<void> fetchProjects() async {
    try {
      final value = await HomeApi().getProjects();
      projects.assignAll(value);
    } catch (e) {
      Get.snackbar('error'.tr, 'failed_to_fetch_projects'.tr);
    }
  }

  String _minutesToHHMM(int? minutes) {
    if (minutes == null || minutes <= 0) return '00:00';
    final hours = minutes ~/ 60;
    final mins = minutes % 60;
    return '${hours.toString().padLeft(2, '0')}:${mins.toString().padLeft(2, '0')}';
  }

  int? _hhmmToMinutes(String? time) {
    if (time == null ||
        time.isEmpty ||
        !RegExp(r'^\d{2}:\d{2}$').hasMatch(time)) {
      return null;
    }
    try {
      final parts = time.split(':');
      final hours = int.parse(parts[0]);
      final minutes = int.parse(parts[1]);
      if (hours > 23 || minutes > 59) return null;
      return hours * 60 + minutes;
    } catch (e) {
      return null;
    }
  }

  String? _extractTime(String? time) {
    if (time == null || time.isEmpty) return null;
    try {
      final tehran = tz.getLocation('Asia/Tehran');
      final date = tz.TZDateTime.parse(tehran, time);
      final hours = date.hour.toString().padLeft(2, '0');
      final minutes = date.minute.toString().padLeft(2, '0');
      final result = '$hours:$minutes';
      print('Input ISO: $time, Extracted time: $result');
      return result;
    } catch (e) {
      final timeRegex = RegExp(r'(\d{2}:\d{2})(?::\d{2})?');
      final match = timeRegex.firstMatch(time);
      if (match != null) {
        final result = match.group(1);
        print('Input non-ISO: $time, Extracted time: $result');
        return result;
      }
      print('Error in _extractTime: $e');
      return null;
    }
  }

  String? _toIsoTime(String? time, Jalali? date) {
    if (time == null ||
        time.isEmpty ||
        !RegExp(r'^\d{2}:\d{2}$').hasMatch(time) ||
        date == null) {
      return null;
    }
    try {
      final parts = time.split(':');
      final hours = int.parse(parts[0]);
      final minutes = int.parse(parts[1]);

      if (hours > 23 || minutes > 59) {
        return null;
      }

      final gregorianDate = date.toDateTime();
      final tehran = tz.getLocation('Asia/Tehran');
      final dt = tz.TZDateTime(
        tehran,
        gregorianDate.year,
        gregorianDate.month,
        gregorianDate.day,
        hours,
        minutes,
      );

      // فرمت دستی ISO با افست +03:30
      final isoTime = '${dt.year.toString().padLeft(4, '0')}-'
          '${dt.month.toString().padLeft(2, '0')}-'
          '${dt.day.toString().padLeft(2, '0')}T'
          '${dt.hour.toString().padLeft(2, '0')}:'
          '${dt.minute.toString().padLeft(2, '0')}:'
          '${dt.second.toString().padLeft(2, '0')}.000+03:30';

      print('Input time: $time, Output ISO: $isoTime');
      return isoTime;
    } catch (e) {
      print('Error in _toIsoTime: $e');
      return null;
    }
  }

  Future<void> loadDailyDetail(Jalali date) async {
    currentDate = date;
    try {
      final detail = await HomeApi().getDailyDetail(
        date.toDateTime().toIso8601String().split('T')[0],
        1,
      );
      currentDetail.value = detail;

      selectedProjects.clear();
      durationControllers.clear();
      descriptionControllers.clear();
      selectedCarCostProjects.clear();
      carCostControllers.clear();
      carCostDescriptionControllers.clear();

      arrivalTimeController.text = _extractTime(detail?.arrivalTime) ?? '';
      leaveTimeController.text = _extractTime(detail?.leaveTime) ?? '';
      personalTimeController.text = detail?.personalTime?.toString() ?? '';
      descriptionController.text = detail?.description ?? '';
      goCostController.text =
      detail?.goCost != null
          ? ThousandSeparatorInputFormatter()._formatNumber(detail!.goCost!)
          : '';
      returnCostController.text =
      detail?.returnCost != null
          ? ThousandSeparatorInputFormatter()._formatNumber(
          detail!.returnCost!)
          : '';
      leaveType.value = detail?.leaveType ?? 'کاری';

      for (final task in detail?.tasks ?? []) {
        final project = projects.firstWhereOrNull(
              (p) => p.id == task.projectId,
        );
        selectedProjects.add(Rx<Project?>(project));
        durationControllers.add(
          TextEditingController(text: _minutesToHHMM(task.duration)),
        );
        descriptionControllers.add(
          TextEditingController(text: task.description ?? ''),
        );
      }

      for (final carCost in detail?.personalCarCosts ?? []) {
        final project = projects.firstWhereOrNull(
              (p) => p.id == carCost.projectId,
        );
        selectedCarCostProjects.add(Rx<Project?>(project));
        carCostControllers.add(
          TextEditingController(
            text:
            carCost.cost != null
                ? ThousandSeparatorInputFormatter()._formatNumber(
                carCost.cost!)
                : '',
          ),
        );
        carCostDescriptionControllers.add(
          TextEditingController(text: carCost.description ?? ''),
        );
      }

      if (selectedProjects.isEmpty) {
        addTaskRow();
      }
      if (selectedCarCostProjects.isEmpty) {
        addCarCostRow();
      }
    } catch (e) {
      currentDetail.value = null;
      clearFields();
      Get.snackbar('error'.tr, 'failed_to_fetch_details'.tr);
    }
  }

  void clearFields() {
    arrivalTimeController.clear();
    leaveTimeController.clear();
    personalTimeController.clear();
    descriptionController.clear();
    goCostController.clear();
    returnCostController.clear();
    leaveType.value = 'کاری';
    selectedProjects.clear();
    durationControllers.clear();
    descriptionControllers.clear();
    selectedCarCostProjects.clear();
    carCostControllers.clear();
    carCostDescriptionControllers.clear();
    addTaskRow();
    addCarCostRow();
  }

  void addTaskRow() {
    selectedProjects.add(Rx<Project?>(null));
    durationControllers.add(TextEditingController(text: '00:00'));
    descriptionControllers.add(TextEditingController());
  }

  void addCarCostRow() {
    selectedCarCostProjects.add(Rx<Project?>(null));
    carCostControllers.add(TextEditingController());
    carCostDescriptionControllers.add(TextEditingController());
  }

  void removeCarCostRow(int index) {
    selectedCarCostProjects.removeAt(index);
    carCostControllers.removeAt(index);
    carCostDescriptionControllers.removeAt(index);
  }

  Future<void> saveDailyDetail() async {
    if (currentDate == null) return;

    final tasks = <Task>[];
    for (int i = 0; i < selectedProjects.length; i++) {
      if (selectedProjects[i].value != null) {
        final duration = _hhmmToMinutes(durationControllers[i].text);
        if (duration != null) {
          tasks.add(
            Task(
              projectId: selectedProjects[i].value!.id,
              duration: duration,
              description: descriptionControllers[i].text,
            ),
          );
        }
      }
    }

    final personalCarCosts = <PersonalCarCost>[];
    for (int i = 0; i < selectedCarCostProjects.length; i++) {
      if (selectedCarCostProjects[i].value != null) {
        final cost = int.tryParse(
          carCostControllers[i].text.replaceAll(',', ''),
        );
        if (cost != null) {
          personalCarCosts.add(
            PersonalCarCost(
              projectId: selectedCarCostProjects[i].value!.id,
              cost: cost,
              description: carCostDescriptionControllers[i].text,
            ),
          );
        }
      }
    }

    final detail = DailyDetail(
      date: currentDate!.toDateTime().toIso8601String().split('T')[0],
      userId: 1,
      arrivalTime: _toIsoTime(arrivalTimeController.text, currentDate),
      leaveTime: _toIsoTime(leaveTimeController.text, currentDate),
      leaveType: leaveType.value,
      personalTime: int.tryParse(personalTimeController.text),
      description: descriptionController.text,
      goCost: int.tryParse(goCostController.text.replaceAll(',', '')),
      returnCost: int.tryParse(returnCostController.text.replaceAll(',', '')),
      tasks: tasks,
      personalCarCosts: personalCarCosts,
    );

    try {
      await HomeApi().saveDailyDetail(detail);
      Get.back();
      Get.snackbar('success'.tr, 'details_saved'.tr);
      Get.find<HomeController>().fetchMonthlyDetails();
    } catch (e) {
      Get.snackbar('error'.tr, 'failed_to_save_details'.tr);
    }
  }

  Duration? parseTime(String time) {
    try {
      final parts = time.split(':');
      if (parts.length >= 2) {
        return Duration(
          hours: int.parse(parts[0]),
          minutes: int.parse(parts[1]),
        );
      }
    } catch (_) {}
    return null;
  }

  void calculateStats() {
    final arrival = parseTime(arrivalTimeController.text);
    final leave = parseTime(leaveTimeController.text);
    final personal = int.tryParse(personalTimeController.text) ?? 0;
    int totalTaskMinutes = durationControllers.fold(0, (sum, controller) {
      final minutes = _hhmmToMinutes(controller.text);
      return sum + (minutes ?? 0);
    });
    final totalCost =
        (int.tryParse(goCostController.text.replaceAll(',', '')) ?? 0) +
            (int.tryParse(returnCostController.text.replaceAll(',', '')) ?? 0) +
            carCostControllers.fold(0, (sum, controller) {
              return sum + (int.tryParse(controller.text.replaceAll(',', '')) ?? 0);
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
            Text(
              '${'total_cost'.tr}: ${ThousandSeparatorInputFormatter()._formatNumber(totalCost.toInt())}',
            ),
          ],
        ),
        confirm: ElevatedButton(onPressed: Get.back, child: Text('ok'.tr)),
      );
    } else {
      Get.snackbar('error'.tr, 'error_arrival_leave'.tr);
    }
  }
}