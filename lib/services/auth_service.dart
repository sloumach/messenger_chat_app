import 'dart:convert';

import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:http/http.dart' as http;

import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class AuthService {
  final String baseUrl =
      "https://armessenger.abdessalem.tn/api"; // localhost depuis l'émulateur Android
  final FlutterSecureStorage storage = const FlutterSecureStorage();

  Future<Map<String, dynamic>> login(String email, String password) async {
    final response = await http.post(
      Uri.parse('$baseUrl/login'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'email': email, 'password': password}),
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      await storage.write(key: 'token', value: data['token']);
      await storage.write(key: 'user_id', value: data['id'].toString());
      String? fcmToken = await FirebaseMessaging.instance.getToken();

      if (fcmToken != null) {
        await http.post(
          Uri.parse('$baseUrl/update-fcm-token'),
          headers: {
            'Content-Type': 'application/json',
            'Authorization': 'Bearer ${data['token']}',
          },
          body: jsonEncode({'fcm_token': fcmToken}),
        );
      }
      return {'success': true, 'user': data['user']};
    } else if (response.statusCode == 403) {
      return {
        'success': false,
        'message': 'Please verify your email address before logging in.',
      };
    } else if (response.statusCode == 429) {
      return {
        'success': false,
        'message': 'Too many requests. Please try again later.',
      };
    } else {
      return {
        'success': false,
        'message': jsonDecode(response.body)['message'] ?? 'Connection error',
      };
    }
  }

  Future<Map<String, dynamic>> register(
    String name,
    String email,
    String password,
    String confirmPassword,
  ) async {
    final response = await http.post(
      Uri.parse('$baseUrl/register'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'name': name,
        'email': email,
        'password': password,
        'password_confirmation': confirmPassword,
      }),
    );

    if (response.statusCode == 201) {
      final data = jsonDecode(response.body);
      await storage.write(key: 'token', value: data['token']);

      return {'success': true, 'user': data['user']};
    } else if (response.statusCode == 429) {
      return {
        'success': false,
        'message': 'Too many requests. Please try again later.',
      };
    } else {
      return {
        'success': false,
        'message': jsonDecode(response.body)['message'] ?? 'Erreur',
      };
    }
  }

  Future<void> logout() async {
    final token = await storage.read(key: 'token');
    if (token == null) return;

    await http.post(
      Uri.parse('$baseUrl/logout'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
    );

    await storage.delete(key: 'token');
  }

  Future<String?> getToken() async {
    return await storage.read(key: 'token');
  }

  Future<Map<String, dynamic>> forgotPassword(String email) async {
    final response = await http.post(
      Uri.parse('$baseUrl/forgot-password'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'email': email}),
    );

    if (response.statusCode == 200) {
      return {'success': true, 'message': jsonDecode(response.body)['status']};
    } else if (response.statusCode == 429) {
      return {
        'success': false,
        'message': 'Too many requests. Please try again later.',
      };
    } else {
      return {
        'success': false,
        'message': jsonDecode(response.body)['message'] ?? 'Erreur',
      };
    }
  }
}
