import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:shamsi_date/shamsi_date.dart';
import '../../controller/home_controller.dart';

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

  final numberFormatter = NumberFormat(
    '#,###',
  ); // برای جدا کردن هر سه رقم با کاما (برای فارسی)

  showDialog(
    context: context,
    builder: (context) {
      return AlertDialog(
        title: Text('ثبت هزینه ورزش ماهیانه'.tr, textAlign: TextAlign.center),
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
              // انتخاب ماه با نام‌های شمسی و پیش‌فرض جاری (فقط ماه‌های جاری و قبلی)
              DropdownButtonFormField<int>(
                value: currentMonth,
                decoration: InputDecoration(
                  labelText: 'ماه'.tr,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                items: months.map((month) {
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
                  labelText: 'هزینه (تومان)'.tr,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  hintText: 'حداکثر هزینه ورزش 800 هزارتومان',
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
                  labelText: 'ساعت'.tr,
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
            child: Text('لغو'.tr, style: TextStyle(color: Colors.red)),
          ),
          ElevatedButton(
            onPressed: () async {
              if (monthController.text.isEmpty ||
                  costController.text.isEmpty ||
                  hourController.text.isEmpty ) {
                Get.snackbar('خطا', 'لطفاً همه فیلدها را پر کنید'.tr);
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
                Get.snackbar('موفقیت', 'هزینه ورزش ثبت شد'.tr);
                Navigator.pop(context);
              } catch (e) {
                Get.snackbar('خطا', 'خطا در ثبت هزینه: $e'.tr);
              }
            },
            child: Text('ثبت'.tr),
          ),
        ],
      );
    },
  );
}