import 'package:cloud_firestore/cloud_firestore.dart';

class Chat {
  final String id;
  final String landlordId;
  final String userId;
  final String senderId; // New field
  final String receiverId; // New field
  final Timestamp createdAt;
  final int unreadCount;
  final Timestamp? lastReadAt;

  Chat({
    required this.id,
    required this.landlordId,
    required this.userId,
    required this.createdAt,
    required this.senderId, // New field
    required this.receiverId, // New field
    this.unreadCount = 0,
    this.lastReadAt,
  });

  factory Chat.fromMap(String id, Map<String, dynamic> map) {
    return Chat(
      id: id,
      landlordId: map['landlordId'],
      userId: map['userId'],
      senderId: map['senderId'] ?? '',
      receiverId: map['receiverId'] ?? '',
      createdAt: map['createdAt'],
      unreadCount: map['unreadCount'] ?? 0,
      lastReadAt: map['lastReadAt'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'landlordId': landlordId,
      'userId': userId,
      'senderId': senderId,
      'receiverId': receiverId,
      'createdAt': createdAt,
      'unreadCount': unreadCount,
      'lastReadAt': lastReadAt,
    };
  }
}
