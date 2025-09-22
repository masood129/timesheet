import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:shamsi_date/shamsi_date.dart';
import 'package:timesheet/home/model/monthly_table_model.dart';

import '../../core/api/api_calls.dart';
import '../model/leavetype_model.dart'; // Import LeaveType

class MonthlyTablePage extends StatefulWidget {
  const MonthlyTablePage({super.key});

  @override
  State<MonthlyTablePage> createState() => _MonthlyTablePageState();
}

class _MonthlyTablePageState extends State<MonthlyTablePage> {
  late Future<List<MonthlyTableRowModel>> _dataFuture;
  final HomeApi _homeApi = HomeApi();
  late int _jalaliYear;
  late int _jalaliMonth;
  int? _userId;
  Set<int> _uniqueProjectIds = {}; // To store unique project IDs

  @override
  void initState() {
    super.initState();
    final now = Jalali.now();
    _jalaliYear = now.year;
    _jalaliMonth = now.month;
    _loadUserIdAndFetch();
  }

  Future<void> _loadUserIdAndFetch() async {
    final prefs = await SharedPreferences.getInstance();
    _userId = prefs.getInt('userId');
    if (_userId == null) {
      throw Exception('User not logged in');
    }
    setState(() {
      _dataFuture = _fetchData();
    });
  }

  Future<List<MonthlyTableRowModel>> _fetchData() async {
    final data = await _homeApi.getUserMonthlyTableData(
      _userId!,
      _jalaliYear,
      _jalaliMonth,
    );
    // Extract unique project IDs
    _uniqueProjectIds = {};
    for (var row in data) {
      for (var project in row.projects) {
        _uniqueProjectIds.add(project.projectId);
      }
    }
    return data;
  }

  void _previousMonth() {
    setState(() {
      if (_jalaliMonth == 1) {
        _jalaliMonth = 12;
        _jalaliYear--;
      } else {
        _jalaliMonth--;
      }
      _dataFuture = _fetchData();
    });
  }

  void _nextMonth() {
    setState(() {
      if (_jalaliMonth == 12) {
        _jalaliMonth = 1;
        _jalaliYear++;
      } else {
        _jalaliMonth++;
      }
      _dataFuture = _fetchData();
    });
  }

  String _formatTime(String? isoTime) {
    if (isoTime == null) return '-';
    final dateTime = DateTime.parse(isoTime);
    return DateFormat('HH:mm').format(dateTime);
  }

  String _formatMinutes(int minutes) {
    final hours = minutes ~/ 60;
    final mins = minutes % 60;
    return '$hours:${mins.toString().padLeft(2, '0')}';
  }

  String _getProjectDuration(List<ProjectEntry> projects, int projectId) {
    final project = projects.firstWhere(
          (p) => p.projectId == projectId,
      orElse: () => ProjectEntry(projectId: projectId, duration: 0),
    );
    return _formatMinutes(project.duration);
  }

  String _translateLeaveType(String? type) {
    switch (type) {
      case 'work':
        return 'روزکاری';
      case 'annual_leave':
        return 'مرخصی سالانه';
      case 'sick_leave':
        return 'مرخصی استعلاجی';
      case 'gift_leave':
        return 'مرخصی هدیه';
      case 'mission':
        return 'ماموریت';
      default:
        return type ?? '-';
    }
  }

