import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:shamsi_date/shamsi_date.dart';
import 'package:timesheet/core/theme/theme.dart';
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

  TimeOfDay? _parseTime(String? timeString) {
    if (timeString == null || timeString.isEmpty) {
      return null;
    }
    try {
      final parts = timeString.split(':');
      if (parts.length >= 2) {
        return TimeOfDay(
          hour: int.parse(parts[0]),
          minute: int.parse(parts[1]),
        );
      }
    } catch (e) {
      print('Error parsing time: $timeString, Error: $e');
      return null;
    }
    return null;
  }

  Map<String, dynamic> getCardStatus(Jalali date, BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final brightness = Theme.of(context).brightness;

    final gregorianDate = date.toGregorian();
    final formattedDate =
        '${gregorianDate.year}-${gregorianDate.month.toString().padLeft(2, '0')}-${gregorianDate.day.toString().padLeft(2, '0')}';

    final detail = dailyDetails.firstWhereOrNull(
      (d) => d.date == formattedDate,
    );

    if (detail == null) {
      return {
        'color': colorScheme.surface,
        'leaveType': null,
        'isComplete': false,
      };
    }

    bool isComplete = false;
    if (detail.leaveType == 'کاری') {
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
        final presenceDuration = Duration(
          hours: leave.hour - arrival.hour,
          minutes: leave.minute - arrival.minute,
        );
        effectiveWorkMinutes =
            presenceDuration.inMinutes - (detail.personalTime ?? 0);
      }

      isComplete =
          hasArrivalTime &&
          hasLeaveTime &&
          hasPersonalTime &&
          effectiveWorkMinutes != null &&
          totalTaskMinutes == effectiveWorkMinutes &&
          effectiveWorkMinutes > 0; // اطمینان از اینکه زمان حضور مثبت است
    } else {
      isComplete = true;
    }

    Color cardColor;

    if (detail.leaveType == 'کاری') {
      if (isComplete) {
        cardColor =
            colorScheme.completedStatus; // <-- استفاده از رنگ جدید فسفری
      } else {
        cardColor =
            brightness == Brightness.light
                ? Colors.amber.shade300
                : Colors.amber.shade400;
      }
    } else {
      switch (detail.leaveType) {
        case 'استحقاقی':
          cardColor = colorScheme.tertiaryContainer;
          break;
        case 'استعلاجی':
          cardColor = colorScheme.error;
          break;
        case 'هدیه':
          cardColor = colorScheme.tertiary;
          break;
        default:
          cardColor = colorScheme.surface;
      }
    }

    return {
      'color': cardColor,
      'leaveType': detail.leaveType,
      'isComplete': isComplete,
    };
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
