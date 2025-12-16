import 'package:flutter/material.dart';
import 'package:chat_with_aks/theme/app_theme.dart';
import 'package:chat_with_aks/models/people_data.dart';
import 'package:chat_with_aks/models/user_model.dart';
import 'package:get/get.dart';

class UserProfileView extends StatelessWidget {
  final PersonData? person;

  const UserProfileView({super.key, this.person});

  @override
  Widget build(BuildContext context) {
    // Get the user from arguments if passed
    final UserModel? selectedUser = Get.arguments is UserModel ? Get.arguments as UserModel : null;
    final displayPerson = person;
    
    debugPrint('UserProfileView - selectedUser: ${selectedUser?.displayName}, displayPerson: ${displayPerson?.name}, Get.arguments: ${Get.arguments}');
    
    // If no person/user, show error
    if (displayPerson == null && selectedUser == null) {
      return Scaffold(
        appBar: AppBar(title: Text('Profile')),
        body: Center(child: Text('User not found')),
      );
    }

    // Build display data
    final String displayName = selectedUser?.displayName ?? displayPerson?.name ?? 'User';
    final String? photoUrl = selectedUser?.photoURL ?? displayPerson?.photoUrl;
    final String university = selectedUser?.universityName ?? displayPerson?.university ?? 'N/A';
    final String? faculty = selectedUser?.faculty ?? displayPerson?.faculty;
    final String? department = selectedUser?.department ?? displayPerson?.department;
    final String accountType = selectedUser?.accountType ?? displayPerson?.userType ?? '';
    final String headline = selectedUser?.bio ?? displayPerson?.profileHeadline ?? '';
    final String about = selectedUser?.bio ?? displayPerson?.about ?? '';

    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      body: Column(
        children: [
          // Header with back button and title
          Container(
            width: double.infinity,
            color: Colors.white,
            padding: EdgeInsets.only(
              top: MediaQuery.of(context).padding.top + 8,
              left: 8,
              right: 16,
              bottom: 8,
            ),
            child: Row(
              children: [
                IconButton(
                  onPressed: () => Get.back(),
                  icon: Icon(Icons.arrow_back, color: AppTheme.primaryColor),
                ),
                SizedBox(width: 8),
                Text(
                  'Profile',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w600,
                    color: Colors.black87,
                  ),
                ),
              ],
            ),
          ),

          // Content
          Expanded(
            child: SingleChildScrollView(
              padding: EdgeInsets.all(16),
              child: Column(
                children: [
                  // Profile card
                  Card(
                    elevation: 2,
                    child: Padding(
                      padding: EdgeInsets.all(24),
                      child: Column(
                        children: [
                          // Profile photo
                          photoUrl != null && photoUrl.isNotEmpty
                              ? ClipOval(
                                  child: Image.network(
                                    photoUrl,
                                    width: 96,
                                    height: 96,
                                    fit: BoxFit.cover,
                                    errorBuilder: (context, error, stackTrace) {
                                      return CircleAvatar(
                                        radius: 48,
                                        backgroundColor: Colors.grey[300],
                                        child: Icon(Icons.person, size: 48),
                                      );
                                    },
                                  ),
                                )
                              : CircleAvatar(
                                  radius: 48,
                                  backgroundColor: Color(int.parse(
                                    '0xFF${displayPerson?.avatarColor ?? "E8F5E9"}',
                                  )),
                                  child: Text(
                                    displayName.isNotEmpty ? displayName[0].toUpperCase() : 'U',
                                    style: TextStyle(
                                      fontSize: 36,
                                      color: AppTheme.primaryColor,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                          SizedBox(height: 16),
                          // Name
                          Text(
                            displayName,
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          SizedBox(height: 6),
                          // Profile Headline
                          if (headline.isNotEmpty)
                            Text(
                              headline,
                              style: TextStyle(color: Colors.grey[600]),
                              textAlign: TextAlign.center,
                            ),
                        ],
                      ),
                    ),
                  ),
                  
                  // About section (only if bio is present)
                  if (about.isNotEmpty) ...[
                    SizedBox(height: 16),
                    Card(
                      elevation: 2,
                      child: Padding(
                        padding: EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Bio',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                            SizedBox(height: 12),
                            Text(
                              about,
                              style: TextStyle(
                                color: Colors.grey[700],
                                height: 1.5,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],

                  // User Details card (only if at least one field is present)
                  if ((university.isNotEmpty && university != 'N/A') || 
                      (faculty != null && faculty.isNotEmpty) || 
                      (department != null && department.isNotEmpty) ||
                      (accountType.isNotEmpty)) ...[
                    SizedBox(height: 16),
                    Card(
                      elevation: 2,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Padding(
                            padding: EdgeInsets.all(16),
                            child: Text(
                              'Details',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ),
                          if (accountType.isNotEmpty) ...[
                            Divider(height: 1),
                            ListTile(
                              leading: Icon(Icons.account_circle, color: AppTheme.primaryColor),
                              title: Text(
                                'Account Type',
                                style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                              ),
                              subtitle: Text(
                                accountType == 'individual' ? 'Individual' : accountType == 'organization' ? 'Organization' : accountType,
                                style: TextStyle(
                                  fontSize: 15,
                                  fontWeight: FontWeight.w600,
                                  color: Colors.black87,
                                ),
                              ),
                            ),
                          ],
                          if (university.isNotEmpty && university != 'N/A') ...[
                            Divider(height: 1),
                            ListTile(
                              leading: Icon(Icons.school, color: AppTheme.primaryColor),
                              title: Text(
                                'University',
                                style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                              ),
                              subtitle: Text(
                                university,
                                style: TextStyle(
                                  fontSize: 15,
                                  fontWeight: FontWeight.w600,
                                  color: Colors.black87,
                                ),
                              ),
                            ),
                          ],
                          if (faculty != null && faculty.isNotEmpty) ...[
                            Divider(height: 1),
                            ListTile(
                              leading: Icon(Icons.business, color: AppTheme.primaryColor),
                              title: Text(
                                'Faculty',
                                style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                              ),
                              subtitle: Text(
                                faculty,
                                style: TextStyle(
                                  fontSize: 15,
                                  fontWeight: FontWeight.w600,
                                  color: Colors.black87,
                                ),
                              ),
                            ),
                          ],
                          if (department != null && department.isNotEmpty) ...[
                            Divider(height: 1),
                            ListTile(
                              leading: Icon(Icons.book, color: AppTheme.primaryColor),
                              title: Text(
                                'Department',
                                style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                              ),
                              subtitle: Text(
                                department,
                                style: TextStyle(
                                  fontSize: 15,
                                  fontWeight: FontWeight.w600,
                                  color: Colors.black87,
                                ),
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),
                  ],
                  SizedBox(height: 24),
                ],
              ),
            ),
          )
        ],
      ),
    );
  }
}
