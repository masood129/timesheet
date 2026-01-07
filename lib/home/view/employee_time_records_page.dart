import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:persian_datetime_picker/persian_datetime_picker.dart';
import 'package:shamsi_date/shamsi_date.dart';
import '../../core/api/api_calls/api_calls.dart';
import '../../core/theme/snackbar_helper.dart';
import '../../core/utils/page_title_manager.dart';
import '../../model/time_record_model.dart';
import '../../model/user_model.dart';
import '../controller/auth_controller.dart';

class EmployeeTimeRecordsPage extends StatefulWidget {
  const EmployeeTimeRecordsPage({super.key});

  @override
  State<EmployeeTimeRecordsPage> createState() =>
      _EmployeeTimeRecordsPageState();
}

class _EmployeeTimeRecordsPageState extends State<EmployeeTimeRecordsPage> {
  final ApiCalls _apiCalls = ApiCalls();
  final AuthController _authController = Get.find<AuthController>();

  List<UserModel> _employees = [];
  Map<int, List<TimeRecord>> _employeeTimeRecords = {};
  Jalali _selectedDate = Jalali.now();
  bool _isLoading = false;
  bool _isLoadingRecords = false;

  @override
  void initState() {
    super.initState();
    PageTitleManager.setTitle('ساعت‌های ورود و خروج کارمندان');
    _loadEmployees();
  }

  Future<void> _loadEmployees() async {
    setState(() {
      _isLoading = true;
    });
    try {
      // دریافت personalId کاربر فعلی
      final currentUserId = _authController.user.value?['userId'];
      if (currentUserId == null) {
        throw Exception('کاربر لاگین نشده است');
      }

      // دریافت کارمندان با directAdminId برابر با personalId کاربر فعلی
      final employees = await _apiCalls.getEmployeesByDirectAdminId(
        currentUserId,
      );
      setState(() {
        _employees = employees;
        _isLoading = false;
      });
      // بارگذاری خودکار رکوردهای امروز
      await _loadTimeRecordsForAll();
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      ThemedSnackbar.showError('خطا', 'خطا در بارگذاری لیست کارمندان: $e');
    }
  }

  Future<void> _loadTimeRecordsForAll() async {
    setState(() {
      _isLoadingRecords = true;
    });
    _employeeTimeRecords.clear();

    final formattedDate =
        '${_selectedDate.year}/${_selectedDate.month.toString().padLeft(2, '0')}/${_selectedDate.day.toString().padLeft(2, '0')}';

    for (final employee in _employees) {
      try {
        final cardNo = employee.userId.toString();
        final records = await _apiCalls.getTimeRecords(cardNo, formattedDate);
        _employeeTimeRecords[employee.userId] = records;
      } catch (e) {
        // در صورت خطا، لیست خالی می‌گذاریم
        _employeeTimeRecords[employee.userId] = [];
      }
    }

    setState(() {
      _isLoadingRecords = false;
    });
  }

  Future<void> _selectDate() async {
    final locale = const Locale('fa', 'IR');
    final Jalali? picked = await showPersianDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: Jalali(1400, 1, 1),
      lastDate: Jalali(1450, 12, 29),
      locale: locale,
      builder: (context, child) {
        return Localizations.override(
          context: context,
          locale: locale,
          child: child ?? const SizedBox(),
        );
      },
    );

