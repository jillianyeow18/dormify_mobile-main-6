import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dormify_mobile/data/chat_repository.dart';
import 'package:dormify_mobile/data/landlord_repository.dart';
import 'package:dormify_mobile/pages/chat/chat_detail_page.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:logger/logger.dart';
import 'package:dormify_mobile/data/tenant_repository.dart';
import 'package:dormify_mobile/extensions/user.extension.dart';

class ChatPage extends StatefulWidget {
  const ChatPage({super.key});

  @override
  State<ChatPage> createState() => _ChatPageState();
}

class _ChatPageState extends State<ChatPage> {
  final Logger _logger = Logger();
  final User _user = FirebaseAuth.instance.currentUser!;
  final ChatRepository _chatRepository = ChatRepository.instance;
  final LandlordRepository _landlordRepository = LandlordRepository.instance;
  final TenantRepository _tenantRepository = TenantRepository.instance;
  late bool _isLandlord;

  @override
  void initState() {
    super.initState();
    _initializeUserType();
  }

  Future<void> _initializeUserType() async {
    final userType = await _user.type(_user);
    setState(() {
      _isLandlord = userType == UserTypeEnum.landlord;
    });
  }

  Widget _buildChatItem(String chatId) {
    return StreamBuilder<DocumentSnapshot>(
      stream: FirebaseFirestore.instance
          .collection('Chats')
          .doc(chatId)
          .snapshots(),
      builder: (context, chatSnapshot) {
        if (!chatSnapshot.hasData) {
          return const SizedBox.shrink();
        }

        final chatData = chatSnapshot.data!.data() as Map<String, dynamic>;
        final partnerId = _isLandlord
            ? chatData['userId'] as String
            : chatData['landlordId'] as String;

        return FutureBuilder<dynamic>(
          future: _isLandlord
              ? _tenantRepository.getTenantById(partnerId)
              : _landlordRepository.getLandlordById(partnerId),
          builder: (context, partnerSnapshot) {
            if (!partnerSnapshot.hasData) {
              return const SizedBox.shrink();
            }

            final partner = partnerSnapshot.data!;

            return StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance
                  .collection('Chats')
                  .doc(chatId)
                  .collection('ChatMessages')
                  .orderBy('createdAt', descending: true)
                  .limit(1)
                  .snapshots(),
              builder: (context, messageSnapshot) {
                String lastMessage = '';
                String timestamp = '';
                int unreadCount = 0;

                if (chatSnapshot.data!.data() != null) {
                  final chatData =
                      chatSnapshot.data!.data() as Map<String, dynamic>;
                  unreadCount = chatData['unreadCount'] ?? 0;
                }

                if (messageSnapshot.hasData &&
                    messageSnapshot.data!.docs.isNotEmpty) {
                  final lastMessageData = messageSnapshot.data!.docs.first
                      .data() as Map<String, dynamic>;
                  lastMessage = lastMessageData['message'] ?? '';
                  final createdAt = lastMessageData['createdAt'] as Timestamp?;
                  if (createdAt != null) {
                    timestamp = _formatTimestamp(createdAt);
                  }
                }

                return ListTile(
                  leading: CircleAvatar(
                    backgroundColor: const Color(0xFF4F925A),
                    child: Text(
                      partner.firstName[0].toUpperCase(),
                      style: const TextStyle(color: Colors.white),
                    ),
                  ),
                  title: Text(
                    partner.firstName,
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  subtitle: Text(
                    lastMessage,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  trailing: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        timestamp,
                        style: TextStyle(color: Colors.grey[600], fontSize: 12),
                      ),
                      if (unreadCount > 0) ...[
                        const SizedBox(height: 4),
                        Container(
                          padding: const EdgeInsets.all(6),
                          decoration: const BoxDecoration(
                            color: Color(0xFF4F925A),
                            shape: BoxShape.circle,
                          ),
                          child: Text(
                            unreadCount.toString(),
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                  onTap: () {
                    Navigator.pushNamed(
                      context,
                      '/chat/detail',
                      arguments: ChatDetailArguments(
                        partnerId: partner.id,
                        isLandlord: _isLandlord,
                      ),
                    );
                  },
                );
              },
            );
          },
        );
      },
    );
  }

  String _formatTimestamp(Timestamp timestamp) {
    final now = DateTime.now();
    final date = timestamp.toDate();
    final diff = now.difference(date);

    if (diff.inDays > 0) {
      return '${diff.inDays}d';
    } else if (diff.inHours > 0) {
      return '${diff.inHours}h';
    } else if (diff.inMinutes > 0) {
      return '${diff.inMinutes}m';
    } else {
      return 'now';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: StreamBuilder<List<String>>(
        stream: _chatRepository.getChatsStream(_user.uid, _isLandlord),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            _logger.e('Error loading chats: ${snapshot.error}');
            return const Center(child: Text('Error loading chats'));
          }

          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }

          final chatIds = snapshot.data!;

          if (chatIds.isEmpty) {
            return const Center(child: Text('No chats yet'));
          }

          return ListView.separated(
            itemCount: chatIds.length,
            separatorBuilder: (context, index) => const Divider(height: 1),
            itemBuilder: (context, index) => _buildChatItem(chatIds[index]),
          );
        },
      ),
    );
  }
}
