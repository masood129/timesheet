import 'task_model.dart';

class DailyDetail {
  final String date;
  final int userId;
  final String? arrivalTime;
  final String? leaveTime;
  final String? leaveType;
  final int? personalTime;
  final String? description;
  final int? goCost;
  final int? returnCost;
  final int? personalCarCost;
  final List<Task> tasks;

  DailyDetail({
    required this.date,
    required this.userId,
    this.arrivalTime,
    this.leaveTime,
    this.leaveType,
    this.personalTime,
    this.description,
    this.goCost,
    this.returnCost,
    this.personalCarCost,
    this.tasks = const [],
  });

  factory DailyDetail.fromJson(Map<String, dynamic> json) {
    return DailyDetail(
      date: json['Date'],
      userId: json['UserId'],
      arrivalTime: json['ArrivalTime'],
      leaveTime: json['LeaveTime'],
      leaveType: json['LeaveType'],
      personalTime: json['PersonalTime'],
      description: json['Description'],
      goCost: json['GoCost'],
      returnCost: json['ReturnCost'],
      personalCarCost: json['PersonalCarCost'],
      tasks: (json['tasks'] as List<dynamic>?)?.map((e) => Task.fromJson(e)).toList() ?? [],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'date': date,
      'userId': userId,
      'arrivalTime': arrivalTime,
      'leaveTime': leaveTime,
      'leaveType': leaveType,
      'personalTime': personalTime,
      'description': description,
      'goCost': goCost,
      'returnCost': returnCost,
      'personalCarCost': personalCarCost,
      'tasks': tasks.map((e) => e.toJson()).toList(),
    };
  }
}