import 'package:dormify_mobile/data/chat_repository.dart';
import 'package:dormify_mobile/data/landlord_repository.dart';
import 'package:dormify_mobile/data/tenant_repository.dart'; // Add this
import 'package:dormify_mobile/extensions/user.extension.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:logger/logger.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class ChatDetailArguments {
  final String partnerId;
  final bool isLandlord;
  ChatDetailArguments({required this.partnerId, required this.isLandlord});
}

class ChatDetailPage extends StatefulWidget {
  const ChatDetailPage({super.key});

  @override
  State<ChatDetailPage> createState() => _ChatDetailPageState();
}

class _ChatDetailPageState extends State<ChatDetailPage> {
  final Logger _logger = Logger();
  final User user = FirebaseAuth.instance.currentUser!;
  final LandlordRepository _landlordRepository = LandlordRepository.instance;
  final ChatRepository _chatRepository = ChatRepository.instance;
  final TenantRepository _tenantRepository = TenantRepository.instance;
  final TextEditingController _messageController = TextEditingController();
  bool _isLandlord = false; // Initialize with a default value
  bool _isInitialized = false; // Add this flag
  dynamic _partner; // Can be either Landlord or Tenant
  String? _currentChatId;
  Timestamp? _lastReadAt;

  @override
  void initState() {
    super.initState();
    _initializeUserType();
  }

  Future<void> _initializeUserType() async {
    final userType = await user.type(user);
    setState(() {
      _isLandlord = userType == UserTypeEnum.landlord;
      _isInitialized = true; // Mark as initialized
    });
  }

  @override
  void dispose() {
    _messageController.dispose();
    super.dispose();
  }

