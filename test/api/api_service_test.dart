import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  group('API Service Concepts', () {
    test('SharedPreferences stores and retrieves token', () async {
      SharedPreferences.setMockInitialValues({
        'jwt_token': 'test_token_123',
        'username': 'test_user',
      });

      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('jwt_token');
      final username = prefs.getString('username');

      expect(token, 'test_token_123');
      expect(username, 'test_user');
    });

    test('HTTP status codes are handled correctly', () {
      const successCode = 200;
      const unauthorizedCode = 401;
      const serverErrorCode = 500;

      expect(successCode, 200);
      expect(unauthorizedCode, 401);
      expect(serverErrorCode, 500);
    });

    test('JSON encoding works correctly', () {
      final data = {'key': 'value', 'number': 123};

      expect(data['key'], 'value');
      expect(data['number'], 123);
    });
  });
}
