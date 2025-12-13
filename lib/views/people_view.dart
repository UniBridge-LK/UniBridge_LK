import 'package:flutter/material.dart';
import 'package:chat_with_aks/theme/app_theme.dart';
import 'package:get/get.dart';
import 'package:chat_with_aks/services/firestore_service.dart';
import 'package:chat_with_aks/controllers/auth_controller.dart';
import 'package:chat_with_aks/models/friend_request_model.dart';
import 'package:uuid/uuid.dart';
import 'package:chat_with_aks/widgets/premium_popup.dart';

class PeopleView extends StatefulWidget {
  const PeopleView({super.key});

  @override
  State<PeopleView> createState() => _PeopleViewState();
}

class _PeopleViewState extends State<PeopleView> {
  final FirestoreService _fs = FirestoreService();
  final auth = Get.find<AuthController>();
  final uuid = Uuid();
  String query = '';

  bool isPremiumUser() {
    final email = auth.userModel?.email ?? '';
    return email.toLowerCase().contains('premium');
  }

  List<Map<String, dynamic>> _filter(List<Map<String, dynamic>> list) {
    final q = query.trim().toLowerCase();
    if (q.isEmpty) return list.where((u) => u['id'] != auth.user?.uid).toList();
    return list.where((u) {
      if (u['id'] == auth.user?.uid) return false;
      final name = (u['displayName'] ?? '').toString().toLowerCase();
      final bio = (u['bio'] ?? '').toString().toLowerCase();
      final interests = (u['interests'] is List) ? (u['interests'] as List).join(' ').toLowerCase() : (u['interests']?.toString() ?? '').toLowerCase();
      return name.contains(q) || bio.contains(q) || interests.contains(q);
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('People'),
        backgroundColor: Colors.white,
        foregroundColor: AppTheme.primaryColor,
        elevation: 0,
        automaticallyImplyLeading: false,
      ),
      body: Column(
        children: [
          // Sticky search bar
          Container(
            color: Colors.white,
            padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    decoration: InputDecoration(
                      prefixIcon: Icon(Icons.search),
                      hintText: 'Search by name, bio or interests',
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: BorderSide.none),
                      filled: true,
                      fillColor: Colors.grey.shade100,
                      contentPadding: EdgeInsets.symmetric(vertical: 12, horizontal: 12),
                    ),
                    onChanged: (v){ setState((){ query = v; }); },
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: StreamBuilder<List<Map<String, dynamic>>>(
              stream: _fs.getUserSummariesStream().asBroadcastStream(),
              builder: (context, snap) {
                if (snap.connectionState == ConnectionState.waiting) return Center(child: CircularProgressIndicator(color: AppTheme.primaryColor));
                final list = snap.data ?? [];
                final filtered = _filter(list);
                if (filtered.isEmpty) return Center(child: Text('No members found'));

                return ListView.builder(
                  padding: EdgeInsets.all(16),
                  itemCount: filtered.length,
                  itemBuilder: (c,i){
                    final u = filtered[i];
                    final interests = (u['interests'] is List) ? List<String>.from(u['interests']) : (u['interests'] != null ? u['interests'].toString().split(',') : []);
                    return Card(
                      margin: EdgeInsets.only(bottom:12),
                      child: Padding(
                        padding: EdgeInsets.all(12),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Avatar
                            SizedBox(
                              width:48, height:48,
                              child: CircleAvatar(
                                radius: 24,
                                backgroundColor: AppTheme.primaryColor.withAlpha(31),
                                child: Text((u['displayName'] ?? '?').toString().isNotEmpty ? (u['displayName'] ?? '?').toString()[0] : '?', style: TextStyle(color: AppTheme.primaryColor)),
                              ),
                            ),
                            SizedBox(width:12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    children: [
                                      Expanded(child: Text(u['displayName'] ?? 'Unknown', style: TextStyle(fontSize:18, fontWeight: FontWeight.w700))),
                                      // online dot
                                      Container(
                                        width:10, height:10,
                                        decoration: BoxDecoration(
                                          color: (u['isOnline'] ?? false) ? Colors.green : Colors.grey,
                                          shape: BoxShape.circle,
                                        ),
                                      ),
                                    ],
                                  ),
                                  SizedBox(height:6),
                                  Text((u['bio'] ?? '').toString(), maxLines:2, overflow: TextOverflow.ellipsis, style: TextStyle(color: Colors.grey[700])),
                                  SizedBox(height:8),
                                  Wrap(
                                    spacing:8, runSpacing:4,
                                    children: List.generate(
                                      interests.length > 3 ? 3 : interests.length,
                                      (idx) => Container(
                                        padding: EdgeInsets.symmetric(horizontal:8, vertical:4),
                                        decoration: BoxDecoration(color: Colors.grey.shade200, borderRadius: BorderRadius.circular(16)),
                                        child: Text(interests[idx], style: TextStyle(fontSize:12)),
                                      )
                                    ),
                                  )
                                ],
                              ),
                            ),
                            SizedBox(width:8),
                            ElevatedButton(
                              onPressed: () async {
                                if (!isPremiumUser()) { Get.dialog(const PremiumPopup()); return; }
                                if (auth.user?.uid == null) { Get.snackbar('Error', 'Sign in required'); return; }
                                final req = FriendRequestModel(
                                  id: uuid.v4(), senderId: auth.user!.uid, receiverId: u['id'], createdAt: DateTime.now()
                                );
                                try { await _fs.sendFriendRequest(req); Get.snackbar('Success', 'Friend request sent'); } catch (e){ Get.snackbar('Error','Failed to send request'); }
                              },
                              child: Text('Connect'),
                            )
                          ],
                        ),
                      ),
                    );
                  }
                );
              }
            )
          )
        ],
      ),
    );
  }
}
