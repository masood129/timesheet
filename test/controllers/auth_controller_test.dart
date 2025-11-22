import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:timesheet/home/controller/auth_controller.dart';

void main() {
  group('AuthController', () {
    late AuthController authController;

    setUp(() {
      Get.testMode = true;
      authController = AuthController();
    });

    tearDown(() {
      Get.reset();
    });

    test('loadUserFromPrefs loads user data correctly', () async {
      SharedPreferences.setMockInitialValues({
        'userId': 20,
        'username': 'loaded_user',
        'Role': 'manager',
        'jwt_token': 'loaded_token',
      });

      await authController.loadUserFromPrefs();

      expect(authController.user.value, isNotNull);
      expect(authController.user.value?['userId'], 20);
      expect(authController.user.value?['Username'], 'loaded_user');
      expect(authController.user.value?['Role'], 'manager');
      expect(authController.token.value, 'loaded_token');
    });

    test('loadUserFromPrefs handles missing data', () async {
      SharedPreferences.setMockInitialValues({});

      await authController.loadUserFromPrefs();

      expect(authController.user.value, isNull);
      expect(authController.token.value, isEmpty);
    });

    test('user and token are observable', () {
      expect(authController.user, isA<Rxn<Map<String, dynamic>>>());
      expect(authController.token, isA<RxString>());
    });
  });
}
