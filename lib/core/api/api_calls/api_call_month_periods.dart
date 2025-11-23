part of 'api_calls.dart';

extension MonthPeriodApi on ApiCalls {
  /// دریافت بازه یک ماه خاص
  Future<MonthPeriodModel> getMonthPeriod(int year, int month) async {
    try {
      final response = await coreAPI.get(
        Uri.parse('$baseUrl/month-periods/$year/$month'),
        headers: defaultHeaders,
      );

      if (response?.statusCode == 200) {
        final data = json.decode(response!.body);
        return MonthPeriodModel.fromJson(data);
      } else {
        throw Exception('Failed to load month period: ${response?.statusCode}');
      }
    } catch (e) {
      throw Exception('Error fetching month period: $e');
    }
  }

  /// دریافت تمام بازه‌های یک سال
  Future<List<MonthPeriodModel>> getYearMonthPeriods(int year) async {
    try {
      final response = await coreAPI.get(
        Uri.parse('$baseUrl/month-periods/$year'),
        headers: defaultHeaders,
      );

      if (response?.statusCode == 200) {
        final List<dynamic> data = json.decode(response!.body);
        return data.map((period) => MonthPeriodModel.fromJson(period)).toList();
      } else {
        throw Exception('Failed to load year periods: ${response?.statusCode}');
      }
    } catch (e) {
      throw Exception('Error fetching year periods: $e');
    }
  }
}
