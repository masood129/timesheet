import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_native_splash/flutter_native_splash.dart';
import 'package:get/Get.dart';
import 'package:shamsi_date/shamsi_date.dart';
import 'package:timesheet/core/theme/theme.dart';
import '../../core/api/api_calls/api_calls.dart';
import '../../core/theme/snackbar_helper.dart';
import '../../model/daily_detail_model.dart';
import '../../model/draft_report_model.dart';
import '../../model/leavetype_model.dart';
import '../../data/models/month_period_model.dart';
import '../component/note_dialog.dart';
import '../controller/task_controller.dart';

class HomeController extends GetxController {
  final CalendarModel calendarModel = CalendarModel();

  var currentMonth = Jalali.now().month.obs;
  var currentYear = Jalali.now().year.obs;
  var dailyDetails = <DailyDetail>[].obs;
  var isListView = false.obs;
  var holidays = <String, dynamic>{}.obs;
  var monthStatus = Rx<String?>(
    null,
  ); // استفاده از Rx<String?> برای نگهداری null
  List<DraftReportModel> drafts =
      <DraftReportModel>[].obs; // لیست drafts (json objects)

  // Month period settings
  MonthPeriodModel? currentMonthPeriod;

  int get daysInMonth {
    if (currentMonthPeriod != null) {
      return currentMonthPeriod!.calculateDaysInPeriod(currentYear.value);
    }
    return calendarModel.getDaysInMonth(currentYear.value, currentMonth.value);
  }

  /// دریافت لیست روزهای ماه جاری (بر اساس بازه ادمین یا ماه عادی)
  List<Jalali> get daysInCurrentMonth {
    if (currentMonthPeriod != null) {
      return currentMonthPeriod!.getDaysInPeriod();
    }
    // حالت پیش‌فرض: تمام روزهای ماه
    final daysCount = calendarModel.getDaysInMonth(currentYear.value, currentMonth.value);
    return List.generate(
      daysCount,
      (index) => Jalali(currentYear.value, currentMonth.value, index + 1),
    );
  }

  @override
  void onInit() {
    super.onInit();
    initializeApp();
  }

  Future<List<DraftReportModel>> fetchMyDrafts() async {
    try {
      final reportList = await ApiCalls().getMyDrafts();
      return reportList;
    } catch (e) {
      ThemedSnackbar.showError('خطا', 'خطا در دریافت پیش‌نویس‌ها: $e');
      return [];
    }
  }

  // متد جدید برای ارسال draft به مدیر گروه
  Future<void> submitDraftToManager(int reportId) async {
    try {
      await ApiCalls().submitReportToGroupManager(reportId);
      // بروزرسانی لیست drafts پس از ارسال
      await fetchMyDrafts();
      await fetchMonthlyDetails(); // بروزرسانی وضعیت ماه (فرض بر موجود بودن این متد)
    } catch (e) {
      ThemedSnackbar.showError('خطا', 'خطا در ارسال پیش‌نویس: $e');
    }
  }

  // متد جدید برای حذف draft
  Future<void> exitDraft(int reportId) async {
    try {
      await ApiCalls().exitDraft(reportId);
      // بروزرسانی لیست drafts پس از حذف
      await fetchMyDrafts();
      await fetchMonthlyDetails(); // بروزرسانی وضعیت ماه (فرض بر موجود بودن این متد)
    } catch (e) {
      ThemedSnackbar.showError('خطا', 'خطا در حذف پیش‌نویس: $e');
    }
  }

