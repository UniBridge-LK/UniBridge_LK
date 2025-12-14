import 'package:flutter/material.dart';
import 'package:chat_with_aks/theme/app_theme.dart';
import 'package:chat_with_aks/models/people_data.dart';
import 'package:get/get.dart';

class UserProfileView extends StatelessWidget {
  final PersonData person;

  const UserProfileView({super.key, required this.person});

  @override
  Widget build(BuildContext context) {
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
                          person.photoUrl != null
                              ? ClipOval(
                                  child: Image.network(
                                    person.photoUrl!,
                                    width: 96,
                                    height: 96,
                                    fit: BoxFit.cover,
                                  ),
                                )
                              : CircleAvatar(
                                  radius: 48,
                                  backgroundColor: Color(int.parse('0xFF${person.avatarColor}')),
                                  child: Text(
                                    person.avatarLetter,
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
                            person.name,
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          SizedBox(height: 6),
                          // Profile Headline
                          Text(
                            person.profileHeadline,
                            style: TextStyle(color: Colors.grey[600]),
                            textAlign: TextAlign.center,
                          ),
                        ],
                      ),
                    ),
                  ),
                  SizedBox(height: 16),

                  // About section
                  Card(
                    elevation: 2,
                    child: Padding(
                      padding: EdgeInsets.all(16),
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
                            person.about,
                            style: TextStyle(
                              color: Colors.grey[700],
                              height: 1.5,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  SizedBox(height: 16),

                  // User Details card
                  Card(
                    elevation: 2,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Padding(
                          padding: EdgeInsets.all(16),
                          child: Text(
                            person.userType == 'student'
                                ? 'Student Details'
                                : person.userType == 'staff'
                                    ? 'Academic Staff Details'
                                    : 'Details',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                        Divider(height: 1),
                        ListTile(
                          leading: Icon(Icons.school, color: AppTheme.primaryColor),
                          title: Text(
                            'University',
                            style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                          ),
                          subtitle: Text(
                            person.university,
                            style: TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.w600,
                              color: Colors.black87,
                            ),
                          ),
                        ),
                        if (person.faculty != null) ...[
                          Divider(height: 1),
                          ListTile(
                            leading: Icon(Icons.business, color: AppTheme.primaryColor),
                            title: Text(
                              'Faculty',
                              style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                            ),
                            subtitle: Text(
                              person.faculty!,
                              style: TextStyle(
                                fontSize: 15,
                                fontWeight: FontWeight.w600,
                                color: Colors.black87,
                              ),
                            ),
                          ),
                        ],
                        if (person.department != null) ...[
                          Divider(height: 1),
                          ListTile(
                            leading: Icon(Icons.book, color: AppTheme.primaryColor),
                            title: Text(
                              'Department',
                              style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                            ),
                            subtitle: Text(
                              person.department!,
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
