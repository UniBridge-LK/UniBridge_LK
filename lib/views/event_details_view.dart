import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:chat_with_aks/models/event_model.dart';

class EventDetailsView extends StatefulWidget {
  final EventModel event;

  const EventDetailsView({super.key, required this.event});

  @override
  State<EventDetailsView> createState() => _EventDetailsViewState();
}

class _EventDetailsViewState extends State<EventDetailsView> {
  bool _isAttending = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Event Details'),
        elevation: 0,
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
                          widget.event.title,
                          style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                        ),
                      ),
                      Container(
                        padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(
                          color: Colors.blue.shade100,
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          widget.event.category,
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.blue.shade900,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 16),
                  // Date, Time, Location
                  _buildInfoRow(Icons.calendar_today, widget.event.date),
                  SizedBox(height: 12),
                  _buildInfoRow(Icons.access_time, widget.event.time),
                  SizedBox(height: 12),
                  _buildInfoRow(Icons.location_on, widget.event.location),
                  SizedBox(height: 24),

                  // Hosted By
                  Text(
                    'Hosted by',
                    style: TextStyle(fontSize: 14, color: Colors.grey),
                  ),
                  SizedBox(height: 8),
                  GestureDetector(
                    onTap: () {
                      // Navigate to host profile
                      // For now, just show a snackbar
                      Get.snackbar(
                        'Profile',
                        'View ${widget.event.hostName} profile',
                        snackPosition: SnackPosition.BOTTOM,
                      );
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
                              widget.event.hostAvatar,
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                color: Colors.blue.shade900,
                              ),
                            ),
                          ),
                          SizedBox(width: 12),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                widget.event.hostName,
                                style: TextStyle(
                                  fontWeight: FontWeight.w600,
                                  fontSize: 14,
                                ),
                              ),
                              Text(
                                widget.event.host,
                                style: TextStyle(fontSize: 12, color: Colors.grey),
                              ),
                            ],
                          ),
                          Spacer(),
                          Icon(Icons.arrow_forward, color: Colors.grey),
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
                    widget.event.description,
                    style: TextStyle(fontSize: 14, color: Colors.grey.shade800, height: 1.6),
                  ),
                  SizedBox(height: 32),

                  // Attendees
                  Text(
                    '${widget.event.attendeeCount} people attending',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  SizedBox(height: 12),
                  Container(
                    width: double.infinity,
                    padding: EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.blue.shade50,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      children: [
                        for (int i = 0; i < (widget.event.attendeeCount > 5 ? 5 : widget.event.attendeeCount); i++)
                          Positioned(
                            left: i * 30.0,
                            child: CircleAvatar(
                              radius: 18,
                              backgroundColor: Colors.blue.shade100,
                              child: Text(
                                'A${i + 1}',
                                style: TextStyle(fontSize: 10),
                              ),
                            ),
                          ),
                        SizedBox(width: 150),
                        if (widget.event.attendeeCount > 5)
                          Text(
                            '+${widget.event.attendeeCount - 5} more',
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                              color: Colors.blue.shade900,
                            ),
                          ),
                      ],
                    ),
                  ),
                  SizedBox(height: 32),

                  // Share Button
                  SizedBox(
                    width: double.infinity,
                    height: 48,
                    child: OutlinedButton.icon(
                      onPressed: () {
                        Get.snackbar(
                          'Share',
                          'Event shared! (mock)',
                          snackPosition: SnackPosition.BOTTOM,
                        );
                      },
                      icon: Icon(Icons.share),
                      label: Text('Share Event'),
                    ),
                  ),
                  SizedBox(height: 12),

                  // Attend Button
                  SizedBox(
                    width: double.infinity,
                    height: 48,
                    child: ElevatedButton.icon(
                      onPressed: () {
                        setState(() {
                          _isAttending = !_isAttending;
                        });
                        Get.snackbar(
                          _isAttending ? 'Attending' : 'Not Attending',
                          _isAttending
                              ? 'You are attending this event'
                              : 'You cancelled your attendance',
                          snackPosition: SnackPosition.BOTTOM,
                        );
                      },
                      icon: Icon(_isAttending ? Icons.check_circle : Icons.event_available),
                      label: Text(_isAttending ? 'Attending' : 'I\'m Attending'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: _isAttending ? Colors.green : Colors.blue,
                      ),
                    ),
                  ),
                  SizedBox(height: 20),
                ],
              ),
            ),
          ],
        ),
      ),
    );
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
