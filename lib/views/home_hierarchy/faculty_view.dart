import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:chat_with_aks/theme/app_theme.dart';

class FacultyView extends StatelessWidget {
  const FacultyView({super.key});

  @override
  Widget build(BuildContext context) {
    final args = Get.arguments as Map<String, dynamic>? ?? {};
    final uni = args['uni'] as String? ?? 'Unknown';
    final faculty = args['faculty'] as String? ?? 'Faculty';
    final departments = List<String>.from(args['departments'] ?? []);

    return Scaffold(
      appBar: AppBar(title: Text('$faculty - $uni'), backgroundColor: Colors.white, foregroundColor: AppTheme.primaryColor, elevation: 0),
      body: ListView.builder(
        padding: EdgeInsets.all(16),
        itemCount: departments.length,
        itemBuilder: (c,i){
          final dept = departments[i];
          return Card(
            margin: EdgeInsets.only(bottom:12),
            child: ListTile(
              title: Text(dept),
              trailing: TextButton(onPressed: (){
                Get.toNamed('/home/university/faculty/department', arguments: {'uni': uni, 'faculty': faculty, 'department': dept});
              }, child: Text('View Department')),
            ),
          );
        }
      ),
    );
  }
}
