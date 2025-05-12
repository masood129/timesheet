import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class CoreApi {
  final _client = http.Client();

  Future<http.Response?> get(
      Uri url, {
        Map<String, String>? headers,
      }) async {
    try {
      debugPrint('GET => $url');
      debugPrint('Headers: ${headers ?? {}}');

      final response = await _client.get(url, headers: headers ?? {});

      debugPrint('Response [${response.statusCode}]: ${response.body}');
      return response;
    } catch (e) {
      debugPrint('GET Error: $e');
      return null;
    }
  }

  Future<http.Response?> post(
      Uri url, {
        Map<String, String>? headers,
        Object? body,
      }) async {
    try {
      debugPrint('POST => $url');
      debugPrint('Headers: ${headers ?? {}}');
      debugPrint('Body: $body');

      final response =
      await _client.post(url, headers: headers ?? {}, body: body ?? {});

      debugPrint('Response [${response.statusCode}]: ${response.body}');
      return response;
    } catch (e) {
      debugPrint('POST Error: $e');
      return null;
    }
  }

  Future<http.Response?> delete(
      Uri url, {
        Map<String, String>? headers,
        Object? body,
      }) async {
    try {
      debugPrint('DELETE => $url');
      debugPrint('Headers: ${headers ?? {}}');
      debugPrint('Body: $body');

      final response =
      await _client.delete(url, headers: headers ?? {}, body: body ?? {});

      debugPrint('Response [${response.statusCode}]: ${response.body}');
      return response;
    } catch (e) {
      debugPrint('DELETE Error: $e');
      return null;
    }
  }

  Future<http.Response?> patch(
      Uri url, {
        Map<String, String>? headers,
        Object? body,
      }) async {
    try {
      debugPrint('PATCH => $url');
      debugPrint('Headers: ${headers ?? {}}');
      debugPrint('Body: $body');

      final response =
      await _client.patch(url, headers: headers ?? {}, body: body ?? {});

      debugPrint('Response [${response.statusCode}]: ${response.body}');
      return response;
    } catch (e) {
      debugPrint('PATCH Error: $e');
      return null;
    }
  }

  Future<http.Response?> put(
      Uri url, {
        Map<String, String>? headers,
        Object? body,
      }) async {
    try {
      debugPrint('PUT => $url');
      debugPrint('Headers: ${headers ?? {}}');
      debugPrint('Body: $body');

      final response =
      await _client.put(url, headers: headers ?? {}, body: body ?? {});

      debugPrint('Response [${response.statusCode}]: ${response.body}');
      return response;
    } catch (e) {
      debugPrint('PUT Error: $e');
      return null;
    }
  }
}
