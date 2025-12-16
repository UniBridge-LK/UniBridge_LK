import 'package:connectivity_plus/connectivity_plus.dart';
import '../models/chat_message.dart';
import 'chat_cloud_service.dart';
import 'chat_hive_service.dart';

class ChatSyncService {
  static final _conn = Connectivity();
  static bool _isStarted = false;

  static Future<void> start() async {
    if (_isStarted) return;
    _isStarted = true;
    
    _conn.onConnectivityChanged.listen((result) async {
      if (result != ConnectivityResult.none) {
        await _drainQueue();
      }
    });
  }

  static Future<void> _drainQueue() async {
    final pending = ChatHiveService.getPendingQueue();
    for (final msg in pending) {
      try {
        await ChatCloudService.send(msg);
        msg.status = ChatMessageStatus.delivered;
        await ChatHiveService.upsertMessage(msg);
        await ChatHiveService.removeFromPending(msg.id);
      } catch (_) {
        // keep in queue
      }
    }
  }

  static Future<void> sendOrQueue(ChatMessage msg) async {
    final connectivity = await _conn.checkConnectivity();
    await ChatHiveService.upsertMessage(msg);
    if (connectivity == ConnectivityResult.none) {
      await ChatHiveService.enqueuePending(msg);
    } else {
      try {
        await ChatCloudService.send(msg);
        // Update local cache with delivered status after successful send
        msg.status = ChatMessageStatus.delivered;
        await ChatHiveService.upsertMessage(msg);
      } catch (_) {
        await ChatHiveService.enqueuePending(msg);
      }
    }
  }

  static Stream<List<ChatMessage>> mergedStream(String chatId) async* {
    final local = ChatHiveService.getMessages(chatId);
    yield local;
    yield* ChatCloudService.streamChat(chatId);
  }
}
