class InvitationModel {
  final int id;
  final int senderId;
  final int receiverId;
  final String status;
  final DateTime createdAt;

  InvitationModel({
    required this.id,
    required this.senderId,
    required this.receiverId,
    required this.status,
    required this.createdAt,
  });

  factory InvitationModel.fromJson(Map<String, dynamic> json) {
    return InvitationModel(
      id: json['id'],
      senderId: json['sender_id'],
      receiverId: json['receiver_id'],
      status: json['status'],
      createdAt: DateTime.parse(json['created_at']),
    );
  }
}
