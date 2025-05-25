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