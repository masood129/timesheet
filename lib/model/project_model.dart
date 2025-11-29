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
    // Handle different field name cases (SQL Server might return different cases)
    final idValue = json['Id'] ?? json['id'] ?? json['ID'];
    final projectNameValue = json['ProjectName'] ?? json['projectName'] ?? json['projectname'];
    final securityLevelValue = json['securityLevel'] ?? json['SecurityLevel'] ?? json['securitylevel'] ?? 0;
    
    if (idValue == null) {
      throw Exception('Project id is required. Available keys: ${json.keys.toList()}');
    }
    if (projectNameValue == null) {
      throw Exception('Project name is required. Available keys: ${json.keys.toList()}');
    }
    
    return Project(
      id: idValue is int ? idValue : int.tryParse(idValue.toString()) ?? 0,
      projectName: projectNameValue.toString(),
      securityLevel: securityLevelValue is int ? securityLevelValue : int.tryParse(securityLevelValue.toString()) ?? 0,
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