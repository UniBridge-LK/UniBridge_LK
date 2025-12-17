# UniBridge LK

Connecting the dots between Schools and Universities

## Overview

UniBridge LK is a comprehensive Flutter-based social networking and communication platform designed to connect students, staff, and alumni across universities and educational institutions in Sri Lanka. The app facilitates peer-to-peer communication, event discovery, forum discussions, and community engagement.

## Features

### Core Features
- **User Authentication**: Secure email/password and OTP verification
- **People Discovery**: Browse and connect with users across universities
- **Real-time Messaging**: Direct chat with message editing and deletion
- **Friend Requests**: Send, accept, and manage connection requests
- **Event Management**: Create, discover, and manage events
- **Forum Discussions**: Global, university-specific, faculty, and department forums
- **User Profiles**: Comprehensive profiles with university and department info

### Advanced Features
- **Message Timestamps**: View exact times for sent messages
- **Connection Status Tracking**: Connected, Pending, Request Sent states
- **Search & Filtering**: Search universities, faculties, departments, and people
- **Unread Message Tracking**: Badge notifications for unread chats
- **Message Status Indicators**: Pending, Sent, Delivered, Seen statuses
- **Message Editing & Deletion**: Edit and soft-delete messages with visual indicators
- **Offline Support**: Local caching with Hive and cloud sync

## Tech Stack

### Frontend
- **Framework**: Flutter (latest)
- **State Management**: GetX
- **Local Storage**: Hive
- **Networking**: Cloud Firestore real-time streams

### Backend
- **Database**: Firebase Firestore
- **Authentication**: Firebase Authentication
- **Cloud Functions**: Firebase Cloud Functions (for email notifications)
- **Storage**: Firebase Storage

### Development Tools
- Dart SDK
- Flutter SDK
- Firebase CLI

## Project Structure

```
lib/
├── controllers/          # GetX controllers for state management
│   ├── home_controller.dart
│   ├── chat_controller.dart
│   ├── main_controller.dart
│   └── people_controller.dart
├── models/              # Data models
│   ├── user_model.dart
│   ├── chat_models.dart
│   ├── event_model.dart
│   ├── university_model.dart
│   └── thread_model.dart
├── services/            # Business logic & API calls
│   ├── firestore_service.dart
│   ├── chat_sync_service.dart
│   ├── chat_hive_service.dart
│   └── chat_cloud_service.dart
├── views/               # UI screens
│   ├── home_view.dart
│   ├── chats_view.dart
│   ├── people_view.dart
│   ├── events_view.dart
│   ├── forum_view.dart
│   └── home_hierarchy/  # University/Faculty/Department views
├── widgets/             # Reusable widgets
├── routes/              # Route configuration
├── theme/               # App theming
└── main.dart

android/                # Android-specific files
ios/                    # iOS-specific files
functions/              # Firebase Cloud Functions (Node.js)
extensions/             # Firebase extensions config
```

## Setup & Installation

### Prerequisites
- Flutter SDK (3.0+)
- Dart SDK (3.0+)
- Firebase project with Firestore enabled
- Android SDK / Xcode (for testing)

### Getting Started

1. **Clone the repository**
   ```bash
   git clone https://github.com/yourusername/uniBridge-lk.git
   cd uniBridge-lk
   ```

2. **Install dependencies**
   ```bash
   flutter pub get
   ```

3. **Configure Firebase**
   - Download `google-services.json` from Firebase Console and place in `android/app/`
   - Download `GoogleService-Info.plist` from Firebase Console and place in `ios/Runner/`
   - Generate `lib/firebase_options.dart`:
     ```bash
     flutterfire configure
     ```

4. **Set up environment variables**
   - Create `.env` files in `extensions/` and `functions/` directories with necessary API keys (not tracked in git)

5. **Run the app**
   ```bash
   flutter run
   ```

## Key Features Documentation

### Chat System
- Real-time messaging with Firestore
- Local caching with Hive for offline support
- Message sync when connection is restored
- Edit and delete messages with timestamps
- Message read receipts and delivery status

### Connection Management
- Send friend requests with optional notes
- Accept/reject requests from the Requests tab
- Auto-create chat conversations on acceptance
- View connection status in real-time

### Event System
- Create events with location/platform details
- Support for both physical and online events
- Search events and filter by university
- Attended/pending tracking

### Forum
- Global forums for all users
- University-specific discussion threads
- Faculty and department-level forums
- Thread replies and nested discussions

## Security & Privacy

- Firebase Authentication with email verification
- Cloud Firestore security rules enforce user-level access control
- Sensitive configs (Firebase keys, environment variables) ignored in `.gitignore`
- Message data encrypted at rest by Firebase
- Soft deletes for audit trail

## Firebase Security Rules

Firestore rules enforce:
- Users can only read/write their own profile
- Chats accessible only to participants
- Friend requests visible only to sender/receiver
- Forum data readable by all, writable by authenticated users

## Future Enhancements

- [ ] Voice/video calling
- [ ] Group chats
- [ ] Media sharing (images, documents)
- [ ] Notification preferences
- [ ] Dark mode
- [ ] Push notifications
- [ ] Premium subscription features
- [ ] User blocking/reporting system

## Contributing

Contributions are welcome! Please follow these steps:
1. Fork the repository
2. Create a feature branch (`git checkout -b feature/your-feature`)
3. Commit changes (`git commit -m 'Add your feature'`)
4. Push to branch (`git push origin feature/your-feature`)
5. Open a Pull Request

## License

This project is licensed under the MIT License - see the LICENSE file for details.

## Contact & Support

For questions or issues, please open an issue on GitHub or contact the development team.

---

**Last Updated**: December 17, 2025