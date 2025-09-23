part of 'api_calls.dart';

extension HomeApiProjects on ApiCalls {
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
}