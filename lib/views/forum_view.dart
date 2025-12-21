import 'package:unibridge_lk/controllers/forum_controller.dart';
import 'package:unibridge_lk/models/thread_model.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:unibridge_lk/theme/app_theme.dart';

class ForumView extends StatefulWidget {
  const ForumView({super.key});

  @override
  State<ForumView> createState() => _ForumViewState();
}

class _ForumViewState extends State<ForumView> {
  late ForumController controller;
  String forumType = 'global'; // global, university, faculty, department
  String title = 'Global Forum';
  Map<String, dynamic> forumContext = {};

  @override
  void initState() {
    super.initState();
    controller = Get.isRegistered<ForumController>() ? Get.find<ForumController>() : Get.put(ForumController());
    
    // Read forum context from arguments
    final args = Get.arguments as Map<String, dynamic>?;
    if (args != null) {
      forumType = args['type'] ?? 'global';
      forumContext = args;
      
      // Set title based on forum type
      switch (forumType) {
        case 'university':
          title = '${args['uni'] ?? 'University'} Forum';
          break;
        case 'faculty':
          title = '${args['faculty'] ?? 'Faculty'} Forum';
          break;
        case 'department':
          title = '${args['department'] ?? 'Department'} Forum';
          break;
        default:
          title = 'Global Forum';
      }
    }
  }

  String _formatTime(DateTime t) {
    final diff = DateTime.now().difference(t);
    if (diff.inMinutes < 60) return '${diff.inMinutes}m ago';
    if (diff.inHours < 24) return '${diff.inHours}h ago';
    return '${diff.inDays}d ago';
  }

  List<ThreadModel> _getFilteredThreads() {
    if (forumType == 'global') {
      return controller.threads.where((thread) => thread.forumScope == 'global').toList();
    }
    
    return controller.threads.where((thread) {
      // Only show threads with matching scope
      switch (forumType) {
        case 'university':
          return thread.forumScope == 'university' && thread.uni == forumContext['uni'];
        case 'faculty':
          return thread.forumScope == 'faculty' && 
                 thread.uni == forumContext['uni'] && 
                 thread.course.contains(forumContext['faculty'] ?? '');
        case 'department':
          return thread.forumScope == 'department' && 
                 thread.uni == forumContext['uni'] && 
                 thread.course.contains(forumContext['faculty'] ?? '') &&
                 thread.course.contains(forumContext['department'] ?? '');
        default:
          return false;
      }
    }).toList();
  }

