import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:unibridge_lk/theme/app_theme.dart';
import 'package:unibridge_lk/models/chat_models.dart';
import 'package:unibridge_lk/services/chat_conversations_service.dart';
import 'package:unibridge_lk/services/firestore_service.dart';
import 'package:unibridge_lk/controllers/auth_controller.dart';
import 'package:unibridge_lk/models/friend_request_model.dart';
import 'package:unibridge_lk/models/user_model.dart';
import 'package:unibridge_lk/models/chat_message.dart';
import 'package:unibridge_lk/services/chat_cloud_service.dart';
import 'package:uuid/uuid.dart';
import 'package:unibridge_lk/views/chat_thread_view.dart';

class ChatsView extends StatefulWidget {
  const ChatsView({super.key});

  @override
  State<ChatsView> createState() => _ChatsViewState();
}

class _ChatsViewState extends State<ChatsView> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final _fs = FirestoreService();
  late final AuthController _auth;
  final _uuid = const Uuid();
  final Map<String, UserModel?> _userCache = {};

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _auth = Get.find<AuthController>();
    
    // Check if navigated with specific tab index
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final args = Get.arguments;
      if (args is int && args >= 0 && args < 3) {
        _tabController.animateTo(args);
      }
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  String _formatTime(DateTime? time) {
    if (time == null) return '';
    final now = DateTime.now();
    final diff = now.difference(time);
    if (diff.inMinutes < 1) return 'Just now';
    if (diff.inMinutes < 60) return '${diff.inMinutes}m ago';
    if (diff.inHours < 24) return '${diff.inHours}h ago';
    return '${time.day}/${time.month}/${time.year}';
  }

  Widget _buildChatsTab() {
    final selfId = _auth.user?.uid ?? '';
    return StreamBuilder<List<ChatModel>>(
      stream: ChatConversationsService.streamUserChats(selfId),
      builder: (context, snap) {
        if (snap.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        if (selfId.isEmpty) {
          return const Center(child: Text('Please sign in to view chats'));
        }
        final chats = snap.data ?? const [];
        if (chats.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: const [
                Icon(Icons.chat_bubble_outline, size: 64, color: Colors.grey),
                SizedBox(height: 16),
                Text('No conversations yet', style: TextStyle(color: Colors.grey)),
              ],
            ),
          );
        }

        return ListView.separated(
          padding: const EdgeInsets.all(12),
          itemCount: chats.length,
          separatorBuilder: (context, _) => const Divider(height: 1),
          itemBuilder: (_, i) {
            final c = chats[i];
            final otherId = c.getOtherParticipant(selfId);
            final unread = c.getUnreadCount(selfId);
            final timeText = _formatTime(c.lastMessageTime);
            return FutureBuilder<UserModel?>(
              future: _fs.getUser(otherId),
              initialData: _userCache[otherId],
              builder: (context, userSnap) {
                final user = userSnap.data;
                if (user != null) {
                  _userCache[otherId] = user; // Cache for instant reuse
                }
                final cachedName = _userCache[otherId]?.displayName;
                final userName = user?.displayName ?? cachedName ?? '';
                final displayName = userName.isNotEmpty ? userName : 'Loading...';
                final firstLetter = displayName.isNotEmpty ? displayName[0].toUpperCase() : '?';
                
                return ListTile(
                  onTap: () async {
                    await ChatConversationsService.markAsRead(c.id, selfId);
                    await ChatConversationsService.markMessagesAsSeen(c.id, selfId);
                    Get.to(() => ChatThreadView(chatId: c.id, selfId: selfId, otherId: otherId));
                  },
                  leading: CircleAvatar(
                    backgroundColor: Colors.blue.shade100,
                    child: Text(
                      firstLetter,
                      style: TextStyle(
                        color: Colors.blue.shade900,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  title: Row(
                    children: [
                      Expanded(
                        child: Text(
                          displayName,
                          style: const TextStyle(fontWeight: FontWeight.w600),
                        ),
                      ),
                      Text(
                        timeText,
                        style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                      ),
                    ],
                  ),
                  subtitle: Text(
                    c.lastMessage ?? '',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      color: unread > 0 ? Colors.black : Colors.grey[600],
                      fontWeight: unread > 0 ? FontWeight.w500 : FontWeight.normal,
                    ),
                  ),
                  trailing: unread > 0
                      ? Container(
                          width: 24,
                          height: 24,
                          decoration: const BoxDecoration(
                            color: Colors.red,
                            shape: BoxShape.circle,
                          ),
                          alignment: Alignment.center,
                          child: Text(
                            unread.toString(),
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 11,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        )
                      : null,
                );
              },
            );
          },
        );
      },
    );
  }

  Widget _buildRequestsTab() {
    final selfId = _auth.user?.uid ?? '';
    if (selfId.isEmpty) {
      return const Center(child: Text('Please sign in to view requests'));
    }
    return StreamBuilder<List<FriendRequestModel>>(
      stream: _fs.getFriendRequestsStream(selfId),
      builder: (context, snap) {
        if (snap.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        if (snap.hasError) {
          return Center(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Text(
                'Failed to load requests. Please try again.',
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.red[700]),
              ),
            ),
          );
        }
        final requests = snap.data ?? const [];
        if (requests.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: const [
                Icon(Icons.mark_email_unread_outlined, size: 64, color: Colors.grey),
                SizedBox(height: 16),
                Text('No requests', style: TextStyle(color: Colors.grey)),
              ],
            ),
          );
        }

        return ListView.separated(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          itemCount: requests.length,
          separatorBuilder: (_, __) => const SizedBox(height: 16),
          itemBuilder: (_, i) {
            final r = requests[i];
            final senderId = r.senderId;
            return FutureBuilder<UserModel?>(
              future: _fs.getUser(senderId),
              initialData: _userCache[senderId],
              builder: (context, userSnap) {
                final sender = userSnap.data;
                if (sender != null) {
                  _userCache[senderId] = sender;
                }
                final cachedName = _userCache[senderId]?.displayName;
                final senderName = sender?.displayName ?? cachedName ?? 'Loading...';
                return Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.grey.shade300),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Sender name
                      Text(
                        senderName,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.black87,
                        ),
                      ),
                      // Optional message/note
                      if ((r.message ?? '').isNotEmpty) ...[
                        const SizedBox(height: 8),
                        Text(
                          'Note: "${r.message}"',
                          style: TextStyle(
                            fontSize: 14,
                            fontStyle: FontStyle.italic,
                            color: Colors.grey[700],
                          ),
                        ),
                      ],
                      const SizedBox(height: 16),
                      // Action buttons
                      Row(
                        children: [
                          Expanded(
                            child: ElevatedButton.icon(
                              onPressed: () async {
                                try {
                                  // Show loading indicator
                                  Get.dialog(
                                    Center(child: CircularProgressIndicator()),
                                    barrierDismissible: false,
                                  );

                                  // Step 1: Accept request and create friendship
                                  await _fs.responseToFriendRequest(r.id, FriendRequestStatus.accepted);
                                  
                                  // Step 2: Create chat conversation
                                  final chatId = await ChatConversationsService.getOrCreateChat(senderId, selfId);
                                  
                                  // Step 3: Send system message with connection request details
                                  if ((r.message ?? '').isNotEmpty) {
                                    final systemMsg = ChatMessage(
                                      id: _uuid.v4(),
                                      chatId: chatId,
                                      senderId: 'system',
                                      receiverId: selfId,
                                      content: '$senderName sent you a connection request:\n\n"${r.message}"',
                                      status: ChatMessageStatus.sent,
                                      isSystemMessage: true,
                                    );
                                    await ChatCloudService.send(systemMsg);
                                  }

                                  // Close loading dialog
                                  Get.back();

                                  // Show success message
                                  Get.snackbar(
                                    'Connected', 
                                    'You are now connected with $senderName',
                                    snackPosition: SnackPosition.BOTTOM,
                                    backgroundColor: Colors.green,
                                    colorText: Colors.white,
                                    duration: Duration(seconds: 3),
                                  );

                                  // Switch to Chats tab
                                  _tabController.animateTo(0);
                                } catch (e) {
                                  // Close loading dialog if open
                                  if (Get.isDialogOpen ?? false) Get.back();
                                  
                                  // Show error
                                  Get.snackbar(
                                    'Error',
                                    'Failed to accept request: ${e.toString()}',
                                    snackPosition: SnackPosition.BOTTOM,
                                    backgroundColor: Colors.red,
                                    colorText: Colors.white,
                                    duration: Duration(seconds: 4),
                                  );
                                }
                              },
                              icon: const Icon(Icons.check, size: 20),
                              label: const Text('Accept'),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: const Color(0xFF00BFA5),
                                foregroundColor: Colors.white,
                                padding: const EdgeInsets.symmetric(vertical: 12),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(8),
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: OutlinedButton.icon(
                              onPressed: () async {
                                try {
                                  // Silent delete - no notification to sender
                                  await _fs.deleteFriendRequest(r.id);
                                  Get.snackbar(
                                    'Deleted', 
                                    'Request deleted',
                                    snackPosition: SnackPosition.BOTTOM,
                                    backgroundColor: Colors.grey[700],
                                    colorText: Colors.white,
                                  );
                                } catch (e) {
                                  Get.snackbar(
                                    'Error',
                                    'Failed to delete request',
                                    snackPosition: SnackPosition.BOTTOM,
                                    backgroundColor: Colors.red,
                                    colorText: Colors.white,
                                  );
                                }
                              },
                              icon: const Icon(Icons.close, size: 20),
                              label: const Text('Delete'),
                              style: OutlinedButton.styleFrom(
                                foregroundColor: Colors.red,
                                side: const BorderSide(color: Colors.red),
                                padding: const EdgeInsets.symmetric(vertical: 12),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(8),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                );
              },
            );
          },
        );
      },
    );
  }

  Widget _buildBlockedTab() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: const [
          Icon(Icons.block, size: 64, color: Colors.grey),
          SizedBox(height: 16),
          Text('Blocked users will appear here', style: TextStyle(color: Colors.grey)),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Chats'),
        backgroundColor: Colors.white,
        foregroundColor: AppTheme.primaryColor,
        elevation: 0,
        automaticallyImplyLeading: false,
        bottom: TabBar(
          controller: _tabController,
          labelColor: AppTheme.primaryColor,
          unselectedLabelColor: Colors.grey,
          indicatorColor: AppTheme.primaryColor,
          tabs: [
            const Tab(text: 'Chats'),
            Tab(
              child: StreamBuilder<List<FriendRequestModel>>(
                stream: _fs.getFriendRequestsStream(_auth.user?.uid ?? ''),
                builder: (context, snap) {
                  final count = snap.data?.length ?? 0;
                  return Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Text('Requests'),
                      if (count > 0) ...[
                        const SizedBox(width: 6),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                          decoration: BoxDecoration(
                            color: Colors.red,
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Text(
                            count.toString(),
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ],
                  );
                },
              ),
            ),
            const Tab(text: 'Blocked'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildChatsTab(),
          _buildRequestsTab(),
          _buildBlockedTab(),
        ],
      ),
    );
  }
}

