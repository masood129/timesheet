import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:shamsi_date/shamsi_date.dart';

import '../../controller/home_controller.dart';
import '../../../core/widgets/searchable_dropdown.dart';

void showMonthlyReportDialog(
  BuildContext context,
  HomeController homeController,
) {
  final currentYear = Jalali.now().year;
  final currentMonth = Jalali.now().month;

  // ماه‌های شمسی تا ماه جاری
  final months = List.generate(currentMonth, (index) => index + 1);
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

  // متغیر انتخاب‌شده برای ماه (پیشفرض: جاری)
  var selectedMonth = currentMonth.obs;

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
            // انتخاب ماه با نام‌های شمسی و محدود به ماه جاری
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
                    months.map((month) {
                      return DropdownMenuItem(
                        value: month,
                        child: Text(monthNames[month - 1]),
                      );
                    }).toList(),
                onChanged: (newMonth) {
                  if (newMonth != null) {
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
