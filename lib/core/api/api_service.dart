import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

class CoreApi {
  final _client = http.Client();
  final String baseUrl = 'http://localhost:3000';

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
        debugPrint('No username found for token refresh');
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
        debugPrint('Token refreshed successfully');
        return token;
      }
      debugPrint('Failed to refresh token: ${response.statusCode}');
      return null;
    } catch (e) {
      debugPrint('Refresh token error: $e');
      return null;
    }
  }

  // Interceptor برای مدیریت درخواست‌ها
  Future<http.Response?> _interceptRequest(
    Future<http.Response> Function(Map<String, String>) request,
    Map<String, String>? headers,
  ) async {
    try {
      // اگر درخواست برای /auth/login است، نیازی به توکن نیست
      if (headers != null && headers.containsKey('skip-auth')) {
        final updatedHeaders = Map<String, String>.from(headers);
        updatedHeaders.remove('skip-auth'); // حذف هدر موقت
        debugPrint('Skipping auth');
        return await request(updatedHeaders);
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
      final response = await request(updatedHeaders);

      // مدیریت خطای 401
      if (response.statusCode == 401) {
        debugPrint('Unauthorized: Attempting to refresh token');
        final newToken = await _refreshToken();
        if (newToken != null) {
          // بازنویسی هدرها با توکن جدید
          updatedHeaders['Authorization'] = 'Bearer $newToken';
          // تکرار درخواست با توکن جدید
          return await request(updatedHeaders);
        } else {
          // اگر رفرش توکن ممکن نبود، خطا پرتاب کنید
          throw Exception('Unauthorized: Please log in again');
        }
      }

      return response;
    } catch (e) {
      debugPrint('Interceptor error: $e');
      rethrow;
    }
  }

  Future<http.Response?> get(Uri url, {Map<String, String>? headers}) async {
    return _interceptRequest((updatedHeaders) async {
      debugPrint('GET => $url');
      debugPrint('Headers: $updatedHeaders');
      final response = await _client.get(url, headers: updatedHeaders);
      debugPrint('Response [${response.statusCode}]: ${response.body}');
      return response;
    }, headers);
  }

  Future<http.Response?> post(
    Uri url, {
    Map<String, String>? headers,
    Object? body,
  }) async {
    return _interceptRequest((updatedHeaders) async {
      debugPrint('POST : $url');
      debugPrint('Headers: $updatedHeaders');
      debugPrint('Body: $body');
      final response = await _client.post(
        url,
        headers: updatedHeaders,
        body: body ?? {},
      );
      debugPrint('Response [${response.statusCode}]: ${response.body}');
      return response;
    }, headers);
  }

  Future<http.Response?> delete(
    Uri url, {
    Map<String, String>? headers,
    Object? body,
  }) async {
    return _interceptRequest((updatedHeaders) async {
      debugPrint('DELETE => $url');
      debugPrint('Headers: $updatedHeaders');
      debugPrint('Body: $body');
      final response = await _client.delete(
        url,
        headers: updatedHeaders,
        body: body ?? {},
      );
      debugPrint('Response [${response.statusCode}]: ${response.body}');
      return response;
    }, headers);
  }

  Future<http.Response?> put(
    Uri url, {
    Map<String, String>? headers,
    Object? body,
  }) async {
    return _interceptRequest((updatedHeaders) async {
      debugPrint('PUT => $url');
      debugPrint('Headers: $updatedHeaders');
      debugPrint('Body: $body');
      final response = await _client.put(
        url,
        headers: updatedHeaders,
        body: body ?? {},
      );
      debugPrint('Response [${response.statusCode}]: ${response.body}');
      return response;
    }, headers);
  }

  Future<http.Response?> patch(
    Uri url, {
    Map<String, String>? headers,
    Object? body,
  }) async {
    return _interceptRequest((updatedHeaders) async {
      debugPrint('PATCH => $url');
      debugPrint('Headers: $updatedHeaders');
      debugPrint('Body: $body');
      final response = await _client.patch(
        url,
        headers: updatedHeaders,
        body: body ?? {},
      );
      debugPrint('Response [${response.statusCode}]: ${response.body}');
      return response;
    }, headers);
  }
}
