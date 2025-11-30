import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:shamsi_date/shamsi_date.dart';
import '../../controller/home_controller.dart';
import '../../../core/theme/snackbar_helper.dart';
import '../../../core/widgets/searchable_dropdown.dart';

void showGymCostDialog(BuildContext context, HomeController homeController) {
  final now = Jalali.now();
  final currentYear = now.year;
  final currentMonth = now.month;
  final yearController = TextEditingController(text: currentYear.toString());
  final monthController = TextEditingController(text: currentMonth.toString());
  final costController = TextEditingController();
  final hourController = TextEditingController();

  // تغییر: فقط ماه‌های جاری و قبلی را نمایش دهید
  final months = List.generate(currentMonth, (index) => index + 1);
  final monthNames = [
    'month_1'.tr,
    'month_2'.tr,
    'month_3'.tr,
    'month_4'.tr,
    'month_5'.tr,
    'month_6'.tr,
    'month_7'.tr,
    'month_8'.tr,
    'month_9'.tr,
    'month_10'.tr,
    'month_11'.tr,
    'month_12'.tr,
  ];

  final numberFormatter = NumberFormat(
    '#,###',
  ); // برای جدا کردن هر سه رقم با کاما (برای فارسی)

  showDialog(
    context: context,
    builder: (context) {
      return AlertDialog(
        title: Text(
          'register_monthly_gym_cost'.tr,
          textAlign: TextAlign.center,
        ),
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
                        'year'.tr,
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
              // انتخاب ماه با نام‌های شمسی و پیش‌فرض جاری (فقط ماه‌های جاری و قبلی)
              SearchableDropdown<int>(
                value: currentMonth,
                decoration: InputDecoration(
                  labelText: 'month'.tr,
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
                onChanged: (value) {
                  if (value != null) {
                    monthController.text = value.toString();
                  }
                },
              ),
              const SizedBox(height: 16),
              TextField(
                controller: costController,
                decoration: InputDecoration(
                  labelText: 'cost_toman'.tr,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  hintText: 'gym_cost_hint'.tr,
                  suffixIcon: Icon(Icons.money),
                ),
                keyboardType: TextInputType.number,
                inputFormatters: [
                  FilteringTextInputFormatter.digitsOnly,
                  // فقط اعداد
                  LengthLimitingTextInputFormatter(7),
                  // حداکثر 7 رقم (برای 800,000)
                ],
                onChanged: (value) {
                  // حذف کاماها برای پردازش
                  String newValue = value.replaceAll(',', '');
                  if (newValue.isNotEmpty) {
                    int cost = int.parse(newValue);
                    if (cost > 800000) {
                      cost = 800000;
                      newValue = cost.toString();
                    }
                    // اعمال فرمت کاما
                    final formatted = numberFormatter.format(
                      int.parse(newValue),
                    );
                    costController.value = TextEditingValue(
                      text: formatted,
                      selection: TextSelection.collapsed(
                        offset: formatted.length,
                      ),
                    );
                  }
                },
              ),
              const SizedBox(height: 16),
              TextField(
                controller: hourController,
                decoration: InputDecoration(
                  labelText: 'hour'.tr,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  suffixIcon: Icon(Icons.lock_clock),
                ),
                keyboardType: TextInputType.number,
                inputFormatters: [FilteringTextInputFormatter.digitsOnly],
              ),
            ],
          ),
        ),
        actionsAlignment: MainAxisAlignment.spaceEvenly,
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('cancel'.tr, style: TextStyle(color: Colors.red)),
          ),
          ElevatedButton(
            onPressed: () async {
              if (monthController.text.isEmpty ||
                  costController.text.isEmpty ||
                  hourController.text.isEmpty) {
                ThemedSnackbar.showError('error'.tr, 'fill_all_fields'.tr);
                return;
              }
              try {
                // حذف کاماها از هزینه قبل از ذخیره
                final cleanCost = costController.text.replaceAll(',', '');
                await homeController.saveMonthlyGymCost(
                  int.parse(yearController.text),
                  int.parse(monthController.text),
                  int.parse(cleanCost),
                  int.parse(hourController.text),
                );
                ThemedSnackbar.showSuccess('success'.tr, 'gym_cost_saved'.tr);
                if (context.mounted) {
                  Navigator.pop(context);
                }
              } catch (e) {
                ThemedSnackbar.showError(
                  'error'.tr,
                  '${'save_cost_error'.tr}: $e',
                );
              }
            },
            child: Text('submit'.tr),
          ),
        ],
      );
    },
  );
}
