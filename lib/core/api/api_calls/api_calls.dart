import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:path_provider/path_provider.dart';
import 'package:timesheet/core/utils/browser_download.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:timesheet/core/api/api_service.dart';
import 'dart:convert';
import '../../../model/daily_detail_model.dart';
import '../../../model/draft_report_model.dart';
import '../../../model/monthly_report_model.dart';
import '../../../model/monthly_table_model.dart';
import '../../../model/project_model.dart';
import '../../../model/project_access_model.dart';
import '../../../model/user_model.dart';
import '../../../data/models/month_period_model.dart';

part 'api_call_auth.dart';
part 'api_call_gym_cost.dart';
part 'api_call_report_status.dart';
part 'api_call_projects.dart';
part 'api_call_daily_details.dart';
part 'api_call_monthly_reports.dart';
part 'api_call_drafts.dart';
part 'api_call_users.dart';
part 'api_call_table_export.dart';
part 'api_call_month_periods.dart';
part 'api_call_user_project_access.dart';

class ApiCalls {
  static final ApiCalls _instance = ApiCalls._internal();

  factory ApiCalls() {
    return _instance;
  }

  ApiCalls._internal();

  final coreAPI = CoreApi();
  String get baseUrl => coreAPI.baseUrl;

  Future<Directory?> get downloadsDirectory async {
    if (kIsWeb) return null;
    try {
      return await getDownloadsDirectory();
    } catch (_) {
      return null;
    }
  }

  Future<Directory?> get applicationDocumentsDirectory async {
    if (kIsWeb) return null;
    try {
      return await getApplicationDocumentsDirectory();
    } catch (_) {
      return null;
    }
  }

  final Map<String, String> defaultHeaders = {
    'Content-Type': 'application/json',
    'accept': 'application/json',
  };
}
