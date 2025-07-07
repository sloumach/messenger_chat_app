import 'dart:convert';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http/http.dart' as http;
import 'package:firebase_messaging/firebase_messaging.dart';

class FcmService {
  final FlutterSecureStorage storage = const FlutterSecureStorage();

  void listenForTokenChanges() {
    FirebaseMessaging.instance.onTokenRefresh.listen((newToken) async {
      await _sendFcmTokenToServer(newToken);
    });
  }

  Future<void> _sendFcmTokenToServer(String token) async {
    final jwt = await storage.read(key: 'token');
    if (jwt == null) return;

    await http.post(
      Uri.parse('https://armessenger.abdessalem.tn/api/update-fcm-token'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $jwt',
      },
      body: jsonEncode({'fcm_token': token}),
    );
  }
}
