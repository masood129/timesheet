import 'package:flutter_test/flutter_test.dart';
import 'package:timesheet/model/draft_report_model.dart';
import 'package:timesheet/model/leavetype_model.dart';

void main() {
  group('ProjectHours', () {
    test('fromJson creates ProjectHours correctly', () {
      // Arrange
      final json = {'ProjectID': 5, 'TotalHours': 120};

      // Act
      final projectHours = ProjectHours.fromJson(json);

      // Assert
      expect(projectHours.projectId, 5);
      expect(projectHours.totalHours, 120);
    });

    test('fromJson handles lowercase field names', () {
      // Arrange
      final json = {'projectId': 3, 'totalHours': 80};

      // Act
      final projectHours = ProjectHours.fromJson(json);

      // Assert
      expect(projectHours.projectId, 3);
      expect(projectHours.totalHours, 80);
    });

    test('toJson converts ProjectHours correctly', () {
      // Arrange
      final projectHours = ProjectHours(projectId: 7, totalHours: 150);

      // Act
      final json = projectHours.toJson();

      // Assert
      expect(json['ProjectID'], 7);
      expect(json['TotalHours'], 150);
    });
  });

  group('ProjectCarCost', () {
    test('fromJson creates ProjectCarCost correctly', () {
      // Arrange
      final json = {'ProjectID': 5, 'TotalCost': 50000};

      // Act
      final carCost = ProjectCarCost.fromJson(json);

      // Assert
      expect(carCost.projectId, 5);
      expect(carCost.cost, 50000);
    });

    test('fromJson handles lowercase field names', () {
      // Arrange
      final json = {'projectId': 3, 'cost': 30000};

      // Act
      final carCost = ProjectCarCost.fromJson(json);

      // Assert
      expect(carCost.projectId, 3);
      expect(carCost.cost, 30000);
    });

    test('toJson converts ProjectCarCost correctly', () {
      // Arrange
      final carCost = ProjectCarCost(projectId: 7, cost: 70000);

      // Act
      final json = carCost.toJson();

      // Assert
      expect(json['ProjectID'], 7);
      expect(json['TotalCost'], 70000);
    });
  });

  group('DraftReportModel', () {
    test('fromJson creates DraftReportModel with all fields', () {
      // Arrange
      final json = {
        'ReportId': 1,
        'UserId': 10,
        'Year': 2024,
        'Month': 1,
        'TotalHours': 160,
        'GymCost': 50000,
        'Status': 'draft',
        'GroupId': 5,
        'GeneralManagerStatus': 'pending',
        'ManagerComment': 'Review needed',
        'FinanceComment': 'Pending',
        'SubmittedAt': '2024-01-31T10:00:00',
        'ApprovedAt': '2024-02-01T14:00:00',
        'JalaliYear': 1402,
        'JalaliMonth': 11,
        'Username': 'test_user',
        'GroupName': 'Engineering',
        'ManagerUsername': 'manager1',
        'totalCommuteCost': 100000,
        'personalCarCostsByProject': [
          {'ProjectID': 5, 'TotalCost': 50000},
        ],
        'projectHoursByProject': [
          {'ProjectID': 5, 'TotalHours': 120},
        ],
        'leaveTypesCount': {'work': 20, 'annual_leave': 2},
      };

      // Act
      final draft = DraftReportModel.fromJson(json);

      // Assert
      expect(draft.reportId, 1);
      expect(draft.userId, 10);
      expect(draft.year, 2024);
      expect(draft.month, 1);
      expect(draft.totalHours, 160);
      expect(draft.gymCost, 50000);
      expect(draft.status, 'draft');
      expect(draft.groupId, 5);
      expect(draft.username, 'test_user');
      expect(draft.totalCommuteCost, 100000);
      expect(draft.personalCarCostsByProject?.length, 1);
      expect(draft.projectHoursByProject?.length, 1);
      expect(draft.leaveTypesCount?.length, 2);
      expect(draft.leaveTypesCount?[LeaveType.work], 20);
      expect(draft.leaveTypesCount?[LeaveType.annualLeave], 2);
    });

    test('fromJson handles null optional fields', () {
      // Arrange
      final json = {'ReportId': 2, 'UserId': 20};

      // Act
      final draft = DraftReportModel.fromJson(json);

      // Assert
      expect(draft.reportId, 2);
      expect(draft.userId, 20);
      expect(draft.year, isNull);
      expect(draft.personalCarCostsByProject, isNull);
      expect(draft.projectHoursByProject, isNull);
      expect(draft.leaveTypesCount, isNull);
    });

    test('toJson converts DraftReportModel correctly', () {
      // Arrange
      final draft = DraftReportModel(
        reportId: 5,
        userId: 50,
        year: 2024,
        month: 5,
        totalHours: 170,
        gymCost: 60000,
        status: 'submitted',
        leaveTypesCount: {
          LeaveType.work: 18,
          LeaveType.sickLeave: 1,
          LeaveType.mission: 1,
        },
      );

      // Act
      final json = draft.toJson();

      // Assert
      expect(json['ReportId'], 5);
      expect(json['UserId'], 50);
      expect(json['Year'], 2024);
      expect(json['Month'], 5);
      expect(json['TotalHours'], 170);
      expect(json['GymCost'], 60000);
      expect(json['Status'], 'submitted');
      expect(json['leaveTypesCount'], isA<Map>());
      expect(json['leaveTypesCount']['work'], 18);
      expect(json['leaveTypesCount']['sick_leave'], 1);
      expect(json['leaveTypesCount']['mission'], 1);
    });

    test('leaveTypesCount conversion works correctly', () {
      // Arrange
      final json = {
        'ReportId': 3,
        'leaveTypesCount': {
          'work': 15,
          'annual_leave': 3,
          'sick_leave': 1,
          'gift_leave': 1,
        },
      };

      // Act
      final draft = DraftReportModel.fromJson(json);
      final resultJson = draft.toJson();

      // Assert
      expect(draft.leaveTypesCount?[LeaveType.work], 15);
      expect(draft.leaveTypesCount?[LeaveType.annualLeave], 3);
      expect(draft.leaveTypesCount?[LeaveType.sickLeave], 1);
      expect(draft.leaveTypesCount?[LeaveType.giftLeave], 1);
      expect(resultJson['leaveTypesCount']['work'], 15);
      expect(resultJson['leaveTypesCount']['annual_leave'], 3);
    });

    test('DateTime parsing works correctly', () {
      // Arrange
      final json = {
        'ReportId': 4,
        'SubmittedAt': '2024-06-15T12:30:45',
        'ApprovedAt': '2024-06-16T14:20:30',
      };

      // Act
      final draft = DraftReportModel.fromJson(json);

      // Assert
      expect(draft.submittedAt, isA<DateTime>());
      expect(draft.approvedAt, isA<DateTime>());
    });
  });
}
