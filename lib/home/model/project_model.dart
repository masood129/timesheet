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
