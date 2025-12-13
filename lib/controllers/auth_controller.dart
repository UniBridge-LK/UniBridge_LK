import 'package:chat_with_aks/models/user_model.dart';
import 'package:chat_with_aks/services/firestore_service.dart';
import 'package:chat_with_aks/routes/app_routes.dart';
import 'package:chat_with_aks/services/auth_service.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:chat_with_aks/services/otp_service.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:get/get.dart';

class AuthController extends GetxController {
  final AuthService _authService = AuthService();
  final FirestoreService _firestoreService = FirestoreService();
  final Rx<User?> _user = Rx<User?>(null);
  final Rx<UserModel?> _userModel = Rx<UserModel?>(null);
  final RxBool _isLoading = false.obs;
  final RxString _error = ''.obs;
  final RxBool _isinitialized = false.obs;
  User? get user => _user.value;
  UserModel? get userModel => _userModel.value;
  bool get isLoading => _isLoading.value;
  String get error => _error.value;
  bool get isAuthenticated => _user.value != null;
  bool get isInitialized => _isinitialized.value;

  @override
  void onInit() {
    super.onInit();
    _user.bindStream(_authService.authStateChanges);
    ever(_user, _handleAuthStateChange);
  }

  void _handleAuthStateChange(User? user) async {
  print('Firebase Auth State Changed. User is: ${user == null ? "NULL" : (user.emailVerified ? "PRESENT (Verified)" : "PRESENT (Unverified)")}');
  if (user == null) {
    if (Get.currentRoute != AppRoutes.login) {
      Get.offAllNamed(AppRoutes.login);
    }
  } else {
    // Prefer Firestore profile flag for email verification via OTP
    final model = await _firestoreService.getUser(user.uid);
    _userModel.value = model;
    final verified = model?.isEmailVerified ?? false;
    if (verified) {
      if (Get.currentRoute != AppRoutes.profile) {
        Get.offAllNamed(AppRoutes.profile);
      }
    } else {
      if (Get.currentRoute != AppRoutes.verifyOtp) {
        Get.offAllNamed(AppRoutes.verifyOtp);
      }
    }
  }
  if (!_isinitialized.value) _isinitialized.value = true;
  }

  void checkInitialAuthState(){
    final currentUser = FirebaseAuth.instance.currentUser;
    if(currentUser != null){
      _user.value = currentUser;
      Get.offAllNamed(AppRoutes.profile);
    }else{
      Get.offAllNamed(AppRoutes.login);
    }
    _isinitialized.value = true;
  }

  Future<void> signInWithEmailAndPassword(String email, String password) async {
    try {
      _isLoading.value = true;
      _error.value = '';
      UserModel? userModel = await _authService.signInWithEmailAndPassword(email, password);
      if (userModel != null) {
        _userModel.value = userModel;
        Get.offAllNamed(AppRoutes.profile);
      }
    } catch (e) {
      _error.value = e.toString();
      Get.snackbar('Error', 'Failed to Login');
      print(e);
    } finally {
      _isLoading.value = false;
    }
  }

  Future<void> registerWithEmailAndPassword(
    String email,
    String password,
    String displayName, {
    required String accountType,
    String universityName = '',
    String faculty = '',
    String department = '',
    String organizationName = '',
  }) async {
    try {
      _isLoading.value = true;
      _error.value = '';
      UserModel? userModel = await _authService.registerWithEmailAndPassword(
        email,
        password,
        displayName,
        accountType: accountType,
        universityName: universityName,
        faculty: faculty,
        department: department,
        organizationName: organizationName,
      );
      if (userModel != null) {
        _userModel.value = userModel;
        // Send OTP to email and navigate to OTP screen
        final user = FirebaseAuth.instance.currentUser;
        if (user != null) {
          try {
            await OtpService().sendEmailOtp(userId: user.uid, email: user.email ?? email);
          } catch (_) {}
        }
        Get.offAllNamed(AppRoutes.verifyOtp);
      }
    } on FirebaseAuthException catch (e) {
      _error.value = e.code;
      String errorMessage = _getErrorMessage(e.code);
      Get.snackbar('Error', errorMessage);
      print('Firebase Auth Error: ${e.code} - ${e.message}');
    } catch (e) {
      _error.value = e.toString();
      Get.snackbar('Error', 'Failed to Register');
      print(e);
    } finally {
      _isLoading.value = false;
    }
  }

  Future<void> signOut() async {
    try {
      _isLoading.value = true;
      await _authService.signOut();
      _userModel.value = null;
      Get.offAllNamed(AppRoutes.login);
    } catch (e) {
      _error.value = e.toString();
      Get.snackbar('Error', 'Failed to Sign Out');
      print(e);
    } finally {
      _isLoading.value = false;
    }
  }

  Future<void> deleteAccount() async {
    try {
      _isLoading.value = true;
      await _authService.deleteAccount();
      _userModel.value = null;
      Get.offAllNamed(AppRoutes.login);
    } catch (e) {
      _error.value = e.toString();
      Get.snackbar('Error', 'Failed to Delete Account');
      print(e);
    } finally {
      _isLoading.value = false;
    }
  }

  Future clearError() async {
    _error.value = '';
  }

  String _getErrorMessage(String errorCode) {
    switch (errorCode) {
      case 'email-already-in-use':
        return 'This email is already in use. Please try logging in or use a different email.';
      case 'invalid-email':
        return 'The email address is invalid.';
      case 'weak-password':
        return 'The password is too weak. Please use a stronger password.';
      case 'user-disabled':
        return 'This user account has been disabled.';
      case 'user-not-found':
        return 'No account found with this email.';
      case 'wrong-password':
        return 'The password is incorrect.';
      case 'operation-not-allowed':
        return 'Email/password registration is not enabled.';
      case 'too-many-requests':
        return 'Too many failed login attempts. Please try again later.';
      default:
        return 'An error occurred. Please try again.';
    }
  }

}

