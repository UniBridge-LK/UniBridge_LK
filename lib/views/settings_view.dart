import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:chat_with_aks/theme/app_theme.dart';
import 'package:chat_with_aks/controllers/profile_controller.dart';
import 'package:chat_with_aks/controllers/settings_controller.dart';
import 'package:chat_with_aks/controllers/auth_controller.dart';
import 'package:chat_with_aks/controllers/change_password_controller.dart';

class SettingsView extends StatelessWidget {
  const SettingsView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(icon: Icon(Icons.chevron_left), onPressed: () => Get.back()),
        title: Text('Settings'),
        backgroundColor: Colors.white,
        foregroundColor: AppTheme.primaryColor,
        elevation: 0,
      ),
      body: Builder(builder: (context) {
        final pc = Get.find<ProfileController>();
        final sc = Get.put(SettingsController());
        final auth = Get.find<AuthController>();

        return Obx(() {
          final user = pc.currentUser;
          if (user == null) {
            return Center(
              child: CircularProgressIndicator(color: AppTheme.primaryColor),
            );
          }

          return ListView(
            padding: EdgeInsets.all(16),
            children: [
              _buildSettingsTile(
                context: context,
                icon: Icons.lock,
                title: 'Change Password',
                onTap: () {
                  _showChangePasswordDialog(context);
                },
              ),
              SizedBox(height: 12),
              _buildSettingsTile(
                context: context,
                icon: Icons.star,
                title: 'Rate App',
                onTap: () {
                  Get.snackbar(
                    'Rate App',
                    'Redirecting to app store... (mock)',
                    snackPosition: SnackPosition.BOTTOM,
                  );
                },
              ),
              SizedBox(height: 12),
              Card(
                child: Padding(
                  padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  child: Obx(
                    () => SwitchListTile(
                      contentPadding: EdgeInsets.zero,
                      title: Text('Dark Theme'),
                      subtitle: Text(
                        'Enable dark mode for better visibility at night',
                        style: TextStyle(fontSize: 12, color: Colors.grey),
                      ),
                      value: sc.darkThemeEnabled.value,
                      onChanged: (v) {
                        sc.setDarkTheme(v);
                        Get.snackbar(
                          'Theme',
                          v ? 'Dark theme enabled' : 'Light theme enabled',
                          snackPosition: SnackPosition.BOTTOM,
                        );
                      },
                    ),
                  ),
                ),
              ),
              SizedBox(height: 12),
              Card(
                child: Padding(
                  padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  child: Column(
                    children: [
                      Obx(
                        () => SwitchListTile(
                          contentPadding: EdgeInsets.zero,
                          title: Text('In-App Notifications'),
                          subtitle: Text(
                            'Receive notifications within the app',
                            style: TextStyle(fontSize: 12, color: Colors.grey),
                          ),
                          value: sc.notificationsEnabled.value,
                          onChanged: (v) {
                            sc.setNotifications(v);
                            Get.snackbar(
                              'Notification',
                              v ? 'In-app notifications enabled' : 'In-app notifications disabled',
                              snackPosition: SnackPosition.BOTTOM,
                            );
                          },
                        ),
                      ),
                      Divider(),
                      Obx(
                        () => SwitchListTile(
                          contentPadding: EdgeInsets.zero,
                          title: Text('Push Notifications'),
                          subtitle: Text(
                            'Receive notifications on your device',
                            style: TextStyle(fontSize: 12, color: Colors.grey),
                          ),
                          value: sc.pushNotificationsEnabled.value,
                          onChanged: (v) {
                            sc.setPushNotifications(v);
                            Get.snackbar(
                              'Push Notification',
                              v ? 'Push notifications enabled' : 'Push notifications disabled',
                              snackPosition: SnackPosition.BOTTOM,
                            );
                          },
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              SizedBox(height: 12),
              _buildSettingsTile(
                context: context,
                icon: Icons.workspace_premium,
                title: 'Buy Premium',
                subtitle: 'Unlock all features - LKR 500/mo',
                onTap: () {
                  Get.dialog(
                    Dialog(
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Padding(
                        padding: EdgeInsets.all(24),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(Icons.workspace_premium, color: Colors.amber, size: 56),
                            SizedBox(height: 16),
                            Text(
                              'Unlock Premium',
                              style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                            ),
                            SizedBox(height: 12),
                            Text(
                              'Access unlimited messages, event creation, and exclusive features!',
                              textAlign: TextAlign.center,
                              style: TextStyle(color: Colors.grey[700]),
                            ),
                            SizedBox(height: 20),
                            SizedBox(
                              width: double.infinity,
                              height: 48,
                              child: ElevatedButton(
                                onPressed: () {
                                  Get.back();
                                  Get.snackbar(
                                    'Premium',
                                    'Redirecting to payment... (mock)',
                                  );
                                },
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.orange,
                                ),
                                child: Text('Continue to Payment'),
                              ),
                            )
                          ],
                        ),
                      ),
                    ),
                  );
                },
              ),
              SizedBox(height: 12),
              _buildSettingsTile(
                context: context,
                icon: Icons.help,
                title: 'Contact Support',
                subtitle: 'Get help and report issues',
                onTap: () {
                  _showContactSupportDialog(context);
                },
              ),
              SizedBox(height: 12),
              _buildSettingsTile(
                context: context,
                icon: Icons.delete_forever,
                title: 'Delete Account',
                subtitle: 'Permanently delete your account',
                isDestructive: true,
                onTap: () {
                  _showDeleteAccountDialog(context, auth);
                },
              ),
              SizedBox(height: 32),
              Center(
                child: Text(
                  'User ID: ${user.id}',
                  style: TextStyle(color: Colors.grey, fontSize: 12),
                ),
              ),
            ],
          );
        });
      }),
    );
  }

  Widget _buildSettingsTile({
    required BuildContext context,
    required IconData icon,
    required String title,
    String? subtitle,
    required VoidCallback onTap,
    bool isDestructive = false,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: Colors.grey.shade200),
        ),
        padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Row(
          children: [
            Icon(
              icon,
              color: isDestructive ? Colors.red : AppTheme.primaryColor,
              size: 24,
            ),
            SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w500,
                      color: isDestructive ? Colors.red : Colors.black87,
                    ),
                  ),
                  if (subtitle != null) ...[
                    SizedBox(height: 4),
                    Text(
                      subtitle,
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey,
                      ),
                    ),
                  ],
                ],
              ),
            ),
            Icon(
              Icons.arrow_forward_ios,
              size: 16,
              color: Colors.grey,
            ),
          ],
        ),
      ),
    );
  }

  void _showChangePasswordDialog(BuildContext context) {
    final controller = Get.put(ChangePasswordController());

    Get.dialog(
      AlertDialog(
        title: Text('Change Password'),
        content: SingleChildScrollView(
          child: Form(
            key: controller.formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Obx(() => TextFormField(
                  controller: controller.currentPasswordController,
                  obscureText: controller.obscureCurrentPassword,
                  decoration: InputDecoration(
                    labelText: 'Current Password',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    suffixIcon: IconButton(
                      icon: Icon(
                        controller.obscureCurrentPassword
                            ? Icons.visibility_off
                            : Icons.visibility,
                      ),
                      onPressed: controller.toggleCurrentPasswordVisibility,
                    ),
                  ),
                  validator: controller.validateCurrentPassword,
                )),
                SizedBox(height: 12),
                Obx(() => TextFormField(
                  controller: controller.newPasswordController,
                  obscureText: controller.obscureNewPassword,
                  decoration: InputDecoration(
                    labelText: 'New Password',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    suffixIcon: IconButton(
                      icon: Icon(
                        controller.obscureNewPassword
                            ? Icons.visibility_off
                            : Icons.visibility,
                      ),
                      onPressed: controller.toggleNewPasswordVisibility,
                    ),
                  ),
                  validator: controller.validateNewPassword,
                )),
                SizedBox(height: 12),
                Obx(() => TextFormField(
                  controller: controller.confirmPasswordController,
                  obscureText: controller.obscureConfirmPassword,
                  decoration: InputDecoration(
                    labelText: 'Confirm Password',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    suffixIcon: IconButton(
                      icon: Icon(
                        controller.obscureConfirmPassword
                            ? Icons.visibility_off
                            : Icons.visibility,
                      ),
                      onPressed: controller.toggleConfirmPasswordVisibility,
                    ),
                  ),
                  validator: controller.validateConfirmPassword,
                )),
              ],
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: Text('Cancel'),
          ),
          Obx(() => ElevatedButton(
            onPressed: controller.isLoading ? null : controller.changePassword,
            child: controller.isLoading
                ? SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: Colors.white,
                    ),
                  )
                : Text('Change'),
          )),
        ],
      ),
    );
  }

  void _showContactSupportDialog(BuildContext context) {
    Get.dialog(
      AlertDialog(
        title: Text('Contact Support'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'How can we help?',
              style: TextStyle(fontWeight: FontWeight.w600),
            ),
            SizedBox(height: 16),
            ListTile(
              leading: Icon(Icons.email),
              title: Text('Email Support'),
              onTap: () {
                Get.back();
                Get.snackbar(
                  'Email',
                  'Opening email client... (mock)',
                  snackPosition: SnackPosition.BOTTOM,
                );
              },
            ),
            ListTile(
              leading: Icon(Icons.chat),
              title: Text('Live Chat'),
              onTap: () {
                Get.back();
                Get.snackbar(
                  'Chat',
                  'Opening live chat... (mock)',
                  snackPosition: SnackPosition.BOTTOM,
                );
              },
            ),
            ListTile(
              leading: Icon(Icons.phone),
              title: Text('Call Support'),
              onTap: () {
                Get.back();
                Get.snackbar(
                  'Phone',
                  'Dialing support number... (mock)',
                  snackPosition: SnackPosition.BOTTOM,
                );
              },
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: Text('Close'),
          ),
        ],
      ),
    );
  }

  void _showDeleteAccountDialog(BuildContext context, AuthController auth) {
    Get.dialog(
      AlertDialog(
        title: Text('Delete Account', style: TextStyle(color: Colors.red)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Are you sure you want to delete your account?',
              style: TextStyle(fontWeight: FontWeight.w600),
            ),
            SizedBox(height: 12),
            Text(
              'This action cannot be undone. All your data will be permanently deleted.',
              style: TextStyle(color: Colors.grey, fontSize: 13),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              Get.back();
              // In a real app, this would delete the account from Firestore
              Get.snackbar(
                'Account Deleted',
                'Your account has been deleted (mock)',
                snackPosition: SnackPosition.BOTTOM,
                backgroundColor: Colors.red,
                colorText: Colors.white,
              );
              await auth.signOut();
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
            ),
            child: Text('Delete'),
          ),
        ],
      ),    );
  }
}