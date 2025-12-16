import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:chat_with_aks/data/sample_forum_data.dart';

class ForumSeedingService {
  static final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  /// Seeds all forums with sample data
  static Future<void> seedAllForums() async {
    try {
      await seedGlobalForum();
      await seedUniversityForum('TECH_UNIVERSITY_ID');
      await seedFacultyForum('TECH_UNIVERSITY_ID', 'TECHNOLOGY_FACULTY_ID');
      await seedDepartmentForum(
          'TECH_UNIVERSITY_ID', 'TECHNOLOGY_FACULTY_ID', 'CS_DEPT_ID');
      // All forums seeded successfully
    } catch (e) {
      // Error seeding forums
      rethrow;
    }
  }

  /// Seed Global Forum
  static Future<void> seedGlobalForum() async {
    final String forumPath = 'forums/GLOBAL_GLOBAL/threads';
    
    for (var threadData in SampleForumData.globalThreads) {
      await _seedThread(forumPath, threadData);
    }
    // Global forum seeded
  }

  /// Seed University Forum
  static Future<void> seedUniversityForum(String universityId) async {
    final String forumPath = 'forums/UNIVERSITY_$universityId/threads';
    
    for (var threadData in SampleForumData.universityThreads) {
      await _seedThread(forumPath, threadData);
    }
    // University forum seeded
  }

  /// Seed Faculty Forum
  static Future<void> seedFacultyForum(
      String universityId, String facultyId) async {
    final String forumPath = 'forums/FACULTY_${universityId}_$facultyId/threads';
    
    for (var threadData in SampleForumData.facultyThreads) {
      await _seedThread(forumPath, threadData);
    }
    // Faculty forum seeded
  }

  /// Seed Department Forum
  static Future<void> seedDepartmentForum(
      String universityId, String facultyId, String departmentId) async {
    final String forumPath =
        'forums/DEPARTMENT_${universityId}_${facultyId}_$departmentId/threads';
    
    for (var threadData in SampleForumData.departmentThreads) {
      await _seedThread(forumPath, threadData);
    }
    // Department forum seeded
  }

  /// Helper method to seed individual thread with replies
  static Future<void> _seedThread(
      String forumPath, Map<String, dynamic> threadData) async {
    final String threadId =
        'thread_${DateTime.now().millisecondsSinceEpoch}_${threadData['title'].hashCode}';

    // Extract replies
    List<Map<String, dynamic>> replies =
        List<Map<String, dynamic>>.from(threadData['replies'] ?? []);
    threadData.remove('replies');

    // Create thread
    await _firestore.doc('$forumPath/$threadId').set({
      'id': threadId,
      'title': threadData['title'],
      'question': threadData['question'],
      'authorId': threadData['authorId'],
      'authorName': threadData['authorName'],
      'timestamp': Timestamp.fromDate(
          DateTime.parse(threadData['timestamp'] as String)),
      'createdAt': FieldValue.serverTimestamp(),
    });

    // Seed replies
    for (var replyData in replies) {
      await _seedReply('$forumPath/$threadId/replies', replyData);
    }
  }

  /// Helper method to recursively seed replies
  static Future<void> _seedReply(
      String repliesPath, Map<String, dynamic> replyData) async {
    final String replyId =
        'reply_${DateTime.now().millisecondsSinceEpoch}_${replyData['content'].hashCode}';

    // Extract nested replies
    List<Map<String, dynamic>> nestedReplies =
        List<Map<String, dynamic>>.from(replyData['replies'] ?? []);
    replyData.remove('replies');

    // Create reply
    await _firestore.doc('$repliesPath/$replyId').set({
      'id': replyId,
      'content': replyData['content'],
      'authorId': replyData['authorId'],
      'authorName': replyData['authorName'],
      'timestamp': Timestamp.fromDate(
          DateTime.parse(replyData['timestamp'] as String)),
      'createdAt': FieldValue.serverTimestamp(),
    });

    // Seed nested replies
    for (var nestedReplyData in nestedReplies) {
      await _seedReply('$repliesPath/$replyId/replies', nestedReplyData);
    }
  }

  /// Check if forums are already seeded
  static Future<bool> areForumsSeeded() async {
    try {
      final QuerySnapshot globalThreads =
          await _firestore.collection('forums').doc('GLOBAL_GLOBAL').collection('threads').limit(1).get();
      return globalThreads.docs.isNotEmpty;
    } catch (e) {
      return false;
    }
  }

  /// Clear all forum data (useful for testing)
  static Future<void> clearAllForums() async {
    try {
      final forumDocs =
          await _firestore.collection('forums').get();
      for (var doc in forumDocs.docs) {
        // Delete threads and their subcollections
        final threadDocs = await doc.reference.collection('threads').get();
        for (var threadDoc in threadDocs.docs) {
          // Delete replies and their nested replies recursively
          await _deleteRepliesRecursively(threadDoc.reference.collection('replies'));
          await threadDoc.reference.delete();
        }
        await doc.reference.delete();
      }
      // All forums cleared
    } catch (e) {
      // Error clearing forums
    }
  }

  static Future<void> _deleteRepliesRecursively(
      CollectionReference repliesCollection) async {
    final QuerySnapshot replies = await repliesCollection.get();
    for (var replyDoc in replies.docs) {
      await _deleteRepliesRecursively(replyDoc.reference.collection('replies'));
      await replyDoc.reference.delete();
    }
  }
}
