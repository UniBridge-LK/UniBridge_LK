import 'package:chat_with_aks/controllers/change_password_controller.dart';
import 'package:chat_with_aks/theme/app_theme.dart';
import 'package:flutter/material.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:get/get_instance/src/extension_instance.dart';
import 'package:get/get_state_manager/src/rx_flutter/rx_obx_widget.dart';

class ChangePasswordView extends StatelessWidget {

  const ChangePasswordView({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(ChangePasswordController());
    return Scaffold( appBar: AppBar(
      title: Text('Change Password'),
    ),
    body: SafeArea(child: SingleChildScrollView(
      padding: EdgeInsets.all(24.0),
      child: Form(
        key: controller.formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [SizedBox(height: 20),
          Center(
            child: Container(
              width: 120,
              height: 120,
              decoration: BoxDecoration(
                color: AppTheme.primaryColor.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(Icons.security_rounded, size: 40, color: AppTheme.primaryColor,),
            ),
          ),
          SizedBox(height: 20),
          Text('Update your password', 
          style: Theme.of(context).textTheme.headlineSmall?.copyWith(
            fontWeight: FontWeight.bold,
          ),
          textAlign: TextAlign.center,
          ),
          SizedBox(height: 8),
          Text('Please enter your current password and new password to update your account password.', 
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
            color: AppTheme.textSecondaryColor,
          ),
          textAlign: TextAlign.start,
          ),
          SizedBox(height: 40),
          Obx(() => TextFormField(
            controller: controller.currentPasswordController,
            obscureText: controller.obscureCurrentPassword,
            decoration: InputDecoration(
              labelText: 'Current Password',
              prefixIcon: Icon(Icons.lock_outline),
              suffixIcon: IconButton(
                icon: Icon(
                  controller.obscureCurrentPassword ? Icons.visibility_off : Icons.visibility,
                ),
                onPressed: controller.toggleCurrentPasswordVisibility,
              ),
              hintText: 'Enter your current password',
            ),
            validator: controller.validateCurrentPassword,
          ),
          ),
          SizedBox(height: 20),
          Obx(() => TextFormField(
            controller: controller.newPasswordController,
            obscureText: controller.obscureNewPassword,
            decoration: InputDecoration(
              labelText: 'New Password',
              prefixIcon: Icon(Icons.lock_outline),
              suffixIcon: IconButton(
                icon: Icon(
                  controller.obscureNewPassword ? Icons.visibility_off : Icons.visibility,
                ),
                onPressed: controller.toggleNewPasswordVisibility,
              ),
              hintText: 'Enter your new password',
            ),
            validator: controller.validateNewPassword,
          ),
          ),
          SizedBox(height: 20),
          Obx(() => TextFormField(
            controller: controller.confirmPasswordController,
            obscureText: controller.obscureConfirmPassword,
            decoration: InputDecoration(
              labelText: 'Confirm New Password',
              prefixIcon: Icon(Icons.lock_outline),
              suffixIcon: IconButton(
                icon: Icon(
                  controller.obscureConfirmPassword ? Icons.visibility_off : Icons.visibility,
                ),
                onPressed: controller.toggleConfirmPasswordVisibility,
              ),
              hintText: 'Re-enter your new password',
            ),
            validator: controller.validateConfirmPassword,
          ),
          ),
          SizedBox(height: 40),
          Obx(() => SizedBox(
            width: double.infinity,
            height: 50,
            child: ElevatedButton.icon(
              onPressed: controller.isLoading ? null : controller.changePassword,
              icon: controller.isLoading ? SizedBox(
                width: 24,
                height: 24,
                child: CircularProgressIndicator(
                  color: Colors.white,
                  strokeWidth: 2.0,
                ),
              ) : Icon(Icons.security),
              label: Text(
                controller.isLoading ? 'Updating...' : 'Change Password',
                style: TextStyle(fontSize: 16),
              ),
            ),
          ),
          ),
          ],
        ),
      ),
    ))

    );
  }
}