import 'package:chat_with_aks/controllers/auth_controller.dart';
import 'package:chat_with_aks/models/user_model.dart';
import 'package:chat_with_aks/routes/app_routes.dart';
import 'package:chat_with_aks/services/firestore_service.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';

class ProfileController extends GetxController {
  
  final FirestoreService _firestoreService = FirestoreService();
  final AuthController _authController = Get.find<AuthController>();

  late TextEditingController _displayNameController;
  bool _displayNameDisposed = false;

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

  @override
  void onInit() {
    super.onInit();
    _displayNameController = TextEditingController();
    _loadUserData();
  }
  @override
  void onClose() {
    _displayNameController.dispose();
    _displayNameDisposed = true;
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
      }
    } else {
      // Exiting edit mode - reset to original values
      final user = _currentUser.value;
      if (user != null) {
        displayNameController.text = user.displayName;
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
        displayName: displayNameController.text,
      );

      await _firestoreService.updateUser(updatedUser);
      _isEditing.value = false;
      Get.snackbar('Success',"Profile updated successfully");

    }catch(e){
      _error.value = e.toString();
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

      final storageRef = FirebaseStorage.instance.ref().child('user_photos').child('${user.id}.jpg');
      final uploadTask = storageRef.putData(await file.readAsBytes());
      final snapshot = await uploadTask;
      final url = await snapshot.ref.getDownloadURL();

      final updatedUser = user.copyWith(photoURL: url);
      await _firestoreService.updateUser(updatedUser);
      Get.snackbar('Success', 'Profile photo updated');
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