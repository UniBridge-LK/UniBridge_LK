import 'package:flutter/material.dart';
import 'package:chat_with_aks/theme/app_theme.dart';
import 'package:chat_with_aks/models/mock_data.dart';
import 'package:get/get.dart';

class EventsView extends StatelessWidget {
  const EventsView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Events'),
        backgroundColor: Colors.white,
        foregroundColor: AppTheme.primaryColor,
        elevation: 0,
        actions: [
          IconButton(
            onPressed: () => Get.dialog(const Padding(padding: EdgeInsets.all(24), child: Center(child: SizedBox(width: 320, child: Card(child: Padding(padding: EdgeInsets.all(16), child: Text('New Event creation (mock)'))))))),
            icon: Icon(Icons.add, color: Colors.white),
            color: Colors.indigo,
            tooltip: 'New Event',
          )
        ],
      ),
      body: ListView.builder(
        padding: EdgeInsets.all(16),
        itemCount: mockEvents.length,
        itemBuilder: (c,i) {
          final e = mockEvents[i];
          final date = DateTime.now();
          final day = date.day.toString();
          final month = ['Jan','Feb','Mar','Apr','May','Jun','Jul','Aug','Sep','Oct','Nov','Dec'][date.month-1];

          return Card(
            margin: EdgeInsets.only(bottom:12),
            child: Row(
              children: [
                // Date block
                Container(
                  width:72,
                  padding: EdgeInsets.symmetric(vertical:12),
                  decoration: BoxDecoration(color: Colors.indigo.shade50, borderRadius: BorderRadius.only(topLeft: Radius.circular(4), bottomLeft: Radius.circular(4))),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(day, style: TextStyle(fontSize:20, fontWeight: FontWeight.bold, color: Colors.indigo)),
                      SizedBox(height:4),
                      Text(month, style: TextStyle(color: Colors.indigo)),
                    ],
                  ),
                ),
                Expanded(
                  child: Padding(
                    padding: EdgeInsets.all(12),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Expanded(child: Text(e.title, style: TextStyle(fontSize:16, fontWeight: FontWeight.w700))),
                            Container(padding: EdgeInsets.symmetric(horizontal:8, vertical:4), decoration: BoxDecoration(color: Colors.grey.shade200, borderRadius: BorderRadius.circular(12)), child: Text('Meetup', style: TextStyle(fontSize:12)))
                          ],
                        ),
                        SizedBox(height:8),
                        Row(children: [Icon(Icons.access_time, size:16, color: Colors.grey), SizedBox(width:6), Text(e.time)],),
                        SizedBox(height:6),
                        Row(children: [Icon(Icons.place, size:16, color: Colors.grey), SizedBox(width:6), Text(e.loc)],),
                        SizedBox(height:6),
                        Row(children: [Icon(Icons.group, size:16, color: Colors.grey), SizedBox(width:6), Text('12 going')],),
                      ],
                    ),
                  ),
                ),
                Padding(
                  padding: EdgeInsets.all(12),
                  child: ElevatedButton(
                    onPressed: () { Get.snackbar('RSVP', 'You are marked as attending (mock)'); },
                    style: ElevatedButton.styleFrom(backgroundColor: Colors.green, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24))),
                    child: Text('RSVP'),
                  ),
                )
              ],
            ),
          );
        },
      ),
    );
  }
}
 
