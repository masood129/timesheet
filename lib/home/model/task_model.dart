
import 'package:shamsi_date/shamsi_date.dart';
import 'package:timesheet/home/model/project_model.dart';



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
