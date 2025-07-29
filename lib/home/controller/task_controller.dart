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
  final RxString leaveType = 'کاری'.obs;
  final RxString summaryReport = ''.obs;
  final RxList<String> taskDetails = <String>[].obs;
  final RxList<String> costDetails = <String>[].obs;
  final RxList<RxBool> carCostProjectErrors = <RxBool>[].obs;
  final RxList<RxBool> taskProjectErrors = <RxBool>[].obs; // Added for task error tracking

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

  Jalali? currentDate;

  @override
  void onInit() {
    super.onInit();
    fetchProjects();
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

  Future<void> fetchProjects() async {
    try {
      final value = await HomeApi().getProjects();
      projects.assignAll(value);
    } catch (e) {
      Get.snackbar('خطا', 'دریافت پروژه‌ها با مشکل مواجه شد');
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

      return dt.toIso8601String().split('.')[0] + '+03:30';
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
      // تبدیل تاریخ جلالی به فرمت گرگویی برای مقایسه
      final gregorianDate = date.toGregorian();
      final formattedDate =
          '${gregorianDate.year}-${gregorianDate.month.toString().padLeft(2, '0')}-${gregorianDate.day.toString().padLeft(2, '0')}';

      // جستجوی داده‌های روز در dailyDetails
      final detail = dailyDetails.firstWhereOrNull(
            (d) => d.date == formattedDate,
      );

      currentDetail.value = detail;

      // پاک کردن لیست‌ها بدون فراخوانی calculateStats
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
      taskProjectErrors.clear(); // Clear task errors

      // پر کردن فیلدها با داده‌های موجود یا مقادیر پیش‌فرض
      arrivalTimeController.text = _extractTime(detail?.arrivalTime) ?? '';
      leaveTimeController.text = _extractTime(detail?.leaveTime) ?? '';
      personalTimeController.text =
          _minutesToHHMM(detail?.personalTime) ?? '00:00';
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

      // پر کردن وظایف
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
        taskProjectErrors.add(RxBool(false)); // Initialize task error state
      }

      // پر کردن هزینه‌های ماشین شخصی
      for (final carCost in detail?.personalCarCosts ?? []) {
        final project = projects.firstWhereOrNull(
              (p) => p.id == carCost.projectId,
        );
        selectedCarCostProjects.add(Rx<Project?>(project));
        carKmControllers.add(
          TextEditingController(
            text: carCost.kilometers != null
                ? ThousandSeparatorInputFormatter()._formatNumber(
              carCost.kilometers!,
            )
                : '',
          ),
        );
        carCostControllers.add(
          TextEditingController(
            text: carCost.cost != null
                ? ThousandSeparatorInputFormatter()._formatNumber(
              carCost.cost!,
            )
                : '',
          ),
        );
        carCostDescriptionControllers.add(
          TextEditingController(text: carCost.description ?? ''),
        );
        carCostProjectErrors.add(RxBool(false));
      }

      if (selectedProjects.isEmpty) {
        addTaskRow();
      }
      if (selectedCarCostProjects.isEmpty) {
        addCarCostRow();
      }

      setupListeners();
      calculateStats();
    } catch (e) {
      currentDetail.value = null;
      // ریست کردن فیلدها
      arrivalTimeController.text = '';
      leaveTimeController.text = '';
      personalTimeController.text = '00:00';
      descriptionController.text = '';
      goCostController.text = '';
      returnCostController.text = '';
      leaveType.value = 'کاری';

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

      Get.snackbar('خطا', 'بارگذاری جزئیات با مشکل مواجه شد');
      calculateStats();
    }
  }

  void clearFields() {
    arrivalTimeController.text = '';
    leaveTimeController.text = '';
    personalTimeController.text = '00:00';
    descriptionController.text = '';
    goCostController.text = '';
    returnCostController.text = '';
    leaveType.value = 'کاری';

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
    taskProjectErrors.add(RxBool(false)); // Add error state for new task row
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
      taskProjectErrors.removeAt(index); // Remove task error state
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

    // Reset error states
    for (var error in carCostProjectErrors) {
      error.value = false;
    }
    for (var error in taskProjectErrors) {
      error.value = false;
    }

    // Validate task projects
    bool hasTaskError = false;
    for (int i = 0; i < selectedProjects.length; i++) {
      final duration = _hhmmToMinutes(durationControllers[i].text) ?? 0;
      if (duration > 0 && selectedProjects[i].value == null) {
        taskProjectErrors[i].value = true;
        hasTaskError = true;
      }
    }

    // Validate car cost projects
    bool hasCarCostError = false;
    for (int i = 0; i < selectedCarCostProjects.length; i++) {
      final kilometers = int.tryParse(
        carKmControllers[i].text.replaceAll(',', ''),
      ) ??
          0;
      if (kilometers > 0 && selectedCarCostProjects[i].value == null) {
        carCostProjectErrors[i].value = true;
        hasCarCostError = true;
      }
    }

    if (hasTaskError || hasCarCostError) {
      Get.snackbar('خطا', 'لطفاً برای تمام وظایف و هزینه‌های خودرو پروژه انتخاب کنید');
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
        final kilometers = int.tryParse(
          carKmControllers[i].text.replaceAll(',', ''),
        ) ??
            0;
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
      leaveType: leaveType.value,
      personalTime: _hhmmToMinutes(personalTimeController.text),
      description: descriptionController.text,
      goCost: cappedGoCost,
      returnCost: cappedReturnCost,
      tasks: tasks,
      personalCarCosts: personalCarCosts,
    );

    try {
      await HomeApi().saveDailyDetail(detail);
      Get.back();
      Get.snackbar('موفقیت', 'جزئیات ذخیره شد');
      // به‌روزرسانی داده‌های ماهانه
      Get.find<HomeController>().fetchMonthlyDetails();
    } catch (e) {
      Get.snackbar('خطا', 'ذخیره جزئیات با مشکل مواجه شد');
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
    final totalTaskMinutes = durationControllers.fold<int>(
      0,
          (
          sum,
          controller,
          ) {
        final minutes = _hhmmToMinutes(controller.text);
        return sum + (minutes ?? 0);
      },
    );

    final goCost = int.tryParse(goCostController.text.replaceAll(',', '')) ?? 0;
    final returnCost =
        int.tryParse(returnCostController.text.replaceAll(',', '')) ?? 0;
    final cappedGoCost = goCost > 40000 ? 40000 : goCost;
    final cappedReturnCost = returnCost > 40000 ? 40000 : returnCost;

    // اطمینان از همگام‌سازی لیست‌ها
    if (carKmControllers.isEmpty ||
        carCostControllers.isEmpty ||
        selectedCarCostProjects.isEmpty) {
      return; // اگر لیست‌ها خالی باشند، از ادامه محاسبات جلوگیری کن
    }

    // همگام‌سازی لیست‌ها
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
      taskProjectErrors.add(RxBool(false)); // Sync task errors
    }

    final totalCarCosts = carKmControllers.asMap().entries.fold<int>(
      0,
          (
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
      },
    );

    for (
    int i = 0;
    i < carKmControllers.length && i < carCostControllers.length;
    i++
    ) {
      final kilometers =
          int.tryParse(carKmControllers[i].text.replaceAll(',', '')) ?? 0;
      final cost = kilometers > 0 ? calculateCarCost(kilometers) : 0;
      carCostControllers[i].text =
          ThousandSeparatorInputFormatter()._formatNumber(cost);
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
      'کار مفید: ${effective ~/ 60} ساعت و ${effective % 60} دقیقه';
      presenceDuration.value =
      'مدت حضور: ${presence.inHours} ساعت و ${presence.inMinutes % 60} دقیقه';
      effectiveWork.value =
      'کار مفید: ${effective ~/ 60} ساعت و ${effective % 60} دقیقه';
      taskTotalTime.value =
      'مجموع زمان وظایف: ${totalTaskMinutes ~/ 60} ساعت و ${totalTaskMinutes % 60} دقیقه';
      totalCost.value =
      'مجموع هزینه: ${ThousandSeparatorInputFormatter()._formatNumber(totalCosts)}';
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