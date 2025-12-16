import 'package:cloud_firestore/cloud_firestore.dart' show Timestamp;

class UserModel {
  final String id;
  final String email;
  final String displayName;
  final String photoURL;
  final bool isOnline;
  final bool premiumStatus;
  final String theme;
  final bool notificationsEnabled;
  final String? bio;
  final List<String>? interests;
  final DateTime lastSeen;
  final DateTime createdAt;

  UserModel({
    required this.id,
    required this.email,
    required this.displayName,
    this.photoURL = '',
    this.isOnline = false,
    this.premiumStatus = false,
    this.theme = 'light',
    this.notificationsEnabled = true,
    this.bio,
    this.interests,
    required this.lastSeen,
    required this.createdAt,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'email': email,
      'displayName': displayName,
      'photoURL': photoURL,
      'isOnline': isOnline,
      'premiumStatus': premiumStatus,
      'theme': theme,
      'notificationsEnabled': notificationsEnabled,
      'bio': bio,
      'interests': interests,
      'lastSeen': lastSeen,
      'createdAt': createdAt,
    };
  }

  static UserModel fromMap(Map<String, dynamic> map) {
    // Helper to parse datetime from either Timestamp or int
    DateTime parseDateTime(dynamic value) {
      if (value == null) return DateTime.now();
      if (value is Timestamp) return value.toDate();
      if (value is int) {
        // Handle both milliseconds and microseconds
        return value > 1000000000000 
          ? DateTime.fromMicrosecondsSinceEpoch(value)
          : DateTime.fromMillisecondsSinceEpoch(value);
      }
      return DateTime.now();
    }

    return UserModel(
      id: map['id'] ?? '',
      email: map['email'] ?? '',
      displayName: map['displayName'] ?? '' ,
      photoURL: map['photoURL'] ?? '',
      isOnline: map['isOnline'] ?? false,
      premiumStatus: map['premiumStatus'] ?? false,
      theme: map['theme'] ?? 'light',
      notificationsEnabled: map['notificationsEnabled'] ?? true,
      bio: map['bio'] as String?,
      interests: map['interests'] is List ? List<String>.from(map['interests']) : null,
      lastSeen: parseDateTime(map['lastSeen']),
      createdAt: parseDateTime(map['createdAt']),
    );
  }

  UserModel copyWith({
    String? id,
    String? email,
    String? displayName,
    String? photoURL,
    bool? isOnline,
    bool? premiumStatus,
    String? theme,
    bool? notificationsEnabled,
    String? bio,
    List<String>? interests,
    DateTime? lastSeen,
    DateTime? createdAt,
  }) {
    return UserModel(
      id: id ?? this.id,
      email: email ?? this.email,
      displayName: displayName ?? this.displayName,
      photoURL: photoURL ?? this.photoURL,
      isOnline: isOnline ?? this.isOnline,
      premiumStatus: premiumStatus ?? this.premiumStatus,
      theme: theme ?? this.theme,
      notificationsEnabled: notificationsEnabled ?? this.notificationsEnabled,
      bio: bio ?? this.bio,
      interests: interests ?? this.interests,
      lastSeen: lastSeen ?? this.lastSeen,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}