import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/chat_controller.dart';
import '../theme/app_theme.dart';

class ChatThreadView extends StatelessWidget {
  final String chatId;
  final String selfId;
  final String otherId;
  ChatThreadView({super.key, required this.chatId, required this.selfId, required this.otherId});

  final _msgCtrl = TextEditingController();
  final ChatController controller = Get.put(ChatController(), tag: UniqueKey().toString());

  @override
  Widget build(BuildContext context) {
    controller.init(chatId: chatId, selfId: selfId, otherId: otherId);
    return Scaffold(
      appBar: AppBar(
        title: const Text('Chat'),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 1,
      ),
      body: Column(
        children: [
          // Sync status indicator
          Obx(() {
            if (controller.syncStatus.value.isEmpty && controller.pendingCount.value == 0) {
              return const SizedBox.shrink();
            }
            return Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              color: controller.syncStatus.value.contains('✓') 
                  ? Colors.green[50] 
                  : Colors.amber[50],
              child: Row(
                children: [
                  if (controller.isSyncing.value)
                    SizedBox(
                      width: 16,
                      height: 16,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        valueColor: AlwaysStoppedAnimation<Color>(AppTheme.primaryColor),
                      ),
                    )
                  else if (controller.syncStatus.value.contains('failed'))
                    Icon(Icons.error_outline, size: 16, color: Colors.red[700])
                  else if (controller.syncStatus.value.contains('✓'))
                    Icon(Icons.check_circle_outline, size: 16, color: Colors.green[700])
                  else
                    Icon(Icons.schedule_outlined, size: 16, color: Colors.amber[700]),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      controller.syncStatus.value,
                      style: const TextStyle(fontSize: 12),
                    ),
                  ),
                  if (controller.syncStatus.value.contains('failed'))
                    GestureDetector(
                      onTap: controller.manualRetry,
                      child: Text(
                        'Retry',
                        style: TextStyle(
                          fontSize: 12,
                          color: AppTheme.primaryColor,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                ],
              ),
            );
          }),
          // Messages list
          Expanded(
            child: Obx(() {
              final messages = controller.messages;
              if (messages.isEmpty) {
                return const Center(
                  child: Text('No messages yet. Start the conversation!'),
                );
              }
              return ListView.builder(
                padding: const EdgeInsets.all(12),
                reverse: true,
                itemCount: messages.length,
                itemBuilder: (c, i) {
                  final m = messages[messages.length - 1 - i];
                  final isMe = m.senderId == controller.selfId;
                  
                  // System message - centered with different styling
                  if (m.isSystemMessage) {
                    return Container(
                      margin: const EdgeInsets.symmetric(vertical: 12, horizontal: 24),
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.blue[50],
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: Colors.blue[200]!, width: 1),
                      ),
                      child: Column(
                        children: [
                          Icon(Icons.info_outline, size: 20, color: Colors.blue[700]),
                          const SizedBox(height: 8),
                          Text(
                            m.content,
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontSize: 13,
                              color: Colors.blue[900],
                              fontStyle: FontStyle.italic,
                            ),
                          ),
                        ],
                      ),
                    );
                  }
                  
                  // Regular message
                  return Align(
                    alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                      margin: const EdgeInsets.symmetric(vertical: 4),
                      decoration: BoxDecoration(
                        color: isMe ? Colors.blue[50] : Colors.grey[200],
                        borderRadius: BorderRadius.only(
                          topLeft: const Radius.circular(12),
                          topRight: const Radius.circular(12),
                          bottomLeft: Radius.circular(isMe ? 12 : 0),
                          bottomRight: Radius.circular(isMe ? 0 : 12),
                        ),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Text(m.content),
                          const SizedBox(height: 4),
                          Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                m.status.name,
                                style: TextStyle(
                                  fontSize: 10,
                                  color: m.status.name == 'pending' 
                                      ? Colors.amber[700] 
                                      : Colors.grey[600],
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                              if (m.status.name == 'pending')
                                const SizedBox(width: 4)
                              else
                                const SizedBox.shrink(),
                              if (m.status.name == 'pending')
                                Icon(
                                  Icons.schedule,
                                  size: 10,
                                  color: Colors.amber[700],
                                ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  );
                },
              );
            }),
          ),
          const Divider(height: 1),
          // Message input
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _msgCtrl,
                    decoration: InputDecoration(
                      hintText: 'Type a message',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(24),
                        borderSide: BorderSide(color: Colors.grey[300]!),
                      ),
                      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                FloatingActionButton(
                  mini: true,
                  onPressed: () async {
                    final text = _msgCtrl.text;
                    _msgCtrl.clear();
                    await controller.sendText(text);
                  },
                  backgroundColor: AppTheme.primaryColor,
                  child: const Icon(Icons.send, color: Colors.white),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
