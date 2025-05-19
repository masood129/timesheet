import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:shamsi_date/shamsi_date.dart';
import 'package:timesheet/home/api/home_api.dart';
import 'package:timesheet/home/model/daily_detail_model.dart';
import 'package:timesheet/home/model/project_model.dart';
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

    // حذف همه کاراکترهای غیرعددی
    String newText = newValue.text.replaceAll(RegExp(r'[^0-9]'), '');

    // تبدیل به عدد و فرمت با جداکننده
    try {
      final number = int.parse(newText);
      final formatted = _formatNumber(number);
      return newValue.copyWith(
        text: formatted,
        selection: TextSelection.collapsed(offset: formatted.length),
      );
    } catch (e) {
      return oldValue; // در صورت خطا، مقدار قبلی را نگه می‌دارد
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
      return hours * 60 + minutes;
    } catch (e) {
      return null;
    }
  }

  Future<void> loadDailyDetail(Jalali date) async {
    currentDate = date;
    try {
      final detail = await HomeApi().getDailyDetail(
        date.toDateTime().toIso8601String().split('T')[0],
        1,
      ); // فرض userId=1
      currentDetail.value = detail;

      // Clear previous data
      selectedProjects.clear();
      durationControllers.clear();
      descriptionControllers.clear();
      selectedCarCostProjects.clear();
      carCostControllers.clear();
      carCostDescriptionControllers.clear();

      // Populate fields
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
                detail!.returnCost!,
              )
              : '';
      leaveType.value = detail?.leaveType ?? 'کاری';

      // Populate tasks
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

      // Populate personal car costs
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
                      carCost.cost!,
                    )
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

  String? _extractTime(String? time) {
    if (time == null || time.isEmpty) return null;
    try {
      // پشتیبانی از فرمت‌های HH:mm، HH:mm:ss
      final timeRegex = RegExp(r'(\d{2}:\d{2})(?::\d{2})?');
      final match = timeRegex.firstMatch(time);
      if (match != null) {
        return match.group(1); // فقط HH:mm را برمی‌گرداند
      }
      return null;
    } catch (e) {
      return null;
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
      // فرض userId=1
      arrivalTime:
          arrivalTimeController.text.isEmpty
              ? null
              : arrivalTimeController.text,
      leaveTime:
          leaveTimeController.text.isEmpty ? null : leaveTimeController.text,
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
