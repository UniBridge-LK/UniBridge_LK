import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:unibridge_lk/models/event_model.dart';
import 'package:unibridge_lk/views/add_event_view.dart';
import 'package:unibridge_lk/views/user_profile_view.dart';
import 'package:unibridge_lk/services/firestore_service.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class EventDetailsView extends StatefulWidget {
  final EventModel event;

  const EventDetailsView({super.key, required this.event});

  @override
  State<EventDetailsView> createState() => _EventDetailsViewState();
}

class _EventDetailsViewState extends State<EventDetailsView> {
  late EventModel _currentEvent;

  @override
  void initState() {
    super.initState();
    _currentEvent = widget.event;
    _reloadEventData();
  }

  Future<void> _reloadEventData() async {
    try {
      final doc = await FirebaseFirestore.instance
          .collection('events')
          .doc(widget.event.id)
          .get();

      if (doc.exists) {
        final data = doc.data()!;
        
        // Parse event date/time
        DateTime eventDateTime = DateTime.now();
        if (data['eventDate'] != null) {
          final timestamp = data['eventDate'] as Timestamp;
          eventDateTime = timestamp.toDate();
        }

        setState(() {
          _currentEvent = EventModel(
            id: doc.id,
            title: data['title'] ?? '',
            date: _formatDate(eventDateTime),
            time: _formatTime(eventDateTime),
            location: data['location'] ?? '',
            host: data['hostOrganization'] ?? '',
            hostId: data['hostId'] ?? '',
            hostName: data['hostName'] ?? '',
            hostAvatar: _getAvatarLetter(data['hostName'] ?? ''),
            description: data['description'] ?? '',
            category: data['category'] ?? 'Event',
            attendeeCount: data['attendeeCount'] ?? 0,
            attendees: List<String>.from(data['attendees'] ?? []),
            imageUrl: data['imageUrl'] ?? '',
            eventType: data['eventType'] ?? 'Physical',
            platform: data['platform'],
          );
        });
      }
    } catch (e) {
      // Handle error silently or show message
    }
  }

  String _formatDate(DateTime dateTime) {
    const months = [
      'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'
    ];
    return '${months[dateTime.month - 1]} ${dateTime.day}, ${dateTime.year}';
  }

  String _formatTime(DateTime dateTime) {
    final hour = dateTime.hour;
    final minute = dateTime.minute;
    final ampm = hour >= 12 ? 'PM' : 'AM';
    final displayHour = hour > 12 ? hour - 12 : (hour == 0 ? 12 : hour);
    return '$displayHour:${minute.toString().padLeft(2, '0')} $ampm';
  }

  String _getAvatarLetter(String name) {
    return name.isNotEmpty ? name[0].toUpperCase() : 'U';
  }

