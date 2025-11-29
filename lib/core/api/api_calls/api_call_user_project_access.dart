part of 'api_calls.dart';

extension UserProjectAccessApi on ApiCalls {
  // Get all projects with access status for current user
  Future<List<ProjectAccess>> getUserProjectAccess() async {
    final response = await coreAPI.get(
      Uri.parse('$baseUrl/user-project-access'),
      headers: defaultHeaders,
    );
    if (response == null) {
      throw Exception('Failed to fetch: No response from server');
    }
    if (response.statusCode == 200) {
      final List<dynamic> data = jsonDecode(response.body);
      return data.map((e) => ProjectAccess.fromJson(e)).toList();
    }
    throw Exception('Failed to fetch project access: ${response.statusCode}');
  }

  // Toggle project access for a specific project
  Future<Map<String, dynamic>> toggleProjectAccess(int projectId) async {
    final response = await coreAPI.put(
      Uri.parse('$baseUrl/user-project-access/$projectId'),
      body: jsonEncode({}),
    );
    if (response == null) {
      throw Exception('Failed to toggle: No response from server');
    }
    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    }
    if (response.statusCode == 404) {
      throw Exception('Project not found');
    }
    throw Exception('Failed to toggle project access: ${response.statusCode}');
  }
}
