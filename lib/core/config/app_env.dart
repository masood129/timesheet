import 'package:flutter_dotenv/flutter_dotenv.dart';

class AppEnv {
  static const String _defaultApiBaseUrl = 'http://localhost:3000';

  static String get apiBaseUrl {
    final envValue = dotenv.env['API_BASE_URL'];
    if (envValue != null && envValue.isNotEmpty) {
      return envValue;
    }

    const defineValue = String.fromEnvironment(
      'API_BASE_URL',
      defaultValue: '',
    );
    if (defineValue.isNotEmpty) {
      return defineValue;
    }

    return _defaultApiBaseUrl;
  }
}

