import 'package:timesheet/core/api/api_service.dart';
import 'dart:convert';
import '../model/project_model.dart';
import '../model/daily_detail_model.dart';

class HomeApi {
  final String baseUrl = 'http://localhost:3000/projects';
  final coreAPI = CoreApi();
  Map<String, String> defaultHeaders = {
    'Content-Type': 'application/json',
    'accept': 'application/json',
  };

  Future<List<Project>> getProjects() async {
    final response = await coreAPI.get(
      Uri.parse(baseUrl),
      headers: defaultHeaders,
    );
    if (response!.statusCode == 200) {
      final List<dynamic> data = jsonDecode(response.body);
      return data.map((e) => Project.fromJson(e)).toList();
    }
    throw Exception('Failed to fetch projects');
  }

  Future<DailyDetail?> getDailyDetail(String date, int userId) async {
    final response = await coreAPI.get(
      Uri.parse('$baseUrl/daily-details/$date?userId=$userId'),
      headers: defaultHeaders,
    );
    if (response!.statusCode == 200) {
      return DailyDetail.fromJson(jsonDecode(response.body));
    }
    return null;
  }

  Future<void> saveDailyDetail(DailyDetail detail) async {
    final response = await coreAPI.post(
      Uri.parse('$baseUrl/daily-details'),
      headers: defaultHeaders,
      body: jsonEncode(detail.toJson()),
    );
    if (response!.statusCode != 201) {
      throw Exception('Failed to save daily detail');
    }
  }

  Future<List<DailyDetail>> getMonthlyDetails(
    int year,
    int month,
    int userId,
  ) async {
    final response = await coreAPI.get(
      Uri.parse('$baseUrl/daily-details/month/$year/$month?userId=$userId'),
    );
    if (response!.statusCode == 200) {
      final List<dynamic> data = jsonDecode(response.body);
      return data.map((e) => DailyDetail.fromJson(e)).toList();
    }
    throw Exception('Failed to fetch monthly details');
  }
}
