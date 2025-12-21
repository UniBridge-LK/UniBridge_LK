import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:get/get.dart';
import 'package:chat_with_aks/models/user_model.dart';

class PeopleController extends GetxController {
  final RxList<UserModel> _users = <UserModel>[].obs;
  final RxBool _isLoading = false.obs;
  final RxString _error = ''.obs;

  List<UserModel> get users => _users;
  bool get isLoading => _isLoading.value;
  String get error => _error.value;

  @override
  void onInit() {
    super.onInit();
    _loadUsers();
  }

  void _loadUsers() {
    try {
      _isLoading.value = true;
      _error.value = '';
      update(); // Notify GetBuilder
      
      final currentUserId = FirebaseAuth.instance.currentUser?.uid;
      debugPrint('Loading users, current user ID: $currentUserId');
      
      if (currentUserId == null) {
        _error.value = 'User not authenticated';
        _isLoading.value = false;
        update();
        return;
      }
      
      // Bind stream to get real-time updates from Firestore
      _users.bindStream(
        FirebaseFirestore.instance
            .collection('users')
            .snapshots()
            .map((snapshot) {
          debugPrint('Received ${snapshot.docs.length} users from Firestore');
          
          final allUsers = snapshot.docs
              .map((doc) {
                try {
                  return UserModel.fromMap(doc.data());
                } catch (e) {
                  debugPrint('Error parsing user ${doc.id}: $e');
                  return null;
                }
              })
              .whereType<UserModel>()
              .toList();
          
          debugPrint('Parsed ${allUsers.length} users successfully');
          
          final filteredUsers = allUsers.where((user) {
            final isCurrentUser = user.id == currentUserId;
            
            debugPrint('User ${user.displayName}: id=${user.id}, isCurrent=$isCurrentUser');
            
            // Show all users except current user and admin
            return !isCurrentUser && user.role != 'admin';
          }).toList();
          
          debugPrint('Filtered to ${filteredUsers.length} users');
          
          // Set loading to false after first data arrives
          if (_isLoading.value) {
            _isLoading.value = false;
            update(); // Notify GetBuilder
          }
          
          return filteredUsers;
        }),
      );
    } catch (e) {
      _error.value = e.toString();
      _isLoading.value = false;
      update(); // Notify GetBuilder
      debugPrint('Error loading users: $e');
    }
  }

  void refreshUsers() {
    _loadUsers();
  }

  String getAvatarLetter(String name) {
    return name.isNotEmpty ? name[0].toUpperCase() : 'U';
  }

  String getAvatarColor(int index) {
    // Cycle through colors
    final colors = [
      'E8D5F5', // Light purple
      'D5E0F5', // Light blue
      'F5D5E8', // Light pink
      'D5F5E8', // Light green
      'F5E8D5', // Light yellow
      'FFE5E5', // Light red
      'E5F5FF', // Light cyan
      'FFF5E5', // Light orange
    ];
    return colors[index % colors.length];
  }

  String getProfileHeadline(UserModel user) {
    if (user.accountType == 'organization') {
      return user.organizationName;
    }
    return '${user.universityName} | ${user.department}';
  }
}
