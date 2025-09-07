// models/leave_type.dart (فایل جدید برای enum)
enum LeaveType {
  work,        // روز کاری عادی
  annualLeave, // مرخصی استحقاقی
  sickLeave,   // مرخصی استعلاجی
  giftLeave,   // مرخصی هدیه
}

extension LeaveTypeExtension on LeaveType {
  String get displayName {
    switch (this) {
      case LeaveType.work: return 'کاری';
      case LeaveType.annualLeave: return 'استحقاقی';
      case LeaveType.sickLeave: return 'استعلاجی';
      case LeaveType.giftLeave: return 'هدیه';
    }
  }

  // اگر نیاز به مقدار انگلیسی برای API دارید
  String get apiValue {
    switch (this) {
      case LeaveType.work: return 'work';
      case LeaveType.annualLeave: return 'annual_leave';
      case LeaveType.sickLeave: return 'sick_leave';
      case LeaveType.giftLeave: return 'gift_leave';
    }
  }

  // Parser برای تبدیل string از backend به enum
  static LeaveType? fromString(String? value) {
    switch (value) {
      case 'work': return LeaveType.work;
      case 'annual_leave': return LeaveType.annualLeave;
      case 'sick_leave': return LeaveType.sickLeave;
      case 'gift_leave': return LeaveType.giftLeave;
      default: return null;
    }
  }
}