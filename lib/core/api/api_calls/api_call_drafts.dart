part of 'api_calls.dart';

extension HomeApiDrafts on ApiCalls {
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
}