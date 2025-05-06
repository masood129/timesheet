


import 'package:flutter/material.dart';
import 'package:http/http.dart' as http ;

class CoreApi {
  final _client = http.Client();

  Future<http.Response?> get(
      Uri url, {
        Map<String, String>? headers,
      }) async {
    try {
      return await _client.get(
        url,
        headers: headers ?? {},
      );
    } catch (e) {
      debugPrint(e.toString());
      return null;
    }
  }

  Future<http.Response?> post(
      Uri url, {
        Map<String, String>? headers,
        Object? body,
      }) async{
    try {
      return await _client.post(
          url,
          headers: headers ?? {},
          body: body ?? {}
      );
    } catch (e) {
      debugPrint(e.toString());
      return null;
    }
  }

  Future<http.Response?> delete(
      Uri url, {
        Map<String, String>? headers,
        Object? body,
      }) async{
    try {
      return await _client.delete(
          url,
          headers: headers ?? {},
          body: body ?? {}
      );
    } catch (e) {
      debugPrint(e.toString());
      return null;
    }
  }
}
