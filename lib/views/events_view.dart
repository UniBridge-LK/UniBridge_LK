import 'package:flutter/material.dart';
import 'package:chat_with_aks/theme/app_theme.dart';
import 'package:chat_with_aks/models/dummy_events.dart';
import 'package:chat_with_aks/views/event_details_view.dart';
import 'package:chat_with_aks/views/add_event_view.dart';
import 'package:chat_with_aks/widgets/premium_popup.dart';
import 'package:get/get.dart';

class EventsView extends StatelessWidget {
  const EventsView({super.key});

  bool isPremiumUser() {
    // Simple premium check
    return false; // For now, assume non-premium
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Events'),
        backgroundColor: Colors.white,
        foregroundColor: AppTheme.primaryColor,
        elevation: 0,
        automaticallyImplyLeading: false,
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          if (isPremiumUser()) {
            Get.to(() => AddEventView());
          } else {
            Get.dialog(const PremiumPopup());
          }
        },
        backgroundColor: AppTheme.primaryColor,
        child: Icon(Icons.add, color: Colors.white),
      ),
      body: ListView.builder(
        padding: EdgeInsets.all(16),
        itemCount: dummyEvents.length,
        itemBuilder: (context, index) {
          final event = dummyEvents[index];

          return Container(
            margin: EdgeInsets.only(bottom: 16),
            decoration: BoxDecoration(
              border: Border(left: BorderSide(color: Colors.teal.shade600, width: 4)),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Card(
              elevation: 2,
              margin: EdgeInsets.zero,
              child: Padding(
                padding: EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Event Title & Category
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: Text(
                            event.title,
                            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                          ),
                        ),
                        Container(
                          padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: Colors.grey.shade200,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            event.category,
                            style: TextStyle(fontSize: 11, color: Colors.grey.shade700),
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 12),

                    // Date, Time, Location
                    Row(
                      children: [
                        Icon(Icons.calendar_today, size: 16, color: Colors.grey),
                        SizedBox(width: 8),
                        Text(event.date, style: TextStyle(fontSize: 13, color: Colors.grey)),
                        SizedBox(width: 16),
                        Icon(Icons.access_time, size: 16, color: Colors.grey),
                        SizedBox(width: 8),
                        Text(event.time, style: TextStyle(fontSize: 13, color: Colors.grey)),
                      ],
                    ),
                    SizedBox(height: 8),
                    Row(
                      children: [
                        Icon(Icons.location_on, size: 16, color: Colors.grey),
                        SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            event.location,
                            style: TextStyle(fontSize: 13, color: Colors.grey),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 12),

                    // Hosted By
                    Row(
                      children: [
                        Icon(Icons.person, size: 16, color: Colors.grey),
                        SizedBox(width: 8),
                        Text('Hosted by: ', style: TextStyle(fontSize: 12, color: Colors.grey)),
                        GestureDetector(
                          onTap: () {
                            Get.snackbar(
                              'Profile',
                              'View ${event.hostName} profile',
                              snackPosition: SnackPosition.BOTTOM,
                            );
                          },
                          child: Text(
                            event.hostName,
                            style: TextStyle(
                              fontSize: 12,
                              color: AppTheme.primaryColor,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 12),

                    // Attendees
                    Row(
                      children: [
                        Icon(Icons.group, size: 16, color: Colors.grey),
                        SizedBox(width: 8),
                        Text(
                          '${event.attendeeCount} attending',
                          style: TextStyle(fontSize: 13, color: Colors.grey),
                        ),
                      ],
                    ),
                    SizedBox(height: 16),

                    // View Details Button
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => EventDetailsView(event: event),
                            ),
                          );
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppTheme.primaryColor,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                        ),
                        child: Text('View Details'),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}

 
