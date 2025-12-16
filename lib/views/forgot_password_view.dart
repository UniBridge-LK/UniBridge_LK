import 'package:chat_with_aks/controllers/forgot_password_controller.dart';
import 'package:chat_with_aks/theme/app_theme.dart';
import 'package:flutter/material.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:get/get_instance/src/extension_instance.dart';
import 'package:get/get_navigation/src/extension_navigation.dart';
import 'package:get/get_state_manager/src/rx_flutter/rx_obx_widget.dart';

class ForgotPasswordView extends StatelessWidget {
  const ForgotPasswordView({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(ForgotPasswordController());

    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Form(
            key: controller.formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(height: 40),
                Row(children: [
                  IconButton(
                    icon: Icon(Icons.arrow_back),
                    onPressed:controller.goBackToLogin                    
                  ),
                  SizedBox(width: 8),
                  Text(
                    'Forgot Password',
                    style: Theme.of(context).textTheme.headlineLarge,
                  ),
                ],
                ),
                SizedBox(height: 32),
                Padding(padding: EdgeInsets.only(left: 56),
                  child: Text(
                    'Enter your email address below to receive a password reset link.',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: AppTheme.textSecondaryColor,
                    ),
                  ),
                ),
              SizedBox(height: 60),
              Center(
                child: Container(
                  width: 100,
                  height: 100,
                  decoration: BoxDecoration(
                    color: AppTheme.primaryColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(50),
                  ),
                  child: Icon(
                    Icons.lock_reset_rounded, 
                    color: AppTheme.primaryColor, 
                    size: 50,
                  ),
                  ),
                  ),
              SizedBox(height: 40),
              Obx(() {
                if (controller.emailSent) {
                  return _buildEmailSentContent(controller);
                } else {
                  return _buildEmailForm(controller);
                }
              })
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildEmailForm(ForgotPasswordController controller) {
    return Column(
      children: [
        TextFormField(
          controller: controller.emailController,
          keyboardType: TextInputType.emailAddress,
          decoration: InputDecoration(
            labelText: 'Email Address',
            prefixIcon: Icon(Icons.email_outlined),
            hintText: 'Enter your email address',
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
          validator: controller.validateEmail,
          onChanged: (_) => controller.clearError(),
        ),
        SizedBox(height: 24),
        Obx(() => SizedBox(
          width: double.infinity,
          height: 50,
          child: ElevatedButton.icon(
            onPressed: controller.isLoading ? null : controller.sendPasswordResetEmail,
            icon: controller.isLoading 
              ? SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(
                    color: Colors.white,
                    strokeWidth: 2,
                  ),
                )
              : Icon(Icons.send_outlined),
            label: Text(controller.isLoading ? 'Sending...' : 'Send Reset Link'),
          )
        )),
        SizedBox(height: 32),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text('Remembered your password?', 
            style: Theme.of(Get.context!).textTheme.bodyMedium),
            SizedBox(width: 8),            
            GestureDetector(
              onTap: controller.goBackToLogin,
              child: Text(
                'Sign In',
                style: Theme.of(Get.context!).textTheme.bodyMedium?.copyWith(
                  color: AppTheme.primaryColor,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildEmailSentContent(ForgotPasswordController controller) {
    return Column(
      children: [
        Container(
          padding: EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: AppTheme.successColor.withOpacity(0.1),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: AppTheme.successColor.withOpacity(0.3),
            ),
          ),
          child: Column(
            children: [
              Icon(
                Icons.mark_email_read_rounded,
                color: AppTheme.successColor,
                size: 64,
              ),
              SizedBox(height: 16),
              Text(
                'Email Sent!',
                style: Theme.of(Get.context!).textTheme.headlineSmall?.copyWith(
                  color: AppTheme.successColor,
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(height: 8),
              Text(
                'A password reset link has been sent to your email address. Please check your inbox.',
                textAlign: TextAlign.center,
                style: Theme.of(Get.context!).textTheme.bodyMedium?.copyWith(
                  color: AppTheme.textSecondaryColor,
                ),
              ),
              SizedBox(height: 4),
              Text(
                controller.emailController.text,
                style: Theme.of(Get.context!).textTheme.bodySmall?.copyWith(
                  color: AppTheme.textSecondaryColor,
                  // fontWeight: FontWeight.w600,
                ),
                textAlign: TextAlign.center,
              )
            ],
          ),
        ),
        SizedBox(height: 32),
        SizedBox(
          width: double.infinity,          
          child: OutlinedButton.icon(
            onPressed: controller.resendEmail,
            icon: Icon(Icons.refresh),
            label: Text('Resend Email'),
          )
        ),
        SizedBox(height: 16),
        SizedBox(
          width: double.infinity,          
          child: ElevatedButton.icon(
            onPressed: controller.goBackToLogin,
            icon: Icon(Icons.arrow_back),
            label: Text('Back to Sign In'),
          )
        ),
        SizedBox(height: 32),
        Container(
          padding: EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: AppTheme.secondaryColor.withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
            border: Border.all(
              color: AppTheme.secondaryColor.withOpacity(0.3),
            ),
          ),
          child: Row(
            children: [
              Icon(
                Icons.info_outline,
                color: AppTheme.secondaryColor,
                size: 20,
              ),
              SizedBox(width: 12),
              Expanded(
                child: Text(
                  "Didn't receive the email? Please check your spam folder or try resending the email.",
                  style: Theme.of(Get.context!).textTheme.bodySmall?.copyWith(
                    color: AppTheme.secondaryColor,
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}