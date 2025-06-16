import 'dart:convert';
import '../models/message_model.dart';
import '../helpers/api_helper.dart';
import 'package:flutter/material.dart';

class MessageService {
  final String baseUrl = "http://10.0.2.2:8000/api";

  Future<List<MessageModel>> fetchMessages(
    BuildContext context,
    int contactId, {
    String? beforeIso,
  }) async {
    final query = beforeIso != null ? '?before=$beforeIso' : '';
    final url = '$baseUrl/messages/$contactId$query';

    final res = await ApiHelper.get(context, Uri.parse(url));

    if (res.statusCode == 200) {
      final List decoded = jsonDecode(res.body);
      return decoded.map((e) => MessageModel.fromJson(e)).toList();
    } else {
      throw Exception('Erreur chargement messages (${res.statusCode})');
    }
  }

  Future<void> sendMessage(
    BuildContext context,
    int contactId,
    String content,
  ) async {
    final response = await ApiHelper.post(
      context,
      Uri.parse('$baseUrl/messages/$contactId'),
      {'content': content},
    );

    if (response.statusCode != 200 && response.statusCode != 201) {
      throw Exception('Erreur lors de l\'envoi du message');
    }
  }
}
