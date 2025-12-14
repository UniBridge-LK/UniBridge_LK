class ThreadModel {
  final String id;
  final String title;
  final String author;
  final DateTime timestamp;
  final String content;
  final String userId;
  final String uni;
  final String course;
  final int replyCount;
  final List<String> likes;
  final String category; // 'global' or 'general'
  final DateTime lastActivity;

  ThreadModel({
    required this.id,
    required this.title,
    required this.author,
    required this.timestamp,
    required this.content,
    required this.userId,
    required this.uni,
    required this.course,
    this.replyCount = 0,
    this.likes = const [],
    this.category = 'general',
    DateTime? lastActivity,
  }) : lastActivity = lastActivity ?? timestamp;

  factory ThreadModel.fromMap(Map<String, dynamic> m) {
    DateTime parseTime(dynamic v) {
      if (v == null) return DateTime.now();
      if (v is int) return DateTime.fromMillisecondsSinceEpoch(v);
      if (v is String) return DateTime.tryParse(v) ?? DateTime.now();
      if (v is DateTime) return v;
      return DateTime.now();
    }

    return ThreadModel(
      id: m['id']?.toString() ?? '',
      title: m['title'] ?? '',
      author: m['author'] ?? m['userName'] ?? '',
      timestamp: parseTime(m['timestamp'] ?? m['time'] ?? m['lastActivity']),
      content: m['content'] ?? '',
      userId: m['userId'] ?? m['ownerId'] ?? '',
      uni: m['uni'] ?? '',
      course: m['course'] ?? '',
      replyCount: m['replyCount'] ?? m['replies'] ?? 0,
      likes: (m['likes'] is List) ? List<String>.from(m['likes']) : [],
      category: m['category'] ?? 'general',
      lastActivity: parseTime(m['lastActivity'] ?? m['timestamp'] ?? m['time']),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'author': author,
      'content': content,
      'userId': userId,
      'userName': author,
      'uni': uni,
      'course': course,
      'replyCount': replyCount,
      'likes': likes,
      'category': category,
      'timestamp': timestamp.millisecondsSinceEpoch,
      'lastActivity': lastActivity.millisecondsSinceEpoch,
    };
  }
}
