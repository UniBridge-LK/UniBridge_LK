import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:chat_with_aks/theme/app_theme.dart';
import 'package:chat_with_aks/views/forum_view.dart';
import 'package:chat_with_aks/models/forum_models.dart';
import 'package:chat_with_aks/controllers/main_controller.dart';
import 'package:chat_with_aks/services/persistence_service.dart';

class UniversityView extends StatelessWidget {
  final String uniName;
  final Map<String, List<String>> faculties;
  const UniversityView({super.key, required this.uniName, required this.faculties});

  @override
  Widget build(BuildContext context) {
    final entries = faculties.entries.toList();
    return Scaffold(
      appBar: AppBar(
        title: Text(uniName),
        backgroundColor: Colors.white,
        foregroundColor: AppTheme.primaryColor,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // General Forum Card
              Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(colors: [Color(0xFF6C5CE7), Color(0xFF7F5CD1)]),
                  borderRadius: BorderRadius.circular(16),
                ),
                padding: EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(Icons.forum_outlined, color: Colors.white, size: 24),
                        SizedBox(width: 8),
                        Text(
                          'General Forum',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 12),
                    Text(
                      'Discuss hostels, canteen food, and campus life irrespective of course.',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 14,
                        height: 1.4,
                      ),
                    ),
                    SizedBox(height: 16),
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.white,
                        foregroundColor: AppTheme.primaryColor,
                        padding: EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      onPressed: () {
                        // Route to Forum tab with university scope
                        final mainCtrl = Get.find<MainController>();
                        PersistenceService.saveNavState(
                          tabIndex: 0,
                          universityPath: uniName,
                        );
                        mainCtrl.setIndex(0);
                        // Also navigate to Forum view with university scope
                        Get.to(() => const ForumView(
                          scope: ForumScope.university,
                          scopeId: 'moratuwa',
                          scopeTitle: 'University Forum',
                        ));
                      },
                      child: Text(
                        'View Uni Threads',
                        style: TextStyle(fontWeight: FontWeight.w600),
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(height: 28),
              // Select a Faculty/Course Header
              Text(
                'Select a Faculty',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                ),
              ),              SizedBox(height: 4),
              Text(
                '${entries.length} faculties available',
                style: TextStyle(
                  fontSize: 13,
                  color: Colors.grey[600],
                ),
              ),              SizedBox(height: 16),
              // Faculties List (Vertical Stack)
              ...entries.map((fac) {
                return GestureDetector(
                  onTap: () {
                    Get.toNamed('/home/university/faculty',
                      arguments: {
                        'uni': uniName,
                        'faculty': fac.key,
                        'departments': fac.value
                      },
                    );
                  },
                  child: Container(
                    margin: EdgeInsets.only(bottom: 12),
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.grey[300]!),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    padding: EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Icon(Icons.school_outlined, color: AppTheme.primaryColor, size: 24),
                            SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    fac.key,
                                    style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w600,
                                      color: Colors.black,
                                    ),
                                  ),
                                  SizedBox(height: 4),
                                  Text(
                                    '${fac.value.length} department${fac.value.length != 1 ? 's' : ''}',
                                    style: TextStyle(
                                      fontSize: 13,
                                      color: Colors.grey[600],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            Icon(Icons.arrow_forward_ios, color: AppTheme.primaryColor, size: 16),
                          ],
                        ),
                      ],
                    ),
                  ),
                );
              }),
            ],
          ),
        ),
      ),
    );
  }
}
