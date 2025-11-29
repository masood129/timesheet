import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/Get.dart';
import 'package:shamsi_date/shamsi_date.dart';
import 'package:timesheet/core/api/api_calls/api_calls.dart';
import 'package:timezone/timezone.dart' as tz;
import '../../core/theme/snackbar_helper.dart';
import '../../model/daily_detail_model.dart';
import '../../model/leavetype_model.dart';
import '../../model/personal_car_cost_model.dart';
import '../../model/project_model.dart';
import '../../model/task_model.dart';
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
      final cappedNumber = number > 40000 ? 40000 : number;
      final formatted = _formatNumber(cappedNumber);
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
  final Rx<LeaveType> leaveType = LeaveType.work.obs; // تغییر به enum
  final RxString summaryReport = ''.obs;
  final RxList<String> taskDetails = <String>[].obs;
  final RxList<String> costDetails = <String>[].obs;
  final RxList<RxBool> carCostProjectErrors = <RxBool>[].obs;
  final RxList<RxBool> taskProjectErrors = <RxBool>[].obs;

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
  final RxList<TextEditingController> carKmControllers =
      <TextEditingController>[].obs;
  final RxList<TextEditingController> carCostControllers =
      <TextEditingController>[].obs;
  final RxList<TextEditingController> carCostDescriptionControllers =
      <TextEditingController>[].obs;

  final RxString presenceDuration = ''.obs;
  final RxString effectiveWork = ''.obs;
  final RxString taskTotalTime = ''.obs;
  final RxString totalCost = ''.obs;

  // Timer-related variables
  final RxBool isTimerRunning = false.obs;
  final Rx<Project?> selectedTimerProject = Rx<Project?>(null);
  final RxString timerDuration = '00:00:00'.obs;
  DateTime? timerStartTime;

  // Personal Timer-related variables
  final RxBool isPersonalTimerRunning = false.obs;
  final RxString personalTimerDuration = '00:00:00'.obs;
  DateTime? personalTimerStartTime;

  Jalali? currentDate;

  @override
  void onInit() {
    super.onInit();
    fetchProjects();
    // Start updating timer duration every second
    ever(isTimerRunning, (_) {
      if (isTimerRunning.value) {
        _updateTimerDuration();
      }
    });
    ever(isPersonalTimerRunning, (_) {
      if (isPersonalTimerRunning.value) {
        _updateTimerDuration();
      }
    });
  }

  void setupListeners() {
    arrivalTimeController.addListener(calculateStats);
    leaveTimeController.addListener(calculateStats);
    personalTimeController.addListener(calculateStats);
    goCostController.addListener(calculateStats);
    returnCostController.addListener(calculateStats);
    carKmControllers.listen((_) => calculateStats());
    durationControllers.listen((_) => calculateStats());
    selectedProjects.listen((_) => calculateStats());
    selectedCarCostProjects.listen((_) => calculateStats());
  }

  void startTimer() {
    if (selectedTimerProject.value == null || isPersonalTimerRunning.value) {
      return;
    }
    isTimerRunning.value = true;
    timerStartTime = DateTime.now();
    _updateTimerDuration();
  }

  void startPersonalTimer() {
    if (isTimerRunning.value) return;
    isPersonalTimerRunning.value = true;
    personalTimerStartTime = DateTime.now();
    _updateTimerDuration();
  }

  Future<void> stopTimer(Jalali date) async {
    if (!isTimerRunning.value || selectedTimerProject.value == null) return;
    isTimerRunning.value = false;
    final duration = DateTime.now().difference(timerStartTime!).inMinutes;
    if (duration > 0) {
      currentDate = date;
      await loadDailyDetail(date, Get.find<HomeController>().dailyDetails);
      // Check if a task with the same projectId already exists
      int existingIndex = selectedProjects.indexWhere(
        (p) => p.value?.id == selectedTimerProject.value!.id,
      );
      if (existingIndex != -1) {
        // Update existing task duration
        final existingDuration =
            _hhmmToMinutes(durationControllers[existingIndex].text) ?? 0;
        durationControllers[existingIndex].text = _minutesToHHMM(
          existingDuration + duration,
        );
        if (descriptionControllers[existingIndex].text.isEmpty) {
          descriptionControllers[existingIndex].text = 'اضافه‌شده توسط تایمر';
        }
      } else {
        // Add new task
        addTaskRow();
        final index = selectedProjects.length - 1;
        selectedProjects[index].value = selectedTimerProject.value;
        durationControllers[index].text = _minutesToHHMM(duration);
        descriptionControllers[index].text = 'اضافه‌شده توسط تایمر';
      }
      calculateStats();
    }
    timerStartTime = null;
    timerDuration.value = '00:00:00';
    selectedTimerProject.value = null;
  }

  Future<void> stopPersonalTimer(Jalali date) async {
    if (!isPersonalTimerRunning.value) return;
    isPersonalTimerRunning.value = false;
    final duration =
        DateTime.now().difference(personalTimerStartTime!).inMinutes;
    if (duration > 0) {
      currentDate = date;
      await loadDailyDetail(date, Get.find<HomeController>().dailyDetails);
      final existingPersonalTime =
          _hhmmToMinutes(personalTimeController.text) ?? 0;
      personalTimeController.text = _minutesToHHMM(
        existingPersonalTime + duration,
      );
      calculateStats();
    }
    personalTimerStartTime = null;
    personalTimerDuration.value = '00:00:00';
  }

  void _updateTimerDuration() {
    if (isTimerRunning.value && timerStartTime != null) {
      Timer.periodic(const Duration(seconds: 1), (timer) {
        if (!isTimerRunning.value) {
          timer.cancel();
          return;
        }
        final duration = DateTime.now().difference(timerStartTime!).inSeconds;
        final hours = duration ~/ 3600;
        final minutes = (duration % 3600) ~/ 60;
        final seconds = duration % 60;
        timerDuration.value =
            '${hours.toString().padLeft(2, '0')}:${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
      });
    }

    if (isPersonalTimerRunning.value && personalTimerStartTime != null) {
      Timer.periodic(const Duration(seconds: 1), (timer) {
        if (!isPersonalTimerRunning.value) {
          timer.cancel();
          return;
        }
        final duration =
            DateTime.now().difference(personalTimerStartTime!).inSeconds;
        final hours = duration ~/ 3600;
        final minutes = (duration % 3600) ~/ 60;
        final seconds = duration % 60;
        personalTimerDuration.value =
            '${hours.toString().padLeft(2, '0')}:${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
      });
    }
  }

  Future<void> fetchProjects() async {
    try {
      final value = await ApiCalls().getProjects();
      projects.assignAll(value);
    } catch (e) {
      if (kDebugMode) {
        print('Error fetching projects: $e');
      }
      final errorMessage = e.toString().replaceFirst('Exception: ', '');
      ThemedSnackbar.showError(
        'error'.tr,
        errorMessage.isNotEmpty
            ? errorMessage
            : 'fetch_projects_issue_snackbar'.tr,
      );
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
      return '$hours:$minutes';
    } catch (e) {
      final timeRegex = RegExp(r'(\d{2}:\d{2})(?::\d{2})?');
      final match = timeRegex.firstMatch(time);
      if (match != null) {
        return match.group(1);
      }
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

      return '${dt.toIso8601String().split('.')[0]}+03:30';
    } catch (e) {
      return null;
    }
  }

  int calculateCarCost(int kilometers) {
    const int baseKm = 10;
    const int baseRate = 5000;
    const int extraRate = 3500;

    if (kilometers <= baseKm) {
      return kilometers * baseRate;
    } else {
      return (baseKm * baseRate) + ((kilometers - baseKm) * extraRate);
    }
  }

  Future<void> loadDailyDetail(
    Jalali date,
    List<DailyDetail> dailyDetails,
  ) async {
    currentDate = date;
    try {
      final gregorianDate = date.toGregorian();
      final formattedDate =
          '${gregorianDate.year}-${gregorianDate.month.toString().padLeft(2, '0')}-${gregorianDate.day.toString().padLeft(2, '0')}';

      final detail = dailyDetails.firstWhereOrNull(
        (d) => d.date == formattedDate,
      );

      currentDetail.value = detail;

      selectedProjects.clear();
      for (var controller in durationControllers) {
        controller.dispose();
      }
      durationControllers.clear();
      for (var controller in descriptionControllers) {
        controller.dispose();
      }
      descriptionControllers.clear();
      selectedCarCostProjects.clear();
      for (var controller in carKmControllers) {
        controller.dispose();
      }
      carKmControllers.clear();
      for (var controller in carCostControllers) {
        controller.dispose();
      }
      carCostControllers.clear();
      for (var controller in carCostDescriptionControllers) {
        controller.dispose();
      }
      carCostDescriptionControllers.clear();
      carCostProjectErrors.clear();
      taskProjectErrors.clear();

      arrivalTimeController.text = _extractTime(detail?.arrivalTime) ?? '';
      leaveTimeController.text = _extractTime(detail?.leaveTime) ?? '';
      personalTimeController.text = _minutesToHHMM(detail?.personalTime);
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
      leaveType.value =
          LeaveTypeExtension.fromString(detail?.leaveType?.apiValue) ??
          LeaveType.work;

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
        taskProjectErrors.add(RxBool(false));
      }

      for (final cost in detail?.personalCarCosts ?? []) {
        final project = projects.firstWhereOrNull(
          (p) => p.id == cost.projectId,
        );
        selectedCarCostProjects.add(Rx<Project?>(project));
        carKmControllers.add(
          TextEditingController(text: cost.kilometers.toString()),
        );
        carCostControllers.add(
          TextEditingController(
            text: ThousandSeparatorInputFormatter()._formatNumber(
              cost.cost ?? 0,
            ),
          ),
        );
        carCostDescriptionControllers.add(
          TextEditingController(text: cost.description ?? ''),
        );
        carCostProjectErrors.add(RxBool(false));
      }

      if (selectedProjects.isEmpty) {
        addTaskRow();
      }
      if (selectedCarCostProjects.isEmpty) {
        addCarCostRow();
      }

      calculateStats();
    } catch (e) {
      ThemedSnackbar.showError('error'.tr, 'failed_to_fetch_details'.tr);
    }
  }

  void clearFields() {
    arrivalTimeController.text = '';
    leaveTimeController.text = '';
    personalTimeController.text = '00:00';
    descriptionController.text = '';
    goCostController.text = '';
    returnCostController.text = '';
    leaveType.value = LeaveType.work; // تغییر به enum

    selectedProjects.clear();
    for (var controller in durationControllers) {
      controller.dispose();
    }
    durationControllers.clear();
    for (var controller in descriptionControllers) {
      controller.dispose();
    }
    descriptionControllers.clear();
    selectedCarCostProjects.clear();
    for (var controller in carKmControllers) {
      controller.dispose();
    }
    carKmControllers.clear();
    for (var controller in carCostControllers) {
      controller.dispose();
    }
    carCostControllers.clear();
    for (var controller in carCostDescriptionControllers) {
      controller.dispose();
    }
    carCostDescriptionControllers.clear();
    carCostProjectErrors.clear();
    taskProjectErrors.clear();

    addTaskRow();
    addCarCostRow();
  }

  void addTaskRow() {
    selectedProjects.add(Rx<Project?>(null));
    durationControllers.add(TextEditingController(text: '00:00'));
    descriptionControllers.add(TextEditingController());
    taskProjectErrors.add(RxBool(false));
  }

  void addCarCostRow() {
    selectedCarCostProjects.add(Rx<Project?>(null));
    carKmControllers.add(TextEditingController());
    carCostControllers.add(TextEditingController());
    carCostDescriptionControllers.add(TextEditingController());
    carCostProjectErrors.add(RxBool(false));
  }

  void removeTaskRow(int index) {
    if (index >= 0 && index < selectedProjects.length) {
      selectedProjects.removeAt(index);
      durationControllers[index].dispose();
      durationControllers.removeAt(index);
      descriptionControllers[index].dispose();
      descriptionControllers.removeAt(index);
      taskProjectErrors.removeAt(index);
      if (selectedProjects.isEmpty) {
        addTaskRow();
      }
      calculateStats();
    }
  }

  void removeCarCostRow(int index) {
    if (index >= 0 && index < selectedCarCostProjects.length) {
      selectedCarCostProjects.removeAt(index);
      carKmControllers[index].dispose();
      carKmControllers.removeAt(index);
      carCostControllers[index].dispose();
      carCostControllers.removeAt(index);
      carCostDescriptionControllers[index].dispose();
      carCostDescriptionControllers.removeAt(index);
      carCostProjectErrors.removeAt(index);

      if (selectedCarCostProjects.isEmpty) {
        addCarCostRow();
      }

      update();
      calculateStats();
    }
  }

  Future<void> saveDailyDetail() async {
    if (currentDate == null) return;

    for (var error in carCostProjectErrors) {
      error.value = false;
    }
    for (var error in taskProjectErrors) {
      error.value = false;
    }

    bool hasTaskError = false;
    for (int i = 0; i < selectedProjects.length; i++) {
      final duration = _hhmmToMinutes(durationControllers[i].text) ?? 0;
      if (duration > 0 && selectedProjects[i].value == null) {
        taskProjectErrors[i].value = true;
        hasTaskError = true;
      }
    }

    bool hasCarCostError = false;
    for (int i = 0; i < selectedCarCostProjects.length; i++) {
      final kilometers =
          int.tryParse(carKmControllers[i].text.replaceAll(',', '')) ?? 0;
      if (kilometers > 0 && selectedCarCostProjects[i].value == null) {
        carCostProjectErrors[i].value = true;
        hasCarCostError = true;
      }
    }

    if (hasTaskError || hasCarCostError) {
      ThemedSnackbar.showError(
        'error'.tr,
        'لطفاً برای تمام وظایف و هزینه‌های خودرو پروژه انتخاب کنید',
      );
      return;
    }

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
        final kilometers =
            int.tryParse(carKmControllers[i].text.replaceAll(',', '')) ?? 0;
        if (kilometers > 0) {
          final cost = calculateCarCost(kilometers);
          personalCarCosts.add(
            PersonalCarCost(
              projectId: selectedCarCostProjects[i].value!.id,
              kilometers: kilometers,
              cost: cost,
              description: carCostDescriptionControllers[i].text,
            ),
          );
        }
      }
    }

    final goCost = int.tryParse(goCostController.text.replaceAll(',', '')) ?? 0;
    final returnCost =
        int.tryParse(returnCostController.text.replaceAll(',', '')) ?? 0;
    final cappedGoCost = goCost > 40000 ? 40000 : goCost;
    final cappedReturnCost = returnCost > 40000 ? 40000 : returnCost;

    final detail = DailyDetail(
      date: currentDate!.toDateTime().toIso8601String().split('T')[0],
      userId: 1,
      arrivalTime: _toIsoTime(arrivalTimeController.text, currentDate),
      leaveTime: _toIsoTime(leaveTimeController.text, currentDate),
      leaveTypeString: leaveType.value.apiValue,
      // تغییر به apiValue برای ارسال string به API
      personalTime: _hhmmToMinutes(personalTimeController.text),
      description: descriptionController.text,
      goCost: cappedGoCost,
      returnCost: cappedReturnCost,
      tasks: tasks,
      personalCarCosts: personalCarCosts,
    );

    try {
      await ApiCalls().saveDailyDetail(detail);
      Get.back();
      ThemedSnackbar.showSuccess('success'.tr, 'details_saved_snackbar'.tr);
      Get.find<HomeController>().fetchMonthlyDetails();
    } catch (e) {
      ThemedSnackbar.showError('error'.tr, 'save_details_issue_snackbar'.tr);
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
    final personal = _hhmmToMinutes(personalTimeController.text) ?? 0;
    final totalTaskMinutes = durationControllers.fold<int>(0, (
      sum,
      controller,
    ) {
      final minutes = _hhmmToMinutes(controller.text);
      return sum + (minutes ?? 0);
    });

    final goCost = int.tryParse(goCostController.text.replaceAll(',', '')) ?? 0;
    final returnCost =
        int.tryParse(returnCostController.text.replaceAll(',', '')) ?? 0;
    final cappedGoCost = goCost > 40000 ? 40000 : goCost;
    final cappedReturnCost = returnCost > 40000 ? 40000 : returnCost;

    if (carKmControllers.isEmpty ||
        carCostControllers.isEmpty ||
        selectedCarCostProjects.isEmpty) {
      return;
    }

    while (carCostControllers.length < carKmControllers.length) {
      carCostControllers.add(TextEditingController());
    }
    while (carCostDescriptionControllers.length < carKmControllers.length) {
      carCostDescriptionControllers.add(TextEditingController());
    }
    while (selectedCarCostProjects.length < carKmControllers.length) {
      selectedCarCostProjects.add(Rx<Project?>(null));
    }
    while (carCostProjectErrors.length < carKmControllers.length) {
      carCostProjectErrors.add(RxBool(false));
    }
    while (taskProjectErrors.length < selectedProjects.length) {
      taskProjectErrors.add(RxBool(false));
    }

    final totalCarCosts = carKmControllers.asMap().entries.fold<int>(0, (
      sum,
      entry,
    ) {
      final i = entry.key;
      final controller = entry.value;
      if (i < carKmControllers.length && i < carCostControllers.length) {
        final kilometers =
            int.tryParse(controller.text.replaceAll(',', '')) ?? 0;
        return sum + (kilometers > 0 ? calculateCarCost(kilometers) : 0);
      }
      return sum;
    });

    for (
      int i = 0;
      i < carKmControllers.length && i < carCostControllers.length;
      i++
    ) {
      final kilometers =
          int.tryParse(carKmControllers[i].text.replaceAll(',', '')) ?? 0;
      final cost = kilometers > 0 ? calculateCarCost(kilometers) : 0;
      carCostControllers[i].text = ThousandSeparatorInputFormatter()
          ._formatNumber(cost);
    }

    final totalCosts = cappedGoCost + cappedReturnCost + totalCarCosts;

    taskDetails.clear();
    costDetails.clear();

    for (int i = 0; i < selectedProjects.length; i++) {
      if (selectedProjects[i].value != null) {
        final minutes = _hhmmToMinutes(durationControllers[i].text) ?? 0;
        if (minutes > 0) {
          final hours = minutes ~/ 60;
          final mins = minutes % 60;
          taskDetails.add(
            '${selectedProjects[i].value!.projectName}: ${hours.toString().padLeft(2, '0')}:${mins.toString().padLeft(2, '0')}',
          );
        }
      }
    }

    if (cappedGoCost > 0) {
      costDetails.add(
        'هزینه رفت: ${ThousandSeparatorInputFormatter()._formatNumber(cappedGoCost)}',
      );
    }
    if (cappedReturnCost > 0) {
      costDetails.add(
        'هزینه بازگشت: ${ThousandSeparatorInputFormatter()._formatNumber(cappedReturnCost)}',
      );
    }
    for (
      int i = 0;
      i < carKmControllers.length && i < selectedCarCostProjects.length;
      i++
    ) {
      if (selectedCarCostProjects[i].value != null) {
        final kilometers =
            int.tryParse(carKmControllers[i].text.replaceAll(',', '')) ?? 0;
        if (kilometers > 0) {
          final cost = calculateCarCost(kilometers);
          costDetails.add(
            'هزینه خودرو (${selectedCarCostProjects[i].value!.projectName} - $kilometers کیلومتر): ${ThousandSeparatorInputFormatter()._formatNumber(cost)}',
          );
        }
      }
    }

    if (arrival != null && leave != null) {
      final presence = leave - arrival;
      final effective = presence.inMinutes - personal;

      summaryReport.value =
          '${'live_calc_effective_work_prefix'.tr}${effective ~/ 60}${'live_calc_hours_and_suffix'.tr}${effective % 60}${'live_calc_minutes_suffix'.tr}';
      presenceDuration.value =
          '${'live_calc_presence_duration_prefix'.tr}${presence.inHours}${'live_calc_hours_and_suffix'.tr}${presence.inMinutes % 60}${'live_calc_minutes_suffix'.tr}';
      effectiveWork.value =
          '${'live_calc_effective_work_prefix'.tr}${effective ~/ 60}${'live_calc_hours_and_suffix'.tr}${effective % 60}${'live_calc_minutes_suffix'.tr}';
      taskTotalTime.value =
          '${'live_calc_total_task_time_prefix'.tr}${totalTaskMinutes ~/ 60}${'live_calc_hours_and_suffix'.tr}${totalTaskMinutes % 60}${'live_calc_minutes_suffix'.tr}';
      totalCost.value =
          '${'live_calc_total_cost_prefix'.tr}${ThousandSeparatorInputFormatter()._formatNumber(totalCosts)}';
    } else {
      summaryReport.value = '';
      presenceDuration.value = '';
      effectiveWork.value = '';
      taskTotalTime.value = '';
      totalCost.value = '';
      taskDetails.clear();
      costDetails.clear();
    }
  }

  @override
  void onClose() {
    arrivalTimeController.dispose();
    leaveTimeController.dispose();
    personalTimeController.dispose();
    descriptionController.dispose();
    goCostController.dispose();
    returnCostController.dispose();

    for (var controller in durationControllers) {
      controller.dispose();
    }
    durationControllers.clear();

    for (var controller in descriptionControllers) {
      controller.dispose();
    }
    descriptionControllers.clear();

    for (var controller in carKmControllers) {
      controller.dispose();
    }
    carKmControllers.clear();

    for (var controller in carCostControllers) {
      controller.dispose();
    }
    carCostControllers.clear();

    for (var controller in carCostDescriptionControllers) {
      controller.dispose();
    }
    carCostDescriptionControllers.clear();

    carCostProjectErrors.clear();
    taskProjectErrors.clear();

    super.onClose();
  }
}
