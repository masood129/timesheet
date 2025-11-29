import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:shamsi_date/shamsi_date.dart';
import '../../core/api/api_calls/api_calls.dart';
import '../../model/leavetype_model.dart';
import '../../model/monthly_table_model.dart';

class MonthlyTablePage extends StatefulWidget {
  const MonthlyTablePage({super.key});

  @override
  State<MonthlyTablePage> createState() => _MonthlyTablePageState();
}

class _MonthlyTablePageState extends State<MonthlyTablePage> {
  late Future<List<MonthlyTableRowModel>> _dataFuture;
  final ApiCalls _homeApi = ApiCalls();
  late int _jalaliYear;
  late int _jalaliMonth;
  int? _userId;
  Set<int> _uniqueProjectIds = {};

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
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('فایل اکسل دانلود شد: $filePath'),
                      behavior: SnackBarBehavior.floating,
                    ),
                  );
                }
              } catch (e) {
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('خطا در دانلود: $e'),
                      behavior: SnackBarBehavior.floating,
                    ),
                  );
                }
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
              final sortedProjectIds = _uniqueProjectIds.toList()..sort();

              // Calculate column widths
              final totalWidth = constraints.maxWidth;
              const fixedColumnWidth = 80.0; // Fixed width for standard columns
              final projectColumnWidth = (totalWidth - (9 * fixedColumnWidth)) / sortedProjectIds.length.clamp(1, double.infinity);

              return Column(
                children: [
                  // Header Table (Fixed)
                  SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    physics: const AlwaysScrollableScrollPhysics(),
                    child: ConstrainedBox(
                      constraints: BoxConstraints(
                        minWidth: totalWidth,
                      ),
                      child: DataTable(
                        border: TableBorder.all(color: Colors.grey.shade300, width: 1),
                        headingRowColor: WidgetStateProperty.all(Colors.blueGrey[700]),
                        headingTextStyle: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                        headingRowHeight: 56,
                        columnSpacing: 16,
                        columns: <DataColumn>[
                          DataColumn(
                            label: SizedBox(
                              width: fixedColumnWidth,
                              child: Text('روز هفته', style: _getHeaderStyle(), textAlign: TextAlign.center),
                            ),
                          ),
                          DataColumn(
                            label: SizedBox(
                              width: fixedColumnWidth,
                              child: Text('تاریخ', style: _getHeaderStyle(), textAlign: TextAlign.center),
                            ),
                          ),
                          DataColumn(
                            label: SizedBox(
                              width: fixedColumnWidth,
                              child: Text('ساعت ورود', style: _getHeaderStyle(), textAlign: TextAlign.center),
                            ),
                          ),
                          DataColumn(
                            label: SizedBox(
                              width: fixedColumnWidth,
                              child: Text('ساعت خروج', style: _getHeaderStyle(), textAlign: TextAlign.center),
                            ),
                          ),
                          DataColumn(
                            label: SizedBox(
                              width: fixedColumnWidth,
                              child: Text('ساعت شخصی', style: _getHeaderStyle(), textAlign: TextAlign.center),
                            ),
                          ),
                          DataColumn(
                            label: SizedBox(
                              width: fixedColumnWidth,
                              child: Text('وضعیت مرخصی', style: _getHeaderStyle(), textAlign: TextAlign.center),
                            ),
                          ),
                          DataColumn(
                            label: SizedBox(
                              width: fixedColumnWidth,
                              child: Text('مجموع کارکرد', style: _getHeaderStyle(), textAlign: TextAlign.center),
                            ),
                          ),
                          DataColumn(
                            label: SizedBox(
                              width: fixedColumnWidth,
                              child: Text('تاخیر ورود', style: _getHeaderStyle(), textAlign: TextAlign.center),
                            ),
                          ),
                          DataColumn(
                            label: SizedBox(
                              width: fixedColumnWidth,
                              child: Text('توضیحات', style: _getHeaderStyle(), textAlign: TextAlign.center),
                            ),
                          ),
                          ...sortedProjectIds.map(
                                (id) => DataColumn(
                              label: SizedBox(
                                width: projectColumnWidth,
                                child: Text('پروژه $id', style: _getHeaderStyle(), textAlign: TextAlign.center),
                              ),
                            ),
                          ),
                        ],
                        rows: const [], // Empty rows for header
                      ),
                    ),
                  ),
                  // Data Table (Scrollable)
                  Expanded(
                    child: SingleChildScrollView(
                      scrollDirection: Axis.vertical,
                      physics: const AlwaysScrollableScrollPhysics(),
                      child: SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        physics: const AlwaysScrollableScrollPhysics(),
                        child: ConstrainedBox(
                          constraints: BoxConstraints(
                            minWidth: totalWidth,
                          ),
                          child: DataTable(
                            border: TableBorder.all(color: Colors.grey.shade300, width: 1),
                            dataRowMinHeight: 40,
                            dataRowMaxHeight: 100,
                            columnSpacing: 16,
                            columns: <DataColumn>[
                              DataColumn(label: SizedBox(width: fixedColumnWidth)),
                              DataColumn(label: SizedBox(width: fixedColumnWidth)),
                              DataColumn(label: SizedBox(width: fixedColumnWidth)),
                              DataColumn(label: SizedBox(width: fixedColumnWidth)),
                              DataColumn(label: SizedBox(width: fixedColumnWidth)),
                              DataColumn(label: SizedBox(width: fixedColumnWidth)),
                              DataColumn(label: SizedBox(width: fixedColumnWidth)),
                              DataColumn(label: SizedBox(width: fixedColumnWidth)),
                              DataColumn(label: SizedBox(width: fixedColumnWidth)),
                              ...sortedProjectIds.map((_) => DataColumn(label: SizedBox(width: projectColumnWidth))),
                            ],
                            rows: data.map((row) {
                              final leaveType = LeaveTypeExtension.fromString(row.leaveType);
                              return DataRow(
                                color: WidgetStateProperty.all(_getRowColor(leaveType)),
                                cells: <DataCell>[
                                  DataCell(
                                    SizedBox(
                                      width: fixedColumnWidth,
                                      child: Text(row.dayOfWeek, style: _getCellStyle(), textAlign: TextAlign.center),
                                    ),
                                  ),
                                  DataCell(
                                    SizedBox(
                                      width: fixedColumnWidth,
                                      child: Text(row.date, style: _getCellStyle(), textAlign: TextAlign.center),
                                    ),
                                  ),
                                  DataCell(
                                    SizedBox(
                                      width: fixedColumnWidth,
                                      child: Text(_formatTime(row.arrivalTime), style: _getCellStyle(), textAlign: TextAlign.center),
                                    ),
                                  ),
                                  DataCell(
                                    SizedBox(
                                      width: fixedColumnWidth,
                                      child: Text(_formatTime(row.leaveTime), style: _getCellStyle(), textAlign: TextAlign.center),
                                    ),
                                  ),
                                  DataCell(
                                    SizedBox(
                                      width: fixedColumnWidth,
                                      child: Text(_formatMinutes(row.personalTime), style: _getCellStyle(), textAlign: TextAlign.center),
                                    ),
                                  ),
                                  DataCell(
                                    SizedBox(
                                      width: fixedColumnWidth,
                                      child: Text(_translateLeaveType(row.leaveType), style: _getCellStyle(), textAlign: TextAlign.center),
                                    ),
                                  ),
                                  DataCell(
                                    SizedBox(
                                      width: fixedColumnWidth,
                                      child: Text(_formatMinutes(row.totalDailyWork), style: _getCellStyle(), textAlign: TextAlign.center),
                                    ),
                                  ),
                                  DataCell(
                                    SizedBox(
                                      width: fixedColumnWidth,
                                      child: Text(_formatMinutes(row.entryDelay), style: _getCellStyle(), textAlign: TextAlign.center),
                                    ),
                                  ),
                                  DataCell(
                                    SizedBox(
                                      width: fixedColumnWidth,
                                      child: Text(row.description ?? '-', style: _getCellStyle(), textAlign: TextAlign.center),
                                    ),
                                  ),
                                  ...sortedProjectIds.map(
                                        (id) => DataCell(
                                      SizedBox(
                                        width: projectColumnWidth,
                                        child: Text(_getProjectDuration(row.projects, id), style: _getCellStyle(), textAlign: TextAlign.center),
                                      ),
                                    ),
                                  ),
                                ],
                              );
                            }).toList(),
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
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