  Color _getRowColor(LeaveType? leaveType) {
    switch (leaveType) {
      case LeaveType.work:
        return Colors.white;
      case LeaveType.annualLeave:
        return Colors.yellow[100]!;
      case LeaveType.sickLeave:
        return Colors.red[100]!;
      case LeaveType.giftLeave:
        return Colors.green[100]!;
      case LeaveType.mission:
        return Colors.blue[100]!;
      default:
        return Colors.grey[100]!;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('جدول ماهانه - $_jalaliYear/${_jalaliMonth.toString().padLeft(2, '0')}'),
        actions: [
          IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: _previousMonth,
          ),
          IconButton(
            icon: const Icon(Icons.arrow_forward),
            onPressed: _nextMonth,
          ),
          IconButton(
            icon: const Icon(Icons.download),
            onPressed: () async {
              try {
                final filePath = await _homeApi.exportUserMonthlyToExcel(
                  _userId!,
                  _jalaliYear,
                  _jalaliMonth,
                );
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('فایل اکسل دانلود شد: $filePath')),
                );
              } catch (e) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('خطا در دانلود: $e')),
                );
              }
            },
          ),
        ],
      ),
      body: LayoutBuilder(
        builder: (context, constraints) {
          return FutureBuilder<List<MonthlyTableRowModel>>(
            future: _dataFuture,
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              } else if (snapshot.hasError) {
                return Center(child: Text('خطا: ${snapshot.error}'));
              } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                return const Center(child: Text('هیچ داده‌ای موجود نیست'));
              }

              final data = snapshot.data!;
              final sortedProjectIds = _uniqueProjectIds.toList()..sort(); // Sort for consistent order

              // Calculate column width based on screen width
              final numColumns = 9 + sortedProjectIds.length; // Fixed columns + project columns
              final columnWidth = constraints.maxWidth / numColumns.clamp(1, 15); // Clamp to avoid too small

              return SingleChildScrollView(
                child: SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: DataTable(
                    border: TableBorder.all(color: Colors.grey.shade300, width: 1),
                    headingRowColor: WidgetStateProperty.all(Colors.blueGrey[700]),
                    headingTextStyle: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                    headingRowHeight: 56,
                    dataRowMinHeight: 40,
                    dataRowMaxHeight: 100,
                    columnSpacing: 16,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(8),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.grey.withOpacity(0.5),
                          spreadRadius: 2,
                          blurRadius: 5,
                          offset: const Offset(0, 3),
                        ),
                      ],
                    ),
                    columns: <DataColumn>[
                      DataColumn(label: Text('روز هفته', style: _getHeaderStyle())),
                      DataColumn(label: Text('تاریخ', style: _getHeaderStyle())),
                      DataColumn(label: Text('ساعت ورود', style: _getHeaderStyle())),
                      DataColumn(label: Text('ساعت خروج', style: _getHeaderStyle())),
                      DataColumn(label: Text('ساعت شخصی', style: _getHeaderStyle())),
                      DataColumn(label: Text('وضعیت مرخصی', style: _getHeaderStyle())),
                      DataColumn(label: Text('مجموع کارکرد', style: _getHeaderStyle())),
                      DataColumn(label: Text('تاخیر ورود', style: _getHeaderStyle())),
                      DataColumn(label: Text('توضیحات', style: _getHeaderStyle())),
                      ...sortedProjectIds.map((id) => DataColumn(
                        label: Text('پروژه $id', style: _getHeaderStyle()),
                      )),
                    ], // If sorting needed, add logic
                    rows: data.map((row) {
                      final leaveType = LeaveTypeExtension.fromString(row.leaveType);
                      return DataRow(
                        color: WidgetStateProperty.all(_getRowColor(leaveType)),
                        cells: <DataCell>[
                          DataCell(Text(row.dayOfWeek, style: _getCellStyle())),
                          DataCell(Text(row.date, style: _getCellStyle())),
                          DataCell(Text(_formatTime(row.arrivalTime), style: _getCellStyle())),
                          DataCell(Text(_formatTime(row.leaveTime), style: _getCellStyle())),
                          DataCell(Text(_formatMinutes(row.personalTime), style: _getCellStyle())),
                          DataCell(Text(_translateLeaveType(row.leaveType), style: _getCellStyle())),
                          DataCell(Text(_formatMinutes(row.totalDailyWork), style: _getCellStyle())),
                          DataCell(Text(_formatMinutes(row.entryDelay), style: _getCellStyle())),
                          DataCell(Text(row.description ?? '-', style: _getCellStyle())),
                          ...sortedProjectIds.map((id) => DataCell(
                            Text(_getProjectDuration(row.projects, id), style: _getCellStyle()),
                          )),
                        ],
                      );
                    }).toList(),
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }

  TextStyle _getHeaderStyle() {
    return const TextStyle(
      color: Colors.white,
      fontWeight: FontWeight.bold,
      fontSize: 14,
    );
  }

  TextStyle _getCellStyle() {
    return const TextStyle(
      fontSize: 12,
      color: Colors.black87,
    );
  }
}