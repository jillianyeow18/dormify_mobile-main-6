import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dormify_mobile/domains/chat.domain.dart';
import 'package:dormify_mobile/extensions/user.extension.dart';
import 'package:logger/logger.dart';

class ChatRepository {
  ChatRepository._();

  static final instance = ChatRepository._();
  static final _firestore = FirebaseFirestore.instance;
  static final _logger = Logger();

  Future<DocumentReference<Map<String, dynamic>>> createChat(
      String landlordId, String userId) async {
    try {
      // Check if chat already exists
      final existingChats =
          await getChatsByUserIdAndLandlordId(userId, landlordId);
      if (existingChats.isNotEmpty) {
        return _firestore.collection('Chats').doc(existingChats.first.id);
      }

      // Create new chat if none exists
      return await _firestore.collection('Chats').add({
        'landlordId': landlordId,
        'userId': userId,
        'createdAt': FieldValue.serverTimestamp(),
        'unreadCount': 0,
      });
    } catch (e) {
      _logger.e('Error creating chat: $e');
      return Future.error('Error creating chat: $e');
    }
  }

  Future<void> sendMessage(
      String chatId, UserTypeEnum type, String message) async {
    try {
      final batch = _firestore.batch();

      // Add message
      final messageRef = _firestore
          .collection('Chats')
          .doc(chatId)
          .collection('ChatMessages')
          .doc();

      batch.set(messageRef, {
        'message': message,
        'type': type == UserTypeEnum.tenant ? 'tenant' : 'landlord',
        'createdAt': FieldValue.serverTimestamp(),
        'isRead': false,
      });

      // Increment unread count
      final chatRef = _firestore.collection('Chats').doc(chatId);
      batch.update(chatRef, {
        'unreadCount': FieldValue.increment(1),
        'lastMessage': message,
        'lastMessageTime': FieldValue.serverTimestamp(),
      });

      await batch.commit();
    } catch (e) {
      _logger.e('Error sending message: $e');
    }
  }

  Future<void> markChatAsRead(String chatId) async {
    try {
      final batch = _firestore.batch();
      final chatRef = _firestore.collection('Chats').doc(chatId);

      // Get the latest message timestamp
      final latestMessage = await _firestore
          .collection('Chats')
          .doc(chatId)
          .collection('ChatMessages')
          .orderBy('createdAt', descending: true)
          .limit(1)
          .get();

      if (latestMessage.docs.isNotEmpty) {
        final lastMessageTimestamp =
            latestMessage.docs.first.data()['createdAt'] as Timestamp?;

        batch.update(chatRef, {
          'unreadCount': 0,
          'lastReadAt': lastMessageTimestamp ?? FieldValue.serverTimestamp(),
        });

        // Mark all messages as read
        final messages = await _firestore
            .collection('Chats')
            .doc(chatId)
            .collection('ChatMessages')
            .where('isRead', isEqualTo: false)
            .get();

        for (var message in messages.docs) {
          batch.update(message.reference, {'isRead': true});
        }

        await batch.commit();
      }
    } catch (e) {
      _logger.e('Error marking chat as read: $e');
    }
  }

  Future<List<Chat>> getChatsByUserIdAndLandlordId(
      String userId, String partnerId) async {
    try {
      // First try to find chat where user is tenant and partner is landlord
      final tenantQuery = await _firestore
          .collection('Chats')
          .where('userId', isEqualTo: userId)
          .where('landlordId', isEqualTo: partnerId)
          .get();

      if (tenantQuery.docs.isNotEmpty) {
        return tenantQuery.docs
            .map((doc) => Chat.fromMap(doc.id, doc.data()))
            .toList();
      }

      // If not found, try to find chat where user is landlord and partner is tenant
      final landlordQuery = await _firestore
          .collection('Chats')
          .where('landlordId', isEqualTo: userId)
          .where('userId', isEqualTo: partnerId)
          .get();

      return landlordQuery.docs
          .map((doc) => Chat.fromMap(doc.id, doc.data()))
          .toList();
    } catch (e) {
      _logger.e('Error getting chats: $e');
      return [];
    }
  }

  Stream<List<String>> getChatsByUserIdStream(String userId) {
    return _firestore
        .collection('Chats')
        .where('userId', isEqualTo: userId)
        .snapshots()
        .map((snapshot) => snapshot.docs.map((doc) => doc.id).toList());
  }

  Stream<List<String>> getChatsByUserIdAndLandlordIdStream(
      String userId, String landlordId) {
    return _firestore
        .collection('Chats')
        .where('userId', isEqualTo: userId)
        .where('landlordId', isEqualTo: landlordId)
        .snapshots()
        .map((snapshot) => snapshot.docs.map((doc) => doc.id).toList());
  }

  Stream<List<String>> getChatsByLandlordId(String landlordId) {
    return _firestore
        .collection('Chats')
        .where('landlordId', isEqualTo: landlordId)
        .snapshots()
        .map((snapshot) => snapshot.docs.map((doc) => doc.id).toList());
  }

  Future<List<Chat>> getAllChats(String userId, bool isLandlord) async {
    try {
      final snapshot = await _firestore
          .collection('Chats')
          .where(isLandlord ? 'landlordId' : 'userId', isEqualTo: userId)
          .get();

      return snapshot.docs
          .map((doc) => Chat.fromMap(doc.id, doc.data()))
          .toList();
    } catch (e) {
      _logger.e('Error getting chats: $e');
      return [];
    }
  }

  Stream<List<String>> getChatsStream(String userId, bool isLandlord) {
    return _firestore
        .collection('Chats')
        .where(isLandlord ? 'landlordId' : 'userId', isEqualTo: userId)
        .snapshots()
        .map((snapshot) => snapshot.docs.map((doc) => doc.id).toList());
  }
}
