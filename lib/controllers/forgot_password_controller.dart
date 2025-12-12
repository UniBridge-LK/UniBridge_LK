import 'package:chat_with_aks/services/auth_service.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';


class ForgotPasswordController  extends GetxController {
  final AuthService _authService = AuthService();
  final TextEditingController emailController = TextEditingController();
  final RxBool _isLoading = false.obs;
  final GlobalKey<FormState> formKey = GlobalKey<FormState>();
  final RxString _error = ''.obs;
  final RxBool _emailSent = false.obs;

  bool get isLoading => _isLoading.value;
  String get error => _error.value;
  bool get emailSent => _emailSent.value;

  @override
  void onClose() {
    emailController.dispose();
    super.onClose();
  }

  Future<void> sendPasswordResetEmail() async {
    if (!formKey.currentState!.validate()) return;    
    
    try {
      _isLoading.value = true;
      _error.value = '';
      await _authService.sendPasswordResetEmail(emailController.text.trim());
      _emailSent.value = true;
      Get.snackbar(
        'Success', 
        'Password reset email sent to ${emailController.text}',
        backgroundColor: Colors.green.withOpacity(0.1),
        colorText: Colors.green,
        duration: Duration(seconds: 4),
        );
    } catch (e) {
      _error.value = e.toString();
      Get.snackbar(
        'Error', 
        e.toString(),
        backgroundColor: Colors.red.withOpacity(0.1),
        colorText: Colors.red,
        duration: Duration(seconds: 4),
        );
    } finally {
      _isLoading.value = false;
    }
  }

  void goBackToLogin() {
        Get.back();
  }

  void resendEmail() {
    _emailSent.value = false;
    sendPasswordResetEmail();
  }

  String? validateEmail(String? value) {
    if (value == null || value.isEmpty) {
      return 'Email is required';
    }
    if (!GetUtils.isEmail(value!)) {
      return 'Enter a valid email address';
    }
    return null;
  }

  void clearError() {
    _error.value = '';
  }    

}