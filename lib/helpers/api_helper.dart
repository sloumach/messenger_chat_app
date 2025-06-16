import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http/http.dart' as http;

class ApiHelper {
  static final _storage = const FlutterSecureStorage();

  /// Appel GET sécurisé
  static Future<http.Response> get(BuildContext context, Uri uri) async {
    final token = await _storage.read(key: 'token');

    final response = await http.get(
      uri,
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
    );

    _handleResponse(context, response);
    return response;
  }

  /// Appel POST sécurisé
  static Future<http.Response> post(
    BuildContext context,
    Uri uri,
    Map<String, dynamic> body,
  ) async {
    final token = await _storage.read(key: 'token');

    final response = await http.post(
      uri,
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
      body: jsonEncode(body),
    );

    _handleResponse(context, response);
    return response;
  }

  static void _handleResponse(BuildContext context, http.Response res) {
    if (res.statusCode == 401) {
      _storage.delete(key: 'token'); // token invalide
      if (context.mounted) {
        Navigator.pushNamedAndRemoveUntil(context, '/login', (route) => false);
      }
    }
  }
}
