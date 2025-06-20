import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:web_socket_channel/web_socket_channel.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class ReverbSocketService {
  final String baseUrl =
      "wss://ws.abdessalem.tn"; // localhost pour l'émulateur Android
  final FlutterSecureStorage storage = const FlutterSecureStorage();
  WebSocketChannel? _channel;

  Function(String content, int senderId)? onMessageReceived;

  Future<void> connect({
    required String channel,
    required Function(String content, int senderId) onMessageReceived,
  }) async {
    final token = await storage.read(key: 'token');
    final userId = await storage.read(key: 'user_id');
    if (token == null || userId == null) {
      return;
    }

    final url = Uri.parse(
      "$baseUrl/app/hdq2mz1lzrvfkwc5mvil?protocol=7&client=js&version=7.0&flash=false",
    );
    _channel = WebSocketChannel.connect(url);

    _channel!.stream.listen((message) async {
      final decoded = jsonDecode(message);
      final event = decoded['event'];
      final data = decoded['data'];
      if (event == 'pusher:connection_established') {
        final parsed = jsonDecode(data);
        final socketId = parsed['socket_id'];

        final authSignature = await getAuthSignature(channel, socketId);
        if (authSignature == null) {
          return;
        }

        final subscribePayload = jsonEncode({
          "event": "pusher:subscribe",
          "data": {"auth": authSignature, "channel": channel},
        });
        _channel!.sink.add(subscribePayload);
      }

      if (event == 'App\\Events\\MessageSent') {
        final parsedData = data is String ? jsonDecode(data) : data;
        final content = parsedData['content'];
        final senderId = parsedData['sender_id'];

        onMessageReceived(content, senderId);
      }
    });
  }

  Future<String?> getAuthSignature(String channelName, String socketId) async {
    final token = await storage.read(key: 'token');
    if (token == null) return null;

    final response = await http.post(
      Uri.parse('https://armessenger.abdessalem.tn/broadcasting/auth'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
      body: jsonEncode({'channel_name': channelName, 'socket_id': socketId}),
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return data['auth']; // 🛡️ Signature d'authentification
    } else {
      return null;
    }
  }

  void disconnect() {
    _channel?.sink.close();
  }
}
