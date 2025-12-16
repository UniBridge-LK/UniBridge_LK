import 'package:get/get.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/forum_models.dart';
import '../services/firestore_forum_service.dart';
import '../data/sample_forum_data.dart';

class ForumController extends GetxController {
  final Rx<ForumScope> scope = ForumScope.global.obs;
  final RxString scopeId = 'global'.obs;
  final RxList<ThreadModel2> threads = <ThreadModel2>[].obs;
  final FirestoreForumService _fs = FirestoreForumService();
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // Auto-seeding disabled - all sample data is kept in lib/data/sample_forum_data.dart
  // To seed to Firestore later, import ForumSeedingService and call: 
  // await ForumSeedingService.seedAllForums()

  // Mock load
  void loadThreads({required ForumScope s, required String id}) {
    scope.value = s;
    scopeId.value = id;
    // If Firestore is available, bind to stream; otherwise fallback to mock
    try {
      threads.bindStream(_fs.threadsStream(s, id));
    } catch (e) {
      threads.assignAll(_mockThreads(s, id));
    }
  }

  List<ThreadModel2> _mockThreads(ForumScope s, String id) {
    // Select sample data based on scope
    final sampleData = _getSampleDataForScope(s);
    
    // Convert sample data maps to ThreadModel2
    return sampleData.asMap().entries.map((entry) {
      final threadData = entry.value;
      final index = entry.key;
      
      return ThreadModel2(
        id: 'thread_${s.toString().split('.').last}_$index',
        scope: s,
        scopeId: id,
        ownerId: threadData['authorId'] as String,
        ownerName: threadData['authorName'] as String,
        title: threadData['title'] as String,
        question: threadData['question'] as String,
        timestamp: DateTime.parse(threadData['timestamp'] as String),
        replyCount: (threadData['replies'] as List).length,
        reactions: [Reaction(emoji: '👍', count: 0)],
        replies: _buildReplies(threadData['replies'] as List, 'thread_${s.toString().split('.').last}_$index'),
      );
    }).toList();
  }

  List<Map<String, dynamic>> _getSampleDataForScope(ForumScope scope) {
    switch (scope) {
      case ForumScope.global:
        return SampleForumData.globalThreads;
      case ForumScope.university:
        return SampleForumData.universityThreads;
      case ForumScope.faculty:
        return SampleForumData.facultyThreads;
      case ForumScope.department:
        return SampleForumData.departmentThreads;
    }
  }

  List<ReplyModel> _buildReplies(List<dynamic> repliesData, String threadId) {
    return repliesData.asMap().entries.map((entry) {
      final replyData = entry.value as Map<String, dynamic>;
      final index = entry.key;
      
      return ReplyModel(
        id: 'reply_${threadId}_$index',
        threadId: threadId,
        authorId: replyData['authorId'] as String,
        authorName: replyData['authorName'] as String,
        timestamp: DateTime.parse(replyData['timestamp'] as String),
        content: replyData['content'] as String,
        reactions: [Reaction(emoji: '👍', count: 0)],
        replies: _buildReplies(replyData['replies'] as List? ?? [], threadId),
      );
    }).toList();
  }

  void toggleReaction(ThreadModel2 thread, String emoji) {
    final idx = threads.indexWhere((t) => t.id == thread.id);
    if (idx == -1) return;
    final uid = _auth.currentUser?.uid ?? 'anonymous';
    final existing = thread.reactions.firstWhereOrNull((r) => r.emoji == emoji);
    final add = !(existing?.reactedByMe ?? false);
    // local UI update for immediate feedback
    List<Reaction> updatedReactions = List.from(thread.reactions);
    if (existing == null) {
      updatedReactions.add(Reaction(emoji: emoji, count: 1, reactedByMe: true));
    } else {
      updatedReactions = updatedReactions.map((r) {
        if (r.emoji != emoji) return r;
        if (r.reactedByMe) {
          final newCount = (r.count - 1).clamp(0, 1 << 31);
          return Reaction(emoji: r.emoji, count: newCount, reactedByMe: false);
        } else {
          return Reaction(emoji: r.emoji, count: r.count + 1, reactedByMe: true);
        }
      }).toList();
    }
    threads[idx] = ThreadModel2(
      id: thread.id,
      scope: thread.scope,
      scopeId: thread.scopeId,
      ownerId: thread.ownerId,
      ownerName: thread.ownerName,
      title: thread.title,
      question: thread.question,
      timestamp: thread.timestamp,
      replyCount: thread.replyCount,
      reactions: updatedReactions,
      replies: thread.replies,
    );
    // persist reaction
    _fs.setReaction(thread.scope, thread.scopeId, thread.id, emoji, uid, add).catchError((_){});
  }

  void addReply(String threadId, ReplyModel reply) {
    final idx = threads.indexWhere((t) => t.id == threadId);
    if (idx == -1) return;
    final t = threads[idx];
    final updatedReplies = List<ReplyModel>.from(t.replies)..add(reply);
    threads[idx] = ThreadModel2(
      id: t.id,
      scope: t.scope,
      scopeId: t.scopeId,
      ownerId: t.ownerId,
      ownerName: t.ownerName,
      title: t.title,
      question: t.question,
      timestamp: t.timestamp,
      replyCount: t.replyCount + 1,
      reactions: t.reactions,
      replies: updatedReplies,
    );
  }

  void editThread(String threadId, {required String title, required String question}) {
    final idx = threads.indexWhere((t) => t.id == threadId);
    if (idx == -1) return;
    final t = threads[idx];
    // Update locally
    threads[idx] = ThreadModel2(
      id: t.id,
      scope: t.scope,
      scopeId: t.scopeId,
      ownerId: t.ownerId,
      ownerName: t.ownerName,
      title: title,
      question: question,
      timestamp: t.timestamp,
      replyCount: t.replyCount,
      reactions: t.reactions,
      replies: t.replies,
    );
    // Attempt to update Firestore
    _fs.editThread(t, title: title, question: question).catchError((_){});
  }

  void deleteThread(String threadId) {
    final t = threads.firstWhereOrNull((x) => x.id == threadId);
    threads.removeWhere((t) => t.id == threadId);
    if (t != null) {
      _fs.deleteThread(t).catchError((_){});
    }
  }
  
  Future<void> createThread({required ForumScope s, required String id, required String title, required String question}) async {
    final user = _auth.currentUser;
    final ownerId = user?.uid ?? 'anonymous';
    final ownerName = user?.displayName ?? 'Anonymous';
    final t = ThreadModel2(
      id: 't${DateTime.now().millisecondsSinceEpoch}',
      scope: s,
      scopeId: id,
      ownerId: ownerId,
      ownerName: ownerName,
      title: title,
      question: question,
      timestamp: DateTime.now(),
      replyCount: 0,
      reactions: const [],
      replies: const [],
    );
    threads.insert(0, t);
    await _fs.createThread(t);
  }
}
