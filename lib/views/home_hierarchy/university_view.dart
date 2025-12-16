import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:chat_with_aks/theme/app_theme.dart';

class UniversityView extends StatelessWidget {
  final String uniName;
  final Map<String, List<String>> faculties;
  const UniversityView({super.key, required this.uniName, required this.faculties});

  @override
  Widget build(BuildContext context) {
    final entries = faculties.entries.toList();
    return Scaffold(
      appBar: AppBar(title: Text(uniName), backgroundColor: Colors.white, foregroundColor: AppTheme.primaryColor, elevation: 0),
      body: ListView.builder(
        padding: EdgeInsets.all(16),
        itemCount: entries.length,
        itemBuilder: (c,i){
          final fac = entries[i];
          return Card(
            margin: EdgeInsets.only(bottom:12),
            child: ListTile(
              title: Text(fac.key),
              subtitle: Text('${fac.value.length} departments'),
              trailing: TextButton(onPressed: (){
                Get.toNamed('/home/university/faculty', arguments: {'uni': uniName, 'faculty': fac.key, 'departments': fac.value});
              }, child: Text('View Faculty')),
            ),
          );
        }
      ),
    );
  }
}
