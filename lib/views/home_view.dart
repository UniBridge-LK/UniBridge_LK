import 'package:chat_with_aks/controllers/home_controller.dart';
import 'package:chat_with_aks/controllers/main_controller.dart';
import 'package:chat_with_aks/theme/app_theme.dart';
import 'package:chat_with_aks/routes/app_routes.dart';
import 'package:chat_with_aks/models/mock_data.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class HomeView extends GetView<HomeController> {
  const HomeView({super.key});

  @override
  Widget build(BuildContext context) {
    final mainController = Get.find<MainController>();
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
                padding: EdgeInsets.all(16),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                        Text('Global Forum', style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
                        SizedBox(height: 8),
                        Text('View global discussions and join threads across universities', style: TextStyle(color: Colors.white70)),
                      ]),
                    ),
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(backgroundColor: Colors.white, foregroundColor: AppTheme.primaryColor),
                      onPressed: (){
                        // switch to forum tab
                        mainController.setIndex(2);
                        // ensure main route
                        if(Get.currentRoute != AppRoutes.main) Get.offAllNamed(AppRoutes.main);
                      },
                      child: Text('View Global Threads'),
                    )
                  ],
                ),
              ),
            ),

            // Header
            Container(
              padding: EdgeInsets.symmetric(horizontal: 24, vertical: 6),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Home - Directory',
                    style: TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      color: AppTheme.primaryColor,
                    ),
                  ),
                  SizedBox(height: 12),
                  Text(
                    'Browse Universities',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                  ),
                ],
              ),
            ),

            // Universities List
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 24),
              child: Column(
                children: List.generate(
                  controller.universityNames.length,
                  (index) {
                    final name = controller.universityNames[index];
                    final faculties = universityStructure[name] ?? {};
                    return Padding(
                      padding: EdgeInsets.only(bottom: 12),
                      child: GestureDetector(
                        onTap: () => controller.openUniversity(name),
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
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Expanded(
                                child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                                  Text(
                                    name,
                                    style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w600,
                                      color: Colors.black87,
                                    ),
                                  ),
                                  SizedBox(height:4),
                                  Text('${faculties.length} faculties', style: TextStyle(color: Colors.grey[600], fontSize: 12)),
                                ]),
                              ),
                              Icon(
                                Icons.arrow_forward_ios,
                                color: AppTheme.primaryColor,
                                size: 20,
                              ),
                            ],
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),
            ),
            SizedBox(height: 24),
          ],
        ),
      ),
    );
  }
}
