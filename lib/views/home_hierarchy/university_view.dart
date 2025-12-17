import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:chat_with_aks/theme/app_theme.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class UniversityView extends StatefulWidget {
  const UniversityView({super.key});

  @override
  State<UniversityView> createState() => _UniversityViewState();
}

class _UniversityViewState extends State<UniversityView> {
  String uniName = '';
  String uniId = '';
  bool loading = true;
  String error = '';
  List<QueryDocumentSnapshot<Map<String, dynamic>>> faculties = [];
  String searchQuery = '';

  List<QueryDocumentSnapshot<Map<String, dynamic>>> get _filteredFaculties {
    final query = searchQuery.trim().toLowerCase();
    if (query.isEmpty) return faculties;
    return faculties
        .where((doc) => (doc.data()['name'] ?? '').toString().toLowerCase().contains(query))
        .toList(growable: false);
  }

  @override
  void initState() {
    super.initState();
    final args = Get.arguments as Map<String, dynamic>? ?? {};
    uniName = (args['uni'] ?? '').toString();
    uniId = (args['uniId'] ?? '').toString();
    _loadFaculties();
  }

  Future<void> _loadFaculties() async {
    setState(() { loading = true; error = ''; });
    try {
      final snap = await FirebaseFirestore.instance
          .collection('faculties')
          .where('universityId', isEqualTo: uniId)
          .get();
      faculties = snap.docs;
    } catch (e) {
      error = e.toString();
    } finally {
      setState(() { loading = false; });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(uniName), backgroundColor: Colors.white, foregroundColor: AppTheme.primaryColor, elevation: 0),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // University Forum header card (similar to HomeView)
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 24, vertical: 16),
              child: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(colors: [Color(0xFF6C5CE7), Color(0xFF7F5CD1)]),
                  borderRadius: BorderRadius.circular(16),
                ),
                padding: EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(Icons.forum_outlined, color: Colors.white, size: 24),
                        SizedBox(width: 8),
                        Text('University Forum', style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold)),
                      ],
                    ),
                    SizedBox(height: 12),
                    Text(
                      'Threads specific to $uniName and its faculties/departments.',
                      style: TextStyle(color: Colors.white, fontSize: 14, height: 1.4),
                    ),
                    SizedBox(height: 16),
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.white,
                        foregroundColor: AppTheme.primaryColor,
                        padding: EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                      ),
                      onPressed: (){
                        Get.toNamed('/forum', arguments: {'type': 'university', 'uni': uniName});
                      },
                      child: Text('View University Threads', style: TextStyle(fontWeight: FontWeight.w600)),
                    )
                  ],
                ),
              ),
            ),

            Padding(
              padding: EdgeInsets.symmetric(horizontal: 24, vertical: 8),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Faculties', style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: AppTheme.primaryColor)),
                  SizedBox(height: 8),
                  TextField(
                    onChanged: (value) => setState(() => searchQuery = value),
                    decoration: InputDecoration(
                      prefixIcon: Icon(Icons.search, color: Colors.grey[600]),
                      hintText: 'Search faculties',
                      filled: true,
                      fillColor: Colors.grey[100],
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide.none,
                      ),
                      contentPadding: EdgeInsets.symmetric(vertical: 0, horizontal: 12),
                    ),
                  ),
                  SizedBox(height: 8),
                  if (loading)
                    Center(child: Padding(padding: EdgeInsets.symmetric(vertical: 16), child: CircularProgressIndicator()))
                  else if (error.isNotEmpty)
                    Text('Error: $error', style: TextStyle(color: Colors.red))
                  else if (_filteredFaculties.isEmpty)
                    Text('No faculties found', style: TextStyle(color: Colors.grey[700]))
                ],
              ),
            ),

            Padding(
              padding: EdgeInsets.symmetric(horizontal: 24),
              child: Column(
                children: List.generate(_filteredFaculties.length, (index) {
                  final doc = _filteredFaculties[index];
                  final facName = (doc.data()['name'] ?? '').toString();
                  return Padding(
                    padding: EdgeInsets.only(bottom: 12),
                    child: GestureDetector(
                      onTap: () => Get.toNamed('/home/university/faculty', arguments: {
                        'uni': uniName,
                        'faculty': facName,
                        'facultyId': doc.id,
                      }),
                      child: Container(
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(12),
                          boxShadow: [
                            BoxShadow(color: Colors.grey.withAlpha(26), blurRadius: 8, offset: Offset(0, 2)),
                          ],
                        ),
                        padding: EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                        child: Row(children: [
                          Container(
                            padding: EdgeInsets.all(12),
                            decoration: BoxDecoration(color: Colors.grey[100], borderRadius: BorderRadius.circular(8)),
                            child: Icon(Icons.account_balance, color: Colors.grey[600], size: 24),
                          ),
                          SizedBox(width: 16),
                          Expanded(
                            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                              Text(facName, style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: Colors.black87)),
                              SizedBox(height: 4),
                              Text('Tap to view departments', style: TextStyle(color: Colors.grey[600], fontSize: 12)),
                            ]),
                          ),
                          Icon(Icons.chevron_right, color: Colors.grey[400], size: 28),
                        ]),
                      ),
                    ),
                  );
                }),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
