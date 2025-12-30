import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:shamsi_date/shamsi_date.dart';
import '../../core/api/api_calls/api_calls.dart';
import '../../model/leavetype_model.dart';
import '../../model/monthly_table_model.dart';
import '../../model/project_access_model.dart';
import '../../core/utils/page_title_manager.dart';

class MonthlyTablePage extends StatefulWidget {
  const MonthlyTablePage({super.key});

  @override
  State<MonthlyTablePage> createState() => _MonthlyTablePageState();
}

class _MonthlyTablePageState extends State<MonthlyTablePage> {
  late Future<List<MonthlyTableRowModel>> _dataFuture;
  late Future<List<ProjectAccess>> _projectsFuture;
  final ApiCalls _homeApi = ApiCalls();
  late int _jalaliYear;
  late int _jalaliMonth;
  int? _userId;
  List<ProjectAccess> _allProjects = [];
  List<MonthlyTableRowModel> _allData = [];
  bool _isLoading = false;

  // Filter states
  String _searchQuery = '';
  String? _selectedLeaveType;
  int? _selectedProjectId;
  final TextEditingController _searchController = TextEditingController();
  final ScrollController _headerScrollController = ScrollController();
  final ScrollController _bodyScrollController = ScrollController();
  bool _isSyncing = false;

