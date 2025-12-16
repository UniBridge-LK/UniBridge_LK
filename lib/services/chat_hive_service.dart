import 'package:hive_flutter/hive_flutter.dart';
import '../models/chat_message.dart';

class ChatHiveService {
  static const _boxName = 'chat_messages';

  static Future<void> init() async {
    await Hive.initFlutter();
    await Hive.openBox(_boxName);
  }

  static Box get _box => Hive.box(_boxName);

  static List<ChatMessage> getMessages(String chatId) {
    final list = (_box.get(chatId) as List?)?.cast<Map>() ?? [];
    return list.map((m) => ChatMessage.fromMap(Map<String, dynamic>.from(m))).toList();
  }

  static Future<void> upsertMessage(ChatMessage msg) async {
    final current = getMessages(msg.chatId);
    final idx = current.indexWhere((m) => m.id == msg.id);
    if (idx >= 0) {
      current[idx] = msg;
    } else {
      current.add(msg);
    }
    await _box.put(msg.chatId, current.map((m) => m.toMap()).toList());
  }

  static List<ChatMessage> getPendingQueue() {
    final list = (_box.get('_pending') as List?)?.cast<Map>() ?? [];
    return list.map((m) => ChatMessage.fromMap(Map<String, dynamic>.from(m))).toList();
  }

  static Future<void> enqueuePending(ChatMessage msg) async {
    final q = getPendingQueue();
    q.add(msg);
    await _box.put('_pending', q.map((m) => m.toMap()).toList());
  }

  static Future<void> removeFromPending(String id) async {
    final q = getPendingQueue();
    q.removeWhere((m) => m.id == id);
    await _box.put('_pending', q.map((m) => m.toMap()).toList());
  }
}
