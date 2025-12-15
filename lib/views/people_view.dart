import 'package:flutter/material.dart';
import 'package:chat_with_aks/theme/app_theme.dart';
import 'package:get/get.dart';
import 'package:chat_with_aks/services/firestore_service.dart';
import 'package:chat_with_aks/controllers/auth_controller.dart';
import 'package:chat_with_aks/controllers/people_controller.dart';
import 'package:chat_with_aks/models/friend_request_model.dart';
import 'package:chat_with_aks/models/user_model.dart';
import 'package:uuid/uuid.dart';
import 'package:chat_with_aks/widgets/premium_popup.dart';
import 'package:chat_with_aks/views/user_profile_view.dart';

class PeopleView extends StatefulWidget {
  const PeopleView({super.key});

  @override
  State<PeopleView> createState() => _PeopleViewState();
}

class _PeopleViewState extends State<PeopleView> {
  final FirestoreService _fs = FirestoreService();
  final auth = Get.find<AuthController>();
  final uuid = Uuid();
  String query = '';

  bool isPremiumUser() {
    final email = auth.userModel?.email ?? '';
    return email.toLowerCase().contains('premium');
  }

  List<UserModel> _filter(List<UserModel> list) {
    final q = query.trim().toLowerCase();
    if (q.isEmpty) return list;
    return list.where((user) {
      final name = user.displayName.toLowerCase();
      final university = user.universityName.toLowerCase();
      final faculty = user.faculty.toLowerCase();
      final department = user.department.toLowerCase();
      return name.contains(q) || university.contains(q) || faculty.contains(q) || department.contains(q);
    }).toList();
  }

  void _showConnectDialog(UserModel person) {
    final noteController = TextEditingController();
    Get.dialog(
      Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: Padding(
          padding: EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Connect with ${person.displayName}', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
              SizedBox(height: 16),
              Text('Add a note (Optional)', style: TextStyle(fontSize: 14, color: Colors.grey[700])),
              SizedBox(height: 8),
              TextField(
                controller: noteController,
                maxLines: 3,
                decoration: InputDecoration(
                  hintText: 'Hi, I would like to connect with you...',
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                  contentPadding: EdgeInsets.all(12),
                ),
              ),
              SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton(
                    onPressed: () => Get.back(),
                    child: Text('Cancel'),
                  ),
                  SizedBox(width: 8),
                  ElevatedButton(
                    onPressed: () async {
                      Get.back();
                      if (auth.user?.uid == null) { 
                        Get.snackbar('Error', 'Sign in required'); 
                        return; 
                      }
                      final req = FriendRequestModel(
                        id: uuid.v4(), 
                        senderId: auth.user!.uid, 
                        receiverId: person.id, 
                        createdAt: DateTime.now()
                      );
                      try { 
                        await _fs.sendFriendRequest(req); 
                        Get.snackbar('Success', 'Connection request sent to ${person.displayName}'); 
                      } catch (e) { 
                        Get.snackbar('Error', 'Failed to send request'); 
                      }
                    },
                    style: ElevatedButton.styleFrom(backgroundColor: AppTheme.primaryColor),
                    child: Text('Send Request'),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('People'),
        backgroundColor: Colors.white,
        foregroundColor: AppTheme.primaryColor,
        elevation: 0,
        automaticallyImplyLeading: false,
      ),
      body: Column(
        children: [
          // Sticky search bar
          Container(
            color: Colors.white,
            padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    decoration: InputDecoration(
                      prefixIcon: Icon(Icons.search),
                      hintText: 'Search by name',
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: BorderSide.none),
                      filled: true,
                      fillColor: Colors.grey.shade100,
                      contentPadding: EdgeInsets.symmetric(vertical: 12, horizontal: 12),
                    ),
                    onChanged: (v){ setState((){ query = v; }); },
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: GetBuilder<PeopleController>(
              init: PeopleController(),
              builder: (controller) {
                if (controller.isLoading) {
                  return Center(child: CircularProgressIndicator());
                }

                if (controller.error.isNotEmpty) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.error_outline, size: 48, color: Colors.red),
                        SizedBox(height: 16),
                        Text('Error: ${controller.error}'),
                        SizedBox(height: 16),
                        ElevatedButton(
                          onPressed: controller.refreshUsers,
                          child: Text('Retry'),
                        ),
                      ],
                    ),
                  );
                }

                return Obx(() {
                  final list = controller.users;
                  final filtered = _filter(list);
                  
                  if (filtered.isEmpty) {
                    return Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.people_outline, size: 64, color: Colors.grey),
                          SizedBox(height: 16),
                          Text(
                            query.isEmpty ? 'No users found' : 'No matching users',
                            style: TextStyle(fontSize: 16, color: Colors.grey),
                          ),
                        ],
                      ),
                    );
                  }

                  return ListView.builder(
                    padding: EdgeInsets.all(16),
                    itemCount: filtered.length,
                    itemBuilder: (c, i) {
                      final person = filtered[i];
                      return GestureDetector(
                        onTap: () {
                          Get.to(() => UserProfileView(), arguments: person);
                        },
                        child: Container(
                          margin: EdgeInsets.only(bottom: 16),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(12),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.grey.withAlpha(26),
                                blurRadius: 6,
                                offset: Offset(0, 2),
                              ),
                            ],
                          ),
                          child: Padding(
                            padding: EdgeInsets.all(16),
                            child: Row(
                              children: [
                                // Avatar
                                CircleAvatar(
                                  radius: 28,
                                  backgroundColor: Color(int.parse('0xFF${controller.getAvatarColor(i)}')),
                                  backgroundImage: person.photoURL.isNotEmpty 
                                      ? NetworkImage(person.photoURL)
                                      : null,
                                  child: person.photoURL.isEmpty
                                      ? Text(
                                          controller.getAvatarLetter(person.displayName),
                                          style: TextStyle(
                                            color: AppTheme.primaryColor,
                                            fontSize: 24,
                                            fontWeight: FontWeight.w600,
                                          ),
                                        )
                                      : null,
                                ),
                                SizedBox(width: 16),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        person.displayName,
                                        style: TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.w700,
                                          color: Colors.black87,
                                        ),
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                      SizedBox(height: 4),                                      
                                    ],
                                  ),
                                ),
                              SizedBox(width: 12),
                              OutlinedButton(
                                onPressed: () {
                                  if (!isPremiumUser()) {
                                    Get.dialog(const PremiumPopup());
                                    return;
                                  }
                                  _showConnectDialog(person);
                                },
                                style: OutlinedButton.styleFrom(
                                  foregroundColor: AppTheme.primaryColor,
                                  side: BorderSide(color: Colors.grey.shade300),
                                  padding: EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                ),
                                child: Text('Connect'),
                              ),
                            ],
                          ),
                          ),
                        ),
                      );
                    },
                  );
                });
              },
            ),
          )
        ],
      ),
    );
  }
}
