import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shamsi_date/shamsi_date.dart';

class Project {
  final int id;
  final String projectName;
  final int securityLevel;

  Project({
    required this.id,
    required this.projectName,
    required this.securityLevel,
  });

  factory Project.fromJson(Map<String, dynamic> json) {
    return Project(
      id: json['Id'],
      projectName: json['ProjectName'],
      securityLevel: json['securityLevel'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'Id': id,
      'ProjectName': projectName,
      'securityLevel': securityLevel,
    };
  }
}


class Task {
  final Jalali date;
  final String? arrivalTime;
  final String? leaveTime;
  final int? personalTime;
  final String leaveType;
  final List<TaskDetail> tasks;
  final String? description;
  final int? goCost;
  final int? returnCost;
  final int? personalCarCost; // فیلد جدید

  Task({
    required this.date,
    this.arrivalTime,
    this.leaveTime,
    this.personalTime,
    required this.leaveType,
    required this.tasks,
    this.description,
    this.goCost,
    this.returnCost,
    this.personalCarCost, // فیلد جدید
  });

  factory Task.fromJson(Map<String, dynamic> json) {
    final dateStr = json['date'] as String;
    final parts = dateStr.split('-').map(int.parse).toList();
    final gregorian = Gregorian(parts[0], parts[1], parts[2]);
    return Task(
      date: Jalali.fromGregorian(gregorian),
      arrivalTime: json['arrivalTime'],
      leaveTime: json['leaveTime'],
      personalTime: json['personalTime'],
      leaveType: json['leaveType'],
      tasks: (json['tasks'] as List).map((e) => TaskDetail.fromJson(e)).toList(),
      description: json['description'],
      goCost: json['goCost'],
      returnCost: json['returnCost'],
      personalCarCost: json['personalCarCost'], // فیلد جدید
    );
  }

  Map<String, dynamic> toJson() {
    final gregorian = date.toGregorian();
    final dateStr =
        '${gregorian.year}-${gregorian.month.toString().padLeft(2, '0')}-${gregorian.day.toString().padLeft(2, '0')}';
    return {
      'date': dateStr,
      'arrivalTime': arrivalTime,
      'leaveTime': leaveTime,
      'personalTime': personalTime,
      'leaveType': leaveType,
      'tasks': tasks.map((e) => e.toJson()).toList(),
      'description': description,
      'goCost': goCost,
      'returnCost': returnCost,
      'personalCarCost': personalCarCost, // فیلد جدید
    };
  }
}

class TaskDetail {
  final Project? project;
  final int? duration;
  final String? description;

  TaskDetail({this.project, this.duration, this.description});

  factory TaskDetail.fromJson(Map<String, dynamic> json) {
    return TaskDetail(
      project: json['project'] != null ? Project.fromJson(json['project']) : null,
      duration: json['duration'],
      description: json['description'],
    );
  }

  Map<String, dynamic> toJson() => {
    'project': project?.toJson(),
    'duration': duration,
    'description': description,
  };
}

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

class TaskModel {
  final Jalali date;
  final Map<String, String> fields; // داده‌های فیلدهای سفارشی

  TaskModel({
    required this.date,
    required this.fields,
  });
}