  @override
  Widget build(BuildContext context) {
    final currentUserId = FirebaseAuth.instance.currentUser?.uid;
    final isCreator = currentUserId == _currentEvent.hostId;

    return Scaffold(
      appBar: AppBar(
        title: Text('Event Details'),
        elevation: 0,
        actions: isCreator
            ? [
                PopupMenuButton<String>(
                  onSelected: (value) {
                    if (value == 'edit') {
                      _editEvent();
                    } else if (value == 'delete') {
                      _deleteEvent();
                    }
                  },
                  itemBuilder: (context) => [
                    PopupMenuItem(
                      value: 'edit',
                      child: Row(
                        children: [
                          Icon(Icons.edit, size: 20),
                          SizedBox(width: 8),
                          Text('Edit Event'),
                        ],
                      ),
                    ),
                    PopupMenuItem(
                      value: 'delete',
                      child: Row(
                        children: [
                          Icon(Icons.delete, size: 20, color: Colors.red),
                          SizedBox(width: 8),
                          Text('Delete Event', style: TextStyle(color: Colors.red)),
                        ],
                      ),
                    ),
                  ],
                ),
              ]
            : null,
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Event Image/Header
            Container(
              width: double.infinity,
              height: 200,
              color: Colors.blue.shade100,
              child: Center(
                child: Icon(Icons.event, size: 80, color: Colors.blue.shade400),
              ),
            ),

            // Event Title & Category
            Padding(
              padding: EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Text(
                          _currentEvent.title,
                          style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                        ),
                      ),
                      
                    ],
                  ),
                  SizedBox(height: 16),
                  // Date, Time, Location
                  _buildInfoRow(Icons.calendar_today, _currentEvent.date),
                  SizedBox(height: 12),
                  _buildInfoRow(Icons.access_time, _currentEvent.time),
                  SizedBox(height: 12),
                  _buildInfoRow(
                    _currentEvent.eventType == 'Online' ? Icons.video_call : Icons.location_on,
                    _currentEvent.eventType == 'Online'
                        ? (_currentEvent.platform ?? 'Online Event')
                        : _currentEvent.location,
                  ),
                  SizedBox(height: 24),

                  // Hosted By
                  if (_currentEvent.host.isNotEmpty) ...[
                    Text(
                      'Hosted by',
                      style: TextStyle(fontSize: 14, color: Colors.grey),
                    ),
                    SizedBox(height: 8),
                    Container(
                      padding: EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.grey.shade100,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Row(
                        children: [
                          Icon(Icons.business, color: Colors.blue.shade700, size: 20),
                          SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              _currentEvent.host,
                              style: TextStyle(
                                fontWeight: FontWeight.w600,
                                fontSize: 14,
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                    ),
                    SizedBox(height: 16),
                  ],

                  // Created By
                  Text(
                    'Created by',
                    style: TextStyle(fontSize: 14, color: Colors.grey),
                  ),
                  SizedBox(height: 8),
                  GestureDetector(
                    onTap: () async {
                      // Navigate to creator profile
                      try {
                        final firestoreService = FirestoreService();
                        final user = await firestoreService.getUser(_currentEvent.hostId);
                        if (user != null) {
                          Get.to(() => UserProfileView(), arguments: user);
                        } else {
                          Get.snackbar('Error', 'User profile not found',
                              snackPosition: SnackPosition.BOTTOM);
                        }
                      } catch (e) {
                        Get.snackbar('Error', 'Failed to load profile',
                            snackPosition: SnackPosition.BOTTOM);
                      }
                    },
                    child: Container(
                      padding: EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.grey.shade100,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Row(
                        children: [
                          CircleAvatar(
                            radius: 20,
                            backgroundColor: Colors.blue.shade100,
                            child: Text(
                              _currentEvent.hostAvatar,
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                color: Colors.blue.shade900,
                              ),
                            ),
                          ),
                          SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              _currentEvent.hostName,
                              style: TextStyle(
                                fontWeight: FontWeight.w600,
                                fontSize: 14,
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  SizedBox(height: 32),

                  // Description
                  Text(
                    'About this event',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  SizedBox(height: 12),
                  Text(
                    _currentEvent.description,
                    style: TextStyle(fontSize: 14, color: Colors.grey.shade800, height: 1.6),
                  ),
                  SizedBox(height: 32),                                 
                  
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _editEvent() async {
    await Get.to(() => AddEventView(event: _currentEvent));
    // Reload event data after returning from edit
    await _reloadEventData();
  }

  Future<void> _deleteEvent() async {
    final confirmed = await Get.dialog<bool>(
      AlertDialog(
        title: Text('Delete Event'),
        content: Text('Are you sure you want to delete this event? This action cannot be undone.'),
        actions: [
          TextButton(
            onPressed: () => Get.back(result: false),
            child: Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Get.back(result: true),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: Text('Delete'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      try {
        await FirebaseFirestore.instance
            .collection('events')
            .doc(_currentEvent.id)
            .delete();

        Get.back(); // Go back to events list
        Get.snackbar(
          'Success',
          'Event deleted successfully',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.green,
          colorText: Colors.white,
        );
      } catch (e) {
        Get.snackbar(
          'Error',
          'Failed to delete event: $e',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.red,
          colorText: Colors.white,
        );
      }
    }
  }

  Widget _buildInfoRow(IconData icon, String text) {
    return Row(
      children: [
        Icon(icon, size: 20, color: Colors.blue),
        SizedBox(width: 12),
        Expanded(
          child: Text(
            text,
            style: TextStyle(fontSize: 14, color: Colors.grey.shade800),
          ),
        ),
      ],
    );
  }
}
