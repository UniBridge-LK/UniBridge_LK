import 'package:get/get.dart';
import 'package:uuid/uuid.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/chat_message.dart';
import '../services/chat_sync_service.dart';
import '../services/chat_hive_service.dart';

class ChatController extends GetxController {
  final RxList<ChatMessage> messages = <ChatMessage>[].obs;
  final RxInt pendingCount = 0.obs;
  final RxBool isSyncing = false.obs;
  final RxString syncStatus = ''.obs;
  late String chatId;
  late String selfId;
  late String otherId;

  void init({required String chatId, required String selfId, required String otherId}) {
    this.chatId = chatId;
    this.selfId = selfId;
    this.otherId = otherId;
    // ChatSyncService already started in main.dart
    ChatSyncService.mergedStream(chatId).listen((list) {
      messages.assignAll(list);
    });
    _updatePendingCount();
  }

  Future<void> _updatePendingCount() async {
    final pending = ChatHiveService.getPendingQueue();
    pendingCount.value = pending.length;
  }

  Future<void> sendText(String text) async {
    if (text.trim().isEmpty) return;
    final msg = ChatMessage(
      id: const Uuid().v4(),
      chatId: chatId,
      senderId: selfId,
      receiverId: otherId,
      content: text.trim(),
      timestamp: Timestamp.now(),
      status: ChatMessageStatus.pending,
    );
    await ChatSyncService.sendOrQueue(msg);
    await _updatePendingCount();
    
    // If offline, show indicator
    if (pendingCount.value > 0) {
      syncStatus.value = 'Offline - ${pendingCount.value} pending';
      Future.delayed(const Duration(seconds: 3), () {
        if (syncStatus.value.startsWith('Offline')) {
          syncStatus.value = '';
        }
      });
    }
  }

  Future<void> manualRetry() async {
    isSyncing.value = true;
    syncStatus.value = 'Syncing...';
    try {
      // Force drain the queue
      final pending = ChatHiveService.getPendingQueue();
      for (final msg in pending) {
        await ChatSyncService.sendOrQueue(msg);
      }
      await _updatePendingCount();
      if (pendingCount.value == 0) {
        syncStatus.value = 'All messages synced ✓';
        Future.delayed(const Duration(seconds: 2), () {
          syncStatus.value = '';
        });
      }
    } catch (_) {
      syncStatus.value = 'Sync failed - will retry';
    } finally {
      isSyncing.value = false;
    }
  }

  Future<void> deleteMessage(ChatMessage msg) async {
    try {
      final now = DateTime.now().millisecondsSinceEpoch;
      final updated = ChatMessage(
        id: msg.id,
        chatId: msg.chatId,
        senderId: msg.senderId,
        receiverId: msg.receiverId,
        content: '',
        timestamp: msg.timestamp,
        status: msg.status,
        isSystemMessage: msg.isSystemMessage,
        isEdited: msg.isEdited,
        isDeleted: true,
        editedAt: msg.editedAt,
        deletedAt: now,
      );

      await FirebaseFirestore.instance
          .collection('chats')
          .doc(chatId)
          .collection('messages')
          .doc(msg.id)
          .set({
            'content': '',
            'isDeleted': true,
            'deletedAt': now,
          }, SetOptions(merge: true));

      await ChatHiveService.upsertMessage(updated);
      final idx = messages.indexWhere((m) => m.id == msg.id);
      if (idx >= 0) {
        messages[idx] = updated;
      }

      if (messages.isNotEmpty && messages.last.id == msg.id) {
        await FirebaseFirestore.instance.collection('chats').doc(chatId).set({
          'lastMessage': 'Message deleted',
          'lastMessageTime': now,
          'lastMessageSenderId': msg.senderId,
          'updatedAt': now,
        }, SetOptions(merge: true));
      }
    } catch (_) {
      rethrow;
    }
  }

  Future<void> editMessage(ChatMessage msg, String newContent) async {
    final trimmed = newContent.trim();
    if (trimmed.isEmpty) return;
    final updated = ChatMessage(
      id: msg.id,
      chatId: msg.chatId,
      senderId: msg.senderId,
      receiverId: msg.receiverId,
      content: trimmed,
      timestamp: msg.timestamp,
      status: msg.status,
      isSystemMessage: msg.isSystemMessage,
      isEdited: true,
      editedAt: Timestamp.now().millisecondsSinceEpoch,
    );
    try {
      await FirebaseFirestore.instance
          .collection('chats')
          .doc(chatId)
          .collection('messages')
          .doc(msg.id)
          .update({'content': trimmed, 'editedAt': updated.editedAt, 'isEdited': true});
      await ChatHiveService.upsertMessage(updated);
      final idx = messages.indexWhere((m) => m.id == msg.id);
      if (idx >= 0) {
        messages[idx] = updated;
      }
      // If this is the latest message, update conversation summary for chats list
      if (messages.isNotEmpty && messages.last.id == msg.id) {
        final now = DateTime.now().millisecondsSinceEpoch;
        await FirebaseFirestore.instance.collection('chats').doc(chatId).set({
          'lastMessage': trimmed,
          'lastMessageTime': now,
          'lastMessageSenderId': msg.senderId,
          'updatedAt': now,
        }, SetOptions(merge: true));
      }
    } catch (_) {
      rethrow;
    }
  }
}
