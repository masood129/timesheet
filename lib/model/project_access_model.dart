class ProjectAccess {
  final int id;
  final String projectName;
  final bool hasAccess;

  ProjectAccess({
    required this.id,
    required this.projectName,
    required this.hasAccess,
  });

  factory ProjectAccess.fromJson(Map<String, dynamic> json) {
    return ProjectAccess(
      id: json['id'],
      projectName: json['projectName'],
      hasAccess: json['hasAccess'] == 1 || json['hasAccess'] == true,
    );
  }

  Map<String, dynamic> toJson() {
    return {'id': id, 'projectName': projectName, 'hasAccess': hasAccess};
  }

  ProjectAccess copyWith({int? id, String? projectName, bool? hasAccess}) {
    return ProjectAccess(
      id: id ?? this.id,
      projectName: projectName ?? this.projectName,
      hasAccess: hasAccess ?? this.hasAccess,
    );
  }
}
