import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:shamsi_date/shamsi_date.dart';

import '../../controller/home_controller.dart';
import '../../model/monthly_report_model.dart';

void showDraftReportsDialog(
  BuildContext context,
  HomeController homeController,
) {
  final currentYear = Jalali.now().year;

  // ماه‌های شمسی تا ماه جاری
  final monthNames = [
    'فروردین',
    'اردیبهشت',
    'خرداد',
    'تیر',
    'مرداد',
    'شهریور',
    'مهر',
    'آبان',
    'آذر',
    'دی',
    'بهمن',
    'اسفند',
  ];

  // متغیر انتخاب‌شده برای ماه (پیشفرض: null)
  var selectedMonth = Rx<int?>(null);
  var selectedReportId = Rx<int?>(null);
  var selectedDraftDetails = Rx<MonthlyReport?>(
    null,
  ); // حالا از مدل استفاده می‌کنه

  // لیست ماه‌های موجود در drafts
  var availableMonths = <int>[].obs;

  // گرفتن drafts و استخراج ماه‌ها
  homeController.fetchMyDrafts().then((drafts) {
    availableMonths.assignAll(
      drafts
          .map((draft) => draft.jalaliMonth ?? 0)
          .where((month) => month != 0)
          .toSet()
          .toList(),
    );
    availableMonths.sort(); // مرتب‌سازی ماه‌ها
    if (availableMonths.isNotEmpty) {
      selectedMonth.value = availableMonths.first;
      final draft = drafts.firstWhereOrNull(
        (draft) => draft.jalaliMonth == selectedMonth.value,
      );
      if (draft != null) {
        selectedReportId.value = draft.reportId;
        selectedDraftDetails.value = draft; // جزئیات draft انتخاب‌شده
      }
    }
  });

  Get.dialog(
    AlertDialog(
      title: Text(
        'مدیریت پیش‌نویس گزارش ماهانه'.tr,
        textAlign: TextAlign.center,
      ),
      content: Obx(() {
        if (availableMonths.isEmpty) {
          return const Text('هیچ پیش‌نویسی یافت نشد.');
        }
        return SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // نمایش سال ثابت (غیرقابل تغییر، شمسی)
              Card(
                elevation: 2,
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'سال'.tr,
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                      Text(
                        currentYear.toString(),
                        style: const TextStyle(fontSize: 16),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),
              // انتخاب ماه فقط از ماه‌های موجود در drafts
              DropdownButtonFormField<int>(
                value: selectedMonth.value,
                decoration: InputDecoration(
                  labelText: 'ماه'.tr,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                items:
                    availableMonths.map((month) {
                      return DropdownMenuItem(
                        value: month,
                        child: Text(monthNames[month - 1]),
                      );
                    }).toList(),
                onChanged: (newMonth) {
                  if (newMonth != null) {
                    selectedMonth.value = newMonth;
                    // پیدا کردن reportId و جزئیات مربوطه
                    final drafts = homeController.drafts;
                    final draft = drafts.firstWhereOrNull(
                      (draft) => draft.jalaliMonth == newMonth,
                    );
                    if (draft != null) {
                      selectedReportId.value = draft.reportId;
                      selectedDraftDetails.value = draft;
                    }
                  }
                },
              ),
              const SizedBox(height: 16),
              // نمایش جزئیات draft انتخاب‌شده
              if (selectedDraftDetails.value != null)
                Card(
                  elevation: 2,
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'جزئیات پیش‌نویس:',
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'سال: ${selectedDraftDetails.value!.jalaliYear ?? 'نامشخص'}',
                        ),
                        Text(
                          'ماه: ${monthNames[(selectedDraftDetails.value!.jalaliMonth ?? 1) - 1]}',
                        ),
                        Text(
                          'جمع ساعت کاری: ${selectedDraftDetails.value!.totalHours ?? 'نامشخص'}',
                        ),
                        // ساعت صرف شده برای هر پروژه: این فیلد در مدل MonthlyReport نیست - اگر نیاز داری، به مدل اضافه کن
                        Text(
                          'ساعت صرف شده برای هر پروژه: ${selectedDraftDetails.value!.totalHours ?? 'نامشخص (نیاز به محاسبه از جزئیات روزانه)'}',
                        ),
                        // placeholder: از totalHours استفاده کردم، اما فیلد اختصاصی اضافه کن
                        Text(
                          'هزینه باشگاه: ${selectedDraftDetails.value!.gymCost ?? 'نامشخص'}',
                        ),
                        // هزینه رفت و آمد: این فیلد در مدل نیست - اضافه کن اگر لازم باشه
                        Text(
                          'هزینه رفت و آمد به شرکت: نامشخص (نیاز به فیلد در مدل یا API جدا)',
                        ),
                        // هزینه ماشین شخصی به تفکیک پروژه: این فیلد در مدل نیست - اضافه کن
                        Text(
                          'هزینه ماشین شخصی به تفکیک هر پروژه: نامشخص (نیاز به محاسبه و فیلد در مدل)',
                        ),
                        Text(
                          'گروه مربوطه: ${selectedDraftDetails.value!.groupId ?? 'نامشخص'}',
                        ),
                        // سرگروه: این فیلد در مدل نیست - شاید نیاز به API جدا برای گرفتن نام مدیر
                        Text('سرگروه مربوطه: نامشخص (نیاز به استعلام از API)'),
                      ],
                    ),
                  ),
                ),
            ],
          ),
        );
      }),
      actionsAlignment: MainAxisAlignment.spaceEvenly,
      actions: [
        TextButton(
          onPressed: () => Get.back(),
          child: Text('لغو'.tr, style: const TextStyle(color: Colors.red)),
        ),
        Obx(
          () => ElevatedButton(
            onPressed:
                availableMonths.isEmpty || selectedReportId.value == null
                    ? null
                    : () async {
                      Get.back(); // بستن دیالوگ
                      await homeController.submitDraftToManager(
                        selectedReportId.value!,
                      );
                      Get.snackbar(
                        'موفقیت',
                        'پیش‌نویس با موفقیت به مدیر گروه ارسال شد.',
                      );
                    },
            child: Text('ارسال به مدیر گروه'.tr),
          ),
        ),
        Obx(
          () => ElevatedButton(
            onPressed:
                availableMonths.isEmpty || selectedReportId.value == null
                    ? null
                    : () async {
                      Get.back(); // بستن دیالوگ
                      await homeController.exitDraft(selectedReportId.value!);
                      Get.snackbar('موفقیت', 'پیش‌نویس با موفقیت حذف شد.');
                    },
            child: Text('حذف پیش‌نویس'.tr),
          ),
        ),
      ],
    ),
  );
}
