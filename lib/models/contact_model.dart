// lib/models/contact_model.dart
class ContactModel {
  final int id;
  final String name;
  final String email;

  ContactModel({required this.id, required this.name, required this.email});

  factory ContactModel.fromJson(Map<String, dynamic> json) {
    return ContactModel(
      id: json['id'],
      name: json['name'],
      email: json['email'],
    );
  }
}
