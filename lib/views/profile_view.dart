
import 'package:chat_with_aks/controllers/profile_controller.dart';
import 'package:chat_with_aks/theme/app_theme.dart';
import 'package:flutter/material.dart';
import 'package:chat_with_aks/views/settings_view.dart';
import 'package:get/get.dart';

class ProfileView extends StatelessWidget {
  const ProfileView({super.key});

  @override
  Widget build(BuildContext context) {
    // Register or find the ProfileController instance and use it locally.
    final ProfileController controller = Get.put(ProfileController());
    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      body: Obx((){
        final user = controller.currentUser;
        if (user == null) return Center(child: CircularProgressIndicator(color: AppTheme.primaryColor));

        return Column(
          children: [
            // Header
            Container(
              width: double.infinity,
              color: Colors.indigo,
              padding: EdgeInsets.only(top: MediaQuery.of(context).padding.top + 16, left: 16, right: 16, bottom: 20),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  CircleAvatar(
                    radius: 44,
                    backgroundColor: Colors.white24,
                    child: user.photoURL.isNotEmpty ? ClipOval(child: Image.network(user.photoURL, width: 84, height: 84, fit: BoxFit.cover)) : Text(user.displayName.isNotEmpty ? user.displayName[0].toUpperCase() : '?', style: TextStyle(fontSize: 36, color: Colors.white)),
                  ),
                  SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(user.displayName, style: TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.w800)),
                        SizedBox(height: 6),
                        Text(user.id, style: TextStyle(color: Colors.white70, fontSize: 12)),
                      ],
                    ),
                  ),
                  IconButton(onPressed: () => Get.to(() => const SettingsView()), icon: Icon(Icons.settings, color: Colors.white)),
                ],
              ),
            ),

            // Content
            Expanded(
              child: SingleChildScrollView(
                padding: EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // About Me
                    Card(elevation: 2, margin: EdgeInsets.only(bottom:12), child: Padding(padding: EdgeInsets.all(16), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                      Text('About Me', style: TextStyle(fontSize:16, fontWeight: FontWeight.w700)),
                      SizedBox(height:8),
                      Text(user.bio ?? 'No bio provided.', style: TextStyle(fontStyle: FontStyle.italic))
                    ]))),

                    // Contact & Info
                    Card(elevation: 2, margin: EdgeInsets.only(bottom:12), child: Padding(padding: EdgeInsets.all(16), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                      Text('Contact & Info', style: TextStyle(fontSize:16, fontWeight: FontWeight.w700)),
                      SizedBox(height:12),
                      _detailRow('Email', user.email),
                      SizedBox(height:8),
                      _detailRow('Member Since', controller.getJoinedDate()),
                    ]))),

                    // Interests
                    Card(elevation: 2, margin: EdgeInsets.only(bottom:12), child: Padding(padding: EdgeInsets.all(16), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                      Text('Interests', style: TextStyle(fontSize:16, fontWeight: FontWeight.w700)),
                      SizedBox(height:8),
                      Wrap(spacing:8, runSpacing:8, children: (user.interests ?? []).map<Widget>((it) => Container(padding: EdgeInsets.symmetric(horizontal:10, vertical:6), decoration: BoxDecoration(color: Colors.indigo.shade50, borderRadius: BorderRadius.circular(16)), child: Text(it, style: TextStyle(color: Colors.indigo)))).toList()),
                    ]))),

                    SizedBox(height: 16),
                    Text('Debug: ${user.id}', style: TextStyle(fontSize:12, color: Colors.grey)),
                    SizedBox(height: 24),
                  ],
                ),
              ),
            )
          ],
        );
      }),
    );
  }

}
// helper detail row
Widget _detailRow(String label, String value) {
  return Row(
    children: [
      Expanded(child: Text(label, style: TextStyle(color: Colors.grey[700]))),
      SizedBox(width: 12),
      Expanded(flex: 2, child: Text(value, textAlign: TextAlign.right)),
    ],
  );
}