  Future<void> openNoteDialog(BuildContext context, Jalali date) async {
    if (monthStatus.value != null) {
      // فقط اگر null باشد، ادیت ممکن است
      showMonthLockedDialog(monthStatus.value!);
      return;
    }

    final taskController = Get.find<TaskController>();
    await taskController.loadDailyDetail(date, dailyDetails);

    showModalBottomSheet(
      useSafeArea: true,
      enableDrag: false,
      isScrollControlled: true,
      context: context,
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) => NoteDialog(date: date),
    );
  }

  void showMonthLockedDialog(String status) {
    String message;
    switch (status) {
      case 'draft':
        message =
            'ساعات کاری این ماه در حال پیش‌نویس است. امکان ویرایش جزئیات روزانه وجود ندارد.';
        break;
      case 'submitted_to_general_manager':
        message =
            'ساعات کاری این ماه به مدیر کل ارسال شده است. امکان ویرایش جزئیات روزانه وجود ندارد.';
        break;
      case 'approved':
        message =
            'ساعات کاری این ماه تایید شده است. امکان ویرایش جزئیات روزانه وجود ندارد.';
        break;
      case 'submitted_to_group_manager':
        message =
            'ساعات کاری این ماه به مدیر گروه ارسال شده است. امکان ویرایش جزئیات روزانه وجود ندارد.';
        break;
      case 'submitted_to_finance':
        message =
            'ساعات کاری این ماه به امور مالی ارسال شده است. امکان ویرایش جزئیات روزانه وجود ندارد.';
        break;
      default:
        message =
            'ساعات کاری این ماه ارسال شده است. امکان ویرایش جزئیات روزانه وجود ندارد.';
    }

    Get.defaultDialog(
      title: 'اطلاعیه',
      content: Text(message),
      actions: [
        TextButton(onPressed: () => Get.back(), child: const Text('تأیید')),
      ],
    );
  }

  saveMonthlyGymCost(int year, int month, int cost, int hours) async {
    try {
      await ApiCalls().saveMonthlyGymCost(year, month, cost, hours);
    } catch (e) {
      rethrow;
    }
  }

  Future<void> initializeApp() async {
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      try {
        await loadHolidays();
        await _fetchCurrentMonthPeriod();
        await fetchMonthlyDetails();
      } finally {
        FlutterNativeSplash.remove();
      }
    });
  }

  /// دریافت بازه ماه جاری
  Future<void> _fetchCurrentMonthPeriod() async {
    try {
      currentMonthPeriod = await ApiCalls().getMonthPeriod(
        currentYear.value,
        currentMonth.value,
      );
      update();
    } catch (e) {
      // در صورت خطا، از مقدار پیش‌فرض استفاده می‌شود
      currentMonthPeriod = null;
    }
  }

  Future<void> loadHolidays() async {
    if (Get.context == null) {
      return;
    }

    try {
      final String holidays1404 = await DefaultAssetBundle.of(
        Get.context!,
      ).loadString('assets/holidays/holidays_1404.json');
      final String holidays1405 = await DefaultAssetBundle.of(
        Get.context!,
      ).loadString('assets/holidays/holidays_1405.json');

      final List<dynamic> data1404 = jsonDecode(holidays1404);
      final List<dynamic> data1405 = jsonDecode(holidays1405);

      final Map<String, dynamic> combinedHolidays = {};
      for (var item in data1404) {
        combinedHolidays[item['date']] = item;
      }
      for (var item in data1405) {
        combinedHolidays[item['date']] = item;
      }
      holidays.assignAll(combinedHolidays);
    } catch (e) {
      if (Get.context != null) {
        ThemedSnackbar.showError('error'.tr, 'failed_to_load_holidays'.tr);
      }
    }
  }

  Map<String, dynamic>? getHolidayForDate(Jalali date) {
    final formattedDate =
        '${date.year}/${date.month.toString().padLeft(2, '0')}/${date.day.toString().padLeft(2, '0')}';
    return holidays[formattedDate];
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
    _fetchCurrentMonthPeriod();
    fetchMonthlyDetails();
  }

  void previousMonth() {
    if (currentMonth.value == 1) {
      currentMonth.value = 12;
      currentYear.value -= 1;
    } else {
      currentMonth.value -= 1;
    }
    _fetchCurrentMonthPeriod();
    fetchMonthlyDetails();
  }

  void toggleView() {
    isListView.value = !isListView.value;
  }

  Future<void> submitMonthlyReport(int year, int month) async {
    // First, ensure monthly details are fetched
    await fetchMonthlyDetails();

    // Check for incomplete working days
    bool hasIncompleteDays = false;
    String errorMessage = 'روزهای ناقص: ';

    final daysList = currentMonthPeriod?.getDaysInPeriod() ?? 
        List.generate(
          calendarModel.getDaysInMonth(year, month),
          (index) => Jalali(year, month, index + 1),
        );
    
    for (final date in daysList) {
      final status = getCardStatus(
        date,
        Get.context!,
      ); // Assuming Get.context is available; adjust if needed
      if (status['leaveType'] == LeaveType.work &&
          !(status['isComplete'] as bool)) {
        hasIncompleteDays = true;
        errorMessage += '${date.day}, ';
      }
    }

    if (hasIncompleteDays) {
      errorMessage = errorMessage.trim().replaceAll(
        RegExp(r',\s*$'),
        '',
      ); // Remove trailing comma
      if (Get.context != null) {
        ThemedSnackbar.showError(
          'خطا',
          '$errorMessage - ساعات پروژه و ساعات مفید مطابقت ندارند',
        );
      }
      return; // Or throw Exception('Incomplete days');
    }

    // Proceed if all working days are complete
    await ApiCalls().createJalaliMonthlyReport(year, month);
    await fetchMonthlyDetails(); // بروزرسانی وضعیت پس از ارسال
  }

  Future<void> fetchMonthlyDetails() async {
    try {
      Jalali startJalali, endJalali;
      
      if (currentMonthPeriod != null) {
        // استفاده از بازه تعریف شده
        final days = currentMonthPeriod!.getDaysInPeriod();
        if (days.isNotEmpty) {
          startJalali = days.first;
          endJalali = days.last;
        } else {
          // fallback به حالت پیش‌فرض
          startJalali = Jalali(currentYear.value, currentMonth.value, 1);
          final daysInMonth = Jalali(currentYear.value, currentMonth.value).monthLength;
          endJalali = Jalali(currentYear.value, currentMonth.value, daysInMonth);
        }
      } else {
        // حالت پیش‌فرض
        startJalali = Jalali(currentYear.value, currentMonth.value, 1);
        final daysInMonth = Jalali(currentYear.value, currentMonth.value).monthLength;
        endJalali = Jalali(currentYear.value, currentMonth.value, daysInMonth);
      }

      final startGregorian = startJalali.toGregorian();
      final endGregorian = endJalali.toGregorian();

      final startDate =
          '${startGregorian.year}-${startGregorian.month.toString().padLeft(2, '0')}-${startGregorian.day.toString().padLeft(2, '0')}';
      final endDate =
          '${endGregorian.year}-${endGregorian.month.toString().padLeft(2, '0')}-${endGregorian.day.toString().padLeft(2, '0')}';

      final details = await ApiCalls().getDateRangeDetails(startDate, endDate);

      // فیلتر کردن بر اساس روزهای بازه
      final periodDays = currentMonthPeriod?.getDaysInPeriod() ?? [];
      final filteredDetails = details.where((detail) {
        final date = DateTime.parse(detail.date);
        final jalali = Jalali.fromDateTime(date);
        // بررسی اینکه آیا این تاریخ در لیست روزهای بازه است
        if (periodDays.isNotEmpty) {
          return periodDays.any((day) => 
            day.year == jalali.year && 
            day.month == jalali.month && 
            day.day == jalali.day
          );
        }
        // fallback به فیلتر قدیمی
        return jalali.year == currentYear.value &&
            jalali.month == currentMonth.value;
      }).toList();

      dailyDetails.assignAll(filteredDetails);

      final status = await ApiCalls().checkMonthlyReportStatus(
        currentYear.value,
        currentMonth.value,
      );
      monthStatus.value = status; // بدون جایگزینی، اگر null باشد، null می‌ماند
    } catch (e) {
      monthStatus.value = null; // In case of error, assume null
      if (Get.context != null) {
        ThemedSnackbar.showError('error'.tr, 'failed_to_fetch_details'.tr);
      }
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
      return null;
    }
    return null;
  }

  String calculateEffectiveWork(Jalali date) {
    final gregorianDate = date.toGregorian();
    final formattedDate =
        '${gregorianDate.year}-${gregorianDate.month.toString().padLeft(2, '0')}-${gregorianDate.day.toString().padLeft(2, '0')}';
    final detail = dailyDetails.firstWhereOrNull(
      (d) => d.date == formattedDate,
    );

    if (detail == null) {
      return 'بدون عملکرد';
    }

    if (detail.leaveType != LeaveType.work &&
        detail.leaveType != LeaveType.mission) {
      // تغییر به enum
      return detail.leaveType?.displayName ??
          'بدون عملکرد'; // استفاده از displayName برای نمایش
    }

    final arrival = _parseTime(detail.arrivalTime);
    final leave = _parseTime(detail.leaveTime);
    final personal = detail.personalTime ?? 0;
    final totalTaskMinutes = detail.tasks.fold<int>(
      0,
      (sum, task) => sum + (task.duration ?? 0),
    );

    if (arrival != null && leave != null) {
      final presenceDuration = Duration(
        hours: leave.hour - arrival.hour,
        minutes: leave.minute - arrival.minute,
      );
      final effective = presenceDuration.inMinutes - personal;
      return 'کار مفید: ${effective ~/ 60} ساعت و ${effective % 60} دقیقه';
    }

    return 'وظایف: ${totalTaskMinutes ~/ 60} ساعت و ${totalTaskMinutes % 60} دقیقه';
  }

  String getTooltipMessage(Jalali date) {
    final gregorianDate = date.toGregorian();
    final formattedDate =
        '${gregorianDate.year}-${gregorianDate.month.toString().padLeft(2, '0')}-${gregorianDate.day.toString().padLeft(2, '0')}';
    final detail = dailyDetails.firstWhereOrNull(
      (d) => d.date == formattedDate,
    );
    final holiday = getHolidayForDate(date);

    if (holiday != null && holiday['isHoliday'] == true) {
      final events = holiday['events'] as List<dynamic>? ?? [];
      final eventDescriptions = events
          .map((e) => e['description'] as String)
          .join(', ');
      return eventDescriptions.isNotEmpty
          ? 'تعطیل: $eventDescriptions'
          : 'تعطیل';
    }

    if (detail == null) {
      return 'بدون اطلاعات';
    }

    if (detail.leaveType != LeaveType.work &&
        detail.leaveType != LeaveType.mission) {
      // تغییر به enum
      return detail.leaveType?.displayName ??
          'بدون اطلاعات'; // استفاده از displayName
    }

    final isComplete = getCardStatus(date, Get.context!)['isComplete'] as bool;
    return isComplete ? 'روز کاری: کامل' : 'روز کاری: ناقص';
  }

  Map<String, dynamic> getCardStatus(Jalali date, BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    final gregorianDate = date.toGregorian();
    final formattedDate =
        '${gregorianDate.year}-${gregorianDate.month.toString().padLeft(2, '0')}-${gregorianDate.day.toString().padLeft(2, '0')}';

    final detail = dailyDetails.firstWhereOrNull(
      (d) => d.date == formattedDate,
    );

    bool hasWorkingHours =
        detail != null &&
        detail.arrivalTime != null &&
        detail.arrivalTime!.isNotEmpty &&
        detail.leaveTime != null &&
        detail.leaveTime!.isNotEmpty;

    if (detail == null && !hasWorkingHours) {
      return {
        'avatarColor': colorScheme.noDataStatus,
        'avatarIcon': Icons.calendar_today,
        'avatarIconColor': colorScheme.onNoDataStatus,
        'leaveType': null,
        'isComplete': false,
      };
    }

    bool isComplete = false;
    if (hasWorkingHours) {
      final hasArrivalTime =
          detail.arrivalTime != null && detail.arrivalTime!.isNotEmpty;
      final hasLeaveTime =
          detail.leaveTime != null && detail.leaveTime!.isNotEmpty;
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
          effectiveWorkMinutes != null &&
          totalTaskMinutes == effectiveWorkMinutes &&
          effectiveWorkMinutes > 0;

      return {
        'avatarColor':
            isComplete
                ? colorScheme.completedStatus
                : colorScheme.incompleteStatus,
        'avatarIcon': isComplete ? Icons.check_circle : Icons.access_time,
        'avatarIconColor':
            isComplete
                ? colorScheme.onCompletedStatus
                : colorScheme.onIncompleteStatus,
        'leaveType': LeaveType.work, // تغییر به enum
        'isComplete': isComplete,
      };
    }

    if (detail.leaveType != LeaveType.work &&
        detail.leaveType != LeaveType.mission) {
      // تغییر به enum
      IconData avatarIcon;
      Color avatarColor;
      Color avatarIconColor;
      switch (detail.leaveType) {
        case LeaveType.annualLeave:
          avatarIcon = Icons.beach_access;
          avatarColor = colorScheme.secondary;
          avatarIconColor = colorScheme.onSecondary;
          isComplete = true;
          break;
        case LeaveType.sickLeave:
          avatarIcon = Icons.local_hospital;
          avatarColor = colorScheme.error;
          avatarIconColor = colorScheme.onError;
          isComplete = true;
          break;
        case LeaveType.giftLeave:
          avatarIcon = Icons.card_giftcard;
          avatarColor = colorScheme.tertiary;
          avatarIconColor = colorScheme.onTertiary;
          isComplete = true;
          break;
        case LeaveType.mission:
          avatarIcon =
              Icons
                  .flight_takeoff; // یا آیکون مناسب برای ماموریت، مثل Icons.business
          avatarColor = colorScheme.primary; // یا secondary، بسته به theme
          avatarIconColor = colorScheme.onPrimary;
          isComplete =
              true; // اگر مثل مرخصی باشه؛ اما چون مثل work، این case رو اصلاً نزن (با شرط if بالا)
          break;
        default:
          avatarIcon = Icons.calendar_today;
          avatarColor = colorScheme.noDataStatus;
          avatarIconColor = colorScheme.onNoDataStatus;
      }
      return {
        'avatarColor': avatarColor,
        'avatarIcon': avatarIcon,
        'avatarIconColor': avatarIconColor,
        'leaveType': detail.leaveType, // enum برمی‌گرداند
        'isComplete': isComplete,
      };
    }

    return {
      'avatarColor': colorScheme.noDataStatus,
      'avatarIcon': Icons.calendar_today,
      'avatarIconColor': colorScheme.onNoDataStatus,
      'leaveType': null,
      'isComplete': false,
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
