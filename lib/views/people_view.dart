import 'package:flutter/material.dart';
import 'package:chat_with_aks/theme/app_theme.dart';
import 'package:chat_with_aks/routes/app_routes.dart';
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
  final RxBool _refreshTrigger = false.obs;

  bool isPremiumUser() {
    // TODO: Set to false to enable premium check, true to bypass for testing
    return true; // Bypassed for chat testing
    // final email = auth.userModel?.email ?? '';
    // return email.toLowerCase().contains('premium');
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

  Widget _buildPersonCard(UserModel person, int index, PeopleController controller) {
    final currentUserId = auth.user?.uid;
    if (currentUserId == null) return SizedBox.shrink();

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
                backgroundColor: Color(int.parse('0xFF${controller.getAvatarColor(index)}')),
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
              // Dynamic button based on connection status
              Obx(() {
                // Rebuild when refresh is triggered
                _refreshTrigger.value; // access to rebuild
                return StreamBuilder<String>(
                  stream: _fs.getConnectionStatusStream(currentUserId, person.id),
                  builder: (context, snapshot) {
                    final status = snapshot.data ?? 'none';
                  
                  if (status == 'connected') {
                    // Show Connected button for connected users
                    return ElevatedButton.icon(
                      onPressed: () {
                        // Navigate to Main with Chats bottom tab selected
                        Get.toNamed(AppRoutes.main, arguments: {'bottomIndex': 2, 'chatsTab': 0});
                      },
                      label: Text('Connected', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600)),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.green,
                        foregroundColor: Colors.white,
                        padding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                        minimumSize: Size(0, 32),
                        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                    );
                  } else if (status == 'pending_sent') {
                    // Show Request Sent label (disabled)
                    return Container(
                      padding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                      decoration: BoxDecoration(
                        color: Colors.grey.shade100,
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: Colors.grey.shade300),
                      ),
                      child: Text(
                        'Request Sent',
                        style: TextStyle(
                          color: Colors.grey.shade600,
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    );
                  } else if (status == 'pending_received') {
                    // Show Pending Request label with tap to go to Requests tab
                    return GestureDetector(
                      onTap: () {
                        // Navigate to Main with Chats bottom tab and Requests inner tab
                        // Get.toNamed(AppRoutes.chat, arguments: {'bottomIndex': 2, 'chatsTab': 1});
                      },
                      child: Container(
                        padding: EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                        decoration: BoxDecoration(
                          color: AppTheme.primaryColor.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: AppTheme.primaryColor),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            SizedBox(width: 4),
                            Text(
                              'Pending Request',
                              style: TextStyle(
                                color: AppTheme.primaryColor,
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  } else {
                    // Show Connect button for no connection
                    return OutlinedButton(
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
                        padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      child: Text('Connect'),
                    );
                  }
                },
              );
              }),
            ],
          ),
        ),
      ),
    );
  }

  void _showConnectDialog(UserModel person) async {
    final currentUserId = auth.user?.uid;
    if (currentUserId == null) {
      Get.snackbar('Error', 'Sign in required');
      return;
    }

    // Validation: Prevent self-connection
    if (currentUserId == person.id) {
      Get.snackbar('Error', 'You cannot connect with yourself');
      return;
    }

    // Validation: Check if already connected or request exists
    final status = await _fs.getConnectionStatus(currentUserId, person.id);
    if (status == 'connected') {
      Get.snackbar('Already Connected', 'You are already connected with ${person.displayName}');
      return;
    }
    if (status == 'pending_sent') {
      Get.snackbar('Request Pending', 'You have already sent a request to ${person.displayName}');
      return;
    }
    if (status == 'pending_received') {
      Get.snackbar('Request Pending', '${person.displayName} has already sent you a request. Check your Requests tab.');
      return;
    }

    // Validation: Check if blocked
    final isBlocked = await _fs.isUserBlocked(currentUserId, person.id);
    if (isBlocked) {
      Get.snackbar('Error', 'Cannot connect with this user');
      return;
    }

    final noteController = TextEditingController();
    final charCount = 0.obs;
    const maxChars = 250;

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
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('Add a note (Optional)', style: TextStyle(fontSize: 14, color: Colors.grey[700])),
                  Obx(() => Text(
                    '${charCount.value}/$maxChars',
                    style: TextStyle(
                      fontSize: 12,
                      color: charCount.value > maxChars ? Colors.red : Colors.grey[600],
                    ),
                  )),
                ],
              ),
              SizedBox(height: 8),
              TextField(
                controller: noteController,
                maxLines: 3,
                maxLength: maxChars,
                onChanged: (text) => charCount.value = text.length,
                decoration: InputDecoration(
                  hintText: 'Hi, I would like to connect with you...',
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                  contentPadding: EdgeInsets.all(12),
                  counterText: '',
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
                  Obx(() => ElevatedButton(
                    onPressed: charCount.value > maxChars ? null : () async {
                      Get.back();
                      final message = noteController.text.trim();
                      final req = FriendRequestModel(
                        id: uuid.v4(), 
                        senderId: currentUserId, 
                        receiverId: person.id, 
                        createdAt: DateTime.now(),
                        message: message.isNotEmpty ? message : null,
                      );
                      try { 
                        await _fs.sendFriendRequest(req); 
                        // Trigger UI refresh to show updated status immediately
                        _refreshTrigger.value = !_refreshTrigger.value;
                        Get.snackbar(
                          'Success', 
                          'Connection request sent to ${person.displayName}',
                          snackPosition: SnackPosition.BOTTOM,
                        ); 
                      } catch (e) { 
                        Get.snackbar(
                          'Error', 
                          'Failed to send request: ${e.toString()}',
                          snackPosition: SnackPosition.BOTTOM,
                        ); 
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppTheme.primaryColor,
                      disabledBackgroundColor: Colors.grey,
                    ),
                    child: Text('Send Request'),
                  )),
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
                      hintText: 'Search by name, university, faculty, department',
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
                      return _buildPersonCard(person, i, controller);
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
