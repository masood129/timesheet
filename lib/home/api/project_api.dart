import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:persian_datetime_picker/persian_datetime_picker.dart';
import '../model/project_model.dart';
import '../model/task_model.dart';

class TaskService {
  final String baseUrl = 'https://api.example.com';

  Future<List<Project>> fetchProjects() async {
    final response = await http.get(Uri.parse('$baseUrl/projects'));
    if (response.statusCode == 200) {
      final List<dynamic> data = jsonDecode(response.body);
      return data.map((e) => Project.fromJson(e)).toList();
    }
    throw Exception('Failed to load projects');
  }

  Future<Task?> fetchTask(Jalali date) async {
    final gregorianDate = date.toGregorian();
    final dateStr =
        '${gregorianDate.year}-${gregorianDate.month.toString().padLeft(2, '0')}-${gregorianDate.day.toString().padLeft(2, '0')}';
    final response = await http.get(Uri.parse('$baseUrl/tasks?date=$dateStr'));
    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return Task.fromJson(data);
    }
    return null;
  }

  Future<void> saveTask(Task task) async {
    final response = await http.post(
      Uri.parse('$baseUrl/tasks'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(task.toJson()),
    );
    if (response.statusCode != 201) {
      throw Exception('Failed to save task');
    }
  }
}
