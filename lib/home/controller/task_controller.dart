import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:shamsi_date/shamsi_date.dart';
import 'package:timesheet/home/api/home_api.dart';
import '../model/daily_detail_model.dart';
import '../model/project_model.dart';
import '../model/task_model.dart';
import 'home_controller.dart';

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
  final personalCarCostController = TextEditingController();

  final RxList<Rx<Project?>> selectedProjects = <Rx<Project?>>[].obs;
  final RxList<TextEditingController> durationControllers = <TextEditingController>[].obs;
  final RxList<TextEditingController> descriptionControllers = <TextEditingController>[].obs;

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

  Future<void> loadDailyDetail(Jalali date) async {
    currentDate = date;
    try {
      final detail = await HomeApi().getDailyDetail(date.toDateTime().toIso8601String().split('T')[0], 1); // فرض userId=1
      currentDetail.value = detail;

      // Clear previous data
      selectedProjects.clear();
      durationControllers.clear();
      descriptionControllers.clear();

      // Populate fields
      arrivalTimeController.text = detail?.arrivalTime ?? '';
      leaveTimeController.text = detail?.leaveTime ?? '';
      personalTimeController.text = detail?.personalTime?.toString() ?? '';
      descriptionController.text = detail?.description ?? '';
      goCostController.text = detail?.goCost?.toString() ?? '';
      returnCostController.text = detail?.returnCost?.toString() ?? '';
      personalCarCostController.text = detail?.personalCarCost?.toString() ?? '';
      leaveType.value = detail?.leaveType ?? 'کاری';

      // Populate tasks
      for (final task in detail?.tasks ?? []) {
        final project = projects.firstWhereOrNull((p) => p.id == task.projectId);
        selectedProjects.add(Rx<Project?>(project));
        durationControllers.add(TextEditingController(text: task.duration?.toString() ?? ''));
        descriptionControllers.add(TextEditingController(text: task.description ?? ''));
      }

      if (selectedProjects.isEmpty) {
        addTaskRow();
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
    personalCarCostController.clear();
    leaveType.value = 'کاری';
    selectedProjects.clear();
    durationControllers.clear();
    descriptionControllers.clear();
    addTaskRow();
  }

  void addTaskRow() {
    selectedProjects.add(Rx<Project?>(null));
    durationControllers.add(TextEditingController());
    descriptionControllers.add(TextEditingController());
  }

  Future<void> saveDailyDetail() async {
    if (currentDate == null) return;

    final tasks = <Task>[];
    for (int i = 0; i < selectedProjects.length; i++) {
      if (selectedProjects[i].value != null) {
        tasks.add(Task(
          projectId: selectedProjects[i].value!.id,
          duration: int.tryParse(durationControllers[i].text),
          description: descriptionControllers[i].text,
        ));
      }
    }

    final detail = DailyDetail(
      date: currentDate!.toDateTime().toIso8601String().split('T')[0],
      userId: 1, // فرض userId=1
      arrivalTime: arrivalTimeController.text,
      leaveTime: leaveTimeController.text,
      leaveType: leaveType.value,
      personalTime: int.tryParse(personalTimeController.text),
      description: descriptionController.text,
      goCost: int.tryParse(goCostController.text),
      returnCost: int.tryParse(returnCostController.text),
      personalCarCost: int.tryParse(personalCarCostController.text),
      tasks: tasks,
    );

    try {
      await HomeApi().saveDailyDetail(detail);
      Get.snackbar('success'.tr, 'details_saved'.tr);
      Get.find<HomeController>().fetchMonthlyDetails();
    } catch (e) {
      Get.snackbar('error'.tr, 'failed_to_save_details'.tr);
    }
  }

  Duration? parseTime(String time) {
    try {
      final parts = time.split(':');
      if (parts.length == 2) {
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
      return sum + (int.tryParse(controller.text) ?? 0);
    });
    final totalCost = (int.tryParse(goCostController.text) ?? 0) +
        (int.tryParse(returnCostController.text) ?? 0) +
        (int.tryParse(personalCarCostController.text) ?? 0);

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
            Text('${'total_cost'.tr}: $totalCost'),
          ],
        ),
        confirm: ElevatedButton(onPressed: Get.back, child: Text('ok'.tr)),
      );
    } else {
      Get.snackbar('error'.tr, 'error_arrival_leave'.tr);
    }
  }
}