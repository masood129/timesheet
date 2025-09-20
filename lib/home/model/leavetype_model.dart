// models/leave_type.dart
enum LeaveType {
  work,        // روز کاری عادی
  annualLeave, // مرخصی استحقاقی
  sickLeave,   // مرخصی استعلاجی
  giftLeave,   // مرخصی هدیه
  mission,
}

extension LeaveTypeExtension on LeaveType {
  String get displayName {
    switch (this) {
      case LeaveType.work: return 'کاری';
      case LeaveType.annualLeave: return 'استحقاقی';
      case LeaveType.sickLeave: return 'استعلاجی';
      case LeaveType.giftLeave: return 'هدیه';
      case LeaveType.mission: return 'ماموریت';
    }
  }

  // اگر نیاز به مقدار انگلیسی برای API دارید
  String get apiValue {
    switch (this) {
      case LeaveType.work: return 'work';
      case LeaveType.annualLeave: return 'annual_leave';
      case LeaveType.sickLeave: return 'sick_leave';
      case LeaveType.giftLeave: return 'gift_leave';
      case LeaveType.mission: return 'mission';
    }
  }

  // Parser برای تبدیل string از backend به enum (انگلیسی)
  static LeaveType? fromString(String? value) {
    switch (value) {
      case 'work': return LeaveType.work;
      case 'annual_leave': return LeaveType.annualLeave;
      case 'sick_leave': return LeaveType.sickLeave;
      case 'gift_leave': return LeaveType.giftLeave;
      case 'mission': return LeaveType.mission;
      default: return null;
    }
  }

  // جدید: Parser برای displayName (فارسی) – اگر field انگلیسی نداری
  static LeaveType? fromDisplayName(String? value) {
    switch (value) {
      case 'کاری': return LeaveType.work;
      case 'استحقاقی': return LeaveType.annualLeave;
      case 'استعلاجی': return LeaveType.sickLeave;
      case 'هدیه': return LeaveType.giftLeave;
      case 'ماموریت': return LeaveType.mission;
      default: return null;
    }
  }
}