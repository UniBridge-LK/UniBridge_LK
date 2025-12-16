import 'package:chat_with_aks/controllers/forum_controller.dart';
import 'package:chat_with_aks/models/thread_model.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:chat_with_aks/theme/app_theme.dart';

class ForumView extends StatefulWidget {
  const ForumView({super.key});

  @override
  State<ForumView> createState() => _ForumViewState();
}

class _ForumViewState extends State<ForumView> {
  late ForumController controller;

  @override
  void initState() {
    super.initState();
    controller = Get.isRegistered<ForumController>() ? Get.find<ForumController>() : Get.put(ForumController());
  }

  String _formatTime(DateTime t) {
    final diff = DateTime.now().difference(t);
    if (diff.inMinutes < 60) return '${diff.inMinutes}m ago';
    if (diff.inHours < 24) return '${diff.inHours}h ago';
    return '${diff.inDays}d ago';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Forum'),
        backgroundColor: Colors.white,
        foregroundColor: AppTheme.primaryColor,
        elevation: 0,
      ),
      body: Obx(() {
        return ListView.builder(
          padding: EdgeInsets.all(16),
          itemCount: controller.threads.length,
          itemBuilder: (context, i) {
            final ThreadModel thread = controller.threads[i];
            final isOwner = controller.currentUserId == thread.userId;
            return Card(
              margin: EdgeInsets.only(bottom: 12),
              child: ListTile(
                title: Text(thread.title, style: TextStyle(fontWeight: FontWeight.bold)),
                subtitle: Text('${thread.author} • ${_formatTime(thread.timestamp)} • ${thread.uni}'),
                trailing: isOwner ? PopupMenuButton<String>(
                  onSelected: (v) {
                    if (v == 'edit') {
                      Get.defaultDialog(
                        title: 'Edit Thread',
                        content: TextField(
                          controller: TextEditingController(text: thread.content),
                          maxLines: 4,
                          onChanged: (val) {},
                        ),
                        confirm: TextButton(onPressed: () { Get.back(); }, child: Text('Save')),
                      );
                    } else if (v == 'delete') {
                      controller.deleteThread(thread.id);
                    }
                  },
                  itemBuilder: (_) => [PopupMenuItem(value: 'edit', child: Text('Edit')), PopupMenuItem(value: 'delete', child: Text('Delete'))],
                ) : Icon(Icons.arrow_forward_ios, size: 16, color: AppTheme.primaryColor),
                onTap: () {
                  Get.defaultDialog(title: thread.title, content: Text(thread.content));
                },
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
                await controller.createThread(title, content);
                Get.back();
              }, child: Text('Post'))
            ]),
          ));
        },
        child: Icon(Icons.add),
      ),
    );
  }
}
