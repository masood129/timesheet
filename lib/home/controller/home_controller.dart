import 'package:get/get.dart';
import 'package:shamsi_date/shamsi_date.dart';
import '../model/home_model.dart';
import '../model/task_model.dart';

class CalendarController extends GetxController {
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
  final List<Project> availableProjects = [
    Project(code: 'PRJ001', name: 'سامانه حضور و غیاب'),
    Project(code: 'PRJ002', name: 'اپلیکیشن تقویم شمسی'),
    Project(code: 'PRJ003', name: 'داشبورد مدیریت پروژه'),
  ];

}
