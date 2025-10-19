import 'package:timesheet/model/personal_car_cost_model.dart';
import 'package:timesheet/model/task_model.dart';

import 'leavetype_model.dart'; // import enum

class DailyDetail {
  final String date;
  final int userId;
  final String? arrivalTime;
  final String? leaveTime;
  final LeaveType? leaveType; // تغییر از String? به LeaveType?
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
    this.personalTime,
    this.description,
    this.goCost,
    this.returnCost,
    this.tasks = const [],
    this.personalCarCosts = const [],
    String? leaveTypeString, // برای سازگاری با backend
  }) : leaveType = LeaveTypeExtension.fromString(leaveTypeString);

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
      leaveTypeString: json['LeaveType'],
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
      'leaveType': leaveType?.apiValue,
      'personalTime': personalTime,
      'description': description,
      'goCost': goCost,
      'returnCost': returnCost,
      'tasks': tasks.map((e) => e.toJson()).toList(),
      'personalCarCosts': personalCarCosts.map((e) => e.toJson()).toList(),
    };
  }
}