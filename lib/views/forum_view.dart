import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../controllers/forum_controller.dart';
import '../models/forum_models.dart';
import '../theme/app_theme.dart';
import 'thread_detail_view.dart';

class ForumView extends StatefulWidget {
  final ForumScope scope;
  final String scopeId; // 'global' or specific id
  final String? scopeTitle;

  const ForumView({super.key, this.scope = ForumScope.global, this.scopeId = 'global', this.scopeTitle});

  @override
  State<ForumView> createState() => _ForumViewState();
}

class _ForumViewState extends State<ForumView> {
  ThreadModel2? selectedThread;

  @override
  Widget build(BuildContext context) {
    final fc = Get.isRegistered<ForumController>() ? Get.find<ForumController>() : Get.put(ForumController());
    fc.loadThreads(s: widget.scope, id: widget.scopeId);

    // If a thread is selected, show thread detail, otherwise show thread list
    if (selectedThread != null) {
      return ThreadDetailView(
        thread: selectedThread!,
        onBack: () {
          setState(() {
            selectedThread = null;
          });
        },
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.scopeTitle ?? _titleForScope(widget.scope)),
        backgroundColor: Colors.white,
        foregroundColor: AppTheme.primaryColor,
        elevation: 0,
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Get.bottomSheet(
            _CreateThreadSheet(scope: widget.scope, scopeId: widget.scopeId),
            isScrollControlled: true,
          );
        },
        child: Icon(Icons.add),
      ),
      body: Obx(() {
        final threads = fc.threads;
        if (threads.isEmpty) {
          return Center(child: Text('No threads yet'));
        }
        return ListView.builder(
          padding: EdgeInsets.all(12),
          itemCount: threads.length,
          itemBuilder: (c, i) {
            final t = threads[i];
            final timeText = _formatTime(t.timestamp);
            final hasLiked = t.reactions.any((r) => r.emoji == '👍' && r.reactedByMe);
            final likeCount = t.reactions.firstWhereOrNull((r) => r.emoji == '👍')?.count ?? 0;
            
            return GestureDetector(
              onTap: () {
                setState(() {
                  selectedThread = t;
                });
              },
              child: Card(
                margin: EdgeInsets.only(bottom: 12),
                child: Padding(
                  padding: EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Title
                      Text(
                        t.title,
                        style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.blue[700]),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      SizedBox(height: 8),
                      // Scope/Category
                      Text(
                        _scopeLabel(t.scope),
                        style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                      ),
                      SizedBox(height: 8),
                      // Question preview
                      Text(
                        t.question,
                        style: TextStyle(fontSize: 13, color: Colors.grey[700]),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      SizedBox(height: 12),
                      // Bottom row: author info, like button, reply count
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              '${t.ownerName} • $timeText',
                              style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                            ),
                          ),
                          IconButton(
                            icon: Icon(hasLiked ? Icons.favorite : Icons.favorite_border, 
                              color: hasLiked ? Colors.red : Colors.grey),
                            iconSize: 20,
                            onPressed: () => fc.toggleReaction(t, '👍'),
                            padding: EdgeInsets.zero,
                            constraints: BoxConstraints(),
                          ),
                          SizedBox(width: 4),
                          Text(likeCount.toString(), style: TextStyle(fontSize: 12, color: Colors.grey[600])),
                          SizedBox(width: 16),
                          Container(
                            padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                            decoration: BoxDecoration(
                              color: AppTheme.primaryColor.withValues(alpha: 0.1),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Row(
                              children: [
                                Icon(Icons.chat_bubble_outline, size: 14, color: AppTheme.primaryColor),
                                SizedBox(width: 4),
                                Text(t.replyCount.toString(), 
                                  style: TextStyle(fontSize: 12, color: AppTheme.primaryColor, fontWeight: FontWeight.w600)),
                              ],
                            ),
                          ),
                        ],
                      ),
                      // Owner menu (three dots)
                      if (_isOwner(t))
                        Align(
                          alignment: Alignment.topRight,
                          child: Transform.translate(
                            offset: Offset(8, -16),
                            child: _ownerMenu(t),
                          ),
                        ),
                    ],
                  ),
                ),
              ),
            );
          },
        );
      }),
    );
  }

  String _titleForScope(ForumScope s) {
    switch (s) {
      case ForumScope.global:
        return 'Global Forum';
      case ForumScope.university:
        return 'University Forum';
      case ForumScope.faculty:
        return 'Faculty Forum';
      case ForumScope.department:
        return 'Department Forum';
    }
  }

  String _scopeLabel(ForumScope s) {
    switch (s) {
      case ForumScope.global:
        return 'General';
      case ForumScope.university:
        return 'University';
      case ForumScope.faculty:
        return 'Faculty';
      case ForumScope.department:
        return 'Department';
    }
  }

  bool _isOwner(ThreadModel2 t) {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    // Allow seeded owner id fallback
    if (uid != null && t.ownerId == uid) return true;
    return t.ownerId == 'u1_mock';
  }

  Widget _ownerMenu(ThreadModel2 t) {
    if (!_isOwner(t)) return SizedBox.shrink();
    final fc = Get.find<ForumController>();

    return PopupMenuButton<String>(
      onSelected: (v) {
        if (v == 'edit') {
          Get.dialog(AlertDialog(
            title: Text('Edit Thread'),
            content: _EditThreadForm(thread: t),
          ));
        } else if (v == 'delete') {
          fc.deleteThread(t.id);
          Get.snackbar('Deleted', 'Thread removed');
        }
      },
      itemBuilder: (c) => [
        PopupMenuItem(value: 'edit', child: Text('Edit')),
        PopupMenuItem(value: 'delete', child: Text('Delete')),
      ],
      child: Icon(Icons.more_vert, color: Colors.grey[700]),
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

class _CreateThreadSheet extends StatefulWidget {
  final ForumScope scope;
  final String scopeId;
  const _CreateThreadSheet({required this.scope, required this.scopeId});
  @override
  State<_CreateThreadSheet> createState() => _CreateThreadSheetState();
}

class _CreateThreadSheetState extends State<_CreateThreadSheet> {
  final _titleCtl = TextEditingController();
  final _questionCtl = TextEditingController();
  bool _submitting = false;

  @override
  void dispose() {
    _titleCtl.dispose();
    _questionCtl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final padding = MediaQuery.of(context).viewInsets;
    return Container(
      padding: EdgeInsets.only(left: 16, right: 16, top: 16, bottom: padding.bottom + 16),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.vertical(top: Radius.circular(16))),
      child: Column(mainAxisSize: MainAxisSize.min, children: [
        Text('Create Thread', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
        SizedBox(height: 12),
        TextField(controller: _titleCtl, decoration: InputDecoration(labelText: 'Heading')),
        SizedBox(height: 8),
        TextField(controller: _questionCtl, maxLines: 5, decoration: InputDecoration(labelText: 'Question')),
        SizedBox(height: 12),
        Row(children: [
          TextButton(onPressed: () => Get.back(), child: Text('Cancel')),
          Spacer(),
          ElevatedButton(
            onPressed: _submitting ? null : () async {
              final title = _titleCtl.text.trim();
              final question = _questionCtl.text.trim();
              if (title.isEmpty || question.isEmpty) {
                Get.snackbar('Error', 'Heading and question are required');
                return;
              }
              setState(() { _submitting = true; });
              await Get.find<ForumController>().createThread(s: widget.scope, id: widget.scopeId, title: title, question: question);
              setState(() { _submitting = false; });
              Get.back();
              Get.snackbar('Posted', 'Thread created');
            },
            child: _submitting ? SizedBox(width: 18, height: 18, child: CircularProgressIndicator(strokeWidth: 2)) : Text('Post'),
          ),
        ])
      ]),
    );
  }

}

class _EditThreadForm extends StatefulWidget {
  final ThreadModel2 thread;
  const _EditThreadForm({required this.thread});
  @override
  State<_EditThreadForm> createState() => _EditThreadFormState();
}

class _EditThreadFormState extends State<_EditThreadForm> {
  late TextEditingController _title;
  late TextEditingController _question;
  @override
  void initState() {
    super.initState();
    _title = TextEditingController(text: widget.thread.title);
    _question = TextEditingController(text: widget.thread.question);
  }
  @override
  void dispose() {
    _title.dispose();
    _question.dispose();
    super.dispose();
  }
  @override
  Widget build(BuildContext context) {
    final fc = Get.find<ForumController>();
    return SingleChildScrollView(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          TextField(controller: _title, decoration: InputDecoration(labelText: 'Heading')),
          SizedBox(height: 12),
          TextField(controller: _question, maxLines: 5, decoration: InputDecoration(labelText: 'Question')),
          SizedBox(height: 16),
          Row(
            children: [
              TextButton(onPressed: () => Get.back(), child: Text('Cancel')),
              Spacer(),
              ElevatedButton(
                onPressed: () {
                  fc.editThread(widget.thread.id, title: _title.text.trim(), question: _question.text.trim());
                  Get.back();
                },
                child: Text('Save'),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
