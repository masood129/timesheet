part of 'api_calls.dart';

extension HomeApiGymCost on ApiCalls {
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
}