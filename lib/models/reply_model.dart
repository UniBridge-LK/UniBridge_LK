class ReplyModel {
  final String id;
  final String threadId;
  final String userId;
  final String author;
  final String content;
  final DateTime timestamp;
  final List<String> likes;

  ReplyModel({
    required this.id,
    required this.threadId,
    required this.userId,
    required this.author,
    required this.content,
    required this.timestamp,
    this.likes = const [],
  });

  factory ReplyModel.fromMap(Map<String, dynamic> map) {
    DateTime parseTime(dynamic v) {
      if (v == null) return DateTime.now();
      if (v is int) return DateTime.fromMillisecondsSinceEpoch(v);
      if (v is String) return DateTime.tryParse(v) ?? DateTime.now();
      if (v is DateTime) return v;
      return DateTime.now();
    }

    return ReplyModel(
      id: map['id']?.toString() ?? '',
      threadId: map['threadId']?.toString() ?? '',
      userId: map['userId']?.toString() ?? '',
      author: map['author'] ?? map['userName'] ?? 'Anonymous',
      content: map['content'] ?? '',
      timestamp: parseTime(map['timestamp'] ?? map['createdAt']),
      likes: (map['likes'] is List) ? List<String>.from(map['likes']) : [],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'threadId': threadId,
      'userId': userId,
      'author': author,
      'userName': author,
      'content': content,
      'timestamp': timestamp.millisecondsSinceEpoch,
      'likes': likes,
    };
  }
}
