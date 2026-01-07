part of 'api_calls.dart';

extension HomeApiUsers on ApiCalls {
  // Method to get subordinates
  Future<List<UserModel>> getSubordinates() async {
    final response = await coreAPI.get(
      Uri.parse('$baseUrl/users/subordinates'),
      headers: defaultHeaders,
    );
    if (response == null) {
      throw Exception('Failed to fetch: No response from server');
    }
    if (response.statusCode == 200) {
      final List<dynamic> data = jsonDecode(response.body);
      return data.map((e) => UserModel.fromJson(e)).toList();
    }
    if (response.statusCode == 403) {
      throw Exception('Access denied: Not a manager');
    }
    throw Exception('Failed to fetch subordinates: ${response.statusCode}');
  }

  // Method to get employees by directAdminId
  Future<List<UserModel>> getEmployeesByDirectAdminId(int directAdminId) async {
    final response = await coreAPI.get(
      Uri.parse('$baseUrl/users/by-direct-admin/$directAdminId'),
      headers: defaultHeaders,
    );
    if (response == null) {
      throw Exception('Failed to fetch: No response from server');
    }
    if (response.statusCode == 200) {
      final List<dynamic> data = jsonDecode(response.body);
      return data.map((e) => UserModel.fromJson(e)).toList();
    }
    if (response.statusCode == 403) {
      throw Exception('Access denied: Not authorized');
    }
    throw Exception('Failed to fetch employees: ${response.statusCode}');
  }
}