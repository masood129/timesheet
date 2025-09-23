part of 'api_calls.dart';

extension HomeApiReportStatus on ApiCalls {
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
}