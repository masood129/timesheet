import 'package:get/get.dart';
import 'package:persian_datetime_picker/persian_datetime_picker.dart';
import 'package:shamsi_date/shamsi_date.dart';
import 'package:timesheet/core/api/api_calls.dart';
import 'dart:convert';
import '../../home/controller/auth_controller.dart';
import '../model/report_model.dart';

class ManagerController extends GetxController {
  final AuthController authController = Get.find<AuthController>();
  final HomeApi homeApi = HomeApi();
  var reports = <Report>[].obs;
  var selectedYear = Jalali.now().year.obs;
  var selectedMonth = Jalali.now().month.obs;

  Future<void> fetchReports() async {
    try {
      Jalali jalaliStart = Jalali(selectedYear.value, selectedMonth.value, 1);
      Jalali jalaliEnd = Jalali(selectedYear.value, selectedMonth.value, jalaliStart.monthLength);
      Gregorian gregorianStart = jalaliStart.toGregorian();
      Gregorian gregorianEnd = jalaliEnd.toGregorian();

      final response = await homeApi.fetchMonthlyReportsForGroup(
        gregorianStart.year,
        gregorianStart.month,
        gregorianEnd.year,
        gregorianEnd.month,
      );

      if (response.statusCode == 200) {
        final List<dynamic> jsonData = jsonDecode(response.body);
        reports.value = jsonData.map((json) => Report.fromJson(json)).toList();
      } else {
        Get.snackbar('خطا', 'خطا در دریافت گزارش‌ها: ${response.body}'.tr);
      }
    } catch (e) {
      Get.snackbar('خطا', 'خطای سرور: $e'.tr);
    }
  }

  Future<void> approveGroupManager(int reportId, String comment, bool toGeneralManager) async {
    try {
      final response = await homeApi.approveReportAsGroupManager(
        reportId,
        comment,
        toGeneralManager,
      );
      if (response.statusCode == 200) {
        Get.snackbar('موفقیت', 'گزارش تأیید شد'.tr);
        await fetchReports();
      } else {
        Get.snackbar('خطا', 'خطا در تأیید گزارش: ${response.body}'.tr);
      }
    } catch (e) {
      Get.snackbar('خطا', 'خطای سرور: $e'.tr);
    }
  }

  Future<void> approveGeneralManager(int reportId, String comment) async {
    try {
      final response = await homeApi.approveReportAsGeneralManager(
        reportId,
        comment,
      );
      if (response.statusCode == 200) {
        Get.snackbar('موفقیت', 'گزارش تأیید شد'.tr);
        await fetchReports();
      } else {
        Get.snackbar('خطا', 'خطا در تأیید گزارش: ${response.body}'.tr);
      }
    } catch (e) {
      Get.snackbar('خطا', 'خطای سرور: $e'.tr);
    }
  }

  Future<void> approveFinance(int reportId, String comment) async {
    try {
      final response = await homeApi.approveReportAsFinance(
        reportId,
        comment,
      );
      if (response.statusCode == 200) {
        Get.snackbar('موفقیت', 'گزارش نهایی تأیید شد'.tr);
        await fetchReports();
      } else {
        Get.snackbar('خطا', 'خطا در تأیید گزارش: ${response.body}'.tr);
      }
    } catch (e) {
      Get.snackbar('خطا', 'خطای سرور: $e'.tr);
    }
  }
}