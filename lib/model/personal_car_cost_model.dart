class PersonalCarCost {
  final int? projectId;
  final String? projectName; // اضافه شد برای نمایش نام پروژه
  final int? kilometers;
  final int? cost;
  final String? description;

  PersonalCarCost({
    this.projectId,
    this.projectName,
    this.kilometers,
    this.cost,
    this.description,
  });

  factory PersonalCarCost.fromJson(Map<String, dynamic> json) {
    return PersonalCarCost(
      projectId: json['ProjectId'],
      projectName: json['ProjectName'], // اضافه شد
      kilometers: json['Kilometers'],
      cost: json['Cost'],
      description: json['Description'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'projectId': projectId,
      'kilometers': kilometers,
      'cost': cost,
      'description': description,
    };
  }
}