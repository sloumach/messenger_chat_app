class MessageModel {
  final int id;
  final int senderId;
  final int receiverId;
  final String content;
  final DateTime createdAt;

  MessageModel({
    required this.id,
    required this.senderId,
    required this.receiverId,
    required this.content,
    required this.createdAt,
    required String status,
  });

  factory MessageModel.fromJson(Map<String, dynamic> json) {
    return MessageModel(
      id: json['id'],
      senderId: json['sender_id'],
      receiverId: json['receiver_id'],
      content: json['content'],
      status: 'sent',
      createdAt: DateTime.parse(json['created_at']),
    );
  }
}
