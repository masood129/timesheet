part of 'api_calls.dart';

extension HomeApiEos on ApiCalls {
  Future<List<Map<String, dynamic>>> getTimeRecords(
    String cardNo,
    String date,
  ) async {
    // date should be formatted as needed by the backend, e.g., 1403/09/10
    // If the date passed here is not in that format, we might need to format it.
    // Assuming the caller passes the correct format.
    final uri = Uri.parse(
      '$baseUrl/eos/time-records',
    ).replace(queryParameters: {'cardNo': cardNo, 'date': date});
    final response = await coreAPI.get(uri);
    if (response == null) {
      throw Exception('Failed to fetch: No response from server');
    }
    if (response.statusCode == 200) {
      final List<dynamic> data = jsonDecode(response.body);
      return data.cast<Map<String, dynamic>>();
    }
    throw Exception('Failed to fetch time records: ${response.statusCode}');
  }
}
