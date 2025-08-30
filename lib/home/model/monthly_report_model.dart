class MonthlyReport {
  final int? reportId;
  final int? userId;
  final int? year;
  final int? month;
  final int? totalHours;
  final int? gymCost;
  final String? status;
  final int? groupId;
  final String? generalManagerStatus;
  final String? managerComment;
  final String? financeComment;
  final DateTime? submittedAt;
  final DateTime? approvedAt;
  final int? jalaliYear;
  final int? jalaliMonth;
  final String? username;

  MonthlyReport({
    this.reportId,
    this.userId,
    this.year,
    this.month,
    this.totalHours,
    this.gymCost,
    this.status,
    this.groupId,
    this.generalManagerStatus,
    this.managerComment,
    this.financeComment,
    this.submittedAt,
    this.approvedAt,
    this.jalaliYear,
    this.jalaliMonth,
    this.username,
  });

  factory MonthlyReport.fromJson(Map<String, dynamic> json) {
    return MonthlyReport(
      reportId: json['ReportId'] ?? json['reportId'],
      userId: json['UserId'] ?? json['userId'],
      year: json['Year'] ?? json['year'],
      month: json['Month'] ?? json['month'],
      totalHours: json['TotalHours'] ?? json['totalHours'],
      gymCost: json['GymCost'] ?? json['gymCost'],
      status: json['Status'] ?? json['status'],
      groupId: json['GroupId'] ?? json['groupId'],
      generalManagerStatus:
      json['GeneralManagerStatus'] ?? json['generalManagerStatus'],
      managerComment: json['ManagerComment'] ?? json['managerComment'],
      financeComment: json['FinanceComment'] ?? json['financeComment'],
      submittedAt:
      json['SubmittedAt'] != null
          ? DateTime.tryParse(json['SubmittedAt'])
          : null,
      approvedAt:
      json['ApprovedAt'] != null
          ? DateTime.tryParse(json['ApprovedAt'])
          : null,
      jalaliYear: json['JalaliYear'] ?? json['jalaliYear'],
      jalaliMonth: json['JalaliMonth'] ?? json['jalaliMonth'],
      username: json['Username'] ?? json['username'],
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
      'SubmittedAt': submittedAt?.toIso8601String(),
      'ApprovedAt': approvedAt?.toIso8601String(),
      'JalaliYear': jalaliYear,
      'JalaliMonth': jalaliMonth,
      'Username': username,
    };
  }
}
