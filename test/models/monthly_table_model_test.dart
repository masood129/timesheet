import 'package:flutter_test/flutter_test.dart';
import 'package:timesheet/model/monthly_table_model.dart';

void main() {
  group('MonthlyTableRowModel', () {
    test('fromJson creates MonthlyTableRowModel correctly', () {
      // Arrange
      final json = {
        'dayOfWeek': 'شنبه',
        'date': '1402/11/15',
        'arrivalTime': '08:30',
        'leaveTime': '17:00',
        'personalTime': 30,
        'leaveType': 'work',
        'projects': [
          {'projectId': 5, 'duration': 120, 'description': 'Task description'},
        ],
        'totalDailyWork': 480,
        'entryDelay': 15,
        'description': 'Daily note',
      };

      // Act
      final row = MonthlyTableRowModel.fromJson(json);

      // Assert
      expect(row.dayOfWeek, 'شنبه');
      expect(row.date, '1402/11/15');
      expect(row.arrivalTime, '08:30');
      expect(row.leaveTime, '17:00');
      expect(row.personalTime, 30);
      expect(row.leaveType, 'work');
      expect(row.projects.length, 1);
      expect(row.totalDailyWork, 480);
      expect(row.entryDelay, 15);
      expect(row.description, 'Daily note');
    });

    test('fromJson handles missing optional fields', () {
      // Arrange
      final json = {
        'dayOfWeek': 'یکشنبه',
        'date': '1402/11/16',
        'personalTime': 0,
        'projects': [],
        'totalDailyWork': 0,
        'entryDelay': 0,
      };

      // Act
      final row = MonthlyTableRowModel.fromJson(json);

      // Assert
      expect(row.dayOfWeek, 'یکشنبه');
      expect(row.date, '1402/11/16');
      expect(row.arrivalTime, isNull);
      expect(row.leaveTime, isNull);
      expect(row.leaveType, isNull);
      expect(row.description, isNull);
      expect(row.projects, isEmpty);
    });

    test('fromJson uses default values for missing fields', () {
      // Arrange
      final json = <String, dynamic>{};

      // Act
      final row = MonthlyTableRowModel.fromJson(json);

      // Assert
      expect(row.dayOfWeek, '-');
      expect(row.date, '-');
      expect(row.personalTime, 0);
      expect(row.totalDailyWork, 0);
      expect(row.entryDelay, 0);
      expect(row.projects, isEmpty);
    });

    test('fromJson parses multiple projects', () {
      // Arrange
      final json = {
        'dayOfWeek': 'دوشنبه',
        'date': '1402/11/17',
        'personalTime': 0,
        'projects': [
          {'projectId': 1, 'duration': 120, 'description': 'Project 1'},
          {'projectId': 2, 'duration': 180, 'description': 'Project 2'},
          {'projectId': 3, 'duration': 60},
        ],
        'totalDailyWork': 360,
        'entryDelay': 0,
      };

      // Act
      final row = MonthlyTableRowModel.fromJson(json);

      // Assert
      expect(row.projects.length, 3);
      expect(row.projects[0].projectId, 1);
      expect(row.projects[1].projectId, 2);
      expect(row.projects[2].projectId, 3);
    });
  });

  group('ProjectEntry', () {
    test('fromJson creates ProjectEntry correctly', () {
      // Arrange
      final json = {
        'projectId': 5,
        'duration': 120,
        'description': 'Test project entry',
      };

      // Act
      final entry = ProjectEntry.fromJson(json);

      // Assert
      expect(entry.projectId, 5);
      expect(entry.duration, 120);
      expect(entry.description, 'Test project entry');
    });

    test('fromJson handles null description', () {
      // Arrange
      final json = {'projectId': 3, 'duration': 90};

      // Act
      final entry = ProjectEntry.fromJson(json);

      // Assert
      expect(entry.projectId, 3);
      expect(entry.duration, 90);
      expect(entry.description, isNull);
    });

    test('fromJson uses default values', () {
      // Arrange
      final json = <String, dynamic>{};

      // Act
      final entry = ProjectEntry.fromJson(json);

      // Assert
      expect(entry.projectId, 0);
      expect(entry.duration, 0);
      expect(entry.description, isNull);
    });

    test('constructor works correctly', () {
      // Act
      final entry = ProjectEntry(
        projectId: 10,
        duration: 150,
        description: 'Direct construction',
      );

      // Assert
      expect(entry.projectId, 10);
      expect(entry.duration, 150);
      expect(entry.description, 'Direct construction');
    });
  });
}
