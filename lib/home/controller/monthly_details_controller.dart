import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/foundation.dart' show kDebugMode, kIsWeb;
import 'package:get/Get.dart';
import 'package:shamsi_date/shamsi_date.dart';
import 'package:excel/excel.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:file_saver/file_saver.dart';
import 'package:timesheet/home/controller/home_controller.dart';
import 'package:timesheet/core/api/api_calls/api_calls.dart';
import 'package:timesheet/model/leavetype_model.dart';
import '../../model/project_model.dart';
import '../../core/theme/snackbar_helper.dart';

class MonthlyDetailsController extends GetxController {
  final HomeController homeController = Get.find<HomeController>();
  final RxList<Project> projects = <Project>[].obs;
  final RxBool isLoading = true.obs;

  @override
  void onInit() {
    super.onInit();
    fetchProjects();
  }

  Future<void> fetchProjects() async {
    try {
      isLoading.value = true;
      final fetchedProjects = await ApiCalls().getProjects();
      projects.assignAll(fetchedProjects);
    } catch (e) {
      if (kDebugMode) {
        print('Error fetching projects: $e');
      }
      final errorMessage = e.toString().replaceFirst('Exception: ', '');
      ThemedSnackbar.showError('error'.tr, errorMessage.isNotEmpty ? errorMessage : 'fetch_projects_issue_snackbar'.tr);
    } finally {
      isLoading.value = false;
    }
  }

  Future<bool> _requestStoragePermission() async {
    if (kIsWeb) {
      return true;
    }
    var status = await Permission.storage.status;
    if (!status.isGranted) {
      status = await Permission.storage.request();
    }
    return status.isGranted;
  }

  String formatDuration(int? minutes) {
    if (minutes == null || minutes == 0) return '';
    final hours = minutes ~/ 60;
    final remainingMinutes = minutes % 60;
    return '${hours.toString().padLeft(2, '0')}:${remainingMinutes.toString().padLeft(2, '0')}';
  }

  Future<void> exportToExcel() async {
    if (!kIsWeb) {
      bool hasPermission = await _requestStoragePermission();
      if (!hasPermission) {
        ThemedSnackbar.showError('error'.tr, 'مجوز ذخیره‌سازی داده نشده است'.tr);
        return;
      }
    }

    var excel = Excel.createExcel();
    Sheet sheet = excel['Sheet1'];

    final projectList = projects.isEmpty ? ['no_project'.tr] : projects.map((p) => p.projectName).toList();

    final headers = [
      TextCellValue('تاریخ'.tr),
      TextCellValue('نوع مرخصی'.tr),
      TextCellValue('زمان ورود'.tr),
      TextCellValue('زمان خروج'.tr),
      TextCellValue('زمان شخصی'.tr),
      ...projectList.map((project) => TextCellValue(project)),
    ];
    sheet.appendRow(headers);

    final daysInMonth = homeController.daysInMonth;
    for (int day = 1; day <= daysInMonth; day++) {
      final date = Jalali(homeController.currentYear.value, homeController.currentMonth.value, day);
      final gregorianDate = date.toGregorian();
      final formattedDate =
          '${gregorianDate.year}-${gregorianDate.month.toString().padLeft(2, '0')}-${gregorianDate.day.toString().padLeft(2, '0')}';
      final detail = homeController.dailyDetails.firstWhereOrNull(
            (d) => d.date == formattedDate,
      );

      final projectDurations = List<String>.filled(projectList.length, '');

      if (detail != null) {
        for (var task in detail.tasks) {
          final projectIndex = projects.indexWhere((p) => p.id == task.projectId);
          if (projectIndex != -1) {
            projectDurations[projectIndex] = formatDuration(task.duration);
          }
        }
      }

      sheet.appendRow([
        TextCellValue('${date.formatter.wN} ${date.day} ${date.formatter.mN}'),
        TextCellValue(detail?.leaveType?.displayName ?? ''),
        TextCellValue(detail?.arrivalTime ?? ''),
        TextCellValue(detail?.leaveTime ?? ''),
        TextCellValue(detail?.personalTime != null ? formatDuration(detail!.personalTime) : ''),
        ...projectDurations.map((duration) => TextCellValue(duration)),
      ]);
    }

    final year = homeController.currentYear.value;
    final month = homeController.currentMonth.value;
    final monthName = Jalali(year, month).formatter.mN;
    final fileName = 'Monthly_Details_${monthName}_$year.xlsx';

    try {
      final excelData = Uint8List.fromList(excel.encode()!);
      if (kIsWeb) {
        await FileSaver.instance.saveFile(
          name: fileName,
          bytes: excelData,
          mimeType: MimeType.microsoftExcel,
        );
        ThemedSnackbar.showSuccess('success'.tr, 'details_saved_snackbar'.tr);
      } else {
        final directory = await getTemporaryDirectory();
        final filePath = '${directory.path}/$fileName';
        final file = File(filePath);
        await file.writeAsBytes(excelData);
        ThemedSnackbar.showSuccess('success'.tr, 'details_saved_snackbar'.tr);
      }
    } catch (e) {
      ThemedSnackbar.showError('error'.tr, '${'save_details_issue_snackbar'.tr}: $e');
    }
  }
}