    if (picked != null && picked != _selectedDate) {
      setState(() {
        _selectedDate = picked;
      });
      await _loadTimeRecordsForAll();
    }
  }

  String _getFirstRecord(List<TimeRecord> records) {
    if (records.isEmpty) return '--:--';
    return records.first.time;
  }

  String _getLastRecord(List<TimeRecord> records) {
    if (records.isEmpty) return '--:--';
    if (records.length == 1) return '--:--';
    return records.last.time;
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: Text('ساعت‌های ورود و خروج کارمندان'),
        actions: [
          IconButton(
            icon: Icon(Icons.refresh),
            onPressed: _loadTimeRecordsForAll,
            tooltip: 'بارگذاری مجدد',
          ),
        ],
      ),
      body:
          _isLoading
              ? Center(child: CircularProgressIndicator())
              : _employees.isEmpty
              ? Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.people_outline,
                      size: 64,
                      color: colorScheme.onSurface.withOpacity(0.5),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'هیچ کارمندی یافت نشد',
                      style: TextStyle(
                        fontSize: 16,
                        color: colorScheme.onSurface.withOpacity(0.7),
                      ),
                    ),
                  ],
                ),
              )
              : Column(
                children: [
                  // انتخاب تاریخ
                  Container(
                    margin: const EdgeInsets.all(16),
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: colorScheme.surfaceContainerHighest,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: colorScheme.outline.withOpacity(0.2),
                      ),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                            Icon(
                              Icons.calendar_today,
                              color: colorScheme.primary,
                              size: 24,
                            ),
                            const SizedBox(width: 12),
                            Text(
                              'تاریخ:',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                                color: colorScheme.onSurface,
                              ),
                            ),
                            const SizedBox(width: 8),
                            Text(
                              '${_selectedDate.year}/${_selectedDate.month.toString().padLeft(2, '0')}/${_selectedDate.day.toString().padLeft(2, '0')}',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: colorScheme.primary,
                              ),
                            ),
                          ],
                        ),
                        ElevatedButton.icon(
                          onPressed: _selectDate,
                          icon: Icon(Icons.edit_calendar, size: 18),
                          label: Text('تغییر تاریخ'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: colorScheme.primary,
                            foregroundColor: colorScheme.onPrimary,
                            padding: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 10,
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  // لیست کارمندان
                  Expanded(
                    child:
                        _isLoadingRecords
                            ? Center(child: CircularProgressIndicator())
                            : ListView.builder(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 16,
                              ),
                              itemCount: _employees.length,
                              itemBuilder: (context, index) {
                                final employee = _employees[index];
                                final records =
                                    _employeeTimeRecords[employee.userId] ?? [];
                                final arrivalTime = _getFirstRecord(records);
                                final leaveTime = _getLastRecord(records);

                                return Card(
                                  margin: const EdgeInsets.only(bottom: 12),
                                  elevation: 2,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: Padding(
                                    padding: const EdgeInsets.all(16),
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        // نام کارمند
                                        Row(
                                          children: [
                                            Container(
                                              padding: const EdgeInsets.all(10),
                                              decoration: BoxDecoration(
                                                color:
                                                    colorScheme
                                                        .primaryContainer,
                                                borderRadius:
                                                    BorderRadius.circular(8),
                                              ),
                                              child: Icon(
                                                Icons.person,
                                                color:
                                                    colorScheme
                                                        .onPrimaryContainer,
                                                size: 24,
                                              ),
                                            ),
                                            const SizedBox(width: 12),
                                            Expanded(
                                              child: Column(
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.start,
                                                children: [
                                                  Text(
                                                    employee.username,
                                                    style: TextStyle(
                                                      fontSize: 18,
                                                      fontWeight:
                                                          FontWeight.bold,
                                                      color:
                                                          colorScheme.onSurface,
                                                    ),
                                                  ),
                                                  if (employee.role.isNotEmpty)
                                                    Text(
                                                      employee.role,
                                                      style: TextStyle(
                                                        fontSize: 14,
                                                        color:
                                                            colorScheme
                                                                .onSurfaceVariant,
                                                      ),
                                                    ),
                                                ],
                                              ),
                                            ),
                                          ],
                                        ),
                                        const SizedBox(height: 16),
                                        // ساعت ورود و خروج
                                        Row(
                                          children: [
                                            Expanded(
                                              child: _buildTimeCard(
                                                context,
                                                'ساعت ورود',
                                                arrivalTime,
                                                Icons.login,
                                                colorScheme,
                                                Colors.green,
                                              ),
                                            ),
                                            const SizedBox(width: 12),
                                            Expanded(
                                              child: _buildTimeCard(
                                                context,
                                                'ساعت خروج',
                                                leaveTime,
                                                Icons.logout,
                                                colorScheme,
                                                Colors.orange,
                                              ),
                                            ),
                                          ],
                                        ),
                                        // تعداد ترددها
                                        if (records.isNotEmpty) ...[
                                          const SizedBox(height: 12),
                                          Container(
                                            padding: const EdgeInsets.symmetric(
                                              horizontal: 12,
                                              vertical: 8,
                                            ),
                                            decoration: BoxDecoration(
                                              color:
                                                  colorScheme
                                                      .secondaryContainer,
                                              borderRadius:
                                                  BorderRadius.circular(8),
                                            ),
                                            child: Row(
                                              mainAxisSize: MainAxisSize.min,
                                              children: [
                                                Icon(
                                                  Icons.history,
                                                  size: 16,
                                                  color:
                                                      colorScheme
                                                          .onSecondaryContainer,
                                                ),
                                                const SizedBox(width: 6),
                                                Text(
                                                  '${records.length} تردد ثبت شده',
                                                  style: TextStyle(
                                                    fontSize: 12,
                                                    color:
                                                        colorScheme
                                                            .onSecondaryContainer,
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                        ],
                                      ],
                                    ),
                                  ),
                                );
                              },
                            ),
                  ),
                ],
              ),
    );
  }

  Widget _buildTimeCard(
    BuildContext context,
    String label,
    String time,
    IconData icon,
    ColorScheme colorScheme,
    Color iconColor,
  ) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: colorScheme.outline.withOpacity(0.2)),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, size: 20, color: iconColor),
              const SizedBox(width: 6),
              Text(
                label,
                style: TextStyle(
                  fontSize: 12,
                  color: colorScheme.onSurfaceVariant,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            time,
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color:
                  time == '--:--'
                      ? colorScheme.onSurfaceVariant
                      : colorScheme.primary,
            ),
          ),
        ],
      ),
    );
  }
}
