part of 'api_calls.dart';

extension HomeApiDailyDetails on ApiCalls {
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
}