// import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:timesheet/core/api/api_service.dart';
import 'dart:convert';
import '../../home/model/monthly_report_model.dart';
import '../../home/model/project_model.dart';
import '../../home/model/daily_detail_model.dart';

class HomeApi {
  static final HomeApi _instance = HomeApi._internal();

  factory HomeApi() {
    return _instance;
  }

  late final String baseUrl; // تغییر به late برای init در constructor

  HomeApi._internal() {
    baseUrl =
        // dotenv.env['API_BASE_URL'] ??
        'http://localhost:3000'; // گرفتن از env یا default
  }

  final coreAPI = CoreApi();
  final Map<String, String> defaultHeaders = {
    'Content-Type': 'application/json',
    'accept': 'application/json',
  };

  Future<String?> _getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('jwt_token');
  }

  // تابع ورود و دریافت توکن
  Future<String> login(String username) async {
    final response = await coreAPI.post(
      Uri.parse('$baseUrl/auth/login'),
      headers: {...defaultHeaders, 'skip-auth': 'true'},
      body: jsonEncode({'username': username}),
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

  // تابع برای ذخیره هزینه ورزش ماهیانه
  Future<void> saveMonthlyGymCost(int year, int month, int cost,int hours) async {
    final prefs = await SharedPreferences.getInstance();
    final userId = prefs.getInt('userId');
    if (userId == null) {
      throw Exception('User ID not found');
    }

    final response = await coreAPI.post(
      Uri.parse('$baseUrl/monthly-reports/monthly-gym-costs/jalali'),
      headers: defaultHeaders,
      body: jsonEncode({
        'userId': userId,
        'year': year,
        'month': month,
        'cost': cost,
        'hours': hours,
      }),
    );
    if (response == null) {
      throw Exception('Failed to post: No response from server');
    }
    if (response.statusCode != 201) {
      throw Exception('Failed to save gym cost: ${response.statusCode}');
    }
  }

  // Projects Endpoints
  Future<List<Project>> getProjects() async {
    final response = await coreAPI.get(
      Uri.parse('$baseUrl/projects'),
      headers: defaultHeaders,
    );
    if (response == null) {
      throw Exception('Failed to fetch: No response from server');
    }
    if (response.statusCode == 200) {
      final List<dynamic> data = jsonDecode(response.body);
      return data.map((e) => Project.fromJson(e)).toList();
    }
    throw Exception('Failed to fetch projects: ${response.statusCode}');
  }

  Future<Project> getProjectById(int id) async {
    final response = await coreAPI.get(
      Uri.parse('$baseUrl/projects/$id'),
      headers: defaultHeaders,
    );
    if (response == null) {
      throw Exception('Failed to fetch: No response from server');
    }
    if (response.statusCode == 200) {
      return Project.fromJson(jsonDecode(response.body));
    }
    if (response.statusCode == 404) {
      throw Exception('Project not found');
    }
    throw Exception('Failed to fetch project: ${response.statusCode}');
  }

  Future<Project> createProject(Project project) async {
    final response = await coreAPI.post(
      Uri.parse('$baseUrl/projects'),
      headers: defaultHeaders,
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
    throw Exception('Failed to create project: ${response.statusCode}');
  }

  Future<Project> updateProject(int id, Map<String, dynamic> updates) async {
    final response = await coreAPI.put(
      Uri.parse('$baseUrl/projects/$id'),
      headers: defaultHeaders,
      body: jsonEncode(updates),
    );
    if (response == null) {
      throw Exception('Failed to put: No response from server');
    }
    if (response.statusCode == 200) {
      return Project.fromJson(jsonDecode(response.body));
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
      headers: defaultHeaders,
    );
    if (response == null) {
      throw Exception('Failed to delete: No response from server');
    }
    if (response.statusCode == 204) {
      return;
    }
    if (response.statusCode == 404) {
      throw Exception('Project not found');
    }
    throw Exception('Failed to delete project: ${response.statusCode}');
  }

  // DailyDetails Endpoints
  Future<DailyDetail?> getDailyDetail(String date) async {
    // حذف int userId
    final dateFormat = RegExp(r'^\d{4}-\d{2}-\d{2}$');
    if (!dateFormat.hasMatch(date)) {
      throw Exception('Invalid date format. Use YYYY-MM-DD');
    }

    final response = await coreAPI.get(
      Uri.parse('$baseUrl/daily-details/$date'),
      headers: defaultHeaders,
    );
    if (response == null) {
      throw Exception('Failed to fetch: No response from server');
    }
    if (response.statusCode == 200) {
      return DailyDetail.fromJson(jsonDecode(response.body));
    }
    if (response.statusCode == 404) {
      return null;
    }
    throw Exception('Failed to fetch daily detail: ${response.statusCode}');
  }

  Future<DailyDetail> saveDailyDetail(DailyDetail detail) async {
    final response = await coreAPI.post(
      Uri.parse('$baseUrl/daily-details'),
      headers: defaultHeaders,
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
    throw Exception('Failed to save daily detail: ${response.statusCode}');
  }

  Future<List<DailyDetail>> getMonthlyDetails(int year, int month) async {
    // حذف int userId
    final response = await coreAPI.get(
      Uri.parse('$baseUrl/daily-details/month/$year/$month'),
      headers: defaultHeaders,
    );
    if (response == null) {
      throw Exception('Failed to fetch: No response from server');
    }
    if (response.statusCode == 200) {
      final List<dynamic> data = jsonDecode(response.body);
      return data.map((e) => DailyDetail.fromJson(e)).toList();
    }
    throw Exception('Failed to fetch monthly details: ${response.statusCode}');
  }

  // اضافه کردن endpoint جدید برای دریافت جزئیات ماهیانه با تاریخ شمسی
  Future<List<DailyDetail>> getJalaliMonthlyDetails(
    int jalaliYear,
    int jalaliMonth,
  ) async {
    final response = await coreAPI.get(
      Uri.parse('$baseUrl/daily-details/jalali/month/$jalaliYear/$jalaliMonth'),
      headers: defaultHeaders,
    );
    if (response == null) {
      throw Exception('Failed to fetch: No response from server');
    }
    if (response.statusCode == 200) {
      final List<dynamic> data = jsonDecode(response.body);
      return data.map((e) => DailyDetail.fromJson(e)).toList();
    }
    throw Exception(
      'Failed to fetch jalali monthly details: ${response.statusCode}',
    );
  }

  Future<List<DailyDetail>> getDateRangeDetails(
    String startDate,
    String endDate,
  ) async {
    // حذف int userId
    final dateFormat = RegExp(r'^\d{4}-\d{2}-\d{2}$');
    if (!dateFormat.hasMatch(startDate) || !dateFormat.hasMatch(endDate)) {
      throw Exception('Invalid date format. Use YYYY-MM-DD');
    }
    if (startDate == 'range' || endDate == 'range') {
      throw Exception('Invalid date: "range" is not a valid date');
    }

    final url = Uri.parse(
      '$baseUrl/daily-details/range?startDate=$startDate&endDate=$endDate',
    );
    final response = await coreAPI.get(url, headers: defaultHeaders);

    if (response == null) {
      throw Exception('Failed to fetch: No response from server');
    }
    if (response.statusCode == 200) {
      final List<dynamic> data = jsonDecode(response.body);
      return data.map((e) => DailyDetail.fromJson(e)).toList();
    }
    throw Exception(
      'Failed to fetch date range details: ${response.statusCode}',
    );
  }

  // Monthly Reports Endpoints - Gregorian
  Future<void> createMonthlyReport(int year, int month) async {
    final response = await coreAPI.post(
      Uri.parse('$baseUrl/monthly-reports/$year/$month'),
      headers: defaultHeaders,
      body: jsonEncode({}), // body خالی
    );
    if (response == null) {
      throw Exception('Failed to create report: No response from server');
    }
    if (response.statusCode != 201) {
      throw Exception(
        'Failed to create monthly report: ${response.statusCode}',
      );
    }
  }

  // اضافه کردن endpoint جدید برای ایجاد گزارش با تاریخ شمسی
  Future<void> createJalaliMonthlyReport(
    int jalaliYear,
    int jalaliMonth,
  ) async {
    final response = await coreAPI.post(
      Uri.parse('$baseUrl/monthly-reports/jalali/$jalaliYear/$jalaliMonth'),
      headers: defaultHeaders,
      body: jsonEncode({}), // body خالی
    );
    if (response == null) {
      throw Exception('Failed to create report: No response from server');
    }
    if (response.statusCode != 201) {
      throw Exception(
        'Failed to create jalali monthly report: ${response.statusCode}',
      );
    }
  }

  Future<void> submitReportToGroupManager(int reportId) async {
    final response = await coreAPI.put(
      Uri.parse('$baseUrl/monthly-reports/$reportId/submit-to-group-manager'),
      headers: defaultHeaders,
      body: jsonEncode({}), // body خالی
    );
    if (response == null) {
      throw Exception('Failed to submit report: No response from server');
    }
    if (response.statusCode != 200) {
      throw Exception('Failed to submit report: ${response.statusCode}');
    }
  }

  Future<MonthlyReport> getMonthlyReportById(int reportId) async {
    final response = await coreAPI.get(
      Uri.parse('$baseUrl/monthly-reports/$reportId'),
      headers: defaultHeaders,
    );
    if (response == null) {
      throw Exception('Failed to fetch: No response from server');
    }
    if (response.statusCode == 200) {
      return MonthlyReport.fromJson(jsonDecode(response.body));
    }
    if (response.statusCode == 404) {
      throw Exception('Report not found');
    }
    throw Exception('Failed to fetch report: ${response.statusCode}');
  }

  Future<List<MonthlyReport>> getMonthlyReportsForGroup(
    int year,
    int month,
  ) async {
    final response = await coreAPI.get(
      Uri.parse('$baseUrl/monthly-reports/group/$year/$month'),
      headers: defaultHeaders,
    );
    if (response == null) {
      throw Exception('Failed to fetch: No response from server');
    }
    if (response.statusCode == 200) {
      final List<dynamic> data = jsonDecode(response.body);
      return data.map((e) => MonthlyReport.fromJson(e)).toList();
    }
    throw Exception('Failed to fetch group reports: ${response.statusCode}');
  }

  // اضافه کردن endpoint جدید برای دریافت گزارش‌های گروه با تاریخ شمسی
  Future<List<MonthlyReport>> getJalaliMonthlyReportsForGroup(
    int jalaliYear,
    int jalaliMonth,
  ) async {
    final response = await coreAPI.get(
      Uri.parse(
        '$baseUrl/monthly-reports/jalali/group/$jalaliYear/$jalaliMonth',
      ),
      headers: defaultHeaders,
    );
    if (response == null) {
      throw Exception('Failed to fetch: No response from server');
    }
    if (response.statusCode == 200) {
      final List<dynamic> data = jsonDecode(response.body);
      return data.map((e) => MonthlyReport.fromJson(e)).toList();
    }
    throw Exception(
      'Failed to fetch jalali group reports: ${response.statusCode}',
    );
  }

  Future<List<MonthlyReport>> fetchMonthlyReportsForGroup(
    int startYear,
    int startMonth,
    int endYear,
    int endMonth,
  ) async {
    final token = await _getToken();
    if (token == null) {
      throw Exception('Authentication token not found');
    }

    final response = await coreAPI.get(
      Uri.parse(
        '$baseUrl/monthly-reports/group/range/$startYear/$startMonth/$endYear/$endMonth',
      ),
      headers: {...defaultHeaders, 'Authorization': 'Bearer $token'},
    );

    if (response == null) {
      throw Exception('Failed to fetch: No response from server');
    }

    if (response.statusCode == 200) {
      final List<dynamic> data = jsonDecode(response.body);
      return data
          .map((e) => MonthlyReport.fromJson(e))
          .toList(); // تغییر به List<MonthlyReport>
    }
    throw Exception('Failed to fetch range reports: ${response.statusCode}');
  }

  Future<Map<String, dynamic>> approveReportAsGroupManager(
    // تغییر به Map برای json
    int reportId,
    String comment,
    bool toGeneralManager,
  ) async {
    final token = await _getToken();
    if (token == null) {
      throw Exception('Authentication token not found');
    }

    final response = await coreAPI.put(
      Uri.parse('$baseUrl/monthly-reports/$reportId/approve-group-manager'),
      headers: {...defaultHeaders, 'Authorization': 'Bearer $token'},
      body: jsonEncode({
        'comment': comment,
        'toGeneralManager': toGeneralManager,
      }),
    );

    if (response == null) {
      throw Exception('Failed to approve: No response from server');
    }

    if (response.statusCode == 200) {
      return jsonDecode(response.body); // یا MonthlyReport اگر نیاز باشه
    }
    throw Exception(
      'Failed to approve as group manager: ${response.statusCode}',
    );
  }

  Future<Map<String, dynamic>> approveReportAsGeneralManager(
    // تغییر به Map
    int reportId,
    String comment,
  ) async {
    final token = await _getToken();
    if (token == null) {
      throw Exception('Authentication token not found');
    }

    final response = await coreAPI.put(
      Uri.parse('$baseUrl/monthly-reports/$reportId/approve-general-manager'),
      headers: {...defaultHeaders, 'Authorization': 'Bearer $token'},
      body: jsonEncode({'comment': comment}),
    );

    if (response == null) {
      throw Exception('Failed to approve: No response from server');
    }

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    }
    throw Exception(
      'Failed to approve as general manager: ${response.statusCode}',
    );
  }

  Future<Map<String, dynamic>> approveReportAsFinance(
    int reportId,
    String comment,
  ) async {
    // تغییر به Map
    final token = await _getToken();
    if (token == null) {
      throw Exception('Authentication token not found');
    }

    final response = await coreAPI.put(
      Uri.parse('$baseUrl/monthly-reports/$reportId/approve-finance'),
      headers: {...defaultHeaders, 'Authorization': 'Bearer $token'},
      body: jsonEncode({'comment': comment}),
    );

    if (response == null) {
      throw Exception('Failed to approve: No response from server');
    }

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    }
    throw Exception('Failed to approve as finance: ${response.statusCode}');
  }

  // اضافه کردن endpoint برای تست تاریخ شمسی
  Future<Map<String, dynamic>> testJalaliDate(
    int jalaliYear,
    int jalaliMonth,
  ) async {
    final response = await coreAPI.get(
      Uri.parse('$baseUrl/test/jalali/$jalaliYear/$jalaliMonth'),
      headers: defaultHeaders,
    );
    if (response == null) {
      throw Exception('Failed to test: No response from server');
    }
    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    }
    throw Exception('Failed to test jalali date: ${response.statusCode}');
  }
}
