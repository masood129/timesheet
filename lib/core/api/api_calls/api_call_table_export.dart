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
      // Save the file locally to Downloads
      final bytes = response.bodyBytes; // Since it's binary
      Directory? directory = await downloadsDirectory;
      directory ??= await applicationDocumentsDirectory;
      final filePath =
          '${directory.path}/monthly_details_${jalaliYear}_$jalaliMonth.xlsx';
      final file = File(filePath);
      await file.writeAsBytes(bytes);

      // Optional: Open the file if you have open_file package
      // OpenFile.open(filePath);

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