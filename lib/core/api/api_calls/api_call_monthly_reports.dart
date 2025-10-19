part of 'api_calls.dart';

extension HomeApiMonthlyReports on ApiCalls {
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

  Future<List<DraftReportModel>> fetchMonthlyReportsForGroup(
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
      return data.map((e) => DraftReportModel.fromJson(e)).toList();
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
}