  void _sendMessage() async {
    if (_messageController.text.trim().isEmpty || _currentChatId == null) {
      return;
    }

    try {
      await _chatRepository.sendMessage(_currentChatId!, await user.type(user),
          _messageController.text.trim());
      _messageController.clear();
    } catch (e) {
      _logger.e('Error sending message: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Failed to send message')),
      );
    }
  }

  Future<void> _initializeChat(String userId, String partnerId) async {
    if (!_isInitialized) {
      await _initializeUserType();
    }

    try {
      _logger.i('Initializing chat with partner: $partnerId');
      if (_isLandlord) {
        _partner = await _tenantRepository.getTenantById(partnerId);
      } else {
        _partner = await _landlordRepository.getLandlordById(partnerId);
      }

      // Get existing chat or create new one
      final chats = await _chatRepository.getChatsByUserIdAndLandlordId(
        _isLandlord ? userId : partnerId, // landlordId
        _isLandlord ? partnerId : userId, // userId
      );

      if (chats.isEmpty) {
        final newChat = await _chatRepository.createChat(
          _isLandlord ? userId : partnerId, // landlordId
          _isLandlord ? partnerId : userId, // userId
        );
        setState(() => _currentChatId = newChat.id);
      } else {
        setState(() {
          _currentChatId = chats.first.id;
          _lastReadAt = chats.first.lastReadAt;
        });
      }

      if (_currentChatId != null) {
        await _chatRepository.markChatAsRead(_currentChatId!);
      }
    } catch (e) {
      _logger.e('Error initializing chat: $e');
    }
  }

  Widget _buildProfileAvatar(String? name, Color backgroundColor) {
    return CircleAvatar(
      backgroundColor: backgroundColor,
      child: Text(
        name?.isNotEmpty == true ? name![0].toUpperCase() : '?',
        style: const TextStyle(
          color: Colors.white,
          fontWeight: FontWeight.bold,
          fontSize: 16,
        ),
      ),
    );
  }

  Widget _buildMessageBubble(Map<String, dynamic> message) {
    final messageType = message['type'];
    // Message is from current user if type matches their role
    final isFromCurrentUser = (messageType == 'landlord' && _isLandlord) ||
        (messageType == 'tenant' && !_isLandlord);

    final bubbleColor = isFromCurrentUser
        ? const Color(0xFF2196F3).withOpacity(0.2)
        : const Color(0xFF4F925A).withOpacity(0.2);
    final alignment =
        isFromCurrentUser ? Alignment.centerRight : Alignment.centerLeft;
    final textColor =
        isFromCurrentUser ? const Color(0xFF1565C0) : const Color(0xFF4F925A);
    final margin = isFromCurrentUser
        ? const EdgeInsets.only(left: 50, right: 8)
        : const EdgeInsets.only(right: 50, left: 8);

    return Container(
      margin: margin,
      alignment: alignment,
      child: Row(
        mainAxisAlignment:
            isFromCurrentUser ? MainAxisAlignment.end : MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (!isFromCurrentUser) ...[
            _buildProfileAvatar(_partner?.firstName, const Color(0xFF4F925A)),
            const SizedBox(width: 8),
          ],
          Flexible(
            child: Column(
              crossAxisAlignment: isFromCurrentUser
                  ? CrossAxisAlignment.end
                  : CrossAxisAlignment.start,
              children: [
                Container(
                  margin: const EdgeInsets.only(bottom: 10),
                  padding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                  decoration: BoxDecoration(
                    color: bubbleColor,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: bubbleColor.withOpacity(0.5),
                      width: 1,
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        isFromCurrentUser
                            ? 'You'
                            : _partner?.firstName ?? 'Partner',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          color: textColor,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        message['message'] ?? '',
                        style: const TextStyle(
                          color: Colors.black87,
                          fontSize: 16,
                        ),
                      ),
                    ],
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.only(top: 4, left: 8, right: 8),
                  child: Text(
                    _formatTimestamp(message['createdAt']),
                    style: TextStyle(
                      fontSize: 11,
                      color: Colors.grey[600],
                    ),
                  ),
                ),
              ],
            ),
          ),
          if (isFromCurrentUser) ...[
            const SizedBox(width: 8),
            _buildProfileAvatar('You', const Color(0xFF2196F3)),
          ],
        ],
      ),
    );
  }

  String _formatTimestamp(Timestamp? timestamp) {
    if (timestamp == null) return '';
    final date = timestamp.toDate();
    return '${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}';
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.chat_bubble_outline,
            size: 64,
            color: Colors.grey[400],
          ),
          const SizedBox(height: 16),
          Text(
            'No messages yet',
            style: TextStyle(
              fontSize: 18,
              color: Colors.grey[600],
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Start the conversation now!',
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey[500],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildUnreadDivider(int unreadCount) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 16, horizontal: 8),
      child: Row(
        children: [
          Expanded(child: Divider(color: Colors.red[300])),
          Container(
            margin: const EdgeInsets.symmetric(horizontal: 8),
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
            decoration: BoxDecoration(
              color: Colors.red[100],
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              '$unreadCount new message${unreadCount > 1 ? 's' : ''}',
              style: TextStyle(
                color: Colors.red[900],
                fontSize: 12,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          Expanded(child: Divider(color: Colors.red[300])),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (!_isInitialized) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    final ChatDetailArguments argument =
        ModalRoute.of(context)!.settings.arguments as ChatDetailArguments;
    final partnerId = argument.partnerId;
    final userId = user.uid;

    if (_currentChatId == null) {
      _initializeChat(userId, partnerId);
    }

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        title: Row(
          children: [
            _buildProfileAvatar(_partner?.firstName, const Color(0xFF4F925A)),
            const SizedBox(width: 12),
            Text(
              _partner?.firstName ?? 'Partner',
              style: const TextStyle(color: Colors.white),
            ),
          ],
        ),
        backgroundColor: const Color(0xFF4F925A),
      ),
      body: Column(
        children: [
          Expanded(
            child: _currentChatId == null
                ? const Center(child: CircularProgressIndicator())
                : StreamBuilder<QuerySnapshot>(
                    stream: FirebaseFirestore.instance
                        .collection('Chats')
                        .doc(_currentChatId)
                        .collection('ChatMessages')
                        .orderBy('createdAt', descending: true)
                        .snapshots(),
                    builder: (context, snapshot) {
                      if (snapshot.hasError) {
                        return const Center(
                            child: Text('Something went wrong'));
                      }

                      if (!snapshot.hasData) {
                        return const Center(child: CircularProgressIndicator());
                      }

                      final messages = snapshot.data!.docs;

                      if (messages.isEmpty) {
                        return _buildEmptyState();
                      }

                      // Mark messages as read when viewing chat
                      if (snapshot.hasData && snapshot.data!.docs.isNotEmpty) {
                        _chatRepository.markChatAsRead(_currentChatId!);
                      }

                      return ListView.builder(
                        reverse: true,
                        padding: const EdgeInsets.all(8.0),
                        itemCount: messages.length,
                        itemBuilder: (context, index) {
                          final message =
                              messages[index].data() as Map<String, dynamic>;
                          final messageTimestamp =
                              message['createdAt'] as Timestamp?;

                          // Only show divider if we have a valid lastReadAt timestamp
                          if (_lastReadAt != null &&
                              messageTimestamp != null &&
                              index < messages.length - 1) {
                            final nextMessage = messages[index + 1].data()
                                as Map<String, dynamic>;
                            final nextMessageTimestamp =
                                nextMessage['createdAt'] as Timestamp?;

                            if (nextMessageTimestamp != null &&
                                messageTimestamp
                                    .toDate()
                                    .isAfter(_lastReadAt!.toDate()) &&
                                nextMessageTimestamp
                                    .toDate()
                                    .isBefore(_lastReadAt!.toDate())) {
                              // Count only messages that are newer than lastReadAt
                              int unreadCount =
                                  messages.take(index + 1).where((doc) {
                                final ts = (doc.data()
                                        as Map<String, dynamic>)['createdAt']
                                    as Timestamp?;
                                return ts != null &&
                                    ts.toDate().isAfter(_lastReadAt!.toDate());
                              }).length;

                              return Column(
                                children: [
                                  _buildMessageBubble(message),
                                  if (unreadCount > 0)
                                    _buildUnreadDivider(unreadCount),
                                ],
                              );
                            }
                          }

                          return _buildMessageBubble(message);
                        },
                      );
                    },
                  ),
          ),
          Container(
            padding: const EdgeInsets.all(8.0),
            decoration: BoxDecoration(
              color: Colors.white,
              boxShadow: [
                BoxShadow(
                  color: Colors.grey.withOpacity(0.5),
                  spreadRadius: 1,
                  blurRadius: 3,
                  offset: const Offset(0, -1),
                ),
              ],
            ),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _messageController,
                    decoration: InputDecoration(
                      hintText: 'Type a message...',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(20),
                        borderSide: BorderSide(
                          color: Colors.grey.withOpacity(0.3),
                        ),
                      ),
                      contentPadding:
                          EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                    ),
                    maxLines: null,
                    textCapitalization: TextCapitalization.sentences,
                  ),
                ),
                const SizedBox(width: 8),
                IconButton(
                  onPressed: _sendMessage,
                  icon: const Icon(Icons.send),
                  color: const Color(0xFF4F925A),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
