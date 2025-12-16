enum ForumScope { global, university, faculty, department }

class Reaction {
  final String emoji; // e.g., '👍', '❤️', '💡'
  final int count;
  final bool reactedByMe;
  Reaction({required this.emoji, required this.count, this.reactedByMe = false});
}

class ReplyModel {
  final String id;
  final String threadId;
  final String authorId;
  final String authorName;
  final DateTime timestamp;
  final String content;
  final List<Reaction> reactions;
  final List<ReplyModel> replies; // nested replies (discord-like)

  ReplyModel({
    required this.id,
    required this.threadId,
    required this.authorId,
    required this.authorName,
    required this.timestamp,
    required this.content,
    this.reactions = const [],
    this.replies = const [],
  });
}

class ThreadModel2 {
  final String id;
  final ForumScope scope;
  final String scopeId; // universityId/facultyId/departmentId or 'global'
  final String ownerId;
  final String ownerName;
  final String title;
  final String question;
  final DateTime timestamp;
  final int replyCount;
  final List<Reaction> reactions;
  final List<ReplyModel> replies; // top-level replies

  ThreadModel2({
    required this.id,
    required this.scope,
    required this.scopeId,
    required this.ownerId,
    required this.ownerName,
    required this.title,
    required this.question,
    required this.timestamp,
    required this.replyCount,
    this.reactions = const [],
    this.replies = const [],
  });
}

