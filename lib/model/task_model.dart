class Task {
  final int? id;
  final String? date;
  final int? userId;
  final int projectId;
  final String? projectName; // اضافه شد برای نمایش نام پروژه
  final int? duration;
  final String? description;

  Task({
    this.id,
    this.date,
    this.userId,
    required this.projectId,
    this.projectName,
    this.duration,
    this.description,
  });

  factory Task.fromJson(Map<String, dynamic> json) {
    return Task(
      id: json['Id'],
      date: json['Date'],
      userId: json['UserId'],
      projectId: json['ProjectId'],
      projectName: json['ProjectName'], // اضافه شد
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