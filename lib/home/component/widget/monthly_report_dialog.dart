import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:shamsi_date/shamsi_date.dart';

import '../../controller/home_controller.dart';

void showMonthlyReportDialog(BuildContext context, HomeController homeController) {
  final currentYear = Jalali.now().year;
  final currentMonth = Jalali.now().month;

  // سال‌های مجاز: از 1400 تا سال جاری
  final List<int> years = List.generate(currentYear - 1400 + 1, (index) => 1400 + index);

  // متغیرهای انتخاب‌شده (پیشفرض: جاری)
  var selectedYear = currentYear.obs;
  var selectedMonth = currentMonth.obs;

  Get.dialog(
    AlertDialog(
      title: Text('تایید ارسال گزارش ماهانه'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text('ماه مورد نظر برای ارسال گزارش را انتخاب کنید:'),
          const SizedBox(height: 16),
          // Dropdown برای سال
          Obx(() => DropdownButton<int>(
            value: selectedYear.value,
            items: years.map((year) => DropdownMenuItem<int>(
              value: year,
              child: Text(year.toString()),
            )).toList(),
            onChanged: (newYear) {
              if (newYear != null) {
                selectedYear.value = newYear;
                // اگر سال جاری باشه، ماه رو محدود کن
                if (newYear == currentYear && selectedMonth.value > currentMonth) {
                  selectedMonth.value = currentMonth;
                }
              }
            },
          )),
          // Dropdown برای ماه
          Obx(() => DropdownButton<int>(
            value: selectedMonth.value,
            items: _getMonthsForYear(selectedYear.value, currentYear, currentMonth)
                .map((month) => DropdownMenuItem<int>(
              value: month,
              child: Text(month.toString()),
            ))
                .toList(),
            onChanged: (newMonth) {
              if (newMonth != null) {
                selectedMonth.value = newMonth;
              }
            },
          )),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Get.back(),
          child: Text('لغو'),
        ),
        ElevatedButton(
          onPressed: () async {
            Get.back(); // بستن دیالوگ
            // await homeController.submitMonthlyReport(selectedYear.value, selectedMonth.value);
          },
          child: Text('بله، ارسال کن'),
        ),
      ],
    ),
  );
}

// تابع کمکی برای گرفتن ماه‌های مجاز بر اساس سال
List<int> _getMonthsForYear(int year, int currentYear, int currentMonth) {
  if (year < currentYear) {
    return List.generate(12, (index) => index + 1); // همه ماه‌ها برای سال‌های گذشته
  } else {
    return List.generate(currentMonth, (index) => index + 1); // فقط تا ماه جاری برای سال جاری
  }
}