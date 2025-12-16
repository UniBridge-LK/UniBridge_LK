import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/chat_models.dart';

class ChatConversationsService {
  static final _db = FirebaseFirestore.instance;

  static String chatIdFor(String a, String b) {
    final list = [a, b]..sort();
    return '${list.first}-${list.last}';
  }

  static Future<String> getOrCreateChat(String a, String b) async {
    final chatId = chatIdFor(a, b);
    final ref = _db.collection('chats').doc(chatId);
    final snap = await ref.get();
    if (!snap.exists) {
      final now = DateTime.now().millisecondsSinceEpoch;
      await ref.set({
        'id': chatId,
        'participants': [a, b]..sort(),
        'unreadCount': {a: 0, b: 0},
        'deletedBy': {},
        'deletedAt': {},
        'lastSeenBy': {},
        'createdAt': now,
        'updatedAt': now,
      }, SetOptions(merge: true));
    }
    return chatId;
  }

  static Stream<List<ChatModel>> streamUserChats(String userId) {
    return _db
        .collection('chats')
        .where('participants', arrayContains: userId)
        .orderBy('lastMessageTime', descending: true)
        .snapshots()
        .map((snap) => snap.docs.map((d) {
              final data = d.data();
              data['id'] = d.id;
              return ChatModel.fromMap(data);
            }).toList());
  }

  static Future<void> markAsRead(String chatId, String userId) async {
    final now = DateTime.now().millisecondsSinceEpoch;
    await _db.collection('chats').doc(chatId).set({
      'unreadCount': {userId: 0},
      'lastSeenBy': {userId: now},
      'updatedAt': now,
    }, SetOptions(merge: true));
  }
}
