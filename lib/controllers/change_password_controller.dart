import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class ChangePasswordController  extends GetxController{
  final TextEditingController currentPasswordController = TextEditingController();
  final TextEditingController newPasswordController = TextEditingController();
  final TextEditingController confirmPasswordController = TextEditingController();

   final RxBool _isLoading = false.obs;
   final RxString _error = ''.obs;
   final RxBool _obscureCurrentPassword = true.obs;
   final RxBool _obscureNewPassword = true.obs;
   final RxBool _obscureConfirmPassword = true.obs;

    final GlobalKey<FormState> formKey = GlobalKey<FormState>();

    bool get isLoading => _isLoading.value;
    String get error => _error.value;
    bool get obscureCurrentPassword => _obscureCurrentPassword.value;
    bool get obscureNewPassword => _obscureNewPassword.value;
    bool get obscureConfirmPassword => _obscureConfirmPassword.value;

    VoidCallback get toggleCurrentPasswordVisibility => toggleObscureCurrentPassword;

  VoidCallback get toggleNewPasswordVisibility => toggleObscureNewPassword;

  VoidCallback get toggleConfirmPasswordVisibility => toggleObscureConfirmPassword;

    @override
    void onClose() {
      currentPasswordController.dispose();
      newPasswordController.dispose();
      confirmPasswordController.dispose();
      super.onClose();
    }

    void toggleObscureCurrentPassword() {
      _obscureCurrentPassword.value = !_obscureCurrentPassword.value;
    }

    void toggleObscureNewPassword() {
      _obscureNewPassword.value = !_obscureNewPassword.value;
    }

    void toggleObscureConfirmPassword() {
      _obscureConfirmPassword.value = !_obscureConfirmPassword.value;
    }
    

    Future<void> changePassword() async{
        if(!formKey.currentState!.validate()) return;
        try{
          _isLoading.value = true;
          _error.value = '';

          final user = FirebaseAuth.instance.currentUser;
          if(user == null){
            throw Exception('No authenticated user found.');
          }

          final credential = EmailAuthProvider.credential(
            email: user.email!,
            password: currentPasswordController.text,
          );
          await user.reauthenticateWithCredential(credential);
          await user.updatePassword(newPasswordController.text);
          Get.snackbar('Success', 'Password changed successfully.',
          backgroundColor: Colors.green.withAlpha(26),
          colorText: Colors.green,
          duration: Duration(seconds: 3),
          );
          
          currentPasswordController.clear();
          newPasswordController.clear();
          confirmPasswordController.clear();

          // Give the snackbar time to render before navigating back
          await Future.delayed(const Duration(milliseconds: 800));
          Get.back();
        } on FirebaseAuthException catch (e) {
          String errorMessage;
          switch (e.code) {
            case 'wrong-password':
              errorMessage = 'The current password is incorrect.';
              break;
            case 'weak-password':
              errorMessage = 'The new password is too weak.';
              break;
            case 'requires-recent-login':
              errorMessage = 'Please log in again and try changing the password.';
              break;
            default:
              errorMessage = 'Failed to change password. Please try again.';
          }
          _error.value = errorMessage;
          Get.snackbar('Error', errorMessage,
          backgroundColor: Colors.red.withAlpha(26),
            colorText: Colors.red,
            duration: Duration(seconds: 3),
          );

        }catch(e){
          _error.value = 'An error occurred. Please try again.';
          debugPrint(e.toString());
          Get.snackbar('Error', _error.value,
            backgroundColor: Colors.red.withAlpha(26),
            colorText: Colors.red,
            duration: Duration(seconds: 3),
          );
        }finally{
          _isLoading.value = false;
        }
    }

        String? validateCurrentPassword(String? value) {
          if (value == null || value.isEmpty) {
            return 'Please enter your current password.';
          }
          return null;
        }

        String? validateNewPassword(String? value) {
          if (value == null || value.isEmpty) {
            return 'Please enter a new password.';
          }
          if (value.length < 6) {
            return 'Password must be at least 6 characters long.';
          }

          if (value == currentPasswordController.text) {
            return 'New password must be different from the current password.';
          }
          return null;
        }

        String? validateConfirmPassword(String? value) {
          if (value == null || value.isEmpty) {
            return 'Please confirm your new password.';
          }
          if (value != newPasswordController.text) {
            return 'Passwords do not match.';
          }
          return null;
        }

        void clearError() {
          _error.value = '';
        }
    


}