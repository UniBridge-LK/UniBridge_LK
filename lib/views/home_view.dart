import 'package:chat_with_aks/controllers/home_controller.dart';
import 'package:chat_with_aks/theme/app_theme.dart';
import 'package:chat_with_aks/routes/app_routes.dart';
import 'package:chat_with_aks/models/university_model.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class HomeView extends GetView<HomeController> {
  const HomeView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.white,
        title: Row(
          children: [
            Icon(Icons.electric_bolt, color: AppTheme.primaryColor, size: 28),
            SizedBox(width: 8),
            Text(
              'UniBridge LK',
              style: TextStyle(
                color: AppTheme.primaryColor,
                fontSize: 22,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.notifications_outlined, color: Colors.grey[800]),
            onPressed: () {},
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Forum Card (Top)
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 24, vertical: 16),
              child: Container(
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
                        Text('Global Forum', style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold)),
                      ],
                    ),
                    SizedBox(height: 12),
                    Text(
                      'Discuss degrees, career paths, and questions common to all universities.',
                      style: TextStyle(color: Colors.white, fontSize: 14, height: 1.4),
                    ),
                    SizedBox(height: 16),
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.white,
                        foregroundColor: AppTheme.primaryColor,
                        padding: EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                      ),
                      onPressed: (){
                        Get.toNamed(AppRoutes.forum, arguments: {'type': 'global'});
                      },
                      child: Text('View Global Threads', style: TextStyle(fontWeight: FontWeight.w600)),
                    )
                  ],
                ),
              ),
            ),

            // Browse Universities Header
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 24, vertical: 8),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Browse Universities',
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: AppTheme.primaryColor,
                    ),
                  ),
                  SizedBox(height: 8),
                  Text(
                    'Find threads related to specific Universities, Faculties, and Departments.',
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey[700],
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(height: 8),

            // Universities List
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 24),
              child: Obx(() {
                if (controller.isLoading) {
                  return Center(child: Padding(padding: EdgeInsets.symmetric(vertical: 24), child: CircularProgressIndicator()));
                }
                if (controller.error.isNotEmpty) {
                  return Padding(
                    padding: EdgeInsets.symmetric(vertical: 24),
                    child: Column(children: [
                      Icon(Icons.error_outline, color: Colors.red),
                      SizedBox(height: 8),
                      Text(controller.error),
                    ]),
                  );
                }

                final items = controller.universities;
                if (items.isEmpty) {
                  return Padding(
                    padding: EdgeInsets.symmetric(vertical: 24),
                    child: Text('No universities available', style: TextStyle(color: Colors.grey[700])),
                  );
                }

                return Column(
                  children: List.generate(
                    items.length,
                    (index) {
                      final UniversityModel uni = items[index];
                      return Padding(
                        padding: EdgeInsets.only(bottom: 12),
                        child: GestureDetector(
                          onTap: () => controller.openUniversity(uni),
                          child: Container(
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(12),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.grey.withAlpha(26),
                                blurRadius: 8,
                                offset: Offset(0, 2),
                              ),
                            ],
                          ),
                          padding: EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                          child: Row(
                            children: [
                              Container(
                                padding: EdgeInsets.all(12),
                                decoration: BoxDecoration(
                                  color: Colors.grey[100],
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Icon(
                                  Icons.account_balance,
                                  color: Colors.grey[600],
                                  size: 24,
                                ),
                              ),
                              SizedBox(width: 16),
                              Expanded(
                                child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                                  Text(
                                    uni.name,
                                    style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w600,
                                      color: Colors.black87,
                                    ),
                                  ),
                                  SizedBox(height:4),
                                  Text('Tap to view faculties', style: TextStyle(color: Colors.grey[600], fontSize: 12)),
                                ]),
                              ),
                              Icon(
                                Icons.chevron_right,
                                color: Colors.grey[400],
                                size: 28,
                              ),
                            ],
                          ),
                          ),
                        ),
                      );
                    },
                  ),
                );
              }),
            ),
            
            SizedBox(height: 24),
          ],
        ),
      ),
    );
  }
}
