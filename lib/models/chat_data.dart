// Dummy chat data - will be replaced with Firestore later

class ChatData {
  final String id;
  final String otherUserId;
  final String otherUserName;
  final String otherUserAvatar;
  final String lastMessage;
  final DateTime lastMessageTime;
  int unreadCount; // Changed to non-final to allow updates
  final List<ChatMessage> messages;

  ChatData({
    required this.id,
    required this.otherUserId,
    required this.otherUserName,
    required this.otherUserAvatar,
    required this.lastMessage,
    required this.lastMessageTime,
    required this.unreadCount,
    required this.messages,
  });
}

class ChatMessage {
  final String id;
  final String senderId;
  final String text;
  final DateTime timestamp;

  ChatMessage({
    required this.id,
    required this.senderId,
    required this.text,
    required this.timestamp,
  });
}

class ChatRequest {
  final String id;
  final String senderId;
  final String senderName;
  final String senderAvatar;
  final String note;

  ChatRequest({
    required this.id,
    required this.senderId,
    required this.senderName,
    required this.senderAvatar,
    required this.note,
  });
}

class BlockedUser {
  final String id;
  final String name;

  BlockedUser({
    required this.id,
    required this.name,
  });
}

// Dummy data
final List<ChatData> dummyChats = [
  ChatData(
    id: 'chat1',
    otherUserId: 'p3',
    otherUserName: 'Zain M.',
    otherUserAvatar: 'Z',
    lastMessage: 'Project done!',
    lastMessageTime: DateTime.now().subtract(Duration(minutes: 38)),
    unreadCount: 2,
    messages: [
      ChatMessage(
        id: 'm1',
        senderId: 'current_user',
        text: 'Hey, how is the project going?',
        timestamp: DateTime.now().subtract(Duration(hours: 2)),
      ),
      ChatMessage(
        id: 'm2',
        senderId: 'p3',
        text: 'Almost done! Just finalizing some details.',
        timestamp: DateTime.now().subtract(Duration(hours: 1)),
      ),
      ChatMessage(
        id: 'm3',
        senderId: 'p3',
        text: 'Project done!',
        timestamp: DateTime.now().subtract(Duration(minutes: 38)),
      ),
    ],
  ),
  ChatData(
    id: 'chat2',
    otherUserId: 'p2',
    otherUserName: 'Dr. S. K. Silva',
    otherUserAvatar: 'D',
    lastMessage: 'Thank you for your guidance!',
    lastMessageTime: DateTime.now().subtract(Duration(hours: 5)),
    unreadCount: 0,
    messages: [
      ChatMessage(
        id: 'm4',
        senderId: 'current_user',
        text: 'Hello Professor, I have a question about the assignment.',
        timestamp: DateTime.now().subtract(Duration(days: 1)),
      ),
      ChatMessage(
        id: 'm5',
        senderId: 'p2',
        text: 'Sure, what would you like to know?',
        timestamp: DateTime.now().subtract(Duration(hours: 20)),
      ),
      ChatMessage(
        id: 'm6',
        senderId: 'current_user',
        text: 'Thank you for your guidance!',
        timestamp: DateTime.now().subtract(Duration(hours: 5)),
      ),
    ],
  ),
  ChatData(
    id: 'chat3',
    otherUserId: 'p4',
    otherUserName: 'Priya R.',
    otherUserAvatar: 'P',
    lastMessage: 'See you at the lab tomorrow',
    lastMessageTime: DateTime.now().subtract(Duration(days: 1)),
    unreadCount: 1,
    messages: [
      ChatMessage(
        id: 'm7',
        senderId: 'p4',
        text: 'Are you coming to the lab session tomorrow?',
        timestamp: DateTime.now().subtract(Duration(days: 1, hours: 3)),
      ),
      ChatMessage(
        id: 'm8',
        senderId: 'current_user',
        text: 'Yes, I will be there!',
        timestamp: DateTime.now().subtract(Duration(days: 1, hours: 2)),
      ),
      ChatMessage(
        id: 'm9',
        senderId: 'p4',
        text: 'See you at the lab tomorrow',
        timestamp: DateTime.now().subtract(Duration(days: 1)),
      ),
    ],
  ),
];

final List<ChatRequest> dummyChatRequests = [
  ChatRequest(
    id: 'req1',
    senderId: 'p5',
    senderName: 'Kasun P. (UoM)',
    senderAvatar: 'K',
    note: 'Hi, saw your CSE thread.',
  ),
  ChatRequest(
    id: 'req2',
    senderId: 'p6',
    senderName: 'Prof. Amara (UoC)',
    senderAvatar: 'A',
    note: 'Regarding your research query.',
  ),
];

final List<BlockedUser> dummyBlockedUsers = [
  BlockedUser(id: 'b1', name: 'Spammer A'),
  BlockedUser(id: 'b2', name: 'Bully B'),
];
