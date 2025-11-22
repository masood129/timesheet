import 'package:flutter_test/flutter_test.dart';
import 'package:timesheet/model/task_model.dart';

void main() {
  group('Task Model', () {
    test('fromJson creates Task correctly with all fields', () {
      // Arrange
      final json = {
        'Id': 1,
        'Date': '2024-01-15',
        'UserId': 10,
        'ProjectId': 5,
        'Duration': 120,
        'Description': 'Test task description',
      };

      // Act
      final task = Task.fromJson(json);

      // Assert
      expect(task.id, 1);
      expect(task.date, '2024-01-15');
      expect(task.userId, 10);
      expect(task.projectId, 5);
      expect(task.duration, 120);
      expect(task.description, 'Test task description');
    });

    test('fromJson handles null optional fields', () {
      // Arrange
      final json = {'ProjectId': 5};

      // Act
      final task = Task.fromJson(json);

      // Assert
      expect(task.id, isNull);
      expect(task.date, isNull);
      expect(task.userId, isNull);
      expect(task.projectId, 5);
      expect(task.duration, isNull);
      expect(task.description, isNull);
    });

    test('toJson converts Task to JSON correctly', () {
      // Arrange
      final task = Task(projectId: 3, duration: 90, description: 'Sample task');

      // Act
      final json = task.toJson();

      // Assert
      expect(json['projectId'], 3);
      expect(json['duration'], 90);
      expect(json['description'], 'Sample task');
      expect(json.containsKey('id'), false);
      expect(json.containsKey('date'), false);
      expect(json.containsKey('userId'), false);
    });

    test('Task constructor with only required field', () {
      // Act
      final task = Task(projectId: 7);

      // Assert
      expect(task.projectId, 7);
      expect(task.id, isNull);
      expect(task.date, isNull);
      expect(task.userId, isNull);
      expect(task.duration, isNull);
      expect(task.description, isNull);
    });

    test('Task constructor with all fields', () {
      // Act
      final task = Task(
        id: 2,
        date: '2024-02-20',
        userId: 15,
        projectId: 8,
        duration: 180,
        description: 'Complete task',
      );

      // Assert
      expect(task.id, 2);
      expect(task.date, '2024-02-20');
      expect(task.userId, 15);
      expect(task.projectId, 8);
      expect(task.duration, 180);
      expect(task.description, 'Complete task');
    });

    test('toJson with null values', () {
      // Arrange
      final task = Task(projectId: 1);

      // Act
      final json = task.toJson();

      // Assert
      expect(json['projectId'], 1);
      expect(json['duration'], isNull);
      expect(json['description'], isNull);
    });
  });
}
