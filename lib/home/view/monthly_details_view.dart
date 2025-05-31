import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:shamsi_date/shamsi_date.dart';
import 'package:excel/excel.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:file_saver/file_saver.dart';
import 'package:timesheet/home/controller/home_controller.dart';

class MonthlyDetailsView extends StatelessWidget {
  MonthlyDetailsView({super.key});

  final HomeController controller = Get.find<HomeController>();

  // تابع برای بررسی و درخواست مجوز ذخیره‌سازی (فقط برای موبایل)
  Future<bool> _requestStoragePermission() async {
    if (kIsWeb) {
      return true; // در وب نیازی به مجوز نیست
    }
    var status = await Permission.storage.status;
    if (!status.isGranted) {
      status = await Permission.storage.request();
    }
    return status.isGranted;
  }

  // تابع برای ایجاد و ذخیره/دانلود فایل اکسل
  Future<void> _exportToExcel() async {
    // بررسی مجوز ذخیره‌سازی (فقط برای موبایل)
    if (!kIsWeb) {
      bool hasPermission = await _requestStoragePermission();
      if (!hasPermission) {
        Get.snackbar('خطا', 'مجوز ذخیره‌سازی داده نشده است'.tr);
        return;
      }
    }

    // ایجاد فایل اکسل
    var excel = Excel.createExcel();
    Sheet sheet = excel['Sheet1'];

    // اضافه کردن هدرها
    sheet.appendRow([
      TextCellValue('تاریخ'.tr),
      TextCellValue('نوع مرخصی'.tr),
      TextCellValue('زمان ورود'.tr),
      TextCellValue('زمان خروج'.tr),
      TextCellValue('زمان شخصی'.tr),
      TextCellValue('هزینه رفت'.tr),
      TextCellValue('هزینه بازگشت'.tr),
      TextCellValue('هزینه‌های ماشین شخصی'.tr),
      TextCellValue('توضیحات'.tr),
      TextCellValue('وظایف'.tr),
    ]);

    // پر کردن داده‌ها
    for (var detail in controller.dailyDetails) {
      final date = Jalali.fromDateTime(DateTime.parse(detail.date));
      final tasks = detail.tasks.map((task) {
        final project = controller.dailyDetails
            .firstWhere((d) => d.tasks.any((t) => t.projectId == task.projectId),
            orElse: () => detail)
            .tasks
            .firstWhere((t) => t.projectId == task.projectId,
            orElse: () => task);
        return '${project.description ?? 'no_description'.tr} (${task.duration ?? 0} ${'minute'.tr})';
      }).join(', ');

      final personalCarCosts = detail.personalCarCosts.map((cost) {
        return '${cost.kilometers ?? 0} km: ${cost.cost ?? 0}';
      }).join(', ');

      sheet.appendRow([
        TextCellValue('${date.formatter.wN} ${date.day} ${date.formatter.mN}'),
        TextCellValue(detail.leaveType ?? 'no_leave_type'.tr),
        TextCellValue(detail.arrivalTime ?? ''),
        TextCellValue(detail.leaveTime ?? ''),
        TextCellValue(detail.personalTime != null ? '${detail.personalTime} ${'minute'.tr}' : ''),
        TextCellValue(detail.goCost?.toString() ?? ''),
        TextCellValue(detail.returnCost?.toString() ?? ''),
        TextCellValue(personalCarCosts),
        TextCellValue(detail.description ?? ''),
        TextCellValue(tasks),
      ]);
    }

    // نام فایل
    final year = controller.currentYear.value;
    final month = controller.currentMonth.value;
    final monthName = Jalali(year, month).formatter.mN;
    final fileName = 'Monthly_Details_${monthName}_${year}.xlsx';

    // ذخیره یا دانلود فایل
    try {
      final excelData = Uint8List.fromList(excel.encode()!); // تبدیل به Uint8List
      if (kIsWeb) {
        // دانلود فایل در وب
        await FileSaver.instance.saveFile(
          name: fileName,
          bytes: excelData,
          mimeType: MimeType.microsoftExcel,
        );
        Get.snackbar('موفقیت', 'فایل اکسل دانلود شد'.tr);
      } else {
        // ذخیره فایل در موبایل
        final directory = await getTemporaryDirectory(); // استفاده از دایرکتوری موقت
        final filePath = '${directory.path}/$fileName';
        final file = File(filePath);
        await file.writeAsBytes(excelData);
        Get.snackbar('موفقیت', 'فایل اکسل در $filePath ذخیره شد'.tr);
      }
    } catch (e) {
      Get.snackbar('خطا', 'خطا در ذخیره/دانلود فایل اکسل: $e'.tr);
    }
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: Obx(() {
          final year = controller.currentYear.value;
          final month = controller.currentMonth.value;
          final monthName = Jalali(year, month).formatter.mN;
          return Text('${'monthly_details'.tr}: $monthName $year');
        }),
        actions: [
          IconButton(
            icon: Icon(Icons.download, color: colorScheme.onPrimary),
            tooltip: 'خروجی اکسل'.tr,
            onPressed: _exportToExcel,
          ),
        ],
      ),
      body: Obx(() {
        if (controller.dailyDetails.isEmpty) {
          return Center(child: Text('no_details'.tr));
        }
        return ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: controller.dailyDetails.length,
          itemBuilder: (context, index) {
            final detail = controller.dailyDetails[index];
            final date = Jalali.fromDateTime(DateTime.parse(detail.date));
            return Card(
              child: ExpansionTile(
                title: Text(
                  '${date.formatter.wN} ${date.day} ${date.formatter.mN}',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: colorScheme.primary,
                  ),
                ),
                subtitle: Text(
                  detail.leaveType ?? 'no_leave_type'.tr,
                  style: TextStyle(color: colorScheme.onSurface.withOpacity(0.7)),
                ),
                children: [
                  Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        if (detail.arrivalTime != null)
                          Text('${'arrival_time'.tr}: ${detail.arrivalTime}'),
                        if (detail.leaveTime != null)
                          Text('${'leave_time'.tr}: ${detail.leaveTime}'),
                        if (detail.personalTime != null)
                          Text('${'personal_time'.tr}: ${detail.personalTime} ${'minute'.tr}'),
                        if (detail.goCost != null)
                          Text('${'go_cost'.tr}: ${detail.goCost}'),
                        if (detail.returnCost != null)
                          Text('${'return_cost'.tr}: ${detail.returnCost}'),
                        if (detail.personalCarCosts.isNotEmpty)
                          Text('${'personal_car_cost'.tr}: ${detail.personalCarCosts}'),
                        if (detail.description != null)
                          Text('${'description'.tr}: ${detail.description}'),
                        const SizedBox(height: 16),
                        Text(
                          'tasks'.tr,
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: colorScheme.primary,
                          ),
                        ),
                        ...detail.tasks.map((task) {
                          final project = controller.dailyDetails
                              .firstWhere((d) => d.tasks.any((t) => t.projectId == task.projectId),
                              orElse: () => detail)
                              .tasks
                              .firstWhere((t) => t.projectId == task.projectId,
                              orElse: () => task);
                          return Padding(
                            padding: const EdgeInsets.symmetric(vertical: 4),
                            child: Text(
                              '- ${project.description ?? 'no_description'.tr} (${task.duration ?? 0} ${'minute'.tr})',
                            ),
                          );
                        }),
                      ],
                    ),
                  ),
                ],
              ),
            );
          },
        );
      }),
    );
  }
}