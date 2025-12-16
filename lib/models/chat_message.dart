import 'package:cloud_firestore/cloud_firestore.dart';

enum ChatMessageStatus { pending, sent, delivered, seen }

class ChatMessage {
  final String id;
  final String chatId;
  final String senderId;
  final String receiverId;
  final String content;
  final Timestamp? timestamp; // Nullable to support server timestamp placeholder
  ChatMessageStatus status;
  final bool isSystemMessage; // Flag for system-generated messages

  ChatMessage({
    required this.id,
    required this.chatId,
    required this.senderId,
    required this.receiverId,
    required this.content,
    this.timestamp, // Optional: null until server assigns timestamp
    required this.status,
    this.isSystemMessage = false,
  });

  Map<String, dynamic> toMap({bool forFirestore = false}) {
    return {
      'id': id,
      'chatId': chatId,
      'senderId': senderId,
      'receiverId': receiverId,
      'content': content,
      'timestamp': forFirestore 
          ? FieldValue.serverTimestamp() // Use server timestamp for Firestore
          : (timestamp?.millisecondsSinceEpoch ?? Timestamp.now().millisecondsSinceEpoch),
      'status': status.name,
      'isSystemMessage': isSystemMessage,
    };
  }

  factory ChatMessage.fromMap(Map<String, dynamic> m) {
    // Handle both Timestamp and int (for Hive storage)
    Timestamp ts;
    if (m['timestamp'] is Timestamp) {
      ts = m['timestamp'] as Timestamp;
    } else if (m['timestamp'] is int) {
      ts = Timestamp.fromMillisecondsSinceEpoch(m['timestamp'] as int);
    } else {
      ts = Timestamp.now();
    }

    return ChatMessage(
      id: m['id'] ?? '',
      chatId: m['chatId'] ?? '',
      senderId: m['senderId'] ?? '',
      receiverId: m['receiverId'] ?? '',
      content: m['content'] ?? '',
      timestamp: ts,
      status: ChatMessageStatus.values.firstWhere(
        (e) => e.name == (m['status'] ?? 'sent'),
        orElse: () => ChatMessageStatus.sent,
      ),
      isSystemMessage: m['isSystemMessage'] ?? false,
    );
  }
}
