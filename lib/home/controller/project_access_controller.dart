import 'package:get/get.dart';
import 'package:timesheet/core/api/api_calls/api_calls.dart';
import 'package:timesheet/model/project_access_model.dart';
import 'package:timesheet/home/controller/task_controller.dart';
import 'package:timesheet/home/controller/monthly_details_controller.dart';

class ProjectAccessController extends GetxController {
  final RxList<ProjectAccess> projects = <ProjectAccess>[].obs;
  final RxBool isLoading = false.obs;
  final RxString errorMessage = ''.obs;

  @override
  void onInit() {
    super.onInit();
    loadProjects();
  }

  Future<void> loadProjects() async {
    try {
      isLoading.value = true;
      errorMessage.value = '';

      final fetchedProjects = await ApiCalls().getUserProjectAccess();
      projects.value = fetchedProjects;
    } catch (e) {
      errorMessage.value = 'خطا در دریافت لیست پروژه‌ها: ${e.toString()}';
      Get.snackbar(
        'خطا',
        errorMessage.value,
        snackPosition: SnackPosition.BOTTOM,
      );
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> toggleProjectAccess(int projectId) async {
    try {
      // Find the project in the list
      final projectIndex = projects.indexWhere((p) => p.id == projectId);
      if (projectIndex == -1) return;

      // Optimistically update UI
      final oldProject = projects[projectIndex];
      projects[projectIndex] = oldProject.copyWith(
        hasAccess: !oldProject.hasAccess,
      );

      // Make API call
      final result = await ApiCalls().toggleProjectAccess(projectId);

      // Update with server response
      projects[projectIndex] = oldProject.copyWith(
        hasAccess: result['hasAccess'],
      );

      // Refresh TaskController projects list if it exists
      try {
        if (Get.isRegistered<TaskController>()) {
          final taskController = Get.find<TaskController>();
          await taskController.fetchProjects();
        }
      } catch (e) {
        // TaskController might not be initialized, ignore the error
        if (Get.isLogEnable) {
          print('TaskController not available: $e');
        }
      }

      // Refresh MonthlyDetailsController projects list if it exists
      try {
        if (Get.isRegistered<MonthlyDetailsController>()) {
          final monthlyController = Get.find<MonthlyDetailsController>();
          await monthlyController.fetchProjects();
        }
      } catch (e) {
        // MonthlyDetailsController might not be initialized, ignore the error
        if (Get.isLogEnable) {
          print('MonthlyDetailsController not available: $e');
        }
      }

      // Show success message
      Get.snackbar(
        'موفق',
        result['message'] ?? 'تغییرات با موفقیت ذخیره شد',
        snackPosition: SnackPosition.BOTTOM,
      );
    } catch (e) {
      // Revert on error
      await loadProjects();

      Get.snackbar(
        'خطا',
        'خطا در تغییر دسترسی پروژه: ${e.toString()}',
        snackPosition: SnackPosition.BOTTOM,
      );
    }
  }

  Future<void> refresh() async {
    await loadProjects();
  }
}
