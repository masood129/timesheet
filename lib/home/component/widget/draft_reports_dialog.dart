import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:shamsi_date/shamsi_date.dart';

import '../../controller/home_controller.dart';
import '../../model/draft_report_model.dart';

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

  // بارگیری drafts و استخراج ماه‌های منحصربه‌فرد
  homeController.fetchMyDrafts().then((drafts) {
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
      final draft = drafts.firstWhereOrNull(
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
          Text('مدیریت پیش‌نویس گزارش ماهانه'.tr, textAlign: TextAlign.center),
        ],
      ),
      content: Obx(() {
        if (availableMonths.isEmpty) {
          return const Card(
            color: Colors.orange,
            child: Padding(
              padding: EdgeInsets.all(16.0),
              child: Text(
                'هیچ پیش‌نویسی یافت نشد.',
                style: TextStyle(color: Colors.white),
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
                        // به‌روزرسانی reportId و جزئیات بر اساس ماه انتخاب‌شده
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
                  // کارت جزئیات draft انتخاب‌شده (با لیست‌های زیباتر برای پروژه‌ها)
                  if (selectedDraftDetails.value != null)
                    _buildDraftDetailsCard(
                      selectedDraftDetails.value!,
                      monthNames,
                    ),
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
          child: Text('لغو'.tr, style: const TextStyle(color: Colors.red)),
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
                      Get.snackbar(
                        'موفقیت',
                        'پیش‌نویس با موفقیت به مدیر گروه ارسال شد.',
                        backgroundColor: Colors.green,
                      );
                    },
            icon: const Icon(Icons.send),
            label: Text('ارسال به مدیر گروه'.tr),
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
                      Get.snackbar(
                        'موفقیت',
                        'پیش‌نویس با موفقیت حذف شد.',
                        backgroundColor: Colors.orange,
                      );
                    },
            icon: const Icon(Icons.delete),
            label: Text('حذف پیش‌نویس'.tr),
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
          const Text(
            'سال',
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: Colors.blue.withOpacity(0.1),
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
      child: DropdownButtonFormField<int>(
        value: selectedMonth.value,
        decoration: InputDecoration(
          labelText: 'انتخاب ماه',
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

/// کارت جزئیات پیش‌نویس با ردیف‌های مرتب و بخش‌های لیست برای پروژه‌ها
Widget _buildDraftDetailsCard(DraftReportModel draft, List<String> monthNames) {
  return Card(
    elevation: 4,
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
    child: Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.info_outline, color: Colors.blue),
              const SizedBox(width: 8),
              const Text(
                'جزئیات پیش‌نویس',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
              ),
            ],
          ),
          const SizedBox(height: 16),
          const Divider(color: Colors.grey),
          const SizedBox(height: 8),
          // ردیف‌های ساده جزئیات
          _buildDetailRow('سال', '${draft.jalaliYear ?? 'نامشخص'}'),
          _buildDetailRow('ماه', monthNames[(draft.jalaliMonth ?? 1) - 1]),
          _buildDetailRow(
            'جمع ساعت کاری کل',
            '${draft.totalHours ?? 'نامشخص'}',
          ),
          _buildDetailRow('هزینه باشگاه', '${draft.gymCost ?? 'نامشخص'} تومان'),
          _buildDetailRow(
            'هزینه رفت و آمد به شرکت',
            '${draft.totalCommuteCost ?? 'نامشخص'} تومان',
          ),
          _buildDetailRow(
            'گروه مربوطه',
            '${draft.groupName ?? draft.groupId?.toString() ?? 'نامشخص'}',
          ),
          _buildDetailRow(
            'سرگروه مربوطه',
            '${draft.managerUsername ?? 'نامشخص'}',
          ),
          const SizedBox(height: 16),
          // بخش لیست ساعت‌های پروژه (جدید: بر اساس API)
          _buildProjectHoursSection(draft),
          const SizedBox(height: 16),
          // بخش لیست هزینه‌های ماشین شخصی (قبلی)
          _buildProjectCostsSection(draft),
        ],
      ),
    ),
  );
}

/// ردیف جزئیات ساده (با استایل بهتر)
Widget _buildDetailRow(String label, String value) {
  return Padding(
    padding: const EdgeInsets.symmetric(vertical: 6.0),
    child: Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 140,
          child: Text(
            '$label:',
            style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14),
          ),
        ),
        Expanded(
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: Colors.grey.withOpacity(0.05),
              borderRadius: BorderRadius.circular(6),
            ),
            child: Text(value, style: const TextStyle(fontSize: 14)),
          ),
        ),
      ],
    ),
  );
}

