class Task {
  final int? projectId;
  final int? duration;
  final String? description;

  Task({
    this.projectId,
    this.duration,
    this.description,
  });

  factory Task.fromJson(Map<String, dynamic> json) {
    return Task(
      projectId: json['ProjectId'],
      duration: json['Duration'],
      description: json['Description'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'projectId': projectId,
      'duration': duration,
      'description': description,
    };
  }
}

class PersonalCarCost {
  final int? projectId;
  final int? cost;
  final String? description;

  PersonalCarCost({
    this.projectId,
    this.cost,
    this.description,
  });

  factory PersonalCarCost.fromJson(Map<String, dynamic> json) {
    return PersonalCarCost(
      projectId: json['ProjectId'],
      cost: json['Cost'],
      description: json['Description'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'projectId': projectId,
      'cost': cost,
      'description': description,
    };
  }
}

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
      date: json['Date'],
      userId: json['UserId'],
      arrivalTime: json['ArrivalTime'],
      leaveTime: json['LeaveTime'],
      leaveType: json['LeaveType'],
      personalTime: json['PersonalTime'],
      description: json['Description'],
      goCost: json['GoCost'],
      returnCost: json['ReturnCost'],
      tasks: (json['tasks'] as List<dynamic>?)
              ?.map((e) => Task.fromJson(e))
              .toList() ??
          [],
      personalCarCosts: (json['personalCarCosts'] as List<dynamic>?)
              ?.map((e) => PersonalCarCost.fromJson(e))
              .toList() ??
          [],
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
      'tasks': tasks.map((e) => e.toJson()).toList(),
      'personalCarCosts': personalCarCosts.map((e) => e.toJson()).toList(),
    };
  }
}