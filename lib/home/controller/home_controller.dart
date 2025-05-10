import 'package:get/get.dart';
import 'package:shamsi_date/shamsi_date.dart';
import '../api/home_api.dart';
import '../model/daily_detail_model.dart';

class HomeController extends GetxController {
  final CalendarModel calendarModel = CalendarModel();

  var currentMonth = Jalali.now().month.obs;
  var currentYear = Jalali.now().year.obs;
  var dailyDetails = <DailyDetail>[].obs;

  int get daysInMonth => calendarModel.getDaysInMonth(currentYear.value, currentMonth.value);

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
      final details = await HomeApi().getMonthlyDetails(currentYear.value, currentMonth.value, 1); // فرض userId=1
      dailyDetails.assignAll(details);
    } catch (e) {
      Get.snackbar('error'.tr, 'failed_to_fetch_details'.tr);
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