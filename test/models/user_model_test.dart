import 'package:flutter_test/flutter_test.dart';
import 'package:timesheet/model/user_model.dart';

void main() {
  group('UserModel', () {
    test('fromJson creates UserModel correctly', () {
      // Arrange
      final json = {'UserId': 1, 'Username': 'test_user', 'Role': 'engineer'};

      // Act
      final user = UserModel.fromJson(json);

      // Assert
      expect(user.userId, 1);
      expect(user.username, 'test_user');
      expect(user.role, 'engineer');
    });

    test('fromJson handles different user roles', () {
      // Arrange
      final managerJson = {
        'UserId': 2,
        'Username': 'manager_user',
        'Role': 'manager',
      };

      // Act
      final manager = UserModel.fromJson(managerJson);

      // Assert
      expect(manager.userId, 2);
      expect(manager.username, 'manager_user');
      expect(manager.role, 'manager');
    });

    test('UserModel constructor works correctly', () {
      // Act
      final user = UserModel(userId: 3, username: 'direct_user', role: 'admin');

      // Assert
      expect(user.userId, 3);
      expect(user.username, 'direct_user');
      expect(user.role, 'admin');
    });

    test('fromJson with integer types', () {
      // Arrange
      final json = {'UserId': 100, 'Username': 'user100', 'Role': 'developer'};

      // Act
      final user = UserModel.fromJson(json);

      // Assert
      expect(user.userId, isA<int>());
      expect(user.username, isA<String>());
      expect(user.role, isA<String>());
    });
  });
}
