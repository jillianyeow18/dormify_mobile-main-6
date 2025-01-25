import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dormify_mobile/extensions/user.extension.dart';

class ChatMessage {
  final String id;
  final String chatId;
  final String message;
  final UserTypeEnum type;
  final Timestamp createdAt;

  ChatMessage({
    required this.id,
    required this.chatId,
    required this.message,
    required this.type,
    required this.createdAt,
  });

  factory ChatMessage.fromMap(String id, Map<String, dynamic> map) {
    return ChatMessage(
      id: id,
      chatId: map['chatId'],
      message: map['message'],
      type: map['type'],
      createdAt: map['createdAt'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'chatId': chatId,
      'message': message,
      'type': type,
      'createdAt': createdAt,
    };
  }
}
