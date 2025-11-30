import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:share_plus/share_plus.dart';
import '../../core/utils/app_logger.dart';
import '../../core/widgets/searchable_dropdown.dart';
import '../../model/app_log_entry.dart';

class LogsViewerPage extends StatefulWidget {
  const LogsViewerPage({super.key});

  @override
  State<LogsViewerPage> createState() => _LogsViewerPageState();
}

class _LogsViewerPageState extends State<LogsViewerPage> {
  final AppLogger _logger = AppLogger();

  String _selectedCategory = 'all';
  String _selectedLevel = 'all';
  List<AppLogEntry> _filteredLogs = [];
  List<String> _categories = [];

  @override
  void initState() {
    super.initState();
    _loadLogs();
  }

  void _loadLogs() {
    setState(() {
      _categories = ['all', ..._logger.getCategories()];
      _filteredLogs = _logger.getLogs(
        category: _selectedCategory,
        level: _selectedLevel,
      );
    });
  }

  void _onCategoryChanged(String? category) {
    if (category != null) {
      setState(() {
        _selectedCategory = category;
        _loadLogs();
      });
    }
  }

  void _onLevelChanged(String? level) {
    if (level != null) {
      setState(() {
        _selectedLevel = level;
        _loadLogs();
      });
    }
  }

