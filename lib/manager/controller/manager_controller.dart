// manager_controller.dart
import 'package:get/get.dart';
import 'package:persian_datetime_picker/persian_datetime_picker.dart';
import 'package:shamsi_date/shamsi_date.dart';
import 'package:timesheet/core/api/api_calls/api_calls.dart';

import '../../home/controller/auth_controller.dart';
import '../../../model/draft_report_model.dart'; // Use DraftReportModel
import '../../../core/theme/snackbar_helper.dart';

class ManagerController extends GetxController {
  final AuthController authController = Get.find<AuthController>();
  final ApiCalls homeApi = ApiCalls();
  var reports = <DraftReportModel>[].obs;
  var selectedYear = Jalali.now().year.obs;
  var selectedMonth = Jalali.now().month.obs;

  Future<void> fetchReports() async {
    try {
      Jalali jalaliStart = Jalali(selectedYear.value, selectedMonth.value, 1);
      Jalali jalaliEnd = Jalali(
        selectedYear.value,
        selectedMonth.value,
        jalaliStart.monthLength,
      );
      Gregorian gregorianStart = jalaliStart.toGregorian();
      Gregorian gregorianEnd = jalaliEnd.toGregorian();

      final response = await homeApi.fetchMonthlyReportsForGroup(
        gregorianStart.year,
        gregorianStart.month,
        gregorianEnd.year,
        gregorianEnd.month,
      );

      if (response.isNotEmpty) {
        reports.value = response;
      } else {
        ThemedSnackbar.showError('error'.tr, '${'fetch_reports_error'.tr}: ');
      }
    } catch (e) {
      ThemedSnackbar.showError('error'.tr, '${'server_error'.tr}: $e');
    }
  }

  Future<void> approveGroupManager(
    int reportId,
    String comment,
    bool toGeneralManager,
  ) async {
    try {
      final response = await homeApi.approveReportAsGroupManager(
        reportId,
        comment,
        toGeneralManager,
      );
      if (response.isNotEmpty) {
        ThemedSnackbar.showSuccess('success'.tr, 'report_approved'.tr);
        await fetchReports();
      } else {
        ThemedSnackbar.showError('error'.tr, '${'approve_report_error'.tr}: ');
      }
    } catch (e) {
      ThemedSnackbar.showError('error'.tr, '${'server_error'.tr}: $e');
    }
  }

  Future<void> approveGeneralManager(int reportId, String comment) async {
    try {
      final response = await homeApi.approveReportAsGeneralManager(
        reportId,
        comment,
      );
      if (response.isNotEmpty) {
        ThemedSnackbar.showSuccess('success'.tr, 'report_approved'.tr);
        await fetchReports();
      } else {
        ThemedSnackbar.showError('error'.tr, '${'approve_report_error'.tr}: ');
      }
    } catch (e) {
      ThemedSnackbar.showError('error'.tr, '${'server_error'.tr}: $e');
    }
  }

  Future<void> approveFinance(int reportId, String comment) async {
    try {
      final response = await homeApi.approveReportAsFinance(reportId, comment);
      if (response.isNotEmpty) {
        ThemedSnackbar.showSuccess('success'.tr, 'final_report_approved'.tr);
        await fetchReports();
      } else {
        ThemedSnackbar.showError('error'.tr, '${'approve_report_error'.tr}: ');
      }
    } catch (e) {
      ThemedSnackbar.showError('error'.tr, '${'server_error'.tr}: $e');
    }
  }
}
