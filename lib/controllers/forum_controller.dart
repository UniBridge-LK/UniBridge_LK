import 'package:get/get.dart';
import '../models/thread_model.dart';
import '../models/mock_data.dart';
import '../services/firestore_service.dart';
import 'auth_controller.dart';

class ForumController extends GetxController {
  final threads = <ThreadModel>[].obs;
  final currentUserId = 'u1_mock';
  final FirestoreService _fs = FirestoreService();
  final AuthController _auth = Get.find<AuthController>();
  final String appId = 'default_app';

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

  Future<void> createThread(String title, String content, {String uni = '', String course = '', String category = 'general'}) async {
    final userId = _auth.user?.uid ?? currentUserId;
    final author = _auth.userModel?.displayName ?? 'Anonymous';
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
    );
    await _fs.createThread(t, appId: appId);
  }

  void deleteThread(String id) {
    _fs.deleteThread(id, appId: appId).catchError((e){
      // fallback local removal
      threads.removeWhere((t) => t.id == id);
    });
  }

  void editThread(String id, String newContent) {
    // Update in Firestore; UI will update via stream
    final updates = {
      'content': newContent,
      'lastActivity': DateTime.now().millisecondsSinceEpoch,
    };
    _fs.editThread(id, updates, appId: appId).catchError((e){
      // fallback local edit
      final idx = threads.indexWhere((t) => t.id == id);
      if (idx != -1) {
        final t = threads[idx];
        threads[idx] = ThreadModel(
          id: t.id,
          title: t.title,
          author: t.author,
          timestamp: DateTime.now(),
          content: newContent,
          userId: t.userId,
          uni: t.uni,
          course: t.course,
          replyCount: t.replyCount,
          likes: t.likes,
          category: t.category,
        );
      }
    });
  }
}
