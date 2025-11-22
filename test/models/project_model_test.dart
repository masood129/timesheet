import 'package:flutter_test/flutter_test.dart';
import 'package:timesheet/model/project_model.dart';

void main() {
  group('Project Model', () {
    test('fromJson creates Project correctly', () {
      // Arrange
      final json = {'Id': 1, 'ProjectName': 'Test Project', 'securityLevel': 2};

      // Act
      final project = Project.fromJson(json);

      // Assert
      expect(project.id, 1);
      expect(project.projectName, 'Test Project');
      expect(project.securityLevel, 2);
    });

    test('toJson converts Project to JSON correctly', () {
      // Arrange
      final project = Project(
        id: 5,
        projectName: 'Sample Project',
        securityLevel: 3,
      );

      // Act
      final json = project.toJson();

      // Assert
      expect(json['Id'], 5);
      expect(json['ProjectName'], 'Sample Project');
      expect(json['securityLevel'], 3);
    });

    test('Project with different security levels', () {
      // Test security level 0
      final project0 = Project(
        id: 1,
        projectName: 'Public Project',
        securityLevel: 0,
      );
      expect(project0.securityLevel, 0);

      // Test security level 5
      final project5 = Project(
        id: 2,
        projectName: 'Top Secret Project',
        securityLevel: 5,
      );
      expect(project5.securityLevel, 5);
    });

    test('fromJson and toJson round trip', () {
      // Arrange
      final originalJson = {
        'Id': 10,
        'ProjectName': 'Round Trip Project',
        'securityLevel': 4,
      };

      // Act
      final project = Project.fromJson(originalJson);
      final resultJson = project.toJson();

      // Assert
      expect(resultJson['Id'], originalJson['Id']);
      expect(resultJson['ProjectName'], originalJson['ProjectName']);
      expect(resultJson['securityLevel'], originalJson['securityLevel']);
    });

    test('Project constructor works correctly', () {
      // Act
      final project = Project(
        id: 99,
        projectName: 'Direct Construction',
        securityLevel: 1,
      );

      // Assert
      expect(project.id, 99);
      expect(project.projectName, 'Direct Construction');
      expect(project.securityLevel, 1);
    });

    test('Project with Persian project name', () {
      // Arrange
      final json = {'Id': 7, 'ProjectName': 'پروژه تست', 'securityLevel': 2};

      // Act
      final project = Project.fromJson(json);

      // Assert
      expect(project.projectName, 'پروژه تست');
    });
  });
}
