
import 'package:chat_with_aks/controllers/profile_controller.dart';
import 'package:chat_with_aks/theme/app_theme.dart';
import 'package:flutter/material.dart';
import 'package:chat_with_aks/views/settings_view.dart';
import 'package:get/get.dart';

class ProfileView extends StatelessWidget {
  ProfileView({super.key});

  @override
  Widget build(BuildContext context) {
    // Register or find the ProfileController instance and use it locally.
    final ProfileController controller = Get.put(ProfileController());
    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      body: Obx((){
        final user = controller.currentUser;
        if (user == null) return Center(child: CircularProgressIndicator(color: AppTheme.primaryColor));

        return Column(
          children: [
            // AppBar with settings
            Container(
              width: double.infinity,
              color: Colors.white,
              padding: EdgeInsets.only(top: MediaQuery.of(context).padding.top + 8, left: 16, right: 16, bottom: 8),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('My Profile', style: TextStyle(fontSize:20, fontWeight: FontWeight.w600, color: Colors.black87)),
                  Row(
                    children: [
                      IconButton(
                        onPressed: () {
                          Get.snackbar(
                            'Edit Profile',
                            'Edit profile feature (mock)',
                            snackPosition: SnackPosition.BOTTOM,
                          );
                        },
                        icon: Icon(Icons.edit, color: AppTheme.primaryColor),
                      ),
                      IconButton(
                        onPressed: () => Get.to(() => const SettingsView()),
                        icon: Icon(Icons.settings, color: AppTheme.primaryColor),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            // Content
            Expanded(
              child: SingleChildScrollView(
                child: Column(
                  children: [
                    // Profile card - centered with proper padding
                    Container(
                      width: double.infinity,
                      margin: EdgeInsets.all(16),
                      child: Card(
                        elevation: 2,
                        child: Padding(
                          padding: EdgeInsets.symmetric(vertical: 32, horizontal: 24),
                          child: Column(
                            children: [
                              // Profile photo with camera icon
                              Stack(
                                children: [
                                  user.photoURL.isNotEmpty
                                      ? ClipOval(
                                          child: Image.network(
                                            user.photoURL,
                                            width: 100,
                                            height: 100,
                                            fit: BoxFit.cover,
                                          ),
                                        )
                                      : CircleAvatar(
                                          radius: 50,
                                          backgroundColor: Colors.indigo.shade100,
                                          child: Text(
                                            user.displayName.isNotEmpty ? user.displayName[0].toUpperCase() : 'U',
                                            style: TextStyle(
                                              fontSize: 40,
                                              color: Colors.indigo,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                        ),
                                  Positioned(
                                    bottom: 0,
                                    right: 0,
                                    child: InkWell(
                                      onTap: controller.uploadPhoto,
                                      child: Container(
                                        padding: EdgeInsets.all(8),
                                        decoration: BoxDecoration(
                                          color: Colors.white,
                                          shape: BoxShape.circle,
                                          boxShadow: [
                                            BoxShadow(
                                              color: Colors.black26,
                                              blurRadius: 4,
                                            ),
                                          ],
                                        ),
                                        child: Icon(Icons.camera_alt, size: 18, color: Colors.grey[700]),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              SizedBox(height: 20),
                              // Name
                              Text(
                                user.displayName,
                                style: TextStyle(
                                  fontSize: 22,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              SizedBox(height: 8),
                              // Profile Headline (university | role)
                              Text(
                                'UoM',
                                style: TextStyle(
                                  color: Colors.grey[600],
                                  fontSize: 15,
                                ),
                                textAlign: TextAlign.center,
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),

                    // About section - full width
                    Container(
                      width: double.infinity,
                      margin: EdgeInsets.symmetric(horizontal: 16),
                      child: Card(
                        elevation: 2,
                        child: Padding(
                          padding: EdgeInsets.all(20),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'About',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                              SizedBox(height: 12),
                              Text(
                                user.bio ?? 'No bio provided yet.',
                                style: TextStyle(
                                  color: Colors.grey[700],
                                  height: 1.5,
                                  fontSize: 14,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                    SizedBox(height: 16),

                    // User Details card - full width
                    Container(
                      width: double.infinity,
                      margin: EdgeInsets.symmetric(horizontal: 16),
                      child: Card(
                        elevation: 2,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Padding(
                              padding: EdgeInsets.all(20),
                              child: Text(
                                'Student Details',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ),
                            Divider(height: 1),
                            ListTile(
                              contentPadding: EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                              leading: Icon(Icons.school, color: AppTheme.primaryColor, size: 24),
                              title: Text(
                                'University',
                                style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                              ),
                              subtitle: Padding(
                                padding: EdgeInsets.only(top: 4),
                                child: Text(
                                  'UoM',
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w600,
                                    color: Colors.black87,
                                  ),
                                ),
                              ),
                            ),
                            Divider(height: 1),
                            ListTile(
                              contentPadding: EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                              leading: Icon(Icons.business, color: AppTheme.primaryColor, size: 24),
                              title: Text(
                                'Faculty',
                                style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                              ),
                              subtitle: Padding(
                                padding: EdgeInsets.only(top: 4),
                                child: Text(
                                  'Faculty of Computing',
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w600,
                                    color: Colors.black87,
                                  ),
                                ),
                              ),
                            ),
                            Divider(height: 1),
                            ListTile(
                              contentPadding: EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                              leading: Icon(Icons.book, color: AppTheme.primaryColor, size: 24),
                              title: Text(
                                'Department',
                                style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                              ),
                              subtitle: Padding(
                                padding: EdgeInsets.only(top: 4),
                                child: Text(
                                  'CSE',
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w600,
                                    color: Colors.black87,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    SizedBox(height: 32),
                    // Sign Out button
                    TextButton.icon(
                      onPressed: controller.signOut,
                      icon: Icon(Icons.logout, color: Colors.red),
                      label: Text('Sign Out', style: TextStyle(color: Colors.red)),
                    ),
                    SizedBox(height: 24),
                  ],
                ),
              ),
            )
          ],
        );
      }),
    );
  }

}