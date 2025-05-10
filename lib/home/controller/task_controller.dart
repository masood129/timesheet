import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:shamsi_date/shamsi_date.dart';
import 'package:timesheet/home/api/home_api.dart';
import '../api/project_api.dart';
import '../model/project_model.dart';
import '../model/task_model.dart';

class TaskController extends GetxController {
  final TaskService taskService = TaskService();

  final RxList<Project> projects = <Project>[].obs;
  final Rx<Task?> currentTask = Rx<Task?>(null);
  final RxString leaveType = 'کاری'.obs;

  final arrivalTimeController = TextEditingController();
  final leaveTimeController = TextEditingController();
  final personalTimeController = TextEditingController();
  final descriptionController = TextEditingController();
  final goCostController = TextEditingController();
  final returnCostController = TextEditingController();
  final personalCarCostController = TextEditingController(); // کنترلر جدید

  final RxList<Rx<Project?>> selectedProjects = <Rx<Project?>>[].obs;
  final RxList<TextEditingController> durationControllers =
      <TextEditingController>[].obs;
  final RxList<TextEditingController> descriptionControllers =
      <TextEditingController>[].obs;

  @override
  void onInit() {
    super.onInit();
    fetchProjects();
    addTaskRow();
  }

  Future<void> fetchProjects() async {
    try {
      await HomeApi().getProjects().then((value) {
      projects.addAll(value) ;
      });
    } catch (e) {
      Get.snackbar('error'.tr, 'failed_to_fetch_projects'.tr);
    }
  }

  Future<void> fetchTask(Jalali date) async {
    try {
      currentTask.value = await taskService.fetchTask(date);
      if (currentTask.value != null) {
        leaveType.value = currentTask.value!.leaveType;
        arrivalTimeController.text = currentTask.value!.arrivalTime ?? '';
        leaveTimeController.text = currentTask.value!.leaveTime ?? '';
        personalTimeController.text =
            currentTask.value!.personalTime?.toString() ?? '';
        descriptionController.text = currentTask.value!.description ?? '';
        goCostController.text = currentTask.value!.goCost?.toString() ?? '';
        returnCostController.text =
            currentTask.value!.returnCost?.toString() ?? '';
        personalCarCostController.text =
            currentTask.value!.personalCarCost?.toString() ?? ''; // فیلد جدید
        selectedProjects.clear();
        durationControllers.clear();
        descriptionControllers.clear();
        for (var task in currentTask.value!.tasks) {
          selectedProjects.add(Rx<Project?>(task.project));
          durationControllers.add(
            TextEditingController(text: task.duration?.toString()),
          );
          descriptionControllers.add(
            TextEditingController(text: task.description),
          );
        }
      }
    } catch (e) {
      Get.snackbar('error'.tr, 'failed_to_fetch_task'.tr);
    }
  }

  void addTaskRow() {
    selectedProjects.add(Rx<Project?>(null));
    durationControllers.add(TextEditingController());
    descriptionControllers.add(TextEditingController());
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
    final totalCost =
        (int.tryParse(goCostController.text) ?? 0) +
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
            Text('${'total_cost'.tr}: $totalCost'), // نمایش مجموع هزینه‌ها
          ],
        ),
        confirm: ElevatedButton(onPressed: Get.back, child: Text('ok'.tr)),
      );
    } else {
      Get.snackbar('error'.tr, 'error_arrival_leave'.tr);
    }
  }

  Future<void> saveTask(Jalali date) async {
    try {
      final task = Task(
        date: date,
        arrivalTime:
            arrivalTimeController.text.isEmpty
                ? null
                : arrivalTimeController.text,
        leaveTime:
            leaveTimeController.text.isEmpty ? null : leaveTimeController.text,
        personalTime: int.tryParse(personalTimeController.text),
        leaveType: leaveType.value,
        tasks: List.generate(selectedProjects.length, (i) {
          return TaskDetail(
            project: selectedProjects[i].value,
            duration: int.tryParse(durationControllers[i].text),
            description:
                descriptionControllers[i].text.isEmpty
                    ? null
                    : descriptionControllers[i].text,
          );
        }),
        description:
            descriptionController.text.isEmpty
                ? null
                : descriptionController.text,
        goCost: int.tryParse(goCostController.text),
        returnCost: int.tryParse(returnCostController.text),
        personalCarCost: int.tryParse(
          personalCarCostController.text,
        ), // فیلد جدید
      );
      await taskService.saveTask(task);
      Get.back();
      Get.snackbar('success'.tr, 'وظیفه با موفقیت ذخیره شد'.tr);
    } catch (e) {
      Get.snackbar('error'.tr, 'failed_to_save_task'.tr);
    }
  }
}
