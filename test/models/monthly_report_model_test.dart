import 'package:flutter_test/flutter_test.dart';
import 'package:timesheet/model/monthly_report_model.dart';

void main() {
  group('MonthlyReport Model', () {
    test('fromJson creates MonthlyReport correctly with all fields', () {
      // Arrange
      final json = {
        'ReportId': 1,
        'UserId': 10,
        'Year': 2024,
        'Month': 1,
        'TotalHours': 160,
        'GymCost': 50000,
        'Status': 'submitted',
        'GroupId': 5,
        'GeneralManagerStatus': 'approved',
        'ManagerComment': 'Good work',
        'FinanceComment': 'Approved',
        'SubmittedAt': '2024-01-31T10:00:00',
        'ApprovedAt': '2024-02-01T14:00:00',
        'JalaliYear': 1402,
        'JalaliMonth': 11,
        'Username': 'test_user',
      };

      // Act
      final report = MonthlyReport.fromJson(json);

      // Assert
      expect(report.reportId, 1);
      expect(report.userId, 10);
      expect(report.year, 2024);
      expect(report.month, 1);
      expect(report.totalHours, 160);
      expect(report.gymCost, 50000);
      expect(report.status, 'submitted');
      expect(report.groupId, 5);
      expect(report.generalManagerStatus, 'approved');
      expect(report.managerComment, 'Good work');
      expect(report.financeComment, 'Approved');
      expect(report.submittedAt, isA<DateTime>());
      expect(report.approvedAt, isA<DateTime>());
      expect(report.jalaliYear, 1402);
      expect(report.jalaliMonth, 11);
      expect(report.username, 'test_user');
    });

    test('fromJson handles lowercase field names', () {
      // Arrange
      final json = {
        'reportId': 2,
        'userId': 20,
        'year': 2024,
        'month': 2,
        'totalHours': 150,
        'gymCost': 40000,
        'status': 'draft',
        'groupId': 3,
        'generalManagerStatus': 'pending',
        'managerComment': 'Review needed',
        'financeComment': 'Pending',
        'jalaliYear': 1402,
        'jalaliMonth': 12,
        'username': 'user2',
      };

      // Act
      final report = MonthlyReport.fromJson(json);

      // Assert
      expect(report.reportId, 2);
      expect(report.userId, 20);
      expect(report.year, 2024);
      expect(report.month, 2);
    });

    test('fromJson handles null DateTime fields', () {
      // Arrange
      final json = {'ReportId': 3, 'UserId': 30, 'Year': 2024, 'Month': 3};

      // Act
      final report = MonthlyReport.fromJson(json);

      // Assert
      expect(report.submittedAt, isNull);
      expect(report.approvedAt, isNull);
    });

    test('toJson converts MonthlyReport to JSON correctly', () {
      // Arrange
      final report = MonthlyReport(
        reportId: 5,
        userId: 50,
        year: 2024,
        month: 5,
        totalHours: 170,
        gymCost: 60000,
        status: 'approved',
        groupId: 7,
        generalManagerStatus: 'approved',
        managerComment: 'Excellent',
        financeComment: 'Paid',
        submittedAt: DateTime(2024, 5, 31, 10, 0),
        approvedAt: DateTime(2024, 6, 1, 14, 0),
        jalaliYear: 1403,
        jalaliMonth: 3,
        username: 'user5',
      );

      // Act
      final json = report.toJson();

      // Assert
      expect(json['ReportId'], 5);
      expect(json['UserId'], 50);
      expect(json['Year'], 2024);
      expect(json['Month'], 5);
      expect(json['TotalHours'], 170);
      expect(json['GymCost'], 60000);
      expect(json['Status'], 'approved');
      expect(json['GroupId'], 7);
      expect(json['GeneralManagerStatus'], 'approved');
      expect(json['ManagerComment'], 'Excellent');
      expect(json['FinanceComment'], 'Paid');
      expect(json['SubmittedAt'], isA<String>());
      expect(json['ApprovedAt'], isA<String>());
      expect(json['JalaliYear'], 1403);
      expect(json['JalaliMonth'], 3);
      expect(json['Username'], 'user5');
    });

    test('round trip conversion', () {
      // Arrange
      final originalJson = {
        'ReportId': 10,
        'UserId': 100,
        'Year': 2024,
        'Month': 10,
        'TotalHours': 180,
        'GymCost': 70000,
        'Status': 'finalized',
        'JalaliYear': 1403,
        'JalaliMonth': 7,
        'Username': 'user10',
      };

      // Act
      final report = MonthlyReport.fromJson(originalJson);
      final resultJson = report.toJson();

      // Assert
      expect(resultJson['ReportId'], originalJson['ReportId']);
      expect(resultJson['UserId'], originalJson['UserId']);
      expect(resultJson['Year'], originalJson['Year']);
      expect(resultJson['Month'], originalJson['Month']);
      expect(resultJson['TotalHours'], originalJson['TotalHours']);
    });

    test('DateTime parsing and serialization', () {
      // Arrange
      final dateTimeString = '2024-06-15T12:30:45';
      final json = {'ReportId': 7, 'UserId': 70, 'SubmittedAt': dateTimeString};

      // Act
      final report = MonthlyReport.fromJson(json);
      final resultJson = report.toJson();

      // Assert
      expect(report.submittedAt, isNotNull);
      expect(resultJson['SubmittedAt'], contains('2024-06-15'));
    });
  });
}
