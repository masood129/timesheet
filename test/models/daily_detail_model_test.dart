import 'package:flutter_test/flutter_test.dart';
import 'package:timesheet/model/daily_detail_model.dart';
import 'package:timesheet/model/leavetype_model.dart';
import 'package:timesheet/model/task_model.dart';
import 'package:timesheet/model/personal_car_cost_model.dart';

void main() {
  group('DailyDetail Model', () {
    test('fromJson creates DailyDetail correctly with all fields', () {
      // Arrange
      final json = {
        'Date': '2024-01-15T00:00:00',
        'UserId': 10,
        'ArrivalTime': '2024-01-15T08:30:00',
        'LeaveTime': '2024-01-15T17:00:00',
        'LeaveType': 'work',
        'PersonalTime': 30,
        'Description': 'Regular work day',
        'GoCost': 5000,
        'ReturnCost': 5000,
        'tasks': [
          {'Id': 1, 'ProjectId': 5, 'Duration': 120, 'Description': 'Task 1'},
        ],
        'personalCarCosts': [
          {'ProjectId': 5, 'Kilometers': 50, 'Cost': 25000},
        ],
      };

      // Act
      final dailyDetail = DailyDetail.fromJson(json);

      // Assert
      expect(dailyDetail.date, '2024-01-15');
      expect(dailyDetail.userId, 10);
      expect(dailyDetail.arrivalTime, '08:30:00');
      expect(dailyDetail.leaveTime, '17:00:00');
      expect(dailyDetail.leaveType, LeaveType.work);
      expect(dailyDetail.personalTime, 30);
      expect(dailyDetail.description, 'Regular work day');
      expect(dailyDetail.goCost, 5000);
      expect(dailyDetail.returnCost, 5000);
      expect(dailyDetail.tasks.length, 1);
      expect(dailyDetail.personalCarCosts.length, 1);
    });

    test('fromJson handles null optional fields', () {
      // Arrange
      final json = {'Date': '2024-01-15T00:00:00', 'UserId': 10};

      // Act
      final dailyDetail = DailyDetail.fromJson(json);

      // Assert
      expect(dailyDetail.date, '2024-01-15');
      expect(dailyDetail.userId, 10);
      expect(dailyDetail.arrivalTime, isNull);
      expect(dailyDetail.leaveTime, isNull);
      expect(dailyDetail.leaveType, isNull);
      expect(dailyDetail.personalTime, isNull);
      expect(dailyDetail.description, isNull);
      expect(dailyDetail.goCost, isNull);
      expect(dailyDetail.returnCost, isNull);
      expect(dailyDetail.tasks, isEmpty);
      expect(dailyDetail.personalCarCosts, isEmpty);
    });

    test('fromJson parses different leave types correctly', () {
      final leaveTypes = [
        'work',
        'annual_leave',
        'sick_leave',
        'gift_leave',
        'mission',
      ];
      final expectedTypes = [
        LeaveType.work,
        LeaveType.annualLeave,
        LeaveType.sickLeave,
        LeaveType.giftLeave,
        LeaveType.mission,
      ];

      for (var i = 0; i < leaveTypes.length; i++) {
        final json = {
          'Date': '2024-01-15T00:00:00',
          'UserId': 10,
          'LeaveType': leaveTypes[i],
        };

        final dailyDetail = DailyDetail.fromJson(json);
        expect(dailyDetail.leaveType, expectedTypes[i]);
      }
    });

    test('toJson converts DailyDetail to JSON correctly', () {
      // Arrange
      final dailyDetail = DailyDetail(
        date: '2024-01-15',
        userId: 10,
        arrivalTime: '08:30:00',
        leaveTime: '17:00:00',
        personalTime: 30,
        description: 'Test day',
        goCost: 5000,
        returnCost: 5000,
        leaveTypeString: 'work',
        tasks: [Task(projectId: 5, duration: 120, description: 'Task 1')],
        personalCarCosts: [
          PersonalCarCost(projectId: 5, kilometers: 50, cost: 25000),
        ],
      );

      // Act
      final json = dailyDetail.toJson();

      // Assert
      expect(json['date'], '2024-01-15T00:00:00.000Z');
      expect(json['userId'], 10);
      expect(json['arrivalTime'], '08:30:00');
      expect(json['leaveTime'], '17:00:00');
      expect(json['leaveType'], 'work');
      expect(json['personalTime'], 30);
      expect(json['description'], 'Test day');
      expect(json['goCost'], 5000);
      expect(json['returnCost'], 5000);
      expect(json['tasks'], isA<List>());
      expect(json['personalCarCosts'], isA<List>());
    });

    test('fromJson parses time correctly', () {
      // Arrange
      final json = {
        'Date': '2024-01-15T00:00:00.000Z',
        'UserId': 10,
        'ArrivalTime': '2024-01-15T09:15:30',
        'LeaveTime': '2024-01-15T18:45:20',
      };

      // Act
      final dailyDetail = DailyDetail.fromJson(json);

      // Assert
      expect(dailyDetail.arrivalTime, '09:15:30');
      expect(dailyDetail.leaveTime, '18:45:20');
    });

    test('constructor with default empty lists', () {
      // Act
      final dailyDetail = DailyDetail(date: '2024-01-15', userId: 10);

      // Assert
      expect(dailyDetail.tasks, isEmpty);
      expect(dailyDetail.personalCarCosts, isEmpty);
    });
  });
}
