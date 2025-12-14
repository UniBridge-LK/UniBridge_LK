import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:chat_with_aks/theme/app_theme.dart';
import 'package:chat_with_aks/models/chat_data.dart';
import 'package:chat_with_aks/views/chat_screen_view.dart';

class ChatsView extends StatefulWidget {
  const ChatsView({super.key});

  @override
  State<ChatsView> createState() => _ChatsViewState();
}

class _ChatsViewState extends State<ChatsView> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final List<ChatData> _chats = List.from(dummyChats);
  final List<ChatRequest> _requests = List.from(dummyChatRequests);
  final List<BlockedUser> _blockedUsers = List.from(dummyBlockedUsers);
  final Set<String> _blockedUserIds = {};

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _blockedUserIds.addAll(_blockedUsers.map((b) => b.id));
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Chats'),
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
            Tab(text: 'Chats'),
            Tab(
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text('Requests'),
                  if (_requests.isNotEmpty) ...[
                    SizedBox(width: 6),
                    Container(
                      padding: EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(
                        color: Colors.red,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Text(
                        _requests.length.toString(),
                        style: TextStyle(color: Colors.white, fontSize: 11),
                      ),
                    ),
                  ],
                ],
              ),
            ),
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

  Widget _buildChatsTab() {
    // Filter out blocked users
    final visibleChats = _chats.where((chat) => !_blockedUserIds.contains(chat.otherUserId)).toList();
    
    if (visibleChats.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.chat_bubble_outline, size: 64, color: Colors.grey),
            SizedBox(height: 16),
            Text('No conversations yet', style: TextStyle(color: Colors.grey)),
          ],
        ),
      );
    }

    return ListView.separated(
      padding: EdgeInsets.all(12),
      itemCount: visibleChats.length,
      separatorBuilder: (context, index) => Divider(height: 1),
      itemBuilder: (c, i) {
        final chat = visibleChats[i];
        final timeText = _formatTime(chat.lastMessageTime);

        return ListTile(
          onTap: () {
            setState(() {
              chat.unreadCount = 0;
            });
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => ChatScreenView(chatData: chat),
              ),
            );
          },
          leading: CircleAvatar(
            backgroundColor: Colors.blue.shade100,
            child: Text(
              chat.otherUserAvatar,
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
                  chat.otherUserName,
                  style: TextStyle(fontWeight: FontWeight.w600),
                ),
              ),
              Text(
                timeText,
                style: TextStyle(fontSize: 12, color: Colors.grey[600]),
              ),
            ],
          ),
          subtitle: Text(
            chat.lastMessage,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              color: chat.unreadCount > 0 ? Colors.black : Colors.grey[600],
              fontWeight: chat.unreadCount > 0 ? FontWeight.w500 : FontWeight.normal,
            ),
          ),
          trailing: chat.unreadCount > 0
              ? Container(
                  width: 24,
                  height: 24,
                  decoration: BoxDecoration(
                    color: Colors.red,
                    shape: BoxShape.circle,
                  ),
                  alignment: Alignment.center,
                  child: Text(
                    chat.unreadCount.toString(),
                    style: TextStyle(
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
  }

  Widget _buildRequestsTab() {
    if (_requests.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.inbox, size: 64, color: Colors.grey),
            SizedBox(height: 16),
            Text('No pending requests', style: TextStyle(color: Colors.grey)),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: EdgeInsets.all(16),
      itemCount: _requests.length,
      itemBuilder: (c, i) {
        final req = _requests[i];
        return Card(
          margin: EdgeInsets.only(bottom: 12),
          child: Padding(
            padding: EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    CircleAvatar(
                      backgroundColor: Colors.blue.shade100,
                      child: Text(
                        req.senderAvatar,
                        style: TextStyle(
                          color: Colors.blue.shade900,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        req.senderName,
                        style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 12),
                Text(
                  'Note: "${req.note}"',
                  style: TextStyle(fontStyle: FontStyle.italic, color: Colors.grey[700]),
                ),
                SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: () {
                          setState(() {
                            // Create a new chat from the request
                            final newChat = ChatData(
                              id: 'chat_${req.senderId}',
                              otherUserId: req.senderId,
                              otherUserName: req.senderName,
                              otherUserAvatar: req.senderAvatar,
                              lastMessage: 'Request accepted',
                              lastMessageTime: DateTime.now(),
                              unreadCount: 0,
                              messages: [
                                ChatMessage(
                                  id: 'm_initial',
                                  senderId: req.senderId,
                                  text: req.note,
                                  timestamp: DateTime.now().subtract(Duration(minutes: 10)),
                                ),
                              ],
                            );
                            _chats.add(newChat);
                            _requests.removeAt(i);
                          });
                          Get.snackbar(
                            'Accepted',
                            'Chat request from ${req.senderName} accepted',
                            snackPosition: SnackPosition.BOTTOM,
                          );
                        },
                        icon: Icon(Icons.check, size: 18),
                        label: Text('Accept'),
                        style: ElevatedButton.styleFrom(backgroundColor: Colors.teal),
                      ),
                    ),
                    SizedBox(width: 12),
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: () {
                          setState(() {
                            _requests.removeAt(i);
                          });
                          Get.snackbar(
                            'Deleted',
                            'Request from ${req.senderName} deleted',
                            snackPosition: SnackPosition.BOTTOM,
                          );
                        },
                        icon: Icon(Icons.close, size: 18),
                        label: Text('Delete'),
                        style: OutlinedButton.styleFrom(foregroundColor: Colors.red),
                      ),
                    ),
                  ],
                )
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildBlockedTab() {
    if (_blockedUsers.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.block, size: 64, color: Colors.grey),
            SizedBox(height: 16),
            Text('No blocked users', style: TextStyle(color: Colors.grey)),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: EdgeInsets.all(16),
      itemCount: _blockedUsers.length,
      itemBuilder: (c, i) {
        final blockedUser = _blockedUsers[i];
        return Card(
          margin: EdgeInsets.only(bottom: 12),
          child: ListTile(
            leading: CircleAvatar(
              backgroundColor: Colors.red.shade100,
              child: Icon(Icons.block, color: Colors.red),
            ),
            title: Text(
              blockedUser.name,
              style: TextStyle(color: Colors.red, fontWeight: FontWeight.w600),
            ),
            subtitle: Text('Messages are blocked'),
            trailing: OutlinedButton.icon(
              onPressed: () {
                setState(() {
                  _blockedUserIds.remove(blockedUser.id);
                  _blockedUsers.removeAt(i);
                });
                Get.snackbar(
                  'Unblocked',
                  '${blockedUser.name} has been unblocked',
                  snackPosition: SnackPosition.BOTTOM,
                );
              },
              icon: Icon(Icons.check_circle_outline, size: 16),
              label: Text('Unblock'),
            ),
          ),
        );
      },
    );
  }

  String _formatTime(DateTime t) {
    final now = DateTime.now();
    final diff = now.difference(t);
    if (diff.inMinutes < 60) return '${diff.inMinutes}m ago';
    if (diff.inHours < 24) return '${diff.inHours}h ago';
    if (diff.inDays == 1) return 'Yesterday';
    return '${t.day}/${t.month}/${t.year}';
  }
}

