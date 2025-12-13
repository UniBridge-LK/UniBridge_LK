import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:chat_with_aks/controllers/auth_controller.dart';
import 'package:chat_with_aks/services/firestore_service.dart';
import 'package:chat_with_aks/theme/app_theme.dart';
import 'package:chat_with_aks/models/chat_models.dart';

class ChatsView extends StatelessWidget {
  const ChatsView({super.key});

  @override
  Widget build(BuildContext context) {
    final auth = Get.find<AuthController>();
    final fs = FirestoreService();
    final currentUserId = auth.user?.uid ?? 'u1_mock';

    return Scaffold(
      appBar: AppBar(title: Text('Chats'), backgroundColor: Colors.white, foregroundColor: AppTheme.primaryColor, elevation: 0),
      body: StreamBuilder<List<ChatModel>>(
        stream: fs.getUserChatsStream(currentUserId),
        builder: (context, snap) {
          if (snap.connectionState == ConnectionState.waiting) return Center(child: CircularProgressIndicator(color: AppTheme.primaryColor));
          final chats = snap.data ?? [];
          if (chats.isEmpty) return Center(child: Text('No conversations yet'));

          return ListView.separated(
            padding: EdgeInsets.all(12),
            itemCount: chats.length,
            separatorBuilder: (context, index) => SizedBox(height:8),
            itemBuilder: (c,i){
              final chat = chats[i];
              final otherId = chat.getOtherParticipant(currentUserId);
              final unread = chat.getUnreadCount(currentUserId);
              final lastMsg = chat.lastMessage ?? '';
              final timeText = chat.lastMessageTime != null ? _formatTime(chat.lastMessageTime!) : '';

              return ListTile(
                onTap: () { /* navigate to chat screen - left as TODO */ },
                leading: CircleAvatar(backgroundColor: AppTheme.primaryColor.withAlpha(31), child: Text(otherId.isNotEmpty ? otherId[0] : '?', style: TextStyle(color: AppTheme.primaryColor))),
                title: Row(
                  children: [
                    Expanded(child: Text(otherId.isNotEmpty ? otherId : 'Conversation', style: TextStyle(fontWeight: FontWeight.w600))),
                    Text(timeText, style: TextStyle(fontSize:12, color: Colors.grey[600])),
                  ],
                ),
                subtitle: Text(lastMsg, maxLines:1, overflow: TextOverflow.ellipsis, style: TextStyle(fontWeight: unread>0 ? FontWeight.w700 : FontWeight.normal)),
                trailing: unread > 0 ? Container(
                  width:32, height:32,
                  decoration: BoxDecoration(color: Colors.red, shape: BoxShape.circle),
                  alignment: Alignment.center,
                  child: Text(unread.toString(), style: TextStyle(color: Colors.white, fontSize:12, fontWeight: FontWeight.w700)),
                ) : null,
              );
            }
          );
        }
      ),
    );
  }

  String _formatTime(DateTime t){
    final now = DateTime.now();
    final diff = now.difference(t);
    if (diff.inDays >= 1) return '${t.day}/${t.month}/${t.year}';
    if (diff.inHours >= 1) return '${diff.inHours}h';
    if (diff.inMinutes >= 1) return '${diff.inMinutes}m';
    return 'now';
  }
}

