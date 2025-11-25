import 'dart:convert';
import 'dart:io';
import 'package:path_provider/path_provider.dart';
import '../../model/app_log_entry.dart';

class AppLogger {
  static final AppLogger _instance = AppLogger._internal();
  factory AppLogger() => _instance;
  AppLogger._internal();

  final List<AppLogEntry> _logs = [];
  final int maxLogs = 500; // Keep last 500 logs in memory
  final int maxDays = 7; // Keep logs for 7 days

  File? _logFile;
  bool _initialized = false;

  /// Initialize the logger
  Future<void> init() async {
    if (_initialized) return;

    try {
      final directory = await getApplicationDocumentsDirectory();
      final logDir = Directory('${directory.path}/logs');

      if (!await logDir.exists()) {
        await logDir.create(recursive: true);
      }

      final today = DateTime.now();
      final fileName =
          'app-${today.year}-${today.month.toString().padLeft(2, '0')}-${today.day.toString().padLeft(2, '0')}.log';
      _logFile = File('${logDir.path}/$fileName');

      // Clean old log files
      await _cleanOldLogs(logDir);

      // Load today's logs
      await _loadTodayLogs();

      _initialized = true;
      info('AppLogger', 'Logger initialized successfully');
    } catch (e) {
      print('Failed to initialize logger: $e');
    }
  }

  /// Clean logs older than maxDays
  Future<void> _cleanOldLogs(Directory logDir) async {
    try {
      final files = await logDir.list().toList();
      final now = DateTime.now();

      for (final file in files) {
        if (file is File && file.path.endsWith('.log')) {
          final stat = await file.stat();
          final age = now.difference(stat.modified).inDays;

          if (age > maxDays) {
            await file.delete();
          }
        }
      }
    } catch (e) {
      print('Failed to clean old logs: $e');
    }
  }

  /// Load today's logs from file
  Future<void> _loadTodayLogs() async {
    if (_logFile == null || !await _logFile!.exists()) return;

    try {
      final lines = await _logFile!.readAsLines();
      _logs.clear();

      for (final line in lines) {
        if (line.trim().isEmpty) continue;
        try {
          final json = jsonDecode(line);
          _logs.add(AppLogEntry.fromJson(json));
        } catch (e) {
          // Skip malformed log entries
        }
      }
    } catch (e) {
      print('Failed to load logs: $e');
    }
  }

  /// Write log entry to file
  Future<void> _writeToFile(AppLogEntry entry) async {
    if (_logFile == null) return;

    try {
      final json = jsonEncode(entry.toJson());
      await _logFile!.writeAsString('$json\n', mode: FileMode.append);
    } catch (e) {
      print('Failed to write log: $e');
    }
  }

  /// Add log entry
  void _log(
    String level,
    String category,
    String message, [
    Map<String, dynamic>? metadata,
  ]) {
    final entry = AppLogEntry(
      timestamp: DateTime.now(),
      level: level,
      category: category,
      message: message,
      metadata: metadata,
    );

    _logs.add(entry);

    // Keep only last maxLogs in memory
    if (_logs.length > maxLogs) {
      _logs.removeAt(0);
    }

    // Write to file
    _writeToFile(entry);

    // Also print to console in debug mode
    print('[$level] [$category] $message');
  }

  // Logging methods
  void info(String category, String message, [Map<String, dynamic>? metadata]) {
    _log('info', category, message, metadata);
  }

  void warning(
    String category,
    String message, [
    Map<String, dynamic>? metadata,
  ]) {
    _log('warning', category, message, metadata);
  }

  void error(
    String category,
    String message, [
    Map<String, dynamic>? metadata,
  ]) {
    _log('error', category, message, metadata);
  }

  void debug(
    String category,
    String message, [
    Map<String, dynamic>? metadata,
  ]) {
    _log('debug', category, message, metadata);
  }

  // Get logs
  List<AppLogEntry> getLogs({String? category, String? level}) {
    var filtered = List<AppLogEntry>.from(_logs);

    if (category != null && category != 'all') {
      filtered = filtered.where((log) => log.category == category).toList();
    }

    if (level != null && level != 'all') {
      filtered = filtered.where((log) => log.level == level).toList();
    }

    return filtered.reversed.toList(); // Most recent first
  }

  /// Get unique categories
  List<String> getCategories() {
    final categories = _logs.map((log) => log.category).toSet().toList();
    categories.sort();
    return categories;
  }

  /// Clear all logs
  Future<void> clearLogs() async {
    _logs.clear();
    if (_logFile != null && await _logFile!.exists()) {
      await _logFile!.delete();
      await init(); // Reinitialize with new file
    }
  }

  /// Export logs as string
  String exportLogs() {
    final buffer = StringBuffer();
    for (final log in _logs) {
      buffer.writeln(
        '${log.formattedDate} ${log.formattedTime} [${log.level}] [${log.category}] ${log.message}',
      );
      if (log.metadata != null) {
        buffer.writeln('  Metadata: ${jsonEncode(log.metadata)}');
      }
    }
    return buffer.toString();
  }
}
