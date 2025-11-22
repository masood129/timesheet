import 'package:flutter_test/flutter_test.dart';
import 'package:timesheet/model/personal_car_cost_model.dart';

void main() {
  group('PersonalCarCost Model', () {
    test('fromJson creates PersonalCarCost correctly', () {
      // Arrange
      final json = {
        'ProjectId': 5,
        'Kilometers': 100,
        'Cost': 50000,
        'Description': 'Trip to client site',
      };

      // Act
      final carCost = PersonalCarCost.fromJson(json);

      // Assert
      expect(carCost.projectId, 5);
      expect(carCost.kilometers, 100);
      expect(carCost.cost, 50000);
      expect(carCost.description, 'Trip to client site');
    });

    test('fromJson handles null fields', () {
      // Arrange
      final json = <String, dynamic>{};

      // Act
      final carCost = PersonalCarCost.fromJson(json);

      // Assert
      expect(carCost.projectId, isNull);
      expect(carCost.kilometers, isNull);
      expect(carCost.cost, isNull);
      expect(carCost.description, isNull);
    });

    test('toJson converts PersonalCarCost to JSON correctly', () {
      // Arrange
      final carCost = PersonalCarCost(
        projectId: 3,
        kilometers: 50,
        cost: 25000,
        description: 'Meeting trip',
      );

      // Act
      final json = carCost.toJson();

      // Assert
      expect(json['projectId'], 3);
      expect(json['kilometers'], 50);
      expect(json['cost'], 25000);
      expect(json['description'], 'Meeting trip');
    });

    test('toJson with null values', () {
      // Arrange
      final carCost = PersonalCarCost();

      // Act
      final json = carCost.toJson();

      // Assert
      expect(json['projectId'], isNull);
      expect(json['kilometers'], isNull);
      expect(json['cost'], isNull);
      expect(json['description'], isNull);
    });

    test('round trip conversion', () {
      // Arrange
      final originalJson = {
        'ProjectId': 10,
        'Kilometers': 200,
        'Cost': 100000,
        'Description': 'Long distance trip',
      };

      // Act
      final carCost = PersonalCarCost.fromJson(originalJson);
      final resultJson = carCost.toJson();

      // Assert
      expect(resultJson['projectId'], originalJson['ProjectId']);
      expect(resultJson['kilometers'], originalJson['Kilometers']);
      expect(resultJson['cost'], originalJson['Cost']);
      expect(resultJson['description'], originalJson['Description']);
    });
  });
}
