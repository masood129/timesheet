import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import 'package:flutter_easyloading/flutter_easyloading.dart'; // اضافه کردن پکیج easyloading
import 'package:timesheet/core/config/app_env.dart';
import 'package:timesheet/core/utils/api_logger.dart';

class CoreApi {
  static final CoreApi _instance = CoreApi._internal();

  factory CoreApi() {
    return _instance;
  }

  CoreApi._internal();

  final _client = http.Client();
  final String baseUrl = AppEnv.apiBaseUrl;

  // تابع برای دریافت توکن از SharedPreferences
  Future<String?> _getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('jwt_token');
  }

  // تابع برای دریافت نام کاربری از SharedPreferences
  Future<String?> _getUsername() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('username');
  }

  // تابع برای رفرش توکن
  Future<String?> _refreshToken() async {
    try {
      final username = await _getUsername();
      if (username == null) {
        if (kDebugMode) debugPrint('No username found for token refresh');
        return null;
      }
      final response = await _client.post(
        Uri.parse('$baseUrl/auth/login'),
        headers: {
          'Content-Type': 'application/json',
          'accept': 'application/json',
        },
        body: jsonEncode({'username': username}),
      );
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final token = data['token'] as String;
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('jwt_token', token);
        if (kDebugMode) debugPrint('Token refreshed successfully');
        return token;
      }
      if (kDebugMode) debugPrint('Failed to refresh token: ${response.statusCode}');
      return null;
    } catch (e) {
      if (kDebugMode) debugPrint('Refresh token error: $e');
      return null;
    }
  }

  String? _encodeBody(Object? body) {
    if (body == null) return null;
    if (body is String) {
      try {
        jsonDecode(body);  // اگر string اما JSON معتبر باشه، بدون encode برگردون
        return body;
      } catch (_) {
        return jsonEncode(body);  // اگر string ساده باشه، encode کن
      }
    }
    return jsonEncode(body);  // اگر Map یا Object باشه، encode کن
  }

  // Interceptor برای مدیریت درخواست‌ها
  Future<http.Response?> _interceptRequest(
      Future<http.Response> Function(Map<String, String>, String?) request,
      Map<String, String>? headers,
      Object? body,
      String method,
      String url,
      int startTime,
      ) async {
    try {
      // نمایش لودینگ قبل از درخواست
      EasyLoading.show(status: 'در حال بارگذاری...');

      // اگر درخواست برای /auth/login است، نیازی به توکن نیست
      if (headers != null && headers.containsKey('skip-auth')) {
        final updatedHeaders = Map<String, String>.from(headers);
        updatedHeaders.remove('skip-auth'); // حذف هدر موقت
        final response = await request(updatedHeaders, _encodeBody(body));
        EasyLoading.dismiss(); // پنهان کردن لودینگ بعد از پاسخ
        return response;
      }

      // افزودن هدر Authorization اگر توکن موجود باشد
      final token = await _getToken();
      final updatedHeaders = {
        'Content-Type': 'application/json',
        'accept': 'application/json',
        if (token != null) 'Authorization': 'Bearer $token',
        ...?headers,
      };

      // اجرای درخواست
      final encodedBody = _encodeBody(body);
      final response = await request(updatedHeaders, encodedBody);

      // مدیریت خطای 401
      if (response.statusCode == 401) {
        final newToken = await _refreshToken();
        if (newToken != null) {
          // بازنویسی هدرها با توکن جدید
          updatedHeaders['Authorization'] = 'Bearer $newToken';
          // تکرار درخواست با توکن جدید
          final retryResponse = await request(updatedHeaders, encodedBody);
          EasyLoading.dismiss(); // پنهان کردن لودینگ بعد از پاسخ
          return retryResponse;
        } else {
          EasyLoading.dismiss(); // پنهان کردن لودینگ در صورت شکست
          final duration = DateTime.now().millisecondsSinceEpoch - startTime;
          ApiLogger.logError(
            method: method,
            url: url,
            statusCode: 401,
            errorMessage: 'Unauthorized: Please log in again',
            responseBody: response.body,
            durationMs: duration,
          );
          throw Exception('Unauthorized: Please log in again');
        }
      }

      // Log errors for non-2xx responses
      if (response.statusCode < 200 || response.statusCode >= 300) {
        final duration = DateTime.now().millisecondsSinceEpoch - startTime;
        ApiLogger.logError(
          method: method,
          url: url,
          statusCode: response.statusCode,
          errorMessage: 'HTTP ${response.statusCode}',
          responseBody: response.body,
          durationMs: duration,
        );
      }

      EasyLoading.dismiss(); // پنهان کردن لودینگ بعد از پاسخ موفق
      return response;
    } catch (e) {
      EasyLoading.dismiss(); // پنهان کردن لودینگ در صورت خطا
      final duration = DateTime.now().millisecondsSinceEpoch - startTime;
      ApiLogger.logError(
        method: method,
        url: url,
        statusCode: 0,
        errorMessage: e.toString(),
        durationMs: duration,
      );
      rethrow;
    }
  }

  Future<http.Response?> get(Uri url, {Map<String, String>? headers}) async {
    final startTime = DateTime.now().millisecondsSinceEpoch;
    
    return _interceptRequest((updatedHeaders, encodedBody) async {
      ApiLogger.logRequest(
        method: 'GET',
        url: url.toString(),
        headers: updatedHeaders,
        body: null,
      );
      
      final response = await _client.get(url, headers: updatedHeaders);
      final duration = DateTime.now().millisecondsSinceEpoch - startTime;
      
      if (response.statusCode >= 200 && response.statusCode < 300) {
        ApiLogger.logResponse(
          method: 'GET',
          url: url.toString(),
          statusCode: response.statusCode,
          body: response.body,
          durationMs: duration,
        );
      }
      
      return response;
    }, headers, null, 'GET', url.toString(), startTime);
  }

  Future<http.Response?> post(
      Uri url, {
        Map<String, String>? headers,
        Object? body,
      }) async {
    final startTime = DateTime.now().millisecondsSinceEpoch;
    
    return _interceptRequest((updatedHeaders, encodedBody) async {
      ApiLogger.logRequest(
        method: 'POST',
        url: url.toString(),
        headers: updatedHeaders,
        body: encodedBody,
      );
      
      final response = await _client.post(
        url,
        headers: updatedHeaders,
        body: encodedBody,
      );
      
      final duration = DateTime.now().millisecondsSinceEpoch - startTime;
      
      if (response.statusCode >= 200 && response.statusCode < 300) {
        ApiLogger.logResponse(
          method: 'POST',
          url: url.toString(),
          statusCode: response.statusCode,
          body: response.body,
          durationMs: duration,
        );
      }
      
      return response;
    }, headers, body, 'POST', url.toString(), startTime);
  }

  Future<http.Response?> delete(
      Uri url, {
        Map<String, String>? headers,
        Object? body,
      }) async {
    final startTime = DateTime.now().millisecondsSinceEpoch;
    
    return _interceptRequest((updatedHeaders, encodedBody) async {
      ApiLogger.logRequest(
        method: 'DELETE',
        url: url.toString(),
        headers: updatedHeaders,
        body: encodedBody,
      );
      
      final response = await _client.delete(
        url,
        headers: updatedHeaders,
        body: encodedBody,
      );
      
      final duration = DateTime.now().millisecondsSinceEpoch - startTime;
      
      if (response.statusCode >= 200 && response.statusCode < 300) {
        ApiLogger.logResponse(
          method: 'DELETE',
          url: url.toString(),
          statusCode: response.statusCode,
          body: response.body,
          durationMs: duration,
        );
      }
      
      return response;
    }, headers, body, 'DELETE', url.toString(), startTime);
  }

  Future<http.Response?> put(
      Uri url, {
        Map<String, String>? headers,
        Object? body,
      }) async {
    final startTime = DateTime.now().millisecondsSinceEpoch;
    
    return _interceptRequest((updatedHeaders, encodedBody) async {
      ApiLogger.logRequest(
        method: 'PUT',
        url: url.toString(),
        headers: updatedHeaders,
        body: encodedBody,
      );
      
      final response = await _client.put(
        url,
        headers: updatedHeaders,
        body: encodedBody,
      );
      
      final duration = DateTime.now().millisecondsSinceEpoch - startTime;
      
      if (response.statusCode >= 200 && response.statusCode < 300) {
        ApiLogger.logResponse(
          method: 'PUT',
          url: url.toString(),
          statusCode: response.statusCode,
          body: response.body,
          durationMs: duration,
        );
      }
      
      return response;
    }, headers, body, 'PUT', url.toString(), startTime);
  }

  Future<http.Response?> patch(
      Uri url, {
        Map<String, String>? headers,
        Object? body,
      }) async {
    final startTime = DateTime.now().millisecondsSinceEpoch;
    
    return _interceptRequest((updatedHeaders, encodedBody) async {
      ApiLogger.logRequest(
        method: 'PATCH',
        url: url.toString(),
        headers: updatedHeaders,
        body: encodedBody,
      );
      
      final response = await _client.patch(
        url,
        headers: updatedHeaders,
        body: encodedBody,
      );
      
      final duration = DateTime.now().millisecondsSinceEpoch - startTime;
      
      if (response.statusCode >= 200 && response.statusCode < 300) {
        ApiLogger.logResponse(
          method: 'PATCH',
          url: url.toString(),
          statusCode: response.statusCode,
          body: response.body,
          durationMs: duration,
        );
      }
      
      return response;
    }, headers, body, 'PATCH', url.toString(), startTime);
  }
}