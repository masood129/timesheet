import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

import 'package:timesheet/home/model/task_model.dart';

import '../../core/api/api_service.dart';
import '../model/project_model.dart';

class HomeApi {
  final _api = CoreApi();
  static const String baseUrl = 'http://localhost:3000';
  String get getAllProjects => '$baseUrl/projects';
  Map<String, String> defaultHeaders = {
    'Content-Type': 'application/json',
    'accept': 'application/json'
  };


  // --- Project Operations ---
  Future<List<Project>> getProjects({
    String? uri,
    Map<String, String>? headers,
  }) async {
    try {
      final response = await _api.get(
        Uri.parse(uri ?? getAllProjects),
        headers: headers ?? defaultHeaders,
      );
      if (response?.statusCode == 200) {
        final body = response!.body;
        List<dynamic> jsonList = json.decode(body);
        List<Project> projects = jsonList.map((jsonItem) => Project.fromJson(jsonItem)).toList();
        return projects;
      } else {
        print('Request failed with status: ${response!.statusCode}');
        return [];
      }
    } catch (e) {
      print('Error occurred: $e');
      return [];
    }
  }

  // Future<void> createProject(int id, String projectName, int securityLevel) async {
  //   try {
  //     final response = await http.post(
  //       Uri.parse('$baseUrl/projects'),
  //       headers: {'Content-Type': 'application/json'},
  //       body: jsonEncode({
  //         'Id': id,
  //         'ProjectName': projectName,
  //         'securityLevel': securityLevel,
  //       }),
  //     );
  //     if (response.statusCode == 201) {
  //       await fetchProjects();
  //       Get.snackbar('موفق', 'پروژه با موفقیت ایجاد شد');
  //     } else if (response.statusCode == 400 && response.body.contains('Id already exists')) {
  //       throw Exception('شناسه قبلاً استفاده شده است');
  //     } else {
  //       throw Exception('Failed to create project');
  //     }
  //   } catch (e) {
  //     Get.snackbar('خطا', 'ایجاد پروژه ناموفق بود: $e');
  //   }
  // }
  //
  // Future<void> updateProject(int id, String? projectName, int? securityLevel) async {
  //   try {
  //     final response = await http.put(
  //       Uri.parse('$baseUrl/projects/$id'),
  //       headers: {'Content-Type': 'application/json'},
  //       body: jsonEncode({
  //         'ProjectName': projectName,
  //         'securityLevel': securityLevel,
  //       }),
  //     );
  //     if (response.statusCode == 200) {
  //       await fetchProjects();
  //       Get.snackbar('موفق', 'پروژه با موفقیت به‌روزرسانی شد');
  //     } else {
  //       throw Exception('Failed to update project');
  //     }
  //   } catch (e) {
  //     Get.snackbar('خطا', 'به‌روزرسانی پروژه ناموفق بود: $e');
  //   }
  // }
  //
  // Future<void> deleteProject(int id) async {
  //   try {
  //     final response = await http.delete(Uri.parse('$baseUrl/projects/$id'));
  //     if (response.statusCode == 204) {
  //       await fetchProjects();
  //       Get.snackbar('موفق', 'پروژه با موفقیت حذف شد');
  //     } else {
  //       throw Exception('Failed to delete project');
  //     }
  //   } catch (e) {
  //     Get.snackbar('خطا', 'حذف پروژه ناموفق بود: $e');
  //   }
  // }
}