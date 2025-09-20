import 'package:shared_preferences/shared_preferences.dart';
import 'package:timesheet/core/api/api_service.dart'; // import CoreApi
import 'package:timesheet/home/model/draft_report_model.dart';
import 'dart:convert';
import '../../home/model/monthly_report_model.dart';
import '../../home/model/project_model.dart';
import '../../home/model/daily_detail_model.dart';
import '../../home/model/user_model.dart';

class HomeApi {
  static final HomeApi _instance = HomeApi._internal();

  factory HomeApi() {
    return _instance;
  }

  late final String baseUrl;

  HomeApi._internal() {
    baseUrl = 'http://localhost:3000'; // یا از dotenv بگیرید
  }

  final coreAPI = CoreApi();
  final Map<String, String> defaultHeaders = {
    'Content-Type': 'application/json',
    'accept': 'application/json',
  };

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

  // تابع برای ذخیره هزینه ورزش ماهیانه
  Future<void> saveMonthlyGymCost(
    int year,
    int month,
    int cost,
    int hours,
  ) async {
    final prefs = await SharedPreferences.getInstance();
    final userId = prefs.getInt('userId');
    if (userId == null) {
      throw Exception('User ID not found');
    }

    final response = await coreAPI.post(
      Uri.parse('$baseUrl/monthly-reports/jalali-monthly-gym-costs'),
      headers: defaultHeaders,
      body: {
        'userId': userId,
        'year': year,
        'month': month,
        'cost': cost,
        'hours': hours,
      },
    );
    if (response == null) {
      throw Exception('Failed to post: No response from server');
    }
    if (response.statusCode != 201) {
      // throw Exception('Failed to save gym cost: ${response.statusCode}');
      throw Exception(response.body);
    }
  }

  Future<String?> checkMonthlyReportStatus(
    int jalaliYear,
    int jalaliMonth,
  ) async {
    final response = await coreAPI.get(
      Uri.parse(
        '$baseUrl/monthly-reports/check-submitted/jalali/$jalaliYear/$jalaliMonth',
      ),
      headers: defaultHeaders,
    );
    if (response == null) {
      throw Exception('Failed to fetch: No response from server');
    }
    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return data['status'] as String?;
    }
    if (response.statusCode == 400) {
      throw Exception('Invalid Jalali year or month');
    }
    if (response.statusCode == 403) {
      throw Exception('Access denied');
    }
    throw Exception('Failed to check report status: ${response.statusCode}');
  }

  // Projects Endpoints (مثال – بقیه مشابه)
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

  // ... بقیه متدها مشابه – explicit token حذف شد، body به Map تبدیل شد، برای delete body null است (مثل deleteProject و exitDraft).
  // مثال exitDraft:
  Future<void> exitDraft(int reportId) async {
    final response = await coreAPI.delete(
      Uri.parse('$baseUrl/monthly-reports/exit-draft/$reportId'),
      headers: defaultHeaders,
      body: null, // بدون body برای سازگاری
    );
    if (response == null) {
      throw Exception('Failed to delete: No response from server');
    }
    if (response.statusCode == 200) {
      return;
    }
    if (response.statusCode == 400) {
      throw Exception('Only draft reports can be exited');
    }
    if (response.statusCode == 403) {
      throw Exception('Access denied');
    }
    if (response.statusCode == 404) {
      throw Exception('Report not found');
    }
    throw Exception('Failed to exit draft: ${response.statusCode}');
  }

  Future<Project> getProjectById(int id) async {
    final response = await coreAPI.get(Uri.parse('$baseUrl/projects/$id'));
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
      body: null, // بدون body
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
    final dateFormat = RegExp(r'^\d{4}-\d{2}-\d{2}$');
    if (!dateFormat.hasMatch(date)) {
      throw Exception('Invalid date format. Use YYYY-MM-DD');
    }

    final response = await coreAPI.get(
      Uri.parse('$baseUrl/daily-details/$date'),
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
    final response = await coreAPI.get(
      Uri.parse('$baseUrl/daily-details/month/$year/$month'),
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
    final response = await coreAPI.get(url);

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
    final response = await coreAPI.get(
      Uri.parse(
        '$baseUrl/monthly-reports/group/range/$startYear/$startMonth/$endYear/$endMonth',
      ),
    );
    if (response == null) {
      throw Exception('Failed to fetch: No response from server');
    }

    if (response.statusCode == 200) {
      final List<dynamic> data = jsonDecode(response.body);
      return data.map((e) => MonthlyReport.fromJson(e)).toList();
    }
    throw Exception('Failed to fetch range reports: ${response.statusCode}');
  }

  Future<Map<String, dynamic>> approveReportAsGroupManager(
    int reportId,
    String comment,
    bool toGeneralManager,
  ) async {
    final response = await coreAPI.put(
      Uri.parse('$baseUrl/monthly-reports/$reportId/approve-group-manager'),
      body: jsonEncode({
        'comment': comment,
        'toGeneralManager': toGeneralManager,
      }),
    );

    if (response == null) {
      throw Exception('Failed to approve: No response from server');
    }

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    }
    throw Exception(
      'Failed to approve as group manager: ${response.statusCode}',
    );
  }

  Future<Map<String, dynamic>> approveReportAsGeneralManager(
    int reportId,
    String comment,
  ) async {
    final response = await coreAPI.put(
      Uri.parse('$baseUrl/monthly-reports/$reportId/approve-general-manager'),
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
    final response = await coreAPI.put(
      Uri.parse('$baseUrl/monthly-reports/$reportId/approve-finance'),
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

  // رد گزارش و بازگشت به draft
  Future<void> rejectToDraft(int reportId, String comment) async {
    final response = await coreAPI.put(
      Uri.parse('$baseUrl/monthly-reports/$reportId/reject-to-draft'),
      body: jsonEncode({'comment': comment}),
    );
    if (response == null) {
      throw Exception('Failed to reject: No response from server');
    }
    if (response.statusCode != 200) {
      throw Exception('Failed to reject to draft: ${response.statusCode}');
    }
  }

  Future<List<DraftReportModel>> getMyDrafts() async {
    final response = await coreAPI.get(
      Uri.parse('$baseUrl/monthly-reports/my-drafts'),
    );
    if (response == null) {
      throw Exception('Failed to fetch: No response from server');
    }
    if (response.statusCode == 200) {
      List<dynamic> data = jsonDecode(response.body);
      return data.map((e) => DraftReportModel.fromJson(e)).toList();
    }
    if (response.statusCode == 403) {
      throw Exception('Access denied');
    }
    throw Exception('Failed to fetch drafts: ${response.statusCode}');
  }

  // Method to get subordinates
  Future<List<UserModel>> getSubordinates() async {
    final response = await coreAPI.get(
      Uri.parse('$baseUrl/users/subordinates'),
      headers: defaultHeaders,
    );
    if (response == null) {
      throw Exception('Failed to fetch: No response from server');
    }
    if (response.statusCode == 200) {
      final List<dynamic> data = jsonDecode(response.body);
      return data.map((e) => UserModel.fromJson(e)).toList();
    }
    if (response.statusCode == 403) {
      throw Exception('Access denied: Not a manager');
    }
    throw Exception('Failed to fetch subordinates: ${response.statusCode}');
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
