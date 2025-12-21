import 'package:unibridge_lk/models/event_model.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:get/get.dart';

class EventsController extends GetxController {
  final RxList<EventModel> _events = <EventModel>[].obs;
  final RxBool _isLoading = false.obs;
  final RxString _error = ''.obs;

  List<EventModel> get events => _events;
  bool get isLoading => _isLoading.value;
  String get error => _error.value;

  @override
  void onInit() {
    super.onInit();
    _loadEvents();
  }

  void _loadEvents() {
    try {
      _isLoading.value = true;
      _error.value = '';
      
      // Bind stream to get real-time updates from Firestore
      _events.bindStream(
        FirebaseFirestore.instance
            .collection('events')
            .orderBy('eventDate', descending: false)
            .snapshots()
            .map((snapshot) {
          return snapshot.docs
              .map((doc) => _parseEventFromMap(doc.data(), doc.id))
              .toList();
        }),
      );
    } catch (e) {
      _error.value = e.toString();
      debugPrint('Error loading events: $e');
    } finally {
      _isLoading.value = false;
    }
  }

  EventModel _parseEventFromMap(Map<String, dynamic> data, String docId) {
    // Parse Firestore timestamp
    DateTime eventDateTime = DateTime.now();
    if (data['eventDate'] != null) {
      final timestamp = data['eventDate'];
      if (timestamp is Timestamp) {
        eventDateTime = timestamp.toDate();
      }
    }

    // Format date and time
    final date = _formatDate(eventDateTime);
    final time = _formatTime(eventDateTime);

    return EventModel(
      id: docId,
      title: data['title'] ?? '',
      date: date,
      time: time,
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

  void refreshEvents() {
    _loadEvents();
  }

  Future<bool> addEvent({
    required String title,
    required DateTime eventDate,
    required String location,
    required String hostOrganization,
    required String description,
    String category = 'Event',
    String imageUrl = '',
    String eventType = 'Physical',
    String? platform,
    String? registrationLink,
  }) async {
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) {
        Get.snackbar(
          'Error',
          'You must be logged in to create an event',
          snackPosition: SnackPosition.BOTTOM,
        );
        return false;
      }

      // Get user data from Firestore
      final userDoc = await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .get();

      final userName = userDoc.data()?['displayName'] ?? user.displayName ?? 'Unknown User';

      // Create event document
      await FirebaseFirestore.instance.collection('events').add({
        'title': title,
        'eventDate': Timestamp.fromDate(eventDate),
        'location': location,
        'hostOrganization': hostOrganization,
        'hostId': user.uid,
        'hostName': userName,
        'description': description,
        'category': category,
        'attendeeCount': 0,
        'attendees': [],
        'imageUrl': imageUrl,
        'eventType': eventType,
        'platform': platform,
        'registrationLink': registrationLink,
        'createdAt': FieldValue.serverTimestamp(),
      });

      Get.snackbar(
        'Success',
        'Event "$title" created successfully!',
        snackPosition: SnackPosition.BOTTOM,
      );
      return true;
    } catch (e) {
      debugPrint('Error adding event: $e');
      Get.snackbar(
        'Error',
        'Failed to create event: $e',
        snackPosition: SnackPosition.BOTTOM,
      );
      return false;
    }
  }

  Future<bool> updateEvent({
    required String eventId,
    required String title,
    required DateTime eventDate,
    required String location,
    required String hostOrganization,
    required String description,
    String category = 'Event',
    String imageUrl = '',
    String eventType = 'Physical',
    String? platform,
    String? registrationLink,
  }) async {
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) {
        Get.snackbar(
          'Error',
          'You must be logged in to update an event',
          snackPosition: SnackPosition.BOTTOM,
        );
        return false;
      }

      // Update event document
      await FirebaseFirestore.instance.collection('events').doc(eventId).update({
        'title': title,
        'eventDate': Timestamp.fromDate(eventDate),
        'location': location,
        'hostOrganization': hostOrganization,
        'description': description,
        'category': category,
        'imageUrl': imageUrl,
        'eventType': eventType,
        'platform': platform,
        'registrationLink': registrationLink,
        'updatedAt': FieldValue.serverTimestamp(),
      });

      Get.snackbar(
        'Success',
        'Event "$title" updated successfully!',
        snackPosition: SnackPosition.BOTTOM,
      );
      return true;
    } catch (e) {
      debugPrint('Error updating event: $e');
      Get.snackbar(
        'Error',
        'Failed to update event: $e',
        snackPosition: SnackPosition.BOTTOM,
      );
      return false;
    }
  }
}
