import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/chat_message.dart';

class ChatCloudService {
  static final _db = FirebaseFirestore.instance;

  static Future<void> send(ChatMessage msg) async {
    // Update message status to delivered before sending
    msg.status = ChatMessageStatus.delivered;
    
    // Write message with server timestamp and delivered status
    await _db
        .collection('chats')
        .doc(msg.chatId)
        .collection('messages')
        .doc(msg.id)
        .set(msg.toMap(forFirestore: true));

    // Update conversation metadata under chats/{chatId}
    final convoRef = _db.collection('chats').doc(msg.chatId);
    final now = DateTime.now().millisecondsSinceEpoch;
    await convoRef.set({
      'id': msg.chatId,
      'participants': [msg.senderId, msg.receiverId]..sort(),
      'lastMessage': msg.content,
      'lastMessageTime': now,
      'lastMessageSenderId': msg.senderId,
      'unreadCount': {msg.receiverId: FieldValue.increment(1)},
      'updatedAt': now,
    }, SetOptions(merge: true));
  }

  static Stream<List<ChatMessage>> streamChat(String chatId) {
    return _db
        .collection('chats')
        .doc(chatId)
        .collection('messages')
        .orderBy('timestamp', descending: false)
        .snapshots()
        .map((snap) => snap.docs.map((d) => ChatMessage.fromMap(d.data())).toList());
  }
}
