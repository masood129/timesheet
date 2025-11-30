import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:shamsi_date/shamsi_date.dart';

import '../../../model/draft_report_model.dart';
import '../../../templates/report_details_template.dart';
import '../../controller/home_controller.dart';
import '../../../core/theme/snackbar_helper.dart';
import '../../../core/widgets/searchable_dropdown.dart';

void showDraftReportsDialog(
  BuildContext context,
  HomeController homeController,
) {
  final currentYear = Jalali.now().year;

  // محاسبه maxHeight و maxWidth خارج از Obx برای جلوگیری از مشکلات timing در layout
  final double maxDialogHeight = MediaQuery.of(context).size.height * 0.6;
  final double maxDialogWidth =
      MediaQuery.of(context).size.width * 0.9; // اصلاح‌شده: عرض درصدی از صفحه

  // نام ماه‌های شمسی (فارسی) برای نمایش بهتر
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

  // متغیرهای reactive برای مدیریت انتخاب‌ها
  var selectedMonth = Rx<int?>(null);
  var selectedReportId = Rx<int?>(null);
  var selectedDraftDetails = Rx<DraftReportModel?>(null);

  // لیست ماه‌های موجود در drafts (observable برای reactivity)
  var availableMonths = <int>[].obs;

  // لیست تمام drafts (local برای دسترسی آسان و بدون وابستگی به controller)
  var allDrafts = <DraftReportModel>[];

  // بارگیری drafts و استخراج ماه‌های منحصربه‌فرد
  homeController.fetchMyDrafts().then((drafts) {
    allDrafts = drafts;
    // اصلاح‌شده: تنظیم homeController.drafts اگر لازم باشد، اما از allDrafts استفاده می‌کنیم
    if (homeController.drafts is RxList<DraftReportModel>) {
      (homeController.drafts as RxList<DraftReportModel>).assignAll(drafts);
    }

    availableMonths.assignAll(
      drafts
          .map((draft) => draft.jalaliMonth ?? 0)
          .where((month) => month != 0)
          .toSet()
          .toList(),
    );
    availableMonths.sort(); // مرتب‌سازی صعودی ماه‌ها
    if (availableMonths.isNotEmpty) {
      selectedMonth.value = availableMonths.first;
      final draft = allDrafts.firstWhereOrNull(
        (draft) => draft.jalaliMonth == selectedMonth.value,
      );
      if (draft != null) {
        selectedReportId.value = draft.reportId;
        selectedDraftDetails.value = draft; // تنظیم جزئیات draft انتخاب‌شده
      }
    }
  });

  // نمایش دیالوگ با GetX
  Get.dialog(
    AlertDialog(
      // اصلاح‌شده: insetPadding برای کنترل حاشیه و جلوگیری از عرض کامل صفحه
      insetPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 24),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      // گرد کردن گوشه‌ها برای زیبایی
      title: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.description, color: Colors.blue),
          const SizedBox(width: 8),
          Text('manage_monthly_report_draft'.tr, textAlign: TextAlign.center),
        ],
      ),
      content: Obx(() {
        if (availableMonths.isEmpty) {
          return Card(
            color: Colors.orange,
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Text(
                'no_drafts_found'.tr,
                style: const TextStyle(color: Colors.white),
                textAlign: TextAlign.center,
              ),
            ),
          );
        }
        // اصلاح‌شده: حذف LayoutBuilder و استفاده مستقیم از MediaQuery برای عرض
        return SizedBox(
          width: maxDialogWidth, // عرض ثابت بر اساس MediaQuery
          child: ConstrainedBox(
            constraints: BoxConstraints(maxHeight: maxDialogHeight),
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // کارت نمایش سال (ثابت و غیرقابل تغییر)
                  _buildYearCard(currentYear),
                  const SizedBox(height: 16),
                  // دراپ‌داون انتخاب ماه (فقط ماه‌های موجود)
                  _buildMonthDropdown(
                    selectedMonth,
                    availableMonths,
                    monthNames,
                    (newMonth) {
                      if (newMonth != null) {
                        selectedMonth.value = newMonth;
                        // به‌روزرسانی reportId و جزئیات بر اساس ماه انتخاب‌شده با استفاده از allDrafts
                        final draft = allDrafts.firstWhereOrNull(
                          (draft) => draft.jalaliMonth == newMonth,
                        );
                        if (draft != null) {
                          selectedReportId.value = draft.reportId;
                          selectedDraftDetails.value = draft;
                        } else {
                          // اگر draft پیدا نشد، ریست کن
                          selectedReportId.value = null;
                          selectedDraftDetails.value = null;
                        }
                      }
                    },
                  ),
                  const SizedBox(height: 16),
                  // کارت جزئیات draft انتخاب‌شده (با استفاده از template)
                  if (selectedDraftDetails.value != null)
                    ReportDetailsCard(report: selectedDraftDetails.value!),
                ],
              ),
            ),
          ),
        );
      }),
      actionsAlignment: MainAxisAlignment.spaceEvenly,
      actions: [
        // دکمه لغو (رنگی قرمز برای برجستگی)
        TextButton(
          onPressed: () => Get.back(),
          child: Text('cancel'.tr, style: const TextStyle(color: Colors.red)),
        ),
        // دکمه ارسال به مدیر (غیرفعال اگر انتخابی نباشد)
        Obx(
          () => ElevatedButton.icon(
            onPressed:
                availableMonths.isEmpty || selectedReportId.value == null
                    ? null
                    : () async {
                      Get.back(); // بستن دیالوگ
                      await homeController.submitDraftToManager(
                        selectedReportId.value!,
                      );
                      ThemedSnackbar.showSuccess(
                        'success'.tr,
                        'draft_submitted_success'.tr,
                      );
                    },
            icon: const Icon(Icons.send),
            label: Text('submit_to_group_manager'.tr),
            style: ElevatedButton.styleFrom(backgroundColor: Colors.blue),
          ),
        ),
        // دکمه حذف پیش‌نویس (غیرفعال اگر انتخابی نباشد)
        Obx(
          () => ElevatedButton.icon(
            onPressed:
                availableMonths.isEmpty || selectedReportId.value == null
                    ? null
                    : () async {
                      Get.back(); // بستن دیالوگ
                      await homeController.exitDraft(selectedReportId.value!);
                      ThemedSnackbar.showWarning(
                        'success'.tr,
                        'draft_deleted_success'.tr,
                      );
                    },
            icon: const Icon(Icons.delete),
            label: Text('delete_draft'.tr),
            style: ElevatedButton.styleFrom(backgroundColor: Colors.orange),
          ),
        ),
      ],
    ),
  );
}

