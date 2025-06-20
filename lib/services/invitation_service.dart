import 'dart:convert';
import '../models/invitation_model.dart';
import '../helpers/api_helper.dart';
import 'package:flutter/material.dart';

class InvitationService {
  final String baseUrl = "https://armessenger.abdessalem.tn/api";

  // 🟢 Récupérer les invitations reçues
  Future<List<InvitationModel>> fetchInvitations(BuildContext context) async {
    final response = await ApiHelper.get(
      context,
      Uri.parse('$baseUrl/invitations'),
    );
    if (response.statusCode == 200) {
      final List<dynamic> data = jsonDecode(response.body);
      return data.map((json) => InvitationModel.fromJson(json)).toList();
    } else {
      throw Exception("Erreur ${response.statusCode} lors du chargement.");
    }
  }

  Future<void> sendInvitation(BuildContext context, String email) async {
    final response = await ApiHelper.post(
      context,
      Uri.parse('$baseUrl/sendinvitation'),
      {'email': email},
    );

    if (response.statusCode != 200) {
      final decoded = jsonDecode(response.body);
      throw Exception(
        decoded['message'] ?? 'Erreur lors de l’envoi de l’invitation',
      );
    }
  }

  Future<void> acceptInvitation(BuildContext context, int invitationId) async {
    final response = await ApiHelper.post(
      context,
      Uri.parse('$baseUrl/invitations/$invitationId/accept'),
      {},
    );

    if (response.statusCode != 200) {
      final decoded = jsonDecode(response.body);
      throw Exception(decoded['message'] ?? 'Erreur acceptation invitation');
    }
  }

  Future<void> declineInvitation(BuildContext context, int invitationId) async {
    final response = await ApiHelper.post(
      context,
      Uri.parse('$baseUrl/invitations/$invitationId/decline'),
      {},
    );

    if (response.statusCode != 200) {
      final decoded = jsonDecode(response.body);
      throw Exception(decoded['message'] ?? 'Erreur refus invitation');
    }
  }
}
