import 'package:get/get.dart';
import 'package:shamsi_date/shamsi_date.dart';

class CalendarController extends GetxController {
  var notes = <String, String>{}.obs;
  var currentMonth = Jalali.now().month.obs;
  var currentYear = Jalali.now().year.obs;

  int get daysInMonth => Jalali(currentYear.value, currentMonth.value).monthLength;

  String formatDate(Jalali date) =>
      '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';

  void setNoteForDate(Jalali date, String note) {
    notes[formatDate(date)] = note;
  }

  String? getNoteForDate(Jalali date) {
    return notes[formatDate(date)];
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
