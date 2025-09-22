// monthly_table_model.dart remains the same as before

class MonthlyTableRowModel {
  final String dayOfWeek;
  final String date;
  final String? arrivalTime;
  final String? leaveTime;
  final int personalTime;
  final String? leaveType;
  final List<ProjectEntry> projects;
  final int totalDailyWork;
  final int entryDelay;
  final String? description;

  MonthlyTableRowModel({
    required this.dayOfWeek,
    required this.date,
    this.arrivalTime,
    this.leaveTime,
    required this.personalTime,
    this.leaveType,
    required this.projects,
    required this.totalDailyWork,
    required this.entryDelay,
    this.description,
  });

  factory MonthlyTableRowModel.fromJson(Map<String, dynamic> json) {
    return MonthlyTableRowModel(
      dayOfWeek: json['dayOfWeek'] as String? ?? '-',
      date: json['date'] as String? ?? '-',
      arrivalTime: json['arrivalTime'] as String?,
      leaveTime: json['leaveTime'] as String?,
      personalTime: json['personalTime'] as int? ?? 0,
      leaveType: json['leaveType'] as String?,
      projects: (json['projects'] as List<dynamic>? ?? [])
          .map((p) => ProjectEntry.fromJson(p as Map<String, dynamic>))
          .toList(),
      totalDailyWork: json['totalDailyWork'] as int? ?? 0,
      entryDelay: json['entryDelay'] as int? ?? 0,
      description: json['description'] as String?,
    );
  }
}

class ProjectEntry {
  final int projectId;
  final int duration;
  final String? description;

  ProjectEntry({
    required this.projectId,
    required this.duration,
    this.description,
  });

  factory ProjectEntry.fromJson(Map<String, dynamic> json) {
    return ProjectEntry(
      projectId: json['projectId'] as int? ?? 0,
      duration: json['duration'] as int? ?? 0,
      description: json['description'] as String?,
    );
  }
}