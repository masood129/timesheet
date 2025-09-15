/// مدل ProjectHours برای نگهداری ساعت‌های صرف‌شده به تفکیک پروژه
/// این کلاس بر اساس داده‌های API (projectHoursByProject) ساخته شده است.
class ProjectHours {
  final int? projectId; // شناسه پروژه
  final int? totalHours; // مجموع ساعت‌های صرف‌شده

  ProjectHours({this.projectId, this.totalHours});

  /// تبدیل از JSON به شیء
  factory ProjectHours.fromJson(Map<String, dynamic> json) {
    return ProjectHours(
      projectId: json['ProjectID'] ?? json['projectId'],
      totalHours: json['TotalHours'] ?? json['totalHours'],
    );
  }

  /// تبدیل شیء به JSON
  Map<String, dynamic> toJson() {
    return {'ProjectID': projectId, 'TotalHours': totalHours};
  }
}

/// مدل ProjectCarCost (به‌روزرسانی‌شده: برای هزینه‌های ماشین شخصی به تفکیک پروژه)
/// این مدل با کلیدهای API (مانند TotalCost) سازگار است.
class ProjectCarCost {
  final int? projectId;
  final int? cost;

  ProjectCarCost({this.projectId, this.cost});

  factory ProjectCarCost.fromJson(Map<String, dynamic> json) {
    return ProjectCarCost(
      projectId: json['ProjectID'] ?? json['projectId'],
      cost:
          json['TotalCost'] ??
          json['cost'], // سازگار با API (TotalCost در query)
    );
  }

  Map<String, dynamic> toJson() {
    return {'ProjectID': projectId, 'TotalCost': cost};
  }
}

/// مدل اصلی DraftReportModel (به‌روزرسانی‌شده با فیلد projectHoursByProject)
/// این مدل تمام فیلدهای لازم برای پیش‌نویس گزارش را نگهداری می‌کند،
/// شامل جزئیات جدید از API مانند ساعت‌های پروژه و هزینه‌های ماشین.
class DraftReportModel {
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
  final String? groupName;
  final String? managerUsername;
  final int? totalCommuteCost;
  final List<ProjectCarCost>? personalCarCostsByProject;
  final List<ProjectHours>?
  projectHoursByProject; // فیلد جدید: ساعت‌های به تفکیک پروژه

  DraftReportModel({
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
    this.groupName,
    this.managerUsername,
    this.totalCommuteCost,
    this.personalCarCostsByProject,
    this.projectHoursByProject,
  });

  /// تبدیل از JSON به شیء (با پشتیبانی از فیلدهای جدید)
  factory DraftReportModel.fromJson(Map<String, dynamic> json) {
    return DraftReportModel(
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
      groupName: json['GroupName'] ?? json['groupName'],
      managerUsername: json['ManagerUsername'] ?? json['managerUsername'],
      totalCommuteCost: json['totalCommuteCost'],
      personalCarCostsByProject:
          json['personalCarCostsByProject'] != null
              ? (json['personalCarCostsByProject'] as List)
                  .map((item) => ProjectCarCost.fromJson(item))
                  .toList()
              : null,
      projectHoursByProject:
          json['projectHoursByProject'] != null
              ? (json['projectHoursByProject'] as List)
                  .map((item) => ProjectHours.fromJson(item))
                  .toList()
              : null, // پشتیبانی از فیلد جدید
    );
  }

  /// تبدیل شیء به JSON (با فیلدهای جدید)
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
      'GroupName': groupName,
      'ManagerUsername': managerUsername,
      'totalCommuteCost': totalCommuteCost,
      'personalCarCostsByProject':
          personalCarCostsByProject?.map((e) => e.toJson()).toList(),
      'projectHoursByProject':
          projectHoursByProject?.map((e) => e.toJson()).toList(), // فیلد جدید
    };
  }
}
