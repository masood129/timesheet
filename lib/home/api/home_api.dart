import 'package:shared_preferences/shared_preferences.dart';
import 'package:timesheet/core/api/api_service.dart';
import 'dart:convert';
import '../model/project_model.dart';
import '../model/daily_detail_model.dart';

class HomeApi {
  final String baseUrl = 'http://localhost:3000';
  final coreAPI = CoreApi();
  Map<String, String> defaultHeaders = {
    'Content-Type': 'application/json',
    'accept': 'application/json',
  };

  // تابع برای دریافت هدرها با توکن
  Future<Map<String, String>> _getHeaders() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('jwt_token');
    if (token != null) {
      return {
        ...defaultHeaders,
        'Authorization': 'Bearer $token',
      };
    }
    return defaultHeaders;
  }

  // تابع ورود و دریافت توکن
  Future<String> login(String username) async {
    final response = await coreAPI.post(
      Uri.parse('$baseUrl/auth/login'),
      headers: defaultHeaders,
      body: jsonEncode({'username': username}),
    );
    if (response == null) {
      throw Exception('Failed to login: No response from server');
    }
    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      final token = data['token'] as String;
      // ذخیره توکن
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('jwt_token', token);
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

  // تابع برای خروج (حذف توکن)
  Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('jwt_token');
  }

  // Projects Endpoints
  Future<List<Project>> getProjects() async {
    final response = await coreAPI.get(
      Uri.parse('$baseUrl/projects'),
      headers: await _getHeaders(),
    );
    if (response == null) {
      throw Exception('Failed to fetch: No response from server');
    }
    if (response.statusCode == 200) {
      final List<dynamic> data = jsonDecode(response.body);
      return data.map((e) => Project.fromJson(e)).toList();
    }
    if (response.statusCode == 401) {
      throw Exception('Unauthorized: Invalid or missing token');
    }
    throw Exception('Failed to fetch projects: ${response.statusCode}');
  }

  Future<Project> getProjectById(int id) async {
    final response = await coreAPI.get(
      Uri.parse('$baseUrl/projects/$id'),
      headers: await _getHeaders(),
    );
    if (response == null) {
      throw Exception('Failed to fetch: No response from server');
    }
    if (response.statusCode == 200) {
      return Project.fromJson(jsonDecode(response.body));
    }
    if (response.statusCode == 401) {
      throw Exception('Unauthorized: Invalid or missing token');
    }
    if (response.statusCode == 404) {
      throw Exception('Project not found');
    }
    throw Exception('Failed to fetch project: ${response.statusCode}');
  }

  Future<Project> createProject(Project project) async {
    final response = await coreAPI.post(
      Uri.parse('$baseUrl/projects'),
      headers: await _getHeaders(),
      body: jsonEncode(project.toJson()),
    );
    if (response == null) {
      throw Exception('Failed to post: No response from server');
    }
    if (response.statusCode == 201) {
      return Project.fromJson(jsonDecode(response.body));
    }
    if (response.statusCode == 400) {
      throw Exception('Invalid input or ID already exists');
    }
    if (response.statusCode == 401) {
      throw Exception('Unauthorized: Invalid or missing token');
    }
    throw Exception('Failed to create project: ${response.statusCode}');
  }

  Future<Project> updateProject(int id, Map<String, dynamic> updates) async {
    final response = await coreAPI.put(
      Uri.parse('$baseUrl/projects/$id'),
      headers: await _getHeaders(),
      body: jsonEncode(updates),
    );
    if (response == null) {
      throw Exception('Failed to put: No response from server');
    }
    if (response.statusCode == 200) {
      return Project.fromJson(jsonDecode(response.body));
    }
    if (response.statusCode == 401) {
      throw Exception('Unauthorized: Invalid or missing token');
    }
    if (response.statusCode == 404) {
      throw Exception('Project not found');
    }
    if (response.statusCode == 400) {
      throw Exception('Invalid input');
    }
    throw Exception('Failed to update project: ${response.statusCode}');
  }

  Future<void> deleteProject(int id) async {
    final response = await coreAPI.delete(
      Uri.parse('$baseUrl/projects/$id'),
      headers: await _getHeaders(),
    );
    if (response == null) {
      throw Exception('Failed to delete: No response from server');
    }
    if (response.statusCode == 204) {
      return;
    }
    if (response.statusCode == 401) {
      throw Exception('Unauthorized: Invalid or missing token');
    }
    if (response.statusCode == 404) {
      throw Exception('Project not found');
    }
    throw Exception('Failed to delete project: ${response.statusCode}');
  }

  // DailyDetails Endpoints
  Future<DailyDetail?> getDailyDetail(String date, int userId) async {
    final dateFormat = RegExp(r'^\d{4}-\d{2}-\d{2}$');
    if (!dateFormat.hasMatch(date)) {
      throw Exception('Invalid date format. Use YYYY-MM-DD');
    }

    final response = await coreAPI.get(
      Uri.parse('$baseUrl/daily-details/$date?userId=$userId'),
      headers: await _getHeaders(),
    );
    if (response == null) {
      throw Exception('Failed to fetch: No response from server');
    }
    if (response.statusCode == 200) {
      return DailyDetail.fromJson(jsonDecode(response.body));
    }
    if (response.statusCode == 401) {
      throw Exception('Unauthorized: Invalid or missing token');
    }
    if (response.statusCode == 404) {
      return null;
    }
    throw Exception('Failed to fetch daily detail: ${response.statusCode}');
  }

  Future<DailyDetail> saveDailyDetail(DailyDetail detail) async {
    final response = await coreAPI.post(
      Uri.parse('$baseUrl/daily-details'),
      headers: await _getHeaders(),
      body: jsonEncode(detail.toJson()),
    );
    if (response == null) {
      throw Exception('Failed to post: No response from server');
    }
    if (response.statusCode == 201) {
      return DailyDetail.fromJson(jsonDecode(response.body));
    }
    if (response.statusCode == 400) {
      throw Exception('Invalid input');
    }
    if (response.statusCode == 401) {
      throw Exception('Unauthorized: Invalid or missing token');
    }
    throw Exception('Failed to save daily detail: ${response.statusCode}');
  }

  Future<List<DailyDetail>> getMonthlyDetails(
      int year,
      int month,
      int userId,
      ) async {
    final response = await coreAPI.get(
      Uri.parse('$baseUrl/daily-details/month/$year/$month?userId=$userId'),
      headers: await _getHeaders(),
    );
    if (response == null) {
      throw Exception('Failed to fetch: No response from server');
    }
    if (response.statusCode == 200) {
      final List<dynamic> data = jsonDecode(response.body);
      return data.map((e) => DailyDetail.fromJson(e)).toList();
    }
    if (response.statusCode == 401) {
      throw Exception('Unauthorized: Invalid or missing token');
    }
    throw Exception('Failed to fetch monthly details: ${response.statusCode}');
  }

  Future<List<DailyDetail>> getDateRangeDetails(
      String startDate,
      String endDate,
      int userId,
      ) async {
    final dateFormat = RegExp(r'^\d{4}-\d{2}-\d{2}$');
    if (!dateFormat.hasMatch(startDate) || !dateFormat.hasMatch(endDate)) {
      throw Exception('Invalid date format. Use YYYY-MM-DD');
    }
    if (startDate == 'range' || endDate == 'range') {
      throw Exception('Invalid date: "range" is not a valid date');
    }

    final url = Uri.parse(
      '$baseUrl/daily-details/range?startDate=$startDate&endDate=$endDate&userId=$userId',
    );
    final response = await coreAPI.get(url, headers: await _getHeaders());

    if (response == null) {
      throw Exception('Failed to fetch: No response from server');
    }
    if (response.statusCode == 200) {
      final List<dynamic> data = jsonDecode(response.body);
      return data.map((e) => DailyDetail.fromJson(e)).toList();
    }
    if (response.statusCode == 401) {
      throw Exception('Unauthorized: Invalid or missing token');
    }
    throw Exception('Failed to fetch date range details: ${response.statusCode}');
  }
}