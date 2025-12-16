import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:chat_with_aks/theme/app_theme.dart';
import 'package:chat_with_aks/models/chat_models.dart';
import 'package:chat_with_aks/services/chat_conversations_service.dart';
import 'package:chat_with_aks/views/chat_thread_view.dart';

class ChatsView extends StatefulWidget {
  const ChatsView({super.key});

  @override
  State<ChatsView> createState() => _ChatsViewState();
}

class _ChatsViewState extends State<ChatsView> with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
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
    // TODO: Replace with real authenticated user id
    const selfId = 'user_1';
    return StreamBuilder<List<ChatModel>>(
      stream: ChatConversationsService.streamUserChats(selfId),
      builder: (context, snap) {
        if (snap.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
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
            return ListTile(
              onTap: () async {
                await ChatConversationsService.markAsRead(c.id, selfId);
                await ChatConversationsService.markMessagesAsSeen(c.id, selfId);
                Get.to(() => ChatThreadView(chatId: c.id, selfId: selfId, otherId: otherId));
              },
              leading: CircleAvatar(
                backgroundColor: Colors.blue.shade100,
                child: Text(
                  otherId.isNotEmpty ? otherId[0].toUpperCase() : '?',
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
                      otherId.isEmpty ? 'Unknown user' : otherId,
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
  }

  Widget _buildRequestsTab() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: const [
          Icon(Icons.mark_email_unread_outlined, size: 64, color: Colors.grey),
          SizedBox(height: 16),
          Text('Requests will appear here', style: TextStyle(color: Colors.grey)),
        ],
      ),
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
          tabs: const [
            Tab(text: 'Chats'),
            Tab(text: 'Requests'),
            Tab(text: 'Blocked'),
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

