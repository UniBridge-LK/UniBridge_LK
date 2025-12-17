import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:chat_with_aks/theme/app_theme.dart';

class DepartmentView extends StatelessWidget {
  const DepartmentView({super.key});

  @override
  Widget build(BuildContext context) {
    final args = Get.arguments as Map<String, dynamic>? ?? {};
    final uni = args['uni'] as String? ?? 'Unknown';
    final faculty = args['faculty'] as String? ?? 'Faculty';
    final department = args['department'] as String? ?? 'Department';

    return Scaffold(
      appBar: AppBar(title: Text('$department - $faculty'), backgroundColor: Colors.white, foregroundColor: AppTheme.primaryColor, elevation: 0),
      body: Padding(
        padding: EdgeInsets.all(16),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text('You are viewing threads for', style: TextStyle(color: Colors.grey[600])),
          SizedBox(height:8),
          Text('$department • $faculty • $uni', style: TextStyle(fontSize:18, fontWeight: FontWeight.bold)),
          SizedBox(height:16),
          Text('Threads for specific departments are centralized in the Forum. Use the button below to view or create threads.'),
          SizedBox(height:24),
            ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: AppTheme.primaryColor),
            onPressed: (){
              Get.toNamed('/forum', arguments: {
                'type': 'department', 
                'uni': uni, 
                'faculty': faculty, 
                'department': department
              });
            },
            child: Text('Go to Forum'))
        ],),
      ),
    );
  }
}
