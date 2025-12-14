import 'package:flutter/material.dart';
import 'package:chat_with_aks/theme/app_theme.dart';
import 'package:get/get.dart';
import 'package:chat_with_aks/services/firestore_service.dart';
import 'package:chat_with_aks/controllers/auth_controller.dart';
import 'package:chat_with_aks/models/friend_request_model.dart';
import 'package:uuid/uuid.dart';
import 'package:chat_with_aks/widgets/premium_popup.dart';
import 'package:chat_with_aks/models/people_data.dart';
import 'package:chat_with_aks/views/user_profile_view.dart';

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

  List<PersonData> _filter(List<PersonData> list) {
    final q = query.trim().toLowerCase();
    if (q.isEmpty) return list;
    return list.where((person) {
      final name = person.name.toLowerCase();
      return name.contains(q);
    }).toList();
  }

  void _showConnectDialog(PersonData person) {
    final noteController = TextEditingController();
    Get.dialog(
      Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: Padding(
          padding: EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Connect with ${person.name}', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
              SizedBox(height: 16),
              Text('Add a note (Optional)', style: TextStyle(fontSize: 14, color: Colors.grey[700])),
              SizedBox(height: 8),
              TextField(
                controller: noteController,
                maxLines: 3,
                decoration: InputDecoration(
                  hintText: 'Hi, I would like to connect with you...',
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                  contentPadding: EdgeInsets.all(12),
                ),
              ),
              SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton(
                    onPressed: () => Get.back(),
                    child: Text('Cancel'),
                  ),
                  SizedBox(width: 8),
                  ElevatedButton(
                    onPressed: () async {
                      Get.back();
                      if (auth.user?.uid == null) { 
                        Get.snackbar('Error', 'Sign in required'); 
                        return; 
                      }
                      final req = FriendRequestModel(
                        id: uuid.v4(), 
                        senderId: auth.user!.uid, 
                        receiverId: person.id, 
                        createdAt: DateTime.now()
                      );
                      try { 
                        await _fs.sendFriendRequest(req); 
                        Get.snackbar('Success', 'Connection request sent to ${person.name}'); 
                      } catch (e) { 
                        Get.snackbar('Error', 'Failed to send request'); 
                      }
                    },
                    style: ElevatedButton.styleFrom(backgroundColor: AppTheme.primaryColor),
                    child: Text('Send Request'),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
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
                      hintText: 'Search by name or course...',
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
            child: Builder(
              builder: (context) {
                // Using dummy data - later replace with Firestore stream
                final list = dummyPeople;
                final filtered = _filter(list);
                if (filtered.isEmpty) return Center(child: Text('No members found'));

                return ListView.builder(
                  padding: EdgeInsets.all(16),
                  itemCount: filtered.length,
                  itemBuilder: (c, i) {
                    final person = filtered[i];
                    return GestureDetector(
                      onTap: () {
                        // Navigate to user profile view
                        Get.to(() => UserProfileView(person: person));
                      },
                      child: Container(
                        margin: EdgeInsets.only(bottom: 16),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(12),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.grey.withAlpha(26),
                              blurRadius: 6,
                              offset: Offset(0, 2),
                            ),
                          ],
                        ),
                        child: Padding(
                          padding: EdgeInsets.all(16),
                          child: Row(
                            children: [
                              // Avatar
                              CircleAvatar(
                                radius: 28,
                                backgroundColor: Color(int.parse('0xFF${person.avatarColor}')),
                                child: Text(
                                  person.avatarLetter,
                                  style: TextStyle(
                                    color: AppTheme.primaryColor,
                                    fontSize: 24,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ),
                              SizedBox(width: 16),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      person.name,
                                      style: TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.w700,
                                        color: Colors.black87,
                                      ),
                                    ),
                                    SizedBox(height: 4),
                                    Text(
                                      person.profileHeadline,
                                      style: TextStyle(
                                        fontSize: 13,
                                        color: Colors.grey[600],
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              SizedBox(width: 12),
                              OutlinedButton(
                                onPressed: () {
                                  if (!isPremiumUser()) {
                                    Get.dialog(const PremiumPopup());
                                    return;
                                  }
                                  _showConnectDialog(person);
                                },
                                style: OutlinedButton.styleFrom(
                                  foregroundColor: AppTheme.primaryColor,
                                  side: BorderSide(color: Colors.grey.shade300),
                                  padding: EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                ),
                                child: Text('Connect'),
                              ),
                            ],
                          ),
                        ),
                      ),
                    );
                  },
                );
              },
            ),
          )
        ],
      ),
    );
  }
}
