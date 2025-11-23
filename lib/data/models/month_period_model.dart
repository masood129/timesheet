class MonthPeriodModel {
  final int year;
  final int month;
  final int startDay;
  final int startMonth;
  final int endDay;
  final int endMonth;

  MonthPeriodModel({
    required this.year,
    required this.month,
    required this.startDay,
    required this.startMonth,
    required this.endDay,
    required this.endMonth,
  });

  factory MonthPeriodModel.fromJson(Map<String, dynamic> json) {
    return MonthPeriodModel(
      year: json['Year'] ?? json['year'],
      month: json['Month'] ?? json['month'],
      startDay: json['StartDay'] ?? json['startDay'],
      startMonth: json['StartMonth'] ?? json['startMonth'],
      endDay: json['EndDay'] ?? json['endDay'],
      endMonth: json['EndMonth'] ?? json['endMonth'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'Year': year,
      'Month': month,
      'StartDay': startDay,
      'StartMonth': startMonth,
      'EndDay': endDay,
      'EndMonth': endMonth,
    };
  }

  /// محاسبه تعداد روزهای این بازه
  int calculateDaysInPeriod(int currentYear) {
    if (startMonth == endMonth) {
      // بازه در همان ماه است
      return endDay - startDay + 1;
    } else {
      // بازه شامل چند ماه می‌شود
      // برای سادگی، فرض می‌کنیم فقط دو ماه متوالی است
      final daysInStartMonthRange =
          _getMonthLength(currentYear, startMonth) - startDay + 1;
      final daysInEndMonthRange = endDay;
      return daysInStartMonthRange + daysInEndMonthRange;
    }
  }

  /// محاسبه تعداد روزهای یک ماه شمسی
  int _getMonthLength(int year, int month) {
    if (month <= 6) {
      return 31;
    } else if (month <= 11) {
      return 30;
    } else {
      // اسفند - بررسی کبیسه
      final yearInCycle = year % 33;
      if ([1, 5, 9, 13, 17, 22, 26, 30].contains(yearInCycle)) {
        return 30;
      } else {
        return 29;
      }
    }
  }

  @override
  String toString() {
    return 'MonthPeriodModel(year: $year, month: $month, '
        'start: $startDay/$startMonth, end: $endDay/$endMonth)';
  }
}
