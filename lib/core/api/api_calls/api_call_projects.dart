part of 'api_calls.dart';

extension HomeApiProjects on ApiCalls {
  // Projects Endpoints (مثال – بقیه مشابه)
  Future<List<Project>> getProjects() async {
    try {
      final response = await coreAPI.get(
        Uri.parse('$baseUrl/projects'),
        headers: defaultHeaders,
      );
      if (response == null) {
        throw Exception('Failed to fetch: No response from server');
      }
      if (response.statusCode == 200) {
        try {
          // Handle empty response
          if (response.body.trim().isEmpty) {
            return [];
          }
          
          final decoded = jsonDecode(response.body);
          // Handle both array and object responses
          final List<dynamic> data;
          if (decoded is List) {
            data = decoded;
          } else if (decoded is Map && decoded.containsKey('data')) {
            data = decoded['data'] as List<dynamic>;
          } else if (decoded is Map && decoded.containsKey('projects')) {
            data = decoded['projects'] as List<dynamic>;
          } else {
            throw Exception('Unexpected response format: ${response.body}');
          }
          return data.map((item) {
            try {
              return Project.fromJson(item as Map<String, dynamic>);
            } catch (parseError) {
              throw Exception('Failed to parse project: $parseError. Data: $item');
            }
          }).toList();
        } catch (e) {
          throw Exception('Failed to parse response: $e. Response body: ${response.body}');
        }
      } else {
        // Try to parse error message from response
        String errorMessage = 'Failed to fetch projects: ${response.statusCode}';
        try {
          final errorData = jsonDecode(response.body);
          if (errorData is Map && errorData.containsKey('error')) {
            errorMessage = errorData['error'] as String;
          } else if (errorData is Map && errorData.containsKey('message')) {
            errorMessage = errorData['message'] as String;
          }
        } catch (_) {
          errorMessage = 'Failed to fetch projects: ${response.statusCode}. Response: ${response.body}';
        }
        throw Exception(errorMessage);
      }
    } catch (e) {
      if (e is Exception) {
        rethrow;
      }
      throw Exception('Unexpected error fetching projects: $e');
    }
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