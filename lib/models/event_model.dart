class EventModel {
  final String id;
  final String title;
  final String date; // e.g., "Oct 12, 2024"
  final String time; // e.g., "10:00 AM"
  final String location; // Full location with address
  final String host; // Host organization/club
  final String hostId; // User ID of the event creator
  final String hostName; // Display name of creator
  final String hostAvatar; // Avatar letter of creator
  final String description; // Full event description
  final String category; // e.g., "Workshop", "Seminar", "Meetup"
  final int attendeeCount; // Number of attendees
  final List<String> attendees; // List of attendee IDs
  final String imageUrl; // Event image
  final String eventType; // "Physical" or "Online"
  final String? platform; // e.g., "Zoom", "Google Meet" (for online events)

  EventModel({
    required this.id,
    required this.title,
    required this.date,
    required this.time,
    required this.location,
    required this.host,
    required this.hostId,
    required this.hostName,
    required this.hostAvatar,
    required this.description,
    required this.category,
    required this.attendeeCount,
    required this.attendees,
    required this.imageUrl,
    required this.eventType,
    this.platform,
  });
}