  @override
  void initState() {
    super.initState();
    PageTitleManager.setTitle('جدول ماهانه');
    final now = Jalali.now();
    _jalaliYear = now.year;
    _jalaliMonth = now.month;
    _loadUserIdAndFetch();

    _headerScrollController.addListener(() {
      if (_isSyncing) return;
      _isSyncing = true;
      if (_bodyScrollController.hasClients) {
        _bodyScrollController.jumpTo(_headerScrollController.offset);
      }
      _isSyncing = false;
    });

    _bodyScrollController.addListener(() {
      if (_isSyncing) return;
      _isSyncing = true;
      if (_headerScrollController.hasClients) {
        _headerScrollController.jumpTo(_bodyScrollController.offset);
      }
      _isSyncing = false;
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    _headerScrollController.dispose();
    _bodyScrollController.dispose();
    super.dispose();
  }

  Future<void> _loadUserIdAndFetch() async {
    final prefs = await SharedPreferences.getInstance();
    _userId = prefs.getInt('userId');
    if (_userId == null) {
      throw Exception('User not logged in');
    }
    setState(() {
      _dataFuture = _fetchData();
      _projectsFuture = _fetchProjects();
    });
  }

  Future<List<MonthlyTableRowModel>> _fetchData() async {
    setState(() {
      _isLoading = true;
    });
    try {
      final data = await _homeApi.getUserMonthlyTableData(
        _userId!,
        _jalaliYear,
        _jalaliMonth,
      );
      setState(() {
        _allData = data;
        _isLoading = false;
      });
      return data;
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      rethrow;
    }
  }

  Future<List<ProjectAccess>> _fetchProjects() async {
    final projects = await _homeApi.getUserProjectAccess();
    _allProjects = projects.where((p) => p.hasAccess).toList();
    return _allProjects;
  }

  void _previousMonth() {
    if (_jalaliMonth == 1) {
      _jalaliMonth = 12;
      _jalaliYear--;
    } else {
      _jalaliMonth--;
    }
    setState(() {});
    _dataFuture = _fetchData();
  }

  void _nextMonth() {
    if (_jalaliMonth == 12) {
      _jalaliMonth = 1;
      _jalaliYear++;
    } else {
      _jalaliMonth++;
    }
    setState(() {});
    _dataFuture = _fetchData();
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
        return 'مرخصی استحقاقی';
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

  List<MonthlyTableRowModel> _filterData(List<MonthlyTableRowModel> data) {
    return data.where((row) {
      // Search filter
      if (_searchQuery.isNotEmpty) {
        final searchLower = _searchQuery.toLowerCase();
        if (!row.date.contains(searchLower) &&
            !row.dayOfWeek.toLowerCase().contains(searchLower) &&
            !(row.description?.toLowerCase().contains(searchLower) ?? false)) {
          return false;
        }
      }

      // Leave type filter
      if (_selectedLeaveType != null && _selectedLeaveType != 'all') {
        if (row.leaveType != _selectedLeaveType) {
          return false;
        }
      }

      // Project filter
      if (_selectedProjectId != null) {
        final hasSelectedProject = row.projects.any(
          (project) => project.projectId == _selectedProjectId,
        );
        if (!hasSelectedProject) {
          return false;
        }
      }

      return true;
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('جدول ماهانه'),
        actions: [
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
          if (constraints.maxWidth < 800) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: const [
                  Icon(
                    Icons.warning_amber_rounded,
                    size: 64,
                    color: Colors.orange,
                  ),
                  SizedBox(height: 16),
                  Text(
                    'لطفا برای مشاهده جدول، پنجره را تمام صفحه کنید\nیا سایز آن را افزایش دهید.',
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                ],
              ),
            );
          }

          return FutureBuilder<List<dynamic>>(
            future: Future.wait([_dataFuture, _projectsFuture]),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting && _allData.isEmpty) {
                return const Center(child: CircularProgressIndicator());
              } else if (snapshot.hasError) {
                return Center(child: Text('خطا: ${snapshot.error}'));
              } else if (!snapshot.hasData) {
                return const Center(child: Text('هیچ داده‌ای موجود نیست'));
              }

              final allDataFromSnapshot = snapshot.data![0] as List<MonthlyTableRowModel>;
              final projects = snapshot.data![1] as List<ProjectAccess>;
              
              // Use cached data if available, otherwise use snapshot data
              final dataToFilter = _allData.isNotEmpty ? _allData : allDataFromSnapshot;
              final filteredData = _filterData(dataToFilter);
              final sortedProjectIds =
                  projects.map((p) => p.id).toList()..sort();

              return Column(
                children: [
                  // Filters
                  Padding(
                    padding: const EdgeInsets.all(16),
                    child: Card(
                      elevation: 2,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Column(
                          children: [
                            // Month Selection
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                IconButton(
                                  icon: const Icon(Icons.arrow_back),
                                  onPressed: _previousMonth,
                                  tooltip: 'ماه قبل',
                                ),
                                Text(
                                  '$_jalaliYear/${_jalaliMonth.toString().padLeft(2, '0')}',
                                  style: const TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                IconButton(
                                  icon: const Icon(Icons.arrow_forward),
                                  onPressed: _nextMonth,
                                  tooltip: 'ماه بعد',
                                ),
                              ],
                            ),
                            const SizedBox(height: 16),
                            // Search
                            TextField(
                              controller: _searchController,
                              decoration: const InputDecoration(
                                labelText: 'جستجو',
                                prefixIcon: Icon(Icons.search),
                                border: OutlineInputBorder(),
                                isDense: true,
                              ),
                              onChanged: (value) {
                                setState(() {
                                  _searchQuery = value;
                                });
                              },
                            ),
                            const SizedBox(height: 16),
                            Row(
                              children: [
                                // Leave Type Dropdown
                                Expanded(
                                  child: InputDecorator(
                                    decoration: const InputDecoration(
                                      labelText: 'نوع مرخصی',
                                      border: OutlineInputBorder(),
                                      contentPadding: EdgeInsets.symmetric(
                                        horizontal: 12,
                                        vertical: 8,
                                      ),
                                    ),
                                    child: DropdownButtonHideUnderline(
                                      child: DropdownButton<String>(
                                        value: _selectedLeaveType,
                                        isExpanded: true,
                                        items: const [
                                          DropdownMenuItem(
                                            value: 'all',
                                            child: Text('همه'),
                                          ),
                                          DropdownMenuItem(
                                            value: 'work',
                                            child: Text('روزکاری'),
                                          ),
                                          DropdownMenuItem(
                                            value: 'annual_leave',
                                            child: Text('مرخصی استحقاقی'),
                                          ),
                                          DropdownMenuItem(
                                            value: 'sick_leave',
                                            child: Text('مرخصی استعلاجی'),
                                          ),
                                          DropdownMenuItem(
                                            value: 'gift_leave',
                                            child: Text('مرخصی هدیه'),
                                          ),
                                          DropdownMenuItem(
                                            value: 'mission',
                                            child: Text('ماموریت'),
                                          ),
                                        ],
                                        onChanged: (value) {
                                          setState(() {
                                            _selectedLeaveType = value;
                                          });
                                        },
                                      ),
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 16),
                                // Project Dropdown
                                Expanded(
                                  child: InputDecorator(
                                    decoration: const InputDecoration(
                                      labelText: 'پروژه',
                                      border: OutlineInputBorder(),
                                      contentPadding: EdgeInsets.symmetric(
                                        horizontal: 12,
                                        vertical: 8,
                                      ),
                                    ),
                                    child: DropdownButtonHideUnderline(
                                      child: DropdownButton<int>(
                                        value: _selectedProjectId,
                                        isExpanded: true,
                                        items: [
                                          const DropdownMenuItem<int>(
                                            value: null,
                                            child: Text('همه پروژه‌ها'),
                                          ),
                                          ...projects.map((project) {
                                            return DropdownMenuItem<int>(
                                              value: project.id,
                                              child: Text(project.projectName),
                                            );
                                          }),
                                        ],
                                        onChanged: (value) {
                                          setState(() {
                                            _selectedProjectId = value;
                                          });
                                        },
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  // Loading indicator for table
                  if (_isLoading)
                    const Padding(
                      padding: EdgeInsets.all(8.0),
                      child: LinearProgressIndicator(),
                    ),
                  // Table Header (Sticky)
                  SingleChildScrollView(
                    controller: _headerScrollController,
                    scrollDirection: Axis.horizontal,
                    child: DataTable(
                      border: TableBorder.all(
                        color: Colors.grey.shade300,
                        width: 1,
                      ),
                      headingRowColor: WidgetStateProperty.all(
                        Colors.blueGrey[800],
                      ),
                      headingTextStyle: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                      columnSpacing: 0,
                      horizontalMargin: 0,
                      columns: _buildColumns(sortedProjectIds, projects),
                      rows: const [],
                    ),
                  ),
                  // Table Body (Scrollable)
                  Expanded(
                    child: _isLoading && _allData.isEmpty
                        ? const Center(child: CircularProgressIndicator())
                        : Scrollbar(
                            controller: _bodyScrollController,
                            thumbVisibility: true,
                            child: SingleChildScrollView(
                              controller: _bodyScrollController,
                              scrollDirection: Axis.horizontal,
                              child: SingleChildScrollView(
                                scrollDirection: Axis.vertical,
                                child: DataTable(
                                  border: TableBorder.all(
                                    color: Colors.grey.shade300,
                                    width: 1,
                                  ),
                                  headingRowHeight: 0,
                                  columnSpacing: 0,
                                  horizontalMargin: 0,
                                  columns: _buildColumns(sortedProjectIds, projects),
                                  rows:
                                      filteredData.map((row) {
                                        return _buildDataRow(
                                          row,
                                          sortedProjectIds,
                                          projects,
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

  List<DataColumn> _buildColumns(
    List<int> sortedProjectIds,
    List<ProjectAccess> projects,
  ) {
    return [
      DataColumn(label: _buildConstrainedCell('روز هفته', 80, isHeader: true)),
      DataColumn(label: _buildConstrainedCell('تاریخ', 90, isHeader: true)),
      DataColumn(label: _buildConstrainedCell('ورود', 60, isHeader: true)),
      DataColumn(label: _buildConstrainedCell('خروج', 60, isHeader: true)),
      DataColumn(label: _buildConstrainedCell('شخصی', 60, isHeader: true)),
      DataColumn(label: _buildConstrainedCell('وضعیت', 110, isHeader: true)),
      DataColumn(label: _buildConstrainedCell('کارکرد', 60, isHeader: true)),
      DataColumn(label: _buildConstrainedCell('تاخیر', 60, isHeader: true)),
      DataColumn(label: _buildConstrainedCell('توضیحات', 200, isHeader: true)),
      ...sortedProjectIds.map((id) {
        final project = projects.firstWhere((p) => p.id == id);
        return DataColumn(
          label: _buildConstrainedCell(
            project.projectName,
            100,
            isHeader: true,
          ),
        );
      }),
    ];
  }

  DataRow _buildDataRow(
    MonthlyTableRowModel row,
    List<int> sortedProjectIds,
    List<ProjectAccess> projects,
  ) {
    final leaveType = LeaveTypeExtension.fromString(row.leaveType);
    final rowColor = _getRowColor(leaveType);
    return DataRow(
      color: WidgetStateProperty.all(rowColor),
      cells: [
        DataCell(_buildConstrainedCell(row.dayOfWeek, 80)),
        DataCell(_buildConstrainedCell(row.date, 90)),
        DataCell(_buildConstrainedCell(_formatTime(row.arrivalTime), 60)),
        DataCell(_buildConstrainedCell(_formatTime(row.leaveTime), 60)),
        DataCell(_buildConstrainedCell(_formatMinutes(row.personalTime), 60)),
        DataCell(
          _buildConstrainedCell(_translateLeaveType(row.leaveType), 110),
        ),
        DataCell(_buildConstrainedCell(_formatMinutes(row.totalDailyWork), 60)),
        DataCell(_buildConstrainedCell(_formatMinutes(row.entryDelay), 60)),
        DataCell(_buildConstrainedCell(row.description ?? '-', 200)),
        ...sortedProjectIds.map((id) {
          return DataCell(
            _buildConstrainedCell(_getProjectDuration(row.projects, id), 100),
          );
        }),
      ],
    );
  }

  Widget _buildConstrainedCell(
    String text,
    double width, {
    bool isHeader = false,
  }) {
    return Container(
      width: width,
      padding: const EdgeInsets.symmetric(horizontal: 4),
      alignment: Alignment.center,
      child: Text(
        text,
        style:
            isHeader
                ? const TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                  fontSize: 13,
                )
                : const TextStyle(fontSize: 12),
        textAlign: TextAlign.center,
        overflow: TextOverflow.ellipsis,
        maxLines: 1,
      ),
    );
  }
}
