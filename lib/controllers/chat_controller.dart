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
}