/// بخش نمایش ساعت صرف‌شده به تفکیک پروژه (جدید: بر اساس projectHoursByProject از API)
/// اگر لیستی خالی باشد، پیام مناسب نمایش می‌دهد.
Widget _buildProjectHoursSection(DraftReportModel draft) {
  final hours = draft.projectHoursByProject ?? [];
  return Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Row(
        children: [
          const Icon(Icons.access_time, color: Colors.green, size: 20),
          const SizedBox(width: 8),
          const Text(
            'ساعت صرف‌شده به تفکیک هر پروژه',
            style: TextStyle(fontWeight: FontWeight.w600, fontSize: 14),
          ),
        ],
      ),
      const SizedBox(height: 8),
      if (hours.isEmpty)
        _buildDetailRow('ساعت صرف‌شده به تفکیک هر پروژه', 'هیچ ساعتی ثبت نشده')
      else
        Container(
          height: 120, // ارتفاع ثابت برای اسکرول اگر لازم
          decoration: BoxDecoration(
            color: Colors.green.withOpacity(0.05),
            borderRadius: BorderRadius.circular(8),
          ),
          child: ListView.separated(
            padding: const EdgeInsets.all(8),
            itemCount: hours.length,
            separatorBuilder: (context, index) => const Divider(height: 1),
            itemBuilder: (context, index) {
              final hour = hours[index];
              final projectId = hour.projectId?.toString() ?? 'نامشخص';
              final totalHours = hour.totalHours?.toString() ?? 'نامشخص';
              return Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [Text('پروژه $projectId'), Text('$totalHours ساعت')],
              );
            },
          ),
        ),
    ],
  );
}

/// بخش نمایش هزینه‌های ماشین شخصی به تفکیک پروژه (بهبودیافته: با ListView و استایل بهتر)
Widget _buildProjectCostsSection(DraftReportModel draft) {
  final costs = draft.personalCarCostsByProject ?? [];
  return Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Row(
        children: [
          const Icon(Icons.local_gas_station, color: Colors.orange, size: 20),
          const SizedBox(width: 8),
          const Text(
            'هزینه ماشین شخصی به تفکیک هر پروژه',
            style: TextStyle(fontWeight: FontWeight.w600, fontSize: 14),
          ),
        ],
      ),
      const SizedBox(height: 8),
      if (costs.isEmpty)
        _buildDetailRow(
          'هزینه ماشین شخصی به تفکیک هر پروژه',
          'هیچ هزینه‌ای ثبت نشده',
        )
      else
        Container(
          height: 120,
          decoration: BoxDecoration(
            color: Colors.orange.withOpacity(0.05),
            borderRadius: BorderRadius.circular(8),
          ),
          child: ListView.separated(
            padding: const EdgeInsets.all(8),
            itemCount: costs.length,
            separatorBuilder: (context, index) => const Divider(height: 1),
            itemBuilder: (context, index) {
              final cost = costs[index];
              final projectId = cost.projectId?.toString() ?? 'نامشخص';
              final costAmount = cost.cost?.toString() ?? 'نامشخص';
              return Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [Text('پروژه $projectId'), Text('$costAmount تومان')],
              );
            },
          ),
        ),
    ],
  );
}
