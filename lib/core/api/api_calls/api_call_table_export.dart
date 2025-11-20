part of 'api_calls.dart';

extension HomeApiTableExport on ApiCalls {
  Future<List<MonthlyTableRowModel>> getUserMonthlyTableData(
      int userId,
      int jalaliYear,
      int jalaliMonth,
      ) async {
    final response = await coreAPI.get(
      Uri.parse(
        '$baseUrl/daily-details/user/$userId/jalali/month/$jalaliYear/$jalaliMonth',
      ),
      headers: defaultHeaders,
    );
    if (response == null) {
      throw Exception('Failed to fetch: No response from server');
    }
    if (response.statusCode == 200) {
      final List<dynamic> data = jsonDecode(response.body);
      return data
          .map((e) => MonthlyTableRowModel.fromJson(e as Map<String, dynamic>))
          .toList();
    }
    if (response.statusCode == 400) {
      throw Exception('Invalid input');
    }
    if (response.statusCode == 403) {
      throw Exception('Access denied');
    }
    throw Exception('Failed to fetch monthly data: ${response.statusCode}');
  }

  Future<String> exportUserMonthlyToExcel(
      int userId,
      int jalaliYear,
      int jalaliMonth,
      ) async {
    final response = await coreAPI.get(
      Uri.parse(
        '$baseUrl/daily-details/user/$userId/jalali/month/$jalaliYear/$jalaliMonth/export-excel',
      ),
      headers: defaultHeaders,
    );
    if (response == null) {
      throw Exception('Failed to export: No response from server');
    }
    if (response.statusCode == 200) {
      final bytes = response.bodyBytes; // Since it's binary
      final fileName = 'monthly_details_${jalaliYear}_$jalaliMonth.xlsx';

      if (kIsWeb) {
        final result = await triggerBrowserDownload(bytes, fileName);
        if (result != null) {
          return result;
        }
        throw Exception('Browser download failed.');
      }

      Directory? directory = await downloadsDirectory;
      directory ??= await applicationDocumentsDirectory;
      if (directory == null) {
        throw Exception('Unable to locate a writable directory.');
      }

      final filePath = '${directory.path}/$fileName';
      final file = File(filePath);
      await file.writeAsBytes(bytes);

      return filePath; // Return path for UI feedback
    }
    if (response.statusCode == 400) {
      throw Exception('Invalid input');
    }
    if (response.statusCode == 403) {
      throw Exception('Access denied');
    }
    throw Exception('Failed to export excel: ${response.statusCode}');
  }
}