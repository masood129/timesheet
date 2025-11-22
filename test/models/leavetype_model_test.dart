import 'package:flutter_test/flutter_test.dart';
import 'package:timesheet/model/leavetype_model.dart';

void main() {
  group('LeaveType Enum', () {
    test('LeaveType has all expected values', () {
      expect(LeaveType.values.length, 5);
      expect(LeaveType.values, contains(LeaveType.work));
      expect(LeaveType.values, contains(LeaveType.annualLeave));
      expect(LeaveType.values, contains(LeaveType.sickLeave));
      expect(LeaveType.values, contains(LeaveType.giftLeave));
      expect(LeaveType.values, contains(LeaveType.mission));
    });

    group('displayName', () {
      test('returns correct Persian display names', () {
        expect(LeaveType.work.displayName, 'کاری');
        expect(LeaveType.annualLeave.displayName, 'استحقاقی');
        expect(LeaveType.sickLeave.displayName, 'استعلاجی');
        expect(LeaveType.giftLeave.displayName, 'هدیه');
        expect(LeaveType.mission.displayName, 'ماموریت');
      });
    });

    group('apiValue', () {
      test('returns correct API values', () {
        expect(LeaveType.work.apiValue, 'work');
        expect(LeaveType.annualLeave.apiValue, 'annual_leave');
        expect(LeaveType.sickLeave.apiValue, 'sick_leave');
        expect(LeaveType.giftLeave.apiValue, 'gift_leave');
        expect(LeaveType.mission.apiValue, 'mission');
      });
    });

    group('fromString', () {
      test('converts valid API strings to LeaveType', () {
        expect(LeaveTypeExtension.fromString('work'), LeaveType.work);
        expect(
          LeaveTypeExtension.fromString('annual_leave'),
          LeaveType.annualLeave,
        );
        expect(
          LeaveTypeExtension.fromString('sick_leave'),
          LeaveType.sickLeave,
        );
        expect(
          LeaveTypeExtension.fromString('gift_leave'),
          LeaveType.giftLeave,
        );
        expect(LeaveTypeExtension.fromString('mission'), LeaveType.mission);
      });

      test('returns null for invalid strings', () {
        expect(LeaveTypeExtension.fromString('invalid'), isNull);
        expect(LeaveTypeExtension.fromString(''), isNull);
        expect(LeaveTypeExtension.fromString(null), isNull);
      });

      test('is case sensitive', () {
        expect(LeaveTypeExtension.fromString('Work'), isNull);
        expect(LeaveTypeExtension.fromString('WORK'), isNull);
      });
    });

    group('fromDisplayName', () {
      test('converts valid Persian display names to LeaveType', () {
        expect(LeaveTypeExtension.fromDisplayName('کاری'), LeaveType.work);
        expect(
          LeaveTypeExtension.fromDisplayName('استحقاقی'),
          LeaveType.annualLeave,
        );
        expect(
          LeaveTypeExtension.fromDisplayName('استعلاجی'),
          LeaveType.sickLeave,
        );
        expect(LeaveTypeExtension.fromDisplayName('هدیه'), LeaveType.giftLeave);
        expect(
          LeaveTypeExtension.fromDisplayName('ماموریت'),
          LeaveType.mission,
        );
      });

      test('returns null for invalid display names', () {
        expect(LeaveTypeExtension.fromDisplayName('نامعتبر'), isNull);
        expect(LeaveTypeExtension.fromDisplayName(''), isNull);
        expect(LeaveTypeExtension.fromDisplayName(null), isNull);
      });
    });

    group('Round trip conversions', () {
      test('apiValue to fromString round trip', () {
        for (var leaveType in LeaveType.values) {
          final apiValue = leaveType.apiValue;
          final converted = LeaveTypeExtension.fromString(apiValue);
          expect(converted, leaveType);
        }
      });

      test('displayName to fromDisplayName round trip', () {
        for (var leaveType in LeaveType.values) {
          final displayName = leaveType.displayName;
          final converted = LeaveTypeExtension.fromDisplayName(displayName);
          expect(converted, leaveType);
        }
      });
    });
  });
}
