import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:chat_with_aks/theme/app_theme.dart';
import 'package:chat_with_aks/views/forum_view.dart';
import 'package:chat_with_aks/models/forum_models.dart';
import 'package:chat_with_aks/controllers/main_controller.dart';
import 'package:chat_with_aks/services/persistence_service.dart';

class FacultyView extends StatelessWidget {
  const FacultyView({super.key});

  @override
  Widget build(BuildContext context) {
    final args = Get.arguments as Map<String, dynamic>? ?? {};
    final uni = args['uni'] as String? ?? 'Unknown';
    final faculty = args['faculty'] as String? ?? 'Faculty';
    final departments = List<String>.from(args['departments'] ?? []);

    return Scaffold(
      appBar: AppBar(
        title: Text('$faculty - $uni'),
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
              // Faculty Forum Card
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
                          'Faculty Forum',
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
                      'Discuss common topics, course selection, and academic guidance for $faculty.',
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
                        // Route to Forum tab with faculty scope
                        final mainCtrl = Get.find<MainController>();
                        PersistenceService.saveNavState(
                            tabIndex: 0,
                          universityPath: uni,
                          facultyPath: faculty,
                        );
                        mainCtrl.setIndex(0);
                        // Also navigate to Forum view with faculty scope
                        final facId = '$uni-$faculty'.replaceAll(' ', '_');
                        Get.to(() => ForumView(
                          scope: ForumScope.faculty,
                          scopeId: facId,
                          scopeTitle: '$faculty Forum',
                        ));
                      },
                      child: Text(
                        'View Faculty Threads',
                        style: TextStyle(fontWeight: FontWeight.w600),
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(height: 28),
              // Select a Department Header
              Text(
                'Select a Department',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                ),
              ),
              SizedBox(height: 4),
              Text(
                '${departments.length} departments available',
                style: TextStyle(
                  fontSize: 13,
                  color: Colors.grey[600],
                ),
              ),
              SizedBox(height: 16),
              // Departments List (Vertical Stack)
              ...departments.map((dept) {
                return GestureDetector(
                  onTap: () {
                    // Set Forum tab and save navigation state with department
                    final mainController = Get.find<MainController>();
                    mainController.setIndex(0);
                    PersistenceService.saveNavState(
                      tabIndex: 0,
                      universityPath: uni,
                      facultyPath: faculty,
                      departmentPath: dept,
                    );
                    // ForumView will be shown by tab change
                  },
                  child: Container(
                    margin: EdgeInsets.only(bottom: 12),
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.grey[300]!),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    padding: EdgeInsets.all(16),
                    child: Row(
                      children: [
                        Icon(Icons.apartment_outlined, color: AppTheme.primaryColor, size: 24),
                        SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            dept,
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                              color: Colors.black,
                            ),
                          ),
                        ),
                        Icon(Icons.arrow_forward_ios, color: AppTheme.primaryColor, size: 16),
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
