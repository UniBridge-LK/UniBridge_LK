import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/forum_models.dart';

class FirestoreForumService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  // Collections layout:
  // forums/{scope}-{scopeId}/threads/{threadId}
  // replies/{replyId} as subcollection under thread
  // reactions: counts and per-user state can be derived or stored in a map

  CollectionReference<Map<String, dynamic>> _threadsCol(ForumScope scope, String scopeId) {
    final scopeKey = _scopeKey(scope);
    return _db.collection('forums').doc('$scopeKey-$scopeId').collection('threads');
  }
  CollectionReference<Map<String, dynamic>> _repliesCol(ForumScope scope, String scopeId, String threadId) {
    return _threadsCol(scope, scopeId).doc(threadId).collection('replies');
  }

  CollectionReference<Map<String, dynamic>> _reactionsUsersCol(ForumScope scope, String scopeId, String threadId, String emoji) {
    return _threadsCol(scope, scopeId).doc(threadId).collection('reactions').doc(emoji).collection('users');
  }


  String _scopeKey(ForumScope s) {
    switch (s) {
      case ForumScope.global:
        return 'global';
      case ForumScope.university:
        return 'university';
      case ForumScope.faculty:
        return 'faculty';
      case ForumScope.department:
        return 'department';
    }
  }

  Stream<List<ThreadModel2>> threadsStream(ForumScope scope, String scopeId) {
    return _threadsCol(scope, scopeId)
        .orderBy('timestamp', descending: true)
        .snapshots()
        .map((snap) => snap.docs.map((d) => _threadFromDoc(d, scope, scopeId)).toList());
  }

  Future<void> createThread(ThreadModel2 t) async {
    final col = _threadsCol(t.scope, t.scopeId);
    final doc = col.doc();
    await doc.set({
      'ownerId': t.ownerId,
      'ownerName': t.ownerName,
      'title': t.title,
      'question': t.question,
      'timestamp': t.timestamp.millisecondsSinceEpoch,
      'replyCount': t.replyCount,
      'reactions': t.reactions.map((r) => {'emoji': r.emoji, 'count': r.count}).toList(),
    });
  }

  Future<void> editThread(ThreadModel2 t, {required String title, required String question}) async {
    final col = _threadsCol(t.scope, t.scopeId);
    final q = await col.where('title', isEqualTo: t.title).where('timestamp', isEqualTo: t.timestamp.millisecondsSinceEpoch).limit(1).get();
    if (q.docs.isEmpty) return;
    await q.docs.first.reference.update({'title': title, 'question': question});
  }

  Future<void> deleteThread(ThreadModel2 t) async {
    final col = _threadsCol(t.scope, t.scopeId);
    final q = await col.where('title', isEqualTo: t.title).where('timestamp', isEqualTo: t.timestamp.millisecondsSinceEpoch).limit(1).get();
    if (q.docs.isEmpty) return;
    await q.docs.first.reference.delete();
  }
  // Replies
  Stream<List<ReplyModel>> repliesStream(ForumScope scope, String scopeId, String threadId) {
    return _repliesCol(scope, scopeId, threadId)
        .orderBy('timestamp', descending: false)
        .snapshots()
        .map((snap) => snap.docs.map((d) => _replyFromDoc(d, threadId)).toList());
  }

  Future<void> addReply(ForumScope scope, String scopeId, String threadId, ReplyModel r) async {
    await _repliesCol(scope, scopeId, threadId).add({
      'authorId': r.authorId,
      'authorName': r.authorName,
      'timestamp': r.timestamp.millisecondsSinceEpoch,
      'content': r.content,
    });
    // bump replyCount
    await _threadsCol(scope, scopeId).doc(threadId).update({'replyCount': FieldValue.increment(1)}).catchError((_){});
  }

  ReplyModel _replyFromDoc(QueryDocumentSnapshot<Map<String, dynamic>> d, String threadId) {
    final data = d.data();
    return ReplyModel(
      id: d.id,
      threadId: threadId,
      authorId: (data['authorId'] ?? '') as String,
      authorName: (data['authorName'] ?? 'Unknown') as String,
      timestamp: DateTime.fromMillisecondsSinceEpoch((data['timestamp'] ?? 0) as int),
      content: (data['content'] ?? '') as String,
      reactions: const [],
      replies: const [],
    );
  }

  // Reactions: per-user store under reactions/{emoji}/users/{uid}
  Future<void> setReaction(ForumScope scope, String scopeId, String threadId, String emoji, String uid, bool add) async {
    final users = _reactionsUsersCol(scope, scopeId, threadId, emoji);
    final userDoc = users.doc(uid);
    if (add) {
      await userDoc.set({'at': DateTime.now().millisecondsSinceEpoch});
    } else {
      await userDoc.delete().catchError((_){});
    }
    // maintain aggregate count at reactions/{emoji}/count
    final reactionDoc = _threadsCol(scope, scopeId).doc(threadId).collection('reactions').doc(emoji);
    await reactionDoc.set({'count': FieldValue.increment(add ? 1 : -1)}, SetOptions(merge: true));
  }

  Stream<Map<String, int>> reactionsCountStream(ForumScope scope, String scopeId, String threadId) {
    return _threadsCol(scope, scopeId)
        .doc(threadId)
        .collection('reactions')
        .snapshots()
        .map((snap) {
      final counts = <String, int>{};
      for (final d in snap.docs) {
        counts[d.id] = (d['count'] ?? 0) as int;
      }
      return counts;
    });
  }

  Future<bool> hasUserReacted(ForumScope scope, String scopeId, String threadId, String emoji, String uid) async {
    final snap = await _reactionsUsersCol(scope, scopeId, threadId, emoji).doc(uid).get();
    return snap.exists;
  }

  ThreadModel2 _threadFromDoc(QueryDocumentSnapshot<Map<String, dynamic>> d, ForumScope scope, String scopeId) {
    final data = d.data();
    final reactions = (data['reactions'] as List? ?? [])
        .map((e) => Reaction(emoji: e['emoji'] as String, count: (e['count'] ?? 0) as int))
        .toList();
    return ThreadModel2(
      id: d.id,
      scope: scope,
      scopeId: scopeId,
      ownerId: (data['ownerId'] ?? '') as String,
      ownerName: (data['ownerName'] ?? 'Unknown') as String,
      title: (data['title'] ?? '') as String,
      question: (data['question'] ?? '') as String,
      timestamp: DateTime.fromMillisecondsSinceEpoch((data['timestamp'] ?? 0) as int),
      replyCount: (data['replyCount'] ?? 0) as int,
      reactions: reactions,
      replies: const [],
    );
  }
}
