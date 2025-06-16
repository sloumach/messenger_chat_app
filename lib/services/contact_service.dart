import 'dart:convert';
import '../models/contact_model.dart';
import '../helpers/api_helper.dart';
import 'package:flutter/material.dart';

class ContactService {
  final String baseUrl = "http://10.0.2.2:8000/api";

  /// Récupère la liste des contacts
  Future<List<ContactModel>> fetchContacts(BuildContext context) async {
    final response = await ApiHelper.get(
      context,
      Uri.parse('$baseUrl/contacts'),
    );

    if (response.statusCode == 200) {
      final List<dynamic> data = jsonDecode(response.body);
      return data.map((json) => ContactModel.fromJson(json)).toList();
    } else {
      throw Exception('Erreur lors du chargement des contacts');
    }
  }

  /// Récupère les invitations en attente (optionnel, à utiliser plus tard)
  Future<List<dynamic>> fetchInvitations(BuildContext context) async {
    final response = await ApiHelper.get(
      context,
      Uri.parse('$baseUrl/invitations'),
    );

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception('Erreur lors du chargement des invitations');
    }
  }
}
