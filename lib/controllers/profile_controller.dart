import 'dart:core';
import 'dart:io';

import 'package:chat_with_aks/controllers/auth_controller.dart';
import 'package:chat_with_aks/models/user_model.dart';
import 'package:chat_with_aks/routes/app_routes.dart';
import 'package:chat_with_aks/services/firestore_service.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:firebase_core/firebase_core.dart' show Firebase;
import 'package:chat_with_aks/firebase_options.dart';

class ProfileController extends GetxController {
  
  final FirestoreService _firestoreService = FirestoreService();
  final AuthController _authController = Get.find<AuthController>();

  late TextEditingController _displayNameController;
  late TextEditingController _bioController;
  bool _displayNameDisposed = false;
  bool _bioDisposed = false;

  final RxBool _isLoading = false.obs;
  final RxBool _isEditing = false.obs;
  final RxString _error = ''.obs;
  final Rx<UserModel?> _currentUser = Rx<UserModel?>(null);

  bool get isLoading => _isLoading.value;
  bool get isEditing => _isEditing.value;
  String get error => _error.value;
  UserModel? get currentUser => _currentUser.value;
  TextEditingController get displayNameController {
    if (_displayNameDisposed) {
      _displayNameController = TextEditingController(text: _currentUser.value?.displayName ?? '');
      _displayNameDisposed = false;
    }
    return _displayNameController;
  }
  TextEditingController get bioController {
    if (_bioDisposed) {
      _bioController = TextEditingController(text: _currentUser.value?.bio ?? '');
      _bioDisposed = false;
    }
    return _bioController;
  }

  @override
  void onInit() {
    super.onInit();
    _displayNameController = TextEditingController();
    _bioController = TextEditingController();
    _loadUserData();
  }
  @override
  void onClose() {
    _displayNameController.dispose();
    _displayNameDisposed = true;
    _bioController.dispose();
    _bioDisposed = true;
    super.onClose();
  } 

  void _loadUserData(){
    final currentUserId = _authController.user?.uid;
    if (currentUserId != null) {
      _currentUser.bindStream(_firestoreService.getUserStream(currentUserId));
    } else {
      // If no user ID, try again after a short delay
      Future.delayed(Duration(milliseconds: 500), () {
        final retryUserId = _authController.user?.uid;
        if (retryUserId != null) {
          _currentUser.bindStream(_firestoreService.getUserStream(retryUserId));
        } else {
          Get.snackbar('Error', 'User not authenticated');
          Get.offAllNamed(AppRoutes.login);
        }
      });
    }      
  }

  void toggleEditing() {
    if (!_isEditing.value) {
      // Entering edit mode - initialize controller with current user data
      final user = _currentUser.value;
      if (user != null) {
        displayNameController.text = user.displayName;
        bioController.text = user.bio ?? '';
      }
    } else {
      // Exiting edit mode - reset to original values
      final user = _currentUser.value;
      if (user != null) {
        displayNameController.text = user.displayName;
        bioController.text = user.bio ?? '';
      }
    }
    _isEditing.value = !_isEditing.value;
    _error.value = '';
  }

  Future<void> updateProfile() async{
    try{
      _isLoading.value = true;
      _error.value = '';

      final user = _currentUser.value;
      if(user==null) return;

      final updatedUser = user.copyWith(
        displayName: displayNameController.text.trim().isNotEmpty
            ? displayNameController.text.trim()
            : user.displayName,
        bio: bioController.text.trim(),
      );

      await _firestoreService.UpdateUser(updatedUser);
      _isEditing.value = false;
      Get.snackbar('Success',"Profile updated successfully");

    }catch(e){
      _error.value = e.toString();
      print(e.toString());
      debugPrint(e.toString());
      Get.snackbar('Error',"Failed to update profile");
    } finally{
      _isLoading.value = false;
    }
  }

  Future<void> signOut() async {
    try{
      await _authController.signOut();      
    } catch (e) {
      Get.snackbar('Error', 'Failed to sign out');
    }
  }

  Future<void> uploadPhoto() async {
    try {
      final picker = ImagePicker();
      final XFile? file = await picker.pickImage(source: ImageSource.gallery, maxWidth: 1024, maxHeight: 1024);
      if (file == null) return;
      _isLoading.value = true;

      final user = _currentUser.value;
      if (user == null) {
        Get.snackbar('Error', 'No user loaded');
        return;
      }

        final storage = FirebaseStorage.instanceFor(
          app: Firebase.app(),
          bucket: DefaultFirebaseOptions.android.storageBucket,
        );

        // Reduce long-running resumable session retries that can mask 404s
        storage.setMaxUploadRetryTime(const Duration(seconds: 12));
        storage.setMaxOperationRetryTime(const Duration(seconds: 12));

      final storageRef = storage
          .ref()
          .child('user_photos')
          .child(user.id)
          .child('${DateTime.now().millisecondsSinceEpoch}.jpg');

      try {
        final TaskSnapshot snapshot = await storageRef.putFile(
          File(file.path),
          SettableMetadata(contentType: 'image/jpeg'),
        );
        final String url = await snapshot.ref.getDownloadURL();

        final updatedUser = user.copyWith(photoURL: url);
        await _firestoreService.UpdateUser(updatedUser);
        Get.snackbar('Success', 'Profile photo updated');
      } on FirebaseException catch (fe) {
        debugPrint('FirebaseException during upload: code=${fe.code} message=${fe.message}');
        Get.snackbar('Upload Error', 'Storage error: ${fe.code}');
      }
    } catch (e) {
      Get.snackbar('Error', 'Failed to upload photo');
    } finally {
      _isLoading.value = false;
    }
  }

  Future<void> deleteAccount() async {
    try{
      final result = await Get.dialog<bool>(
        AlertDialog(
          title: Text('Delete Account'),
          content: Text('Are you sure you want to delete your account? This action cannot be undone.'),
          actions: [
            TextButton(
              onPressed: () => Get.back(result: false),
              child: Text('Cancel'),
            ),
            TextButton(
              onPressed: () => Get.back(result: true),
              child: Text('Delete', style: TextStyle(color: Colors.red)),
            ),
          ],
        ),
      );

      if (result == true) {
        _isLoading.value = true;
        await _authController.deleteAccount();
      }

      Get.snackbar('Success', 'Account deleted successfully');      
    } catch (e) {
      Get.snackbar('Error', 'Failed to delete account');
    } finally {
      _isLoading.value = false;
    }
  }

  String getJoinedDate() {
    final user = _currentUser.value;
    if (user == null) return '';
    final date = user.createdAt;
    final months =[
      'January', 'February', 'March', 'April', 'May', 'June',
      'July', 'August', 'September', 'October', 'November', 'December'
    ];
    return 'Joined ${months[date.month - 1]} ${date.year}';
  }

  void clearError() {
    _error.value = '';
  }
}