import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:shamsi_date/shamsi_date.dart';

import '../../controller/home_controller.dart';
import '../../../core/widgets/searchable_dropdown.dart';

void showMonthlyReportDialog(
  BuildContext context,
  HomeController homeController,
) async {
  final currentYear = Jalali.now().year;
  final currentMonth = Jalali.now().month;

  // همه ماه‌های شمسی (12 ماه)
  final allMonths = List.generate(12, (index) => index + 1);
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

  // دریافت لیست گزارش‌های ارسال‌شده
  final drafts = await homeController.fetchMyDrafts();

  // استخراج ماه‌های ارسال‌شده برای سال جاری
  final submittedMonths =
      drafts
          .where(
            (draft) =>
                draft.jalaliYear == currentYear && draft.jalaliMonth != null,
          )
          .map((draft) => draft.jalaliMonth!)
          .toSet();

  // فیلتر کردن ماه‌های ارسال‌شده از لیست ماه‌های موجود
  final availableMonths =
      allMonths.where((month) => !submittedMonths.contains(month)).toList();

  // اگر ماه جاری ارسال شده بود، اولین ماه موجود را انتخاب کن
  var selectedMonth =
      availableMonths.contains(currentMonth)
          ? currentMonth.obs
          : (availableMonths.isNotEmpty
              ? availableMonths.first.obs
              : currentMonth.obs);

  Get.dialog(
    AlertDialog(
      title: Text('monthly_report_draft'.tr, textAlign: TextAlign.center),
      content: SingleChildScrollView(
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
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    Text(
                      currentYear.toString(),
                      style: TextStyle(fontSize: 16),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
            // انتخاب ماه با نام‌های شمسی (ماه‌های ارسال‌شده disable هستند)
            Obx(
              () => SearchableDropdown<int>(
                value: selectedMonth.value,
                decoration: InputDecoration(
                  labelText: 'ماه'.tr,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                searchHint: 'جستجوی ماه...',
                items:
                    allMonths.map((month) {
                      final isSubmitted = submittedMonths.contains(month);
                      final isFutureMonth = month > currentMonth;
                      final isDisabled = isSubmitted || isFutureMonth;
                      return DropdownMenuItem(
                        value: month,
                        enabled: !isDisabled,
                        child: IgnorePointer(
                          ignoring: isDisabled,
                          child: MouseRegion(
                            cursor:
                                isDisabled
                                    ? SystemMouseCursors.basic
                                    : SystemMouseCursors.click,
                            child: Text(
                              monthNames[month - 1],
                              style: TextStyle(
                                color: isDisabled ? Colors.grey : null,
                              ),
                            ),
                          ),
                        ),
                      );
                    }).toList(),
                onChanged: (newMonth) {
                  if (newMonth != null &&
                      !submittedMonths.contains(newMonth) &&
                      newMonth <= currentMonth) {
                    selectedMonth.value = newMonth;
                  }
                },
              ),
            ),
          ],
        ),
      ),
      actionsAlignment: MainAxisAlignment.spaceEvenly,
      actions: [
        TextButton(
          onPressed: () => Get.back(),
          child: Text('لغو'.tr, style: TextStyle(color: Colors.red)),
        ),
        ElevatedButton(
          onPressed: () async {
            Get.back(); // بستن دیالوگ
            await homeController.submitMonthlyReport(
              currentYear,
              selectedMonth.value,
            );
          },
          child: Text('yes_submit'.tr),
        ),
      ],
    ),
  );
}
