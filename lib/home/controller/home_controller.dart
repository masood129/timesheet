import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:shamsi_date/shamsi_date.dart';
import '../api/home_api.dart';
import '../model/daily_detail_model.dart';

class HomeController extends GetxController {
  final CalendarModel calendarModel = CalendarModel();

  var currentMonth = Jalali.now().month.obs;
  var currentYear = Jalali.now().year.obs;
  var dailyDetails = <DailyDetail>[].obs;
  var isLoading = true.obs;

  int get daysInMonth =>
      calendarModel.getDaysInMonth(currentYear.value, currentMonth.value);

  @override
  void onInit() {
    super.onInit();
    fetchMonthlyDetails();
  }

  void setNoteForDate(Jalali date, String note) {
    calendarModel.setNoteForDate(date, note);
  }

  String? getNoteForDate(Jalali date) {
    return calendarModel.getNoteForDate(date);
  }

  void nextMonth() {
    if (currentMonth.value == 12) {
      currentMonth.value = 1;
      currentYear.value += 1;
    } else {
      currentMonth.value += 1;
    }
    fetchMonthlyDetails();
  }

  void previousMonth() {
    if (currentMonth.value == 1) {
      currentMonth.value = 12;
      currentYear.value -= 1;
    } else {
      currentMonth.value -= 1;
    }
    fetchMonthlyDetails();
  }

  Future<void> fetchMonthlyDetails() async {
    try {
      isLoading.value = true;
      final jalaliDate = Jalali(currentYear.value, currentMonth.value);
      final gregorianDate = jalaliDate.toGregorian();
      final gregorianYear = gregorianDate.year;
      final gregorianMonth = gregorianDate.month;

      final details = await HomeApi().getMonthlyDetails(
        gregorianYear,
        gregorianMonth,
        1,
      );
      dailyDetails.assignAll(details);
      print(
        'Fetched DailyDetails: ${dailyDetails.map((d) => d.toJson())}',
      ); // دیباگ
    } catch (e) {
      Get.snackbar('error'.tr, 'failed_to_fetch_details'.tr);
      print('Error fetching details: $e');
    } finally {
      isLoading.value = false;
    }
  }

  Map<String, dynamic> getCardStatus(Jalali date, BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final gregorianDate = date.toGregorian();
    final formattedDate =
        '${gregorianDate.year}-${gregorianDate.month.toString().padLeft(2, '0')}-${gregorianDate.day.toString().padLeft(2, '0')}';

    final detail = dailyDetails.firstWhereOrNull(
      (d) => d.date == formattedDate,
    );

    if (detail == null) {
      print('No detail found for date: $formattedDate'); // دیباگ
      return {
        'color': colorScheme.surface,
        'leaveType': null,
        'isComplete': false,
      };
    }

    final isWorkingDay = detail.leaveType == 'کاری';
    bool isComplete = false;

    if (isWorkingDay) {
      final hasArrivalTime =
          detail.arrivalTime != null && detail.arrivalTime!.isNotEmpty;
      final hasLeaveTime =
          detail.leaveTime != null && detail.leaveTime!.isNotEmpty;
      final hasPersonalTime = detail.personalTime != null;

      final totalTaskMinutes = detail.tasks.fold<int>(
        0,
        (sum, task) => sum + (task.duration ?? 0),
      );

      final arrival = _parseTime(detail.arrivalTime);
      final leave = _parseTime(detail.leaveTime);
      int? effectiveWorkMinutes;
      if (arrival != null && leave != null) {
        final presence = leave - arrival;
        effectiveWorkMinutes = presence.inMinutes - (detail.personalTime ?? 0);
      }

      isComplete =
          hasArrivalTime &&
          hasLeaveTime &&
          hasPersonalTime &&
          effectiveWorkMinutes != null &&
          totalTaskMinutes == effectiveWorkMinutes;
    } else {
      isComplete = true; // روزهای غیرکاری (مثل استحقاقی) کامل هستند
    }

    Color cardColor;
    switch (detail.leaveType) {
      case 'کاری':
        cardColor = isComplete ? colorScheme.primary : colorScheme.secondary;
        break;
      case 'استحقاقی':
        cardColor = colorScheme.tertiary;
        break;
      case 'استعلاجی':
        cardColor = colorScheme.error;
        break;
      case 'هدیه':
        cardColor = colorScheme.secondaryContainer;
        break;
      default:
        cardColor = colorScheme.surface;
    }

    print(
      'Card status for $formattedDate: ${detail.leaveType}, isComplete: $isComplete, color: $cardColor',
    ); // دیباگ
    return {
      'color': cardColor,
      'leaveType': detail.leaveType,
      'isComplete': isComplete,
    };
  }

  Duration? _parseTime(String? time) {
    if (time == null ||
        time.isEmpty ||
        !RegExp(r'^\d{2}:\d{2}:\d{2}$').hasMatch(time)) {
      print('Invalid time format: $time'); // دیباگ
      return null;
    }
    try {
      final parts = time.split(':');
      final hours = int.parse(parts[0]);
      final minutes = int.parse(parts[1]);
      final seconds = int.parse(parts[2]);
      return Duration(hours: hours, minutes: minutes, seconds: seconds);
    } catch (e) {
      print('Error parsing time: $time, error: $e'); // دیباگ
      return null;
    }
  }
}

class CalendarModel {
  final Map<String, String> _notes = {};

  int getDaysInMonth(int year, int month) {
    return Jalali(year, month).monthLength;
  }

  void setNoteForDate(Jalali date, String note) {
    _notes[date.toString()] = note;
  }

  String? getNoteForDate(Jalali date) {
    return _notes[date.toString()];
  }
}
