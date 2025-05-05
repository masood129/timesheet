import 'package:shamsi_date/shamsi_date.dart';

class CalendarModel {
  var notes = <String, String>{};

  int getDaysInMonth(int year, int month) {
    return Jalali(year, month).monthLength;
  }

  String formatDate(Jalali date) {
    return '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
  }

  void setNoteForDate(Jalali date, String note) {
    notes[formatDate(date)] = note;
  }

  String? getNoteForDate(Jalali date) {
    return notes[formatDate(date)];
  }
}
