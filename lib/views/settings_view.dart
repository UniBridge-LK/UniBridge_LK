import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:chat_with_aks/theme/app_theme.dart';
import 'package:chat_with_aks/controllers/profile_controller.dart';
import 'package:chat_with_aks/services/firestore_service.dart';
import 'package:chat_with_aks/controllers/auth_controller.dart';

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
        final auth = Get.find<AuthController>();
        final fs = FirestoreService();

        return Obx((){
          final user = pc.currentUser;
          if (user == null) return Center(child: CircularProgressIndicator(color: AppTheme.primaryColor));

          return ListView(padding: EdgeInsets.all(16), children: [
            Text('General', style: TextStyle(fontSize:16, fontWeight: FontWeight.w700)),
            SizedBox(height:8),
            SwitchListTile(
              title: Text('Dark Theme'),
              value: user.theme == 'dark',
              onChanged: (v) async {
                final updated = user.copyWith(theme: v ? 'dark' : 'light');
                await fs.updateUser(updated);
              },
            ),
            SwitchListTile(
              title: Text('Push Notifications'),
              value: user.notificationsEnabled,
              onChanged: (v) async {
                final updated = user.copyWith(notificationsEnabled: v);
                await fs.updateUser(updated);
              },
            ),
            SizedBox(height: 16),
            Text('Account', style: TextStyle(fontSize:16, fontWeight: FontWeight.w700)),
            SizedBox(height:8),
            ListTile(
              leading: Icon(Icons.edit),
              title: Text('Edit Profile'),
              onTap: () => Get.snackbar('Edit', 'Edit Profile placeholder'),
            ),
            ListTile(
              leading: Icon(Icons.logout, color: AppTheme.errorColor),
              title: Text('Sign Out', style: TextStyle(color: AppTheme.errorColor)),
              onTap: () async {
                await auth.signOut();
              },
            ),
            SizedBox(height: 32),
            Center(child: Text('User ID: ${user.id}', style: TextStyle(color: Colors.grey, fontSize: 12))),
          ]);
        });
      }),
    );
  }
}