/// کارت نمایش سال جاری (شمسی)
Widget _buildYearCard(int currentYear) {
  return Card(
    elevation: 4,
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
    child: Padding(
      padding: const EdgeInsets.all(16.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            'year'.tr,
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: Colors.blue.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              currentYear.toString(),
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
            ),
          ),
        ],
      ),
    ),
  );
}

/// دراپ‌داون انتخاب ماه با استایل زیبا
Widget _buildMonthDropdown(
  Rx<int?> selectedMonth,
  RxList<int> availableMonths,
  List<String> monthNames,
  Function(int?) onChanged,
) {
  return Card(
    elevation: 2,
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
    child: Padding(
      padding: const EdgeInsets.all(12.0),
      child: SearchableDropdown<int>(
        value: selectedMonth.value,
        decoration: InputDecoration(
          labelText: 'select_month'.tr,
          labelStyle: const TextStyle(fontWeight: FontWeight.w500),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
            borderSide: BorderSide(color: Colors.grey.shade300),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
            borderSide: BorderSide(color: Colors.grey.shade300),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
            borderSide: const BorderSide(color: Colors.blue, width: 2),
          ),
        ),
        searchHint: 'جستجوی ماه...',
        items:
            availableMonths.map((month) {
              return DropdownMenuItem(
                value: month,
                child: Text(monthNames[month - 1]),
              );
            }).toList(),
        onChanged: onChanged,
      ),
    ),
  );
}
