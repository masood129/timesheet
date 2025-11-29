import 'package:shamsi_date/shamsi_date.dart';

class MonthPeriodModel {
  final int year;
  final int month;
  final int startDay;
  final int startMonth;
  final int startYear;
  final int endDay;
  final int endMonth;
  final int endYear;

  MonthPeriodModel({
    required this.year,
    required this.month,
    required this.startDay,
    required this.startMonth,
    required this.startYear,
    required this.endDay,
    required this.endMonth,
    required this.endYear,
  });

  factory MonthPeriodModel.fromJson(Map<String, dynamic> json) {
    final periodYear = json['Year'] ?? json['year'];
    return MonthPeriodModel(
      year: periodYear,
      month: json['Month'] ?? json['month'],
      startDay: json['StartDay'] ?? json['startDay'],
      startMonth: json['StartMonth'] ?? json['startMonth'],
      startYear: json['StartYear'] ?? json['startYear'] ?? periodYear,
      endDay: json['EndDay'] ?? json['endDay'],
      endMonth: json['EndMonth'] ?? json['endMonth'],
      endYear: json['EndYear'] ?? json['endYear'] ?? periodYear,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'Year': year,
      'Month': month,
      'StartDay': startDay,
      'StartMonth': startMonth,
      'StartYear': startYear,
      'EndDay': endDay,
      'EndMonth': endMonth,
      'EndYear': endYear,
    };
  }

  /// محاسبه تعداد روزهای این بازه
  int calculateDaysInPeriod(int currentYear) {
    return getDaysInPeriod().length;
  }

  /// دریافت لیست تمام روزهای این بازه
  List<Jalali> getDaysInPeriod() {
    List<Jalali> days = [];
    
    // شروع از تاریخ شروع
    Jalali currentDate = Jalali(startYear, startMonth, startDay);
    
    // پایان در تاریخ پایان
    Jalali endDate = Jalali(endYear, endMonth, endDay);
    
    // تولید تمام روزها
    while (currentDate.compareTo(endDate) <= 0) {
      days.add(Jalali(currentDate.year, currentDate.month, currentDate.day));
      
      // حرکت به روز بعد
      if (currentDate.day < currentDate.monthLength) {
        currentDate = Jalali(currentDate.year, currentDate.month, currentDate.day + 1);
      } else {
        // حرکت به ماه بعد
        if (currentDate.month < 12) {
          currentDate = Jalali(currentDate.year, currentDate.month + 1, 1);
        } else {
          // حرکت به سال بعد
          currentDate = Jalali(currentDate.year + 1, 1, 1);
        }
      }
    }
    
    return days;
  }

  @override
  String toString() {
    return 'MonthPeriodModel(year: $year, month: $month, '
        'start: $startDay/$startMonth/$startYear, end: $endDay/$endMonth/$endYear)';
  }
}
