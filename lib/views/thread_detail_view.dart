import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../controllers/forum_controller.dart';
import '../models/forum_models.dart';
import '../services/firestore_forum_service.dart';

class ThreadDetailView extends StatefulWidget {
  final ThreadModel2 thread;
  final VoidCallback? onBack;
  const ThreadDetailView({super.key, required this.thread, this.onBack});

  @override
  State<ThreadDetailView> createState() => _ThreadDetailViewState();
}

class _ThreadDetailViewState extends State<ThreadDetailView> {
  final TextEditingController _replyController = TextEditingController();
  final FirestoreForumService _fs = FirestoreForumService();
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final RxList<ReplyModel> _replies = <ReplyModel>[].obs;
  late ThreadModel2 _thread;

  @override
  void initState() {
    super.initState();
    _thread = widget.thread;
    _bindReplies();
  }

  @override
  void dispose() {
    _replyController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final fc = Get.find<ForumController>();
    final hasLiked = _thread.reactions.any((r) => r.emoji == '👍' && r.reactedByMe);
    final likeCount = _thread.reactions.firstWhereOrNull((r) => r.emoji == '👍')?.count ?? 0;
    
    return Scaffold(
      appBar: AppBar(
        title: Text('Thread'),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0,
        actions: _isOwner() ? [
          IconButton(
            icon: Icon(Icons.edit_outlined),
            onPressed: () => _editThreadDialog(fc),
          ),
          IconButton(
            icon: Icon(Icons.delete_outline),
            onPressed: () {
              fc.deleteThread(_thread.id);
              Get.back();
              widget.onBack?.call();
            },
          ),
        ] : null,
        leading: widget.onBack != null
          ? IconButton(
              icon: Icon(Icons.arrow_back),
              onPressed: widget.onBack,
            )
          : null,
      ),
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              padding: EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Thread title
                  Text(
                    _thread.title,
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                  SizedBox(height: 12),
                  // Posted by info
                  Row(
                    children: [
                      Text('Posted by ', style: TextStyle(fontSize: 13, color: Colors.grey[700])),
                      Text(_thread.ownerName, style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: Colors.blue[700])),
                      Text(' • ${_formatTime(_thread.timestamp)}', style: TextStyle(fontSize: 13, color: Colors.grey[700])),
                    ],
                  ),
                  SizedBox(height: 4),
                  // Like and reply counts
                  Row(
                    children: [
                      IconButton(
                        icon: Icon(hasLiked ? Icons.favorite : Icons.favorite_border, 
                          color: hasLiked ? Colors.red : Colors.grey),
                        iconSize: 18,
                        onPressed: () => fc.toggleReaction(_thread, '👍'),
                        padding: EdgeInsets.zero,
                        constraints: BoxConstraints(),
                      ),
                      SizedBox(width: 4),
                      Text('$likeCount', style: TextStyle(fontSize: 13, color: Colors.grey[700])),
                      SizedBox(width: 16),
                      Icon(Icons.chat_bubble_outline, size: 18, color: Colors.grey),
                      SizedBox(width: 4),
                      Text('${_replies.length}', style: TextStyle(fontSize: 13, color: Colors.grey[700])),
                    ],
                  ),
                  SizedBox(height: 16),
                  Divider(),
                  SizedBox(height: 12),
                  // Question content
                  Text(
                    _thread.question,
                    style: TextStyle(fontSize: 14, height: 1.6, color: Colors.grey[800]),
                  ),
                  SizedBox(height: 24),
                  // Replies section
                  Text(
                    'Replies (${_replies.length})',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  SizedBox(height: 16),
                  Obx(() => Column(
                    children: _replies.map((r) => _replyTile(r)).toList(),
                  )),
                ],
              ),
            ),
          ),
          _composer(fc),
        ],
      ),
    );
  }

  void _bindReplies() {
    _fs
        .repliesStream(widget.thread.scope, widget.thread.scopeId, widget.thread.id)
        .listen((list) {
      _replies.assignAll(list);
    });
  }

  bool _isOwner() {
    final uid = _auth.currentUser?.uid;
    if (uid != null && uid == _thread.ownerId) return true;
    return _thread.ownerId == 'u1_mock';
  }

  void _editThreadDialog(ForumController fc) {
    final titleCtrl = TextEditingController(text: _thread.title);
    final bodyCtrl = TextEditingController(text: _thread.question);
    Get.dialog(AlertDialog(
      title: Text('Edit Thread'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          TextField(controller: titleCtrl, decoration: InputDecoration(labelText: 'Title')),
          SizedBox(height: 12),
          TextField(controller: bodyCtrl, decoration: InputDecoration(labelText: 'Question'), maxLines: 4),
        ],
      ),
      actions: [
        TextButton(onPressed: () => Get.back(), child: Text('Cancel')),
        ElevatedButton(
          onPressed: () {
            final newTitle = titleCtrl.text.trim();
            final newBody = bodyCtrl.text.trim();
            if (newTitle.isEmpty || newBody.isEmpty) return;
            fc.editThread(_thread.id, title: newTitle, question: newBody);
            setState(() {
              _thread = ThreadModel2(
                id: _thread.id,
                scope: _thread.scope,
                scopeId: _thread.scopeId,
                ownerId: _thread.ownerId,
                ownerName: _thread.ownerName,
                title: newTitle,
                question: newBody,
                timestamp: _thread.timestamp,
                replyCount: _thread.replyCount,
                reactions: _thread.reactions,
                replies: _thread.replies,
              );
            });
            Get.back();
          },
          child: Text('Save'),
        ),
      ],
    ));
  }

  void _addNestedReply({required String parentId, required String content}) {
    final user = _auth.currentUser;
    final nested = ReplyModel(
      id: 'nr${DateTime.now().millisecondsSinceEpoch}',
      threadId: _thread.id,
      authorId: user?.uid ?? 'anonymous',
      authorName: user?.displayName ?? 'Anonymous',
      timestamp: DateTime.now(),
      content: content,
    );

    ReplyModel appendChild(ReplyModel r) {
      if (r.id == parentId) {
        return ReplyModel(
          id: r.id,
          threadId: r.threadId,
          authorId: r.authorId,
          authorName: r.authorName,
          timestamp: r.timestamp,
          content: r.content,
          reactions: r.reactions,
          replies: [...r.replies, nested],
        );
      }
      if (r.replies.isEmpty) return r;
      return ReplyModel(
        id: r.id,
        threadId: r.threadId,
        authorId: r.authorId,
        authorName: r.authorName,
        timestamp: r.timestamp,
        content: r.content,
        reactions: r.reactions,
        replies: r.replies.map(appendChild).toList(),
      );
    }

    _replies.assignAll(_replies.map(appendChild).toList());
  }

  Widget _composer(ForumController fc) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(color: Colors.white, boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 4, offset: Offset(0, -2))]),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: _replyController,
              decoration: InputDecoration(hintText: 'Write a reply...', border: OutlineInputBorder(borderRadius: BorderRadius.circular(24), borderSide: BorderSide.none), filled: true, fillColor: Colors.grey.shade100, contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 10)),
            ),
          ),
          SizedBox(width: 8),
          CircleAvatar(
            backgroundColor: Colors.purple,
            child: IconButton(
              icon: Icon(Icons.send, color: Colors.white),
              onPressed: () {
                final text = _replyController.text.trim();
                if (text.isEmpty) return;
                final user = _auth.currentUser;
                final reply = ReplyModel(
                  id: 'r${DateTime.now().millisecondsSinceEpoch}',
                  threadId: _thread.id,
                  authorId: user?.uid ?? 'anonymous',
                  authorName: user?.displayName ?? 'Anonymous',
                  timestamp: DateTime.now(),
                  content: text,
                );
                _fs.addReply(_thread.scope, _thread.scopeId, _thread.id, reply);
                _replyController.clear();
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _replyTile(ReplyModel r, {int depth = 0}) {
    return Container(
      margin: EdgeInsets.only(bottom: 16, left: depth * 20.0),
      padding: EdgeInsets.all(12),
      decoration: BoxDecoration(color: Colors.grey.shade50, borderRadius: BorderRadius.circular(8), border: Border.all(color: Colors.grey.shade200)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(r.authorName, style: TextStyle(fontWeight: FontWeight.w600, fontSize: 13)),
              SizedBox(width: 8),
              Text(_formatTime(r.timestamp), style: TextStyle(color: Colors.grey, fontSize: 11)),
            ],
          ),
          SizedBox(height: 8),
          Text(r.content, style: TextStyle(fontSize: 13, height: 1.5, color: Colors.grey[800])),
          SizedBox(height: 8),
          Row(
            children: [
              TextButton.icon(
                onPressed: () {},
                icon: Icon(Icons.thumb_up_outlined, size: 14),
                label: Text('Helpful'),
                style: TextButton.styleFrom(padding: EdgeInsets.zero, minimumSize: Size(0, 30)),
              ),
              SizedBox(width: 16),
              TextButton.icon(
                onPressed: () {
                  Get.dialog(_ReplyDialog(onSubmit: (txt) {
                    _addNestedReply(parentId: r.id, content: txt);
                  }));
                },
                icon: Icon(Icons.reply_outlined, size: 14),
                label: Text('Reply'),
                style: TextButton.styleFrom(padding: EdgeInsets.zero, minimumSize: Size(0, 30)),
              ),
            ],
          ),
          if (r.replies.isNotEmpty) ...[
            SizedBox(height: 12),
            ...r.replies.map((sub) => _replyTile(sub, depth: depth + 1)),
          ],
        ],
      ),
    );
  }

  String _formatTime(DateTime t) {
    final diff = DateTime.now().difference(t);
    if (diff.inHours >= 24) return '${t.day}/${t.month}/${t.year}';
    if (diff.inHours >= 1) return '${diff.inHours}h';
    if (diff.inMinutes >= 1) return '${diff.inMinutes}m';
    return 'now';
  }
}

class _ReplyDialog extends StatefulWidget {
  final Function(String) onSubmit;
  const _ReplyDialog({required this.onSubmit});
  @override
  State<_ReplyDialog> createState() => _ReplyDialogState();
}

class _ReplyDialogState extends State<_ReplyDialog> {
  final TextEditingController _c = TextEditingController();
  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text('Reply'),
      content: TextField(controller: _c, maxLines: 4, decoration: InputDecoration(hintText: 'Write your reply')), 
      actions: [
        TextButton(onPressed: () => Get.back(), child: Text('Cancel')),
        ElevatedButton(onPressed: () { final txt = _c.text.trim(); if (txt.isNotEmpty) { widget.onSubmit(txt); Get.back(); } }, child: Text('Send')),
      ],
    );
  }
}