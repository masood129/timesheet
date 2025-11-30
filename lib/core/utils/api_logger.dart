import 'package:flutter/foundation.dart';

class ApiLogger {
  static const String _reset = '\x1B[0m';
  static const String _red = '\x1B[31m';
  static const String _green = '\x1B[32m';
  static const String _yellow = '\x1B[33m';
  static const String _blue = '\x1B[34m';
  static const String _magenta = '\x1B[35m';
  static const String _cyan = '\x1B[36m';
  static const String _white = '\x1B[37m';
  static const String _bold = '\x1B[1m';

  static void logRequest({
    required String method,
    required String url,
    Map<String, String>? headers,
    String? body,
  }) {
    if (!kDebugMode) return;

    debugPrint('\n');
    debugPrint('$_cyan╔════════════════════════════════════════════════════════════════════════════════════$_reset');
    debugPrint('$_cyan║$_reset $_bold${_green}API REQUEST$_reset');
    debugPrint('$_cyan╠════════════════════════════════════════════════════════════════════════════════════$_reset');
    debugPrint('$_cyan║$_reset $_bold${_blue}Method:$_reset $method');
    debugPrint('$_cyan║$_reset $_bold${_blue}URL:$_reset $url');
    
    if (headers != null && headers.isNotEmpty) {
      debugPrint('$_cyan║$_reset $_bold${_blue}Headers:$_reset');
      headers.forEach((key, value) {
        // Hide sensitive data
        if (key.toLowerCase() == 'authorization') {
          final token = value;
          final maskedToken = token.length > 20 
              ? '${token.substring(0, 7)}...${token.substring(token.length - 4)}'
              : '***';
          debugPrint('$_cyan║$_reset   • $key: $maskedToken');
        } else {
          debugPrint('$_cyan║$_reset   • $key: $value');
        }
      });
    }
    
    if (body != null && body.isNotEmpty) {
      debugPrint('$_cyan║$_reset $_bold${_blue}Body:$_reset');
      _printPrettyJson(body);
    }
    
    debugPrint('$_cyan╚════════════════════════════════════════════════════════════════════════════════════$_reset');
  }

  static void logResponse({
    required String method,
    required String url,
    required int statusCode,
    required String body,
    required int durationMs,
  }) {
    if (!kDebugMode) return;

    final statusColor = _getStatusColor(statusCode);
    final methodColor = _getMethodColor(method);

    debugPrint('\n');
    debugPrint('$_green╔════════════════════════════════════════════════════════════════════════════════════$_reset');
    debugPrint('$_green║$_reset $_bold${_green}API RESPONSE$_reset');
    debugPrint('$_green╠════════════════════════════════════════════════════════════════════════════════════$_reset');
    debugPrint('$_green║$_reset $_bold${_blue}Method:$_reset $methodColor$method$_reset');
    debugPrint('$_green║$_reset $_bold${_blue}URL:$_reset $url');
    debugPrint('$_green║$_reset $_bold${_blue}Status Code:$_reset $statusColor$statusCode$_reset ${_getStatusMessage(statusCode)}');
    debugPrint('$_green║$_reset $_bold${_blue}Duration:$_reset ${durationMs}ms');
    
    if (body.isNotEmpty) {
      debugPrint('$_green║$_reset $_bold${_blue}Response Data:$_reset');
      _printPrettyJson(body);
    }
    
    debugPrint('$_green╚════════════════════════════════════════════════════════════════════════════════════$_reset');
  }

  static void logError({
    required String method,
    required String url,
    required int statusCode,
    required String errorMessage,
    String? responseBody,
    required int durationMs,
  }) {
    if (!kDebugMode) return;

    debugPrint('\n');
    debugPrint('$_red╔════════════════════════════════════════════════════════════════════════════════════$_reset');
    debugPrint('$_red║$_reset $_bold${_red}API ERROR$_reset');
    debugPrint('$_red╠════════════════════════════════════════════════════════════════════════════════════$_reset');
    debugPrint('$_red║$_reset $_bold${_blue}Method:$_reset $method');
    debugPrint('$_red║$_reset $_bold${_blue}URL:$_reset $url');
    debugPrint('$_red║$_reset $_bold${_blue}Status Code:$_reset $_red$statusCode$_reset ${_getStatusMessage(statusCode)}');
    debugPrint('$_red║$_reset $_bold${_blue}Duration:$_reset ${durationMs}ms');
    debugPrint('$_red║$_reset $_bold${_blue}Error Message:$_reset $_red$errorMessage$_reset');
    
    if (responseBody != null && responseBody.isNotEmpty) {
      debugPrint('$_red║$_reset $_bold${_blue}Error Response:$_reset');
      _printPrettyJson(responseBody);
    }
    
    debugPrint('$_red╚════════════════════════════════════════════════════════════════════════════════════$_reset');
  }

  static String _getStatusColor(int statusCode) {
    if (statusCode >= 200 && statusCode < 300) return _green;
    if (statusCode >= 300 && statusCode < 400) return _yellow;
    if (statusCode >= 400 && statusCode < 500) return _red;
    if (statusCode >= 500) return _magenta;
    return _white;
  }

  static String _getMethodColor(String method) {
    switch (method.toUpperCase()) {
      case 'GET':
        return _cyan;
      case 'POST':
        return _green;
      case 'PUT':
        return _yellow;
      case 'DELETE':
        return _red;
      case 'PATCH':
        return _magenta;
      default:
        return _white;
    }
  }

  static String _getStatusMessage(int statusCode) {
    switch (statusCode) {
      case 200:
        return '✓ OK';
      case 201:
        return '✓ Created';
      case 204:
        return '✓ No Content';
      case 400:
        return '✗ Bad Request';
      case 401:
        return '✗ Unauthorized';
      case 403:
        return '✗ Forbidden';
      case 404:
        return '✗ Not Found';
      case 500:
        return '✗ Internal Server Error';
      case 502:
        return '✗ Bad Gateway';
      case 503:
        return '✗ Service Unavailable';
      default:
        return '';
    }
  }

  static void _printPrettyJson(String data) {
    try {
      // Split long lines
      if (data.length > 100) {
        final lines = _splitLongString(data, 90);
        for (final line in lines) {
          debugPrint('$_cyan║$_reset   $line');
        }
      } else {
        debugPrint('$_cyan║$_reset   $data');
      }
    } catch (e) {
      debugPrint('$_cyan║$_reset   $data');
    }
  }

  static List<String> _splitLongString(String text, int maxLength) {
    final List<String> result = [];
    int start = 0;
    
    while (start < text.length) {
      int end = start + maxLength;
      if (end > text.length) {
        end = text.length;
      }
      result.add(text.substring(start, end));
      start = end;
    }
    
    return result;
  }
}

