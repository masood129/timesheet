import 'package:timesheet/home/model/personal_car_cost_model.dart';
import 'package:timesheet/home/model/task_model.dart';

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
  final List<Task> tasks;
  final List<PersonalCarCost> personalCarCosts;

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
    this.tasks = const [],
    this.personalCarCosts = const [],
  });

  factory DailyDetail.fromJson(Map<String, dynamic> json) {
    return DailyDetail(
      date: json['Date'].toString().split('T')[0], // فقط تاریخ (YYYY-MM-DD)
      userId: json['UserId'],
      arrivalTime: json['ArrivalTime'] != null
          ? json['ArrivalTime'].toString().split('T')[1].substring(0, 8) // فقط زمان (HH:MM:SS)
          : null,
      leaveTime: json['LeaveTime'] != null
          ? json['LeaveTime'].toString().split('T')[1].substring(0, 8) // فقط زمان (HH:MM:SS)
          : null,
      leaveType: json['LeaveType'],
      personalTime: json['PersonalTime'],
      description: json['Description'],
      goCost: json['GoCost'],
      returnCost: json['ReturnCost'],
      tasks: (json['tasks'] as List<dynamic>?)
          ?.map((e) => Task.fromJson(e as Map<String, dynamic>))
          .toList() ??
          [],
      personalCarCosts: (json['personalCarCosts'] as List<dynamic>?)
          ?.map((e) => PersonalCarCost.fromJson(e as Map<String, dynamic>))
          .toList() ??
          [],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'date': '${date}T00:00:00.000Z', // تغییر به 'date' با حرف کوچک
      'userId': userId,
      'arrivalTime': arrivalTime,
      'leaveTime': leaveTime,
      'leaveType': leaveType,
      'personalTime': personalTime,
      'description': description,
      'goCost': goCost,
      'returnCost': returnCost,
      'tasks': tasks.map((e) => e.toJson()).toList(),
      'personalCarCosts': personalCarCosts.map((e) => e.toJson()).toList(),
    };
  }
}