  void _openThread(ThreadModel thread) {
    final replyCtl = TextEditingController();
    controller.loadReplies(thread.id);

    Get.bottomSheet(
      SafeArea(
        child: Container(
          height: MediaQuery.of(context).size.height * 0.8,
          padding: EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text(
                      thread.title,
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  IconButton(onPressed: () => Get.back(), icon: Icon(Icons.close)),
                ],
              ),
              SizedBox(height: 4),
              Text(thread.content, style: TextStyle(fontSize: 14, color: Colors.grey[800])),
              SizedBox(height: 12),
              Expanded(
                child: Obx(() {
                  final replyList = controller.replies[thread.id] ?? [];
                  if (replyList.isEmpty) {
                    return Center(
                      child: Text(
                        'No replies yet',
                        style: TextStyle(color: Colors.grey[600]),
                      ),
                    );
                  }
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Padding(
                        padding: EdgeInsets.only(bottom: 12),
                        child: Text(
                          '${replyList.length} ${replyList.length == 1 ? 'reply' : 'replies'}',
                          style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: Colors.grey[700]),
                        ),
                      ),
                      Expanded(
                        child: ListView.builder(
                          itemCount: replyList.length,
                          itemBuilder: (_, idx) {
                            final reply = replyList[idx];
                            final isReplyOwner = reply.userId == controller.currentUserId;
                            return Padding(
                              padding: EdgeInsets.only(bottom: 16),
                              child: Container(
                                padding: EdgeInsets.all(16),
                                decoration: BoxDecoration(
                                  color: Colors.grey[100],
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                      children: [
                                        Text(
                                          reply.author,
                                          style: TextStyle(
                                            fontSize: 16,
                                            fontWeight: FontWeight.bold,
                                            color: Colors.black87,
                                          ),
                                        ),
                                        if (isReplyOwner)
                                          PopupMenuButton<String>(
                                            onSelected: (v) {
                                              if (v == 'edit') {
                                                final contentCtl = TextEditingController(text: reply.content);
                                                Get.defaultDialog(
                                                  title: 'Edit Reply',
                                                  content: Padding(
                                                    padding: EdgeInsets.all(16),
                                                    child: TextField(
                                                      controller: contentCtl,
                                                      decoration: InputDecoration(labelText: 'Content'),
                                                      maxLines: 4,
                                                    ),
                                                  ),
                                                  confirm: TextButton(
                                                    onPressed: () async {
                                                      final newContent = contentCtl.text.trim();
                                                      if (newContent.isNotEmpty) {
                                                        Get.back();
                                                        await controller.editReply(thread.id, reply.id, newContent);
                                                      } else {
                                                        Get.snackbar('Error', 'Content cannot be empty');
                                                      }
                                                    },
                                                    child: Text('Save'),
                                                  ),
                                                  cancel: TextButton(
                                                    onPressed: () => Get.back(),
                                                    child: Text('Cancel'),
                                                  ),
                                                );
                                              } else if (v == 'delete') {
                                                Get.defaultDialog(
                                                  title: 'Delete Reply',
                                                  middleText: 'Are you sure you want to delete this reply?',
                                                  confirm: TextButton(
                                                    onPressed: () async {
                                                      Get.back();
                                                      await controller.deleteReply(thread.id, reply.id);
                                                    },
                                                    child: Text('Delete', style: TextStyle(color: Colors.red)),
                                                  ),
                                                  cancel: TextButton(
                                                    onPressed: () => Get.back(),
                                                    child: Text('Cancel'),
                                                  ),
                                                );
                                              }
                                            },
                                            itemBuilder: (_) => [
                                              PopupMenuItem(value: 'edit', child: Row(children: [Icon(Icons.edit, size: 16), SizedBox(width: 8), Text('Edit')])),
                                              PopupMenuItem(value: 'delete', child: Row(children: [Icon(Icons.delete, size: 16, color: Colors.red), SizedBox(width: 8), Text('Delete', style: TextStyle(color: Colors.red))]))
                                            ],
                                            icon: Icon(Icons.more_vert, size: 18, color: Colors.grey[600]),
                                            padding: EdgeInsets.zero,
                                          ),
                                      ],
                                    ),
                                    SizedBox(height: 4),
                                    Text(
                                      _formatTime(reply.timestamp),
                                      style: TextStyle(fontSize: 12, color: Colors.grey[500]),
                                    ),
                                    SizedBox(height: 12),
                                    Row(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Expanded(
                                          child: Text(
                                            reply.content,
                                            style: TextStyle(
                                              fontSize: 15,
                                              color: Colors.grey[700],
                                              height: 1.4,
                                            ),
                                          ),
                                        ),
                                        SizedBox(width: 12),
                                        GestureDetector(
                                          onTap: () {
                                            final isLiked = reply.likes.contains(controller.currentUserId);
                                            controller.toggleLikeReply(thread.id, reply.id, isLiked);
                                          },
                                          child: Row(
                                            mainAxisSize: MainAxisSize.min,
                                            children: [
                                              Icon(
                                                reply.likes.contains(controller.currentUserId) ? Icons.favorite : Icons.favorite_border,
                                                color: Colors.red,
                                                size: 18,
                                              ),
                                              SizedBox(width: 6),
                                              Text(
                                                reply.likes.length.toString(),
                                                style: TextStyle(fontSize: 13, color: Colors.grey[600]),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                            );
                          },
                        ),
                      ),
                    ],
                  );
                }),
              ),
              SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: replyCtl,
                      decoration: InputDecoration(hintText: 'Write a reply...'),
                      minLines: 1,
                      maxLines: 3,
                    ),
                  ),
                  SizedBox(width: 8),
                  ElevatedButton(
                    onPressed: () async {
                      final text = replyCtl.text.trim();
                      if (text.isEmpty) {
                        Get.snackbar('Error', 'Reply cannot be empty');
                        return;
                      }
                      await controller.addReply(thread.id, text);
                      replyCtl.clear();
                    },
                    child: Icon(Icons.send),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
      isScrollControlled: true,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(title),
        backgroundColor: Colors.white,
        foregroundColor: AppTheme.primaryColor,
        elevation: 0,
      ),
      body: Obx(() {
        final filteredThreads = _getFilteredThreads();
        
        // Preload replies for all threads (guard against empty IDs)
        for (final thread in filteredThreads) {
          final id = thread.id;
          if (id.isNotEmpty && !controller.replies.containsKey(id)) {
            controller.loadReplies(id);
          }
        }
        
        if (filteredThreads.isEmpty) {
          return Center(
            child: Text(
              'No threads yet',
              style: TextStyle(color: Colors.grey[600], fontSize: 16),
            ),
          );
        }
        
        return ListView.builder(
          padding: EdgeInsets.all(16),
          itemCount: filteredThreads.length,
          itemBuilder: (context, i) {
            final ThreadModel thread = filteredThreads[i];
            final isOwner = controller.currentUserId == thread.userId;
            return Card(
              margin: EdgeInsets.only(bottom: 12),
              child: GestureDetector(
                onTap: () => _openThread(thread),
                child: Padding(
                  padding: EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Title with menu button
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(
                            child: Text(
                              thread.title,
                              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.black87),
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          if (isOwner)
                            PopupMenuButton<String>(
                              onSelected: (v) {
                                if (v == 'edit') {
                                  final titleCtl = TextEditingController(text: thread.title);
                                  final contentCtl = TextEditingController(text: thread.content);
                                  Get.defaultDialog(
                                    title: 'Edit Thread',
                                    content: Padding(
                                      padding: EdgeInsets.all(16),
                                      child: Column(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          TextField(
                                            controller: titleCtl,
                                            decoration: InputDecoration(labelText: 'Title'),
                                          ),
                                          SizedBox(height: 8),
                                          TextField(
                                            controller: contentCtl,
                                            decoration: InputDecoration(labelText: 'Content'),
                                            maxLines: 4,
                                          ),
                                        ],
                                      ),
                                    ),
                                    confirm: TextButton(
                                      onPressed: () async {
                                        final newTitle = titleCtl.text.trim();
                                        final newContent = contentCtl.text.trim();
                                        if (newTitle.isNotEmpty && newContent.isNotEmpty) {
                                          Get.back();
                                          await controller.editThread(thread.id, newTitle, newContent);
                                        } else {
                                          Get.snackbar('Error', 'Title and content cannot be empty');
                                        }
                                      },
                                      child: Text('Save'),
                                    ),
                                    cancel: TextButton(
                                      onPressed: () => Get.back(),
                                      child: Text('Cancel'),
                                    ),
                                  );
                                } else if (v == 'delete') {
                                  Get.defaultDialog(
                                    title: 'Delete Thread',
                                    middleText: 'Are you sure you want to delete this thread?',
                                    confirm: TextButton(
                                      onPressed: () async {
                                        Get.back();
                                        await controller.deleteThread(thread.id);
                                      },
                                      child: Text('Delete', style: TextStyle(color: Colors.red)),
                                    ),
                                    cancel: TextButton(
                                      onPressed: () => Get.back(),
                                      child: Text('Cancel'),
                                    ),
                                  );
                                }
                              },
                              itemBuilder: (_) => [
                                PopupMenuItem(value: 'edit', child: Row(children: [Icon(Icons.edit, size: 18), SizedBox(width: 8), Text('Edit')])),
                                PopupMenuItem(value: 'delete', child: Row(children: [Icon(Icons.delete, size: 18, color: Colors.red), SizedBox(width: 8), Text('Delete', style: TextStyle(color: Colors.red))]))
                              ],
                              icon: Icon(Icons.more_vert, size: 20, color: Colors.grey[600]),
                            ),
                        ],
                      ),
                      SizedBox(height: 8),
                      // Content
                      Text(
                        thread.content,
                        style: TextStyle(fontSize: 14, color: Colors.grey[700]),
                        maxLines: 3,
                        overflow: TextOverflow.ellipsis,
                      ),
                      SizedBox(height: 12),
                      // Latest reply preview
                      Obx(() {
                        final replyList = controller.replies[thread.id] ?? [];
                        if (replyList.isNotEmpty) {
                          final latestReply = replyList.last;
                          return Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                '${latestReply.author}: ${latestReply.content}',
                                style: TextStyle(fontSize: 13, color: Colors.grey[700]),
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                              ),
                              SizedBox(height: 8),
                            ],
                          );
                        }
                        return SizedBox.shrink();
                      }),
                      SizedBox(height: 12),
                      // Metadata row
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(
                            child: Text(
                              '${thread.author} • ${_formatTime(thread.timestamp)}',
                              style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          SizedBox(width: 8),
                          GestureDetector(
                            onTap: () {
                              final isLiked = thread.likes.contains(controller.currentUserId);
                              controller.toggleLikeThread(thread.id, isLiked);
                            },
                            child: Row(
                              children: [
                                Icon(
                                  thread.likes.contains(controller.currentUserId) ? Icons.favorite : Icons.favorite_border,
                                  color: Colors.red,
                                  size: 20,
                                ),
                                SizedBox(width: 4),
                                Text(
                                  thread.likes.length.toString(),
                                  style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                                ),
                              ],
                            ),
                          ),
                          SizedBox(width: 16),
                          GestureDetector(
                            onTap: () => _openThread(thread),
                            child: Row(
                              children: [
                                Icon(Icons.reply, color: AppTheme.primaryColor, size: 20),
                                SizedBox(width: 4),
                                Obx(() {
                                  final replyCount = controller.replies[thread.id]?.length ?? 0;
                                  return Text(
                                    replyCount.toString(),
                                    style: TextStyle(fontSize: 12, color: AppTheme.primaryColor),
                                  );
                                }),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        );
      }),
      floatingActionButton: FloatingActionButton(
        backgroundColor: AppTheme.primaryColor,
        onPressed: () {
          final titleCtl = TextEditingController();
          final contentCtl = TextEditingController();
          Get.bottomSheet(Container(
            padding: EdgeInsets.all(16),
            decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.vertical(top: Radius.circular(16))),
            child: Column(mainAxisSize: MainAxisSize.min, children: [
              TextField(controller: titleCtl, decoration: InputDecoration(labelText: 'Title')),
              SizedBox(height: 8),
              TextField(controller: contentCtl, decoration: InputDecoration(labelText: 'Content'), maxLines: 3),
              SizedBox(height: 12),
              ElevatedButton(onPressed: () async {
                final title = titleCtl.text.trim();
                final content = contentCtl.text.trim();
                if (title.isEmpty || content.isEmpty) {
                  Get.snackbar('Error', 'Title and content required');
                  return;
                }
                
                // Pass context based on forum type
                String uni = forumType == 'global' ? '' : (forumContext['uni'] ?? '');
                String course = '';
                String scope = forumType; // 'global', 'university', 'faculty', 'department'
                
                if (forumType == 'faculty') {
                  course = forumContext['faculty'] ?? '';
                } else if (forumType == 'department') {
                  course = '${forumContext['faculty']} - ${forumContext['department']}';
                }
                
                await controller.createThread(title, content, uni: uni, course: course, forumScope: scope);
                Get.back();
                Get.snackbar('Success', 'Thread posted successfully', snackPosition: SnackPosition.BOTTOM);
              }, child: Text('Post'))
            ]),
          ));
        },
        child: Icon(Icons.add),
      ),
    );
  }
}
