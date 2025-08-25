class MonthlyReport {
  final int reportId;
  final int userId;
  final int year;
  final int month;
  final int totalHours;
  final int gymCost;
  final String status;
  final int? groupId;
  final String? username;
  final DateTime? submittedAt;
  final DateTime? approvedAt;
  final String? managerComment;
  final String? financeComment;

  MonthlyReport({
    required this.reportId,
    required this.userId,
    required this.year,
    required this.month,
    required this.totalHours,
    required this.gymCost,
    required this.status,
    this.groupId,
    this.username,
    this.submittedAt,
    this.approvedAt,
    this.managerComment,
    this.financeComment,
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
      username: json['Username'] ?? json['username'],
      submittedAt: json['SubmittedAt'] != null ? DateTime.parse(json['SubmittedAt']) : null,
      approvedAt: json['ApprovedAt'] != null ? DateTime.parse(json['ApprovedAt']) : null,
      managerComment: json['ManagerComment'] ?? json['managerComment'],
      financeComment: json['FinanceComment'] ?? json['financeComment'],
    );
  }
}