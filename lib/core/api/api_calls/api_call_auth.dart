part of 'api_calls.dart';

extension HomeApiAuth on ApiCalls {
  // تابع ورود و دریافت توکن
  Future<String> login(String username) async {
    final response = await coreAPI.post(
      Uri.parse('$baseUrl/auth/login'),
      headers: {...defaultHeaders, 'skip-auth': 'true'},
      body: {'username': username}, // Map - CoreApi encode می‌کنه
    );
    if (response == null) {
      throw Exception('Failed to login: No response from server');
    }
    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      final token = data['token'] as String;
      final userId = data['userId'] as int;
      final role = data['Role'] as String;
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('jwt_token', token);
      await prefs.setString('username', username);
      await prefs.setString('Role', role);
      await prefs.setInt('userId', userId);
      return token;
    }
    if (response.statusCode == 400) {
      throw Exception('Invalid input');
    }
    if (response.statusCode == 401) {
      throw Exception('Invalid username');
    }
    throw Exception('Failed to login: ${response.statusCode}');
  }

  // تابع برای خروج
  Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('jwt_token');
    await prefs.remove('username');
    await prefs.remove('userId');
  }

  // Update api_calls.dart with full loginAs (to store all user info)
  Future<void> loginAs(int targetUserId) async {
    final response = await coreAPI.post(
      Uri.parse('$baseUrl/auth/login-as'),
      headers: defaultHeaders,
      body: {'targetUserId': targetUserId},
    );
    if (response == null) {
      throw Exception('Failed to login-as: No response from server');
    }
    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      final token = data['token'] as String;
      final userId = data['userId'] as int;
      final username = data['Username'] as String;
      final role = data['Role'] as String;
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('jwt_token', token);
      await prefs.setInt('userId', userId);
      await prefs.setString('username', username);
      await prefs.setString('Role', role);
      return;
    }
    if (response.statusCode == 403) {
      throw Exception('Access denied: Only managers can impersonate');
    }
    if (response.statusCode == 404) {
      throw Exception('User not found');
    }
    throw Exception('Failed to login-as: ${response.statusCode}');
  }
}