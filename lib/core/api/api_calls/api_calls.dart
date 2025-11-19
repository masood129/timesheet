import 'dart:io';

import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:timesheet/core/api/api_service.dart';
import 'dart:convert';
import '../../../model/daily_detail_model.dart';
import '../../../model/draft_report_model.dart';
import '../../../model/monthly_report_model.dart';
import '../../../model/monthly_table_model.dart';
import '../../../model/project_model.dart';
import '../../../model/user_model.dart';

part 'api_call_auth.dart';
part 'api_call_gym_cost.dart';
part 'api_call_report_status.dart';
part 'api_call_projects.dart';
part 'api_call_daily_details.dart';
part 'api_call_monthly_reports.dart';
part 'api_call_drafts.dart';
part 'api_call_users.dart';
part 'api_call_table_export.dart';

class ApiCalls {
  static final ApiCalls _instance = ApiCalls._internal();

  factory ApiCalls() {
    return _instance;
  }

  late final String baseUrl;

  ApiCalls._internal() {
    baseUrl = 'http://10.10.40.235:3000'; // یا از dotenv بگیرید
  }

  final coreAPI = CoreApi();
  final downloadsDirectory = getDownloadsDirectory();
  final applicationDocumentsDirectory = getApplicationDocumentsDirectory();
  final Map<String, String> defaultHeaders = {
    'Content-Type': 'application/json',
    'accept': 'application/json',
  };
}