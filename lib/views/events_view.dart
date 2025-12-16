import 'package:flutter/material.dart';
import 'package:chat_with_aks/theme/app_theme.dart';
import 'package:chat_with_aks/views/event_details_view.dart';
import 'package:chat_with_aks/views/add_event_view.dart';
import 'package:chat_with_aks/controllers/events_controller.dart';
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
          Get.to(() => AddEventView());
          // if (isPremiumUser()) {
          //   Get.to(() => AddEventView());
          // } else {
          //   // Show premium popup
          //   Get.dialog(
          //     Dialog(
          //       shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          //       child: Padding(
          //         padding: EdgeInsets.all(24),
          //         child: Column(
          //           mainAxisSize: MainAxisSize.min,
          //           children: [
          //             Icon(Icons.workspace_premium, color: Colors.amber, size: 56),
          //             SizedBox(height: 16),
          //             Text('Unlock Premium',
          //                 style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
          //             SizedBox(height: 12),
          //             Text(
          //               'Access features like Chat Initiation, Event Creation, and unlimited connections with the community (Staff, Students, Alumni).',
          //               textAlign: TextAlign.center,
          //               style: TextStyle(color: Colors.grey[700]),
          //             ),
          //             SizedBox(height: 20),
          //             SizedBox(
          //               width: double.infinity,
          //               height: 48,
          //               child: ElevatedButton(
          //                 onPressed: () {
          //                   Get.back();
          //                   Get.snackbar('Premium', 'Redirecting to payment (mock)');
          //                 },
          //                 style: ElevatedButton.styleFrom(
          //                   backgroundColor: Colors.orange,
          //                   shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
          //                 ),
          //                 child: Text('Buy Premium - LKR 500/mo', style: TextStyle(fontSize: 16)),
          //               ),
          //             )
          //           ],
          //         ),
          //       ),
          //     ),
          //   );
          // }
        },
        backgroundColor: AppTheme.primaryColor,
        child: Icon(Icons.add, color: Colors.white),
      ),
      body: GetBuilder<EventsController>(
        init: EventsController(),
        builder: (controller) {
          return Obx(() {
            if (controller.isLoading) {
              return Center(
                child: CircularProgressIndicator(color: AppTheme.primaryColor),
              );
            }

            if (controller.error.isNotEmpty) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.error_outline, color: Colors.red, size: 48),
                    SizedBox(height: 16),
                    Text('Error loading events'),
                    SizedBox(height: 12),
                    ElevatedButton(
                      onPressed: controller.refreshEvents,
                      child: Text('Retry'),
                    ),
                  ],
                ),
              );
            }

            if (controller.events.isEmpty) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.event_note, color: Colors.grey, size: 48),
                    SizedBox(height: 16),
                    Text('No events available'),
                  ],
                ),
              );
            }

            return ListView.builder(
              padding: EdgeInsets.all(16),
              itemCount: controller.events.length,
              itemBuilder: (context, index) {
                final event = controller.events[index];

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
                        Icon(
                          event.eventType == 'Online' 
                            ? Icons.video_call 
                            : Icons.location_on,
                          size: 16,
                          color: Colors.grey,
                        ),
                        SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            event.eventType == 'Online'
                              ? (event.platform ?? 'Online Event')
                              : event.location,
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
                        Expanded(
                          child: GestureDetector(
                            onTap: () {
                              Get.snackbar(
                                'Profile',
                                'View ${event.host} profile',
                                snackPosition: SnackPosition.BOTTOM,
                              );
                            },
                            child: Text(
                              event.host,
                              style: TextStyle(
                                fontSize: 12,
                                color: AppTheme.primaryColor,
                                fontWeight: FontWeight.w600,
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 12),                   

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
            );
            },
          );
        },
      ),
    );
  }
}
