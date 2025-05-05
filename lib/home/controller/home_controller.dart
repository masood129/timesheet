import 'package:get/get.dart';
import 'package:shamsi_date/shamsi_date.dart';

class HomeController extends GetxController {
  final CalendarModel calendarModel = CalendarModel();

  var currentMonth = Jalali.now().month.obs;
  var currentYear = Jalali.now().year.obs;

  int get daysInMonth => calendarModel.getDaysInMonth(currentYear.value, currentMonth.value);

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
  }

  void previousMonth() {
    if (currentMonth.value == 1) {
      currentMonth.value = 12;
      currentYear.value -= 1;
    } else {
      currentMonth.value -= 1;
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