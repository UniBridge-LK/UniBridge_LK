import 'package:chat_with_aks/routes/app_routes.dart';
import 'package:chat_with_aks/services/otp_service.dart';
import 'package:chat_with_aks/theme/app_theme.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class VerifyOtpView extends StatefulWidget {
  const VerifyOtpView({super.key});

  @override
  State<VerifyOtpView> createState() => _VerifyOtpViewState();
}

class _VerifyOtpViewState extends State<VerifyOtpView> {
  final _codeController = TextEditingController();
  bool _isSubmitting = false;
  final _otpService = OtpService();
  bool _isResending = false;

  @override
  void dispose() {
    _codeController.dispose();
    super.dispose();
  }

  Future<void> _verify() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;
    final code = _codeController.text.trim();
    if (code.length < 4) {
      Get.snackbar('Invalid', 'Please enter the verification code');
      return;
    }
    setState(() => _isSubmitting = true);
    try {
      final ok = await _otpService.verifyEmailOtp(userId: user.uid, code: code);
      if (ok) {
        // Get user model from Firestore
        final userModel = await FirebaseFirestore.instance
            .collection('users')
            .doc(user.uid)
            .get();
        
        if (!userModel.exists) {
          // User doesn't exist in Firestore yet, so we need to save them
          // Reconstruct from Firebase Auth user
          // For now, just mark as verified
          await FirebaseFirestore.instance
              .collection('users')
              .doc(user.uid)
              .set({
            'id': user.uid,
            'email': user.email,
            'displayName': user.displayName ?? '',
            'photoURL': '',
            'isOnline': true,
            'lastSeen': DateTime.now().microsecondsSinceEpoch,
            'createdAt': DateTime.now().microsecondsSinceEpoch,
            'accountType': 'individual',
            'universityName': '',
            'faculty': '',
            'department': '',
            'organizationName': '',
            'isEmailVerified': true,
          });
        } else {
          // User exists, just mark as verified
          await FirebaseFirestore.instance
              .collection('users')
              .doc(user.uid)
              .update({
            'isEmailVerified': true,
          });
        }
        
        await FirebaseAuth.instance.currentUser?.reload();
        
        // Show success dialog
        Get.dialog(
          AlertDialog(
            icon: const Icon(Icons.check_circle, color: Colors.green, size: 60),
            title: const Text('Registration Successful!'),
            content: const Text(
              'Your email has been verified and your account is now active. You can now access all features.',
              textAlign: TextAlign.center,
            ),
            actions: [
              ElevatedButton(
                onPressed: () {
                  Get.back(); // Close dialog
                  Get.offAllNamed(AppRoutes.main); // Navigate to home
                },
                child: const Text('Continue to Home'),
              ),
            ],
          ),
          barrierDismissible: false,
        );
      } else {
        Get.snackbar('Invalid', 'Incorrect or expired code');
      }
    } catch (e) {
      Get.snackbar('Error', 'Verification failed, try again');
      print('Error: $e');
    } finally {
      setState(() => _isSubmitting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final email = FirebaseAuth.instance.currentUser?.email ?? '';
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            // Act like a standard back button: pop current route only.
            // This preserves the previous page's state.
            if (Get.isDialogOpen == true) {
              Get.back();
              return;
            }
            // Prefer Navigator.pop to avoid rebuilding previous via routing.
            if (Navigator.of(context).canPop()) {
              Navigator.of(context).pop();
              return;
            }
            // Fallback to Get.back if navigator can't pop.
            Get.back();
          },
        ),
        title: const Text('Enter verification code'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'We sent a 6-digit code to:',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: AppTheme.textSecondaryColor,
                  ),
            ),
            const SizedBox(height: 8),
            Text(
              email,
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: 24),
            TextField(
              controller: _codeController,
              keyboardType: TextInputType.number,
              maxLength: 6,
              decoration: const InputDecoration(
                labelText: 'Verification code',
                border: OutlineInputBorder(),
                counterText: '',
              ),
            ),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _isSubmitting ? null : _verify,
                child: _isSubmitting
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                      )
                    : const Text('Verify'),
              ),
            ),
            const SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                onPressed: _isResending
                    ? null
                    : () async {
                        final user = FirebaseAuth.instance.currentUser;
                        if (user == null) return;
                        setState(() => _isResending = true);
                        try {
                          await _otpService.sendEmailOtp(userId: user.uid, email: user.email ?? '');
                          Get.snackbar('Sent', 'A new code was sent to your email');
                        } catch (e) {
                          Get.snackbar('Error', 'Could not resend code');
                        } finally {
                          setState(() => _isResending = false);
                        }
                      },
                icon: _isResending
                    ? const SizedBox(
                        width: 16,
                        height: 16,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Icon(Icons.refresh),
                label: const Text('Resend code'),
              ),
            ),
            // Cancel button removed; back arrow added in AppBar
          ],
        ),
      ),
    );
  }
}