  Future<void> _clearLogs() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text('پاک کردن لاگ‌ها'),
            content: const Text(
              'آیا مطمئن هستید که می‌خواهید تمام لاگ‌ها را پاک کنید؟',
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context, false),
                child: const Text('لغو'),
              ),
              TextButton(
                onPressed: () => Navigator.pop(context, true),
                child: const Text('پاک کردن'),
              ),
            ],
          ),
    );

    if (confirmed == true) {
      await _logger.clearLogs();
      _loadLogs();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('لاگ‌ها با موفقیت پاک شدند')),
        );
      }
    }
  }

  Future<void> _exportLogs() async {
    final logs = _logger.exportLogs();
    await Share.share(
      logs,
      subject: 'Application Logs - ${DateTime.now().toString()}',
    );
  }

  Future<void> _copyLog(AppLogEntry log) async {
    final text =
        '${log.formattedDate} ${log.formattedTime} [${log.level}] [${log.category}] ${log.message}';
    await Clipboard.setData(ClipboardData(text: text));
    if (mounted) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('لاگ کپی شد')));
    }
  }

  Color _getLevelColor(String level) {
    switch (level.toLowerCase()) {
      case 'error':
        return Colors.red;
      case 'warning':
        return Colors.orange;
      case 'info':
        return Colors.blue;
      case 'debug':
        return Colors.grey;
      default:
        return Colors.black;
    }
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('لاگ‌های برنامه'),
          actions: [
            IconButton(
              icon: const Icon(Icons.refresh),
              onPressed: _loadLogs,
              tooltip: 'بروزرسانی',
            ),
            IconButton(
              icon: const Icon(Icons.share),
              onPressed: _exportLogs,
              tooltip: 'اشتراک‌گذاری',
            ),
            IconButton(
              icon: const Icon(Icons.delete_outline),
              onPressed: _clearLogs,
              tooltip: 'پاک کردن',
            ),
          ],
        ),
        body: Column(
          children: [
            // Filters
            Container(
              padding: const EdgeInsets.all(16),
              color: colorScheme.surface,
              child: Row(
                children: [
                  // Category filter
                  Expanded(
                    child: SearchableDropdown<String>(
                      value: _selectedCategory,
                      decoration: const InputDecoration(
                        labelText: 'دسته‌بندی',
                        border: OutlineInputBorder(),
                        contentPadding: EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 8,
                        ),
                      ),
                      searchHint: 'جستجوی دسته‌بندی...',
                      items:
                          _categories.map((category) {
                            return DropdownMenuItem(
                              value: category,
                              child: Text(category == 'all' ? 'همه' : category),
                            );
                          }).toList(),
                      onChanged: _onCategoryChanged,
                    ),
                  ),
                  const SizedBox(width: 16),
                  // Level filter
                  Expanded(
                    child: SearchableDropdown<String>(
                      value: _selectedLevel,
                      decoration: const InputDecoration(
                        labelText: 'سطح',
                        border: OutlineInputBorder(),
                        contentPadding: EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 8,
                        ),
                      ),
                      searchHint: 'جستجوی سطح...',
                      items: const [
                        DropdownMenuItem(value: 'all', child: Text('همه')),
                        DropdownMenuItem(value: 'error', child: Text('خطا')),
                        DropdownMenuItem(
                          value: 'warning',
                          child: Text('هشدار'),
                        ),
                        DropdownMenuItem(value: 'info', child: Text('اطلاعات')),
                        DropdownMenuItem(value: 'debug', child: Text('دیباگ')),
                      ],
                      onChanged: _onLevelChanged,
                    ),
                  ),
                ],
              ),
            ),
            const Divider(height: 1),
            // Log count
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              color: colorScheme.surfaceContainerHighest,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'تعداد لاگ‌ها: ${_filteredLogs.length}',
                    style: TextStyle(
                      color: colorScheme.onSurfaceVariant,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    'آخرین بروزرسانی: ${DateTime.now().hour}:${DateTime.now().minute}',
                    style: TextStyle(
                      color: colorScheme.onSurfaceVariant,
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),
            // Logs list
            Expanded(
              child:
                  _filteredLogs.isEmpty
                      ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.format_list_bulleted,
                              size: 64,
                              color: Colors.grey[400],
                            ),
                            const SizedBox(height: 16),
                            Text(
                              'هیچ لاگی یافت نشد',
                              style: TextStyle(
                                fontSize: 16,
                                color: Colors.grey[600],
                              ),
                            ),
                          ],
                        ),
                      )
                      : ListView.builder(
                        itemCount: _filteredLogs.length,
                        itemBuilder: (context, index) {
                          final log = _filteredLogs[index];
                          return Card(
                            margin: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 4,
                            ),
                            child: ListTile(
                              leading: Text(
                                log.levelIcon,
                                style: const TextStyle(fontSize: 24),
                              ),
                              title: Row(
                                children: [
                                  Text(
                                    '[${log.category}]',
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      color: colorScheme.primary,
                                      fontSize: 12,
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  Expanded(
                                    child: Text(
                                      log.message,
                                      maxLines: 2,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                ],
                              ),
                              subtitle: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const SizedBox(height: 4),
                                  Text(
                                    '${log.formattedDate} ${log.formattedTime}',
                                    style: TextStyle(
                                      fontSize: 11,
                                      color: Colors.grey[600],
                                    ),
                                  ),
                                  if (log.metadata != null) ...[
                                    const SizedBox(height: 4),
                                    Text(
                                      'Metadata: ${log.metadata}',
                                      style: TextStyle(
                                        fontSize: 10,
                                        color: Colors.grey[500],
                                        fontFamily: 'monospace',
                                      ),
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ],
                                ],
                              ),
                              trailing: Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 8,
                                  vertical: 4,
                                ),
                                decoration: BoxDecoration(
                                  color: _getLevelColor(
                                    log.level,
                                  ).withValues(alpha: 0.1),
                                  borderRadius: BorderRadius.circular(4),
                                  border: Border.all(
                                    color: _getLevelColor(log.level),
                                    width: 1,
                                  ),
                                ),
                                child: Text(
                                  log.level.toUpperCase(),
                                  style: TextStyle(
                                    fontSize: 10,
                                    fontWeight: FontWeight.bold,
                                    color: _getLevelColor(log.level),
                                  ),
                                ),
                              ),
                              onTap: () => _showLogDetails(log),
                              onLongPress: () => _copyLog(log),
                            ),
                          );
                        },
                      ),
            ),
          ],
        ),
      ),
    );
  }

  void _showLogDetails(AppLogEntry log) {
    showDialog(
      context: context,
      builder:
          (context) => Directionality(
            textDirection: TextDirection.rtl,
            child: AlertDialog(
              title: Row(
                children: [
                  Text(log.levelIcon),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text('جزئیات لاگ', style: TextStyle(fontSize: 18)),
                  ),
                ],
              ),
              content: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    _buildDetailRow('سطح', log.level),
                    _buildDetailRow('دسته‌بندی', log.category),
                    _buildDetailRow('تاریخ', log.formattedDate),
                    _buildDetailRow('زمان', log.formattedTime),
                    const Divider(),
                    const Text(
                      'پیام:',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 8),
                    Text(log.message),
                    if (log.metadata != null) ...[
                      const Divider(),
                      const Text(
                        'Metadata:',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        log.metadata.toString(),
                        style: const TextStyle(
                          fontFamily: 'monospace',
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () {
                    _copyLog(log);
                    Navigator.pop(context);
                  },
                  child: const Text('کپی'),
                ),
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('بستن'),
                ),
              ],
            ),
          ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 80,
            child: Text(
              '$label:',
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
          Expanded(child: Text(value)),
        ],
      ),
    );
  }
}
