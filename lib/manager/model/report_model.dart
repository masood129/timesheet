class Report {
  final int reportId;
  final int userId;
  final int year;
  final int month;
  final int totalHours;
  final int gymCost;
  final String status;
  final int groupId;
  final String generalManagerStatus;
  final String? managerComment;
  final String? financeComment;
  final String? submittedAt;
  final String? approvedAt;
  final String username;

  Report({
    required this.reportId,
    required this.userId,
    required this.year,
    required this.month,
    required this.totalHours,
    required this.gymCost,
    required this.status,
    required this.groupId,
    required this.generalManagerStatus,
    this.managerComment,
    this.financeComment,
    this.submittedAt,
    this.approvedAt,
    required this.username,
  });

  factory Report.fromJson(Map<String, dynamic> json) {
    return Report(
      reportId: json['ReportId'] as int,
      userId: json['UserId'] as int,
      year: json['Year'] as int,
      month: json['Month'] as int,
      totalHours: json['TotalHours'] as int,
      gymCost: json['GymCost'] as int,
      status: json['Status'] as String,
      groupId: json['GroupId'] as int,
      generalManagerStatus: json['GeneralManagerStatus'] as String,
      managerComment: json['ManagerComment'] as String?,
      financeComment: json['FinanceComment'] as String?,
      submittedAt: json['SubmittedAt'] as String?,
      approvedAt: json['ApprovedAt'] as String?,
      username: json['Username'] as String,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'ReportId': reportId,
      'UserId': userId,
      'Year': year,
      'Month': month,
      'TotalHours': totalHours,
      'GymCost': gymCost,
      'Status': status,
      'GroupId': groupId,
      'GeneralManagerStatus': generalManagerStatus,
      'ManagerComment': managerComment,
      'FinanceComment': financeComment,
      'SubmittedAt': submittedAt,
      'ApprovedAt': approvedAt,
      'Username': username,
    };
  }
}
