/// وضعیت یک روز در بازه ماهانه
enum DayPeriodStatus {
  /// روز عادی که در بازه ماه جاری قرار دارد
  normal,
  
  /// روز اضافه شده از ماه دیگر به این ماه (بنفش)
  added,
  
  /// روز حذف شده از این ماه که به ماه دیگر رفته (خاکستری و غیرفعال)
  removed,
}

extension DayPeriodStatusExtension on DayPeriodStatus {
  String get displayName {
    switch (this) {
      case DayPeriodStatus.normal:
        return 'عادی';
      case DayPeriodStatus.added:
        return 'اضافه شده';
      case DayPeriodStatus.removed:
        return 'حذف شده';
    }
  }
  
  String get description {
    switch (this) {
      case DayPeriodStatus.normal:
        return 'این روز در بازه ماه جاری قرار دارد';
      case DayPeriodStatus.added:
        return 'این روز از ماه دیگر به این ماه اضافه شده';
      case DayPeriodStatus.removed:
        return 'این روز از این ماه حذف و به ماه دیگر منتقل شده';
    }
  }
}

