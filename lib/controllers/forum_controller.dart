import 'dart:async';
import 'package:get/get.dart';
import 'package:flutter/foundation.dart';
import '../models/thread_model.dart';
import '../models/mock_data.dart';
import '../services/firestore_service.dart';
import 'auth_controller.dart';
import '../models/reply_model.dart';

class ForumController extends GetxController {
  final threads = <ThreadModel>[].obs;
  final replies = <String, List<ReplyModel>>{}.obs;
  final FirestoreService _fs = FirestoreService();
  final AuthController _auth = Get.find<AuthController>();
  final String appId = 'default_app';
  final Map<String, StreamSubscription<List<ReplyModel>>> _replySubs = {};
  
  String get currentUserId => _auth.user?.uid ?? 'u1_mock';

  @override
  void onInit() {
    super.onInit();
    // Bind to Firestore threads stream (fallback to mock if Firestore unavailable)
    try {
      threads.bindStream(_fs.getThreadsStream(appId: appId));
    } catch (e) {
      threads.assignAll(mockGlobalThreads);
    }
  }

  Future<void> createThread(String title, String content, {String uni = '', String course = '', String category = 'general', String forumScope = 'global'}) async {
    try {
      final userId = _auth.user?.uid ?? currentUserId;
      final author = _auth.userModel?.displayName ?? 'Anonymous';
      debugPrint('Creating thread: title=$title, author=$author, uni=$uni, course=$course, scope=$forumScope');
      
      final t = ThreadModel(
        id: '',
        title: title,
        author: author,
        timestamp: DateTime.now(),
        content: content,
        userId: userId,
        uni: uni,
        course: course,
        replyCount: 0,
        likes: [],
        category: category,
        forumScope: forumScope,
      );
      
      await _fs.createThread(t, appId: appId);
      debugPrint('Thread created successfully');
    } catch (e) {
      debugPrint('Error creating thread: $e');
      Get.snackbar('Error', 'Failed to create thread: $e', snackPosition: SnackPosition.BOTTOM);
    }
  }

  Future<void> deleteThread(String id) async {
    try {
      await _fs.deleteThread(id, appId: appId);
      debugPrint('Thread deleted successfully');
      Get.snackbar('Success', 'Thread deleted', snackPosition: SnackPosition.BOTTOM);
    } catch (e) {
      debugPrint('Error deleting thread: $e');
      Get.snackbar('Error', 'Failed to delete thread: $e', snackPosition: SnackPosition.BOTTOM);
    }
  }

  Future<void> editThread(String id, String newTitle, String newContent) async {
    try {
      final updates = {
        'title': newTitle,
        'content': newContent,
        'lastActivity': DateTime.now().millisecondsSinceEpoch,
      };
      await _fs.editThread(id, updates, appId: appId);
      debugPrint('Thread edited successfully');
      Get.snackbar('Success', 'Thread updated', snackPosition: SnackPosition.BOTTOM);
    } catch (e) {
      debugPrint('Error editing thread: $e');
      Get.snackbar('Error', 'Failed to update thread: $e', snackPosition: SnackPosition.BOTTOM);
    }
  }

  void loadReplies(String threadId) {
    if (_replySubs.containsKey(threadId)) return;
    final sub = _fs.getRepliesStream(threadId, appId: appId).listen((data) {
      replies[threadId] = data;
      replies.refresh();
    });
    _replySubs[threadId] = sub;
  }

  Future<void> addReply(String threadId, String content) async {
    try {
      final userId = currentUserId;
      final author = _auth.userModel?.displayName ?? 'Anonymous';
      final reply = ReplyModel(
        id: '',
        threadId: threadId,
        userId: userId,
        author: author,
        content: content,
        timestamp: DateTime.now(),
      );

      await _fs.addReply(threadId, reply, appId: appId);
      Get.snackbar('Success', 'Reply posted', snackPosition: SnackPosition.BOTTOM);
    } catch (e) {
      debugPrint('Error adding reply: $e');
      Get.snackbar('Error', 'Failed to post reply: $e', snackPosition: SnackPosition.BOTTOM);
    }
  }

  Future<void> toggleLikeReply(String threadId, String replyId, bool isLiked) async {
    try {
      final userId = currentUserId;
      if (isLiked) {
        await _fs.unlikeReply(threadId, replyId, userId, appId: appId);
      } else {
        await _fs.likeReply(threadId, replyId, userId, appId: appId);
      }
    } catch (e) {
      debugPrint('Error toggling like: $e');
      Get.snackbar('Error', 'Failed to update like: $e', snackPosition: SnackPosition.BOTTOM);
    }
  }

  Future<void> editReply(String threadId, String replyId, String newContent) async {
    try {
      await _fs.editReply(threadId, replyId, newContent, appId: appId);
      Get.snackbar('Success', 'Reply updated', snackPosition: SnackPosition.BOTTOM);
    } catch (e) {
      debugPrint('Error editing reply: $e');
      Get.snackbar('Error', 'Failed to update reply: $e', snackPosition: SnackPosition.BOTTOM);
    }
  }

  Future<void> deleteReply(String threadId, String replyId) async {
    try {
      await _fs.deleteReply(threadId, replyId, appId: appId);
      Get.snackbar('Success', 'Reply deleted', snackPosition: SnackPosition.BOTTOM);
    } catch (e) {
      debugPrint('Error deleting reply: $e');
      Get.snackbar('Error', 'Failed to delete reply: $e', snackPosition: SnackPosition.BOTTOM);
    }
  }

  Future<void> toggleLikeThread(String threadId, bool isLiked) async {
    try {
      final userId = currentUserId;
      if (isLiked) {
        await _fs.unlikeThread(threadId, userId, appId: appId);
      } else {
        await _fs.likeThread(threadId, userId, appId: appId);
      }
    } catch (e) {
      debugPrint('Error toggling thread like: $e');
      Get.snackbar('Error', 'Failed to update like: $e', snackPosition: SnackPosition.BOTTOM);
    }
  }

  @override
  void onClose() {
    for (final sub in _replySubs.values) {
      sub.cancel();
    }
    super.onClose();
  }
}
