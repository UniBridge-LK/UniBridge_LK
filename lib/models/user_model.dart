import 'package:cloud_firestore/cloud_firestore.dart' show Timestamp;

class UserModel {
  final String id;
  final String email;
  final String displayName;
  final String photoURL;
  final bool isOnline;
  final DateTime lastSeen;
  final DateTime createdAt;
  final String accountType;
  final String universityName;
  final String faculty;
  final String department;
  final String organizationName;
  final bool isEmailVerified;
  final String role;
  final String theme;
  final bool notificationsEnabled;
  final String? bio;
  final List<String>? interests;
  

  UserModel({
    required this.id,
    required this.email,
    required this.displayName,
    this.photoURL = '',
    this.isOnline = false,
    required this.lastSeen,
    required this.createdAt,
    this.accountType = '',
    this.universityName = '',
    this.faculty = '',
    this.department = '',
    this.organizationName = '',
    this.isEmailVerified = false,
    this.role = 'user',
    this.theme = 'light',
    this.notificationsEnabled = true,
    this.bio,
    this.interests,
    
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'email': email,
      'displayName': displayName,
      'photoURL': photoURL,
      'isOnline': isOnline,
      'lastSeen': lastSeen,
      'createdAt': createdAt,
      'accountType': accountType,
      'universityName': universityName,
      'faculty': faculty,
      'department': department,
      'organizationName': organizationName,
      'isEmailVerified': isEmailVerified,
      'role': role,
      'theme': theme,
      'notificationsEnabled': notificationsEnabled,
      'bio': bio,
      'interests': interests,      
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
      lastSeen: parseDateTime(map['lastSeen']),
      createdAt: parseDateTime(map['createdAt']),
      accountType: map['accountType'] ?? '',
      universityName: map['universityName'] ?? '',
      faculty: map['faculty'] ?? '',
      department: map['department'] ?? '',
      organizationName: map['organizationName'] ?? '',
      isEmailVerified: map['isEmailVerified'] ?? false,
      role: map['role'] ?? 'user',
      theme: map['theme'] ?? 'light',
      notificationsEnabled: map['notificationsEnabled'] ?? true,
      bio: map['bio'] as String?,
      interests: map['interests'] is List ? List<String>.from(map['interests']) : null,
      
    );
  }

  UserModel copyWith({
    String? id,
    String? email,
    String? displayName,
    String? photoURL,
    bool? isOnline,
    DateTime? lastSeen,
    DateTime? createdAt,
    String? accountType,
    String? universityName,
    String? faculty,
    String? department,
    String? organizationName,
    bool? isEmailVerified,
    String? role,
    String? theme,
    bool? notificationsEnabled,
    String? bio,
    List<String>? interests,    
  }) {
    return UserModel(
      id: id ?? this.id,
      email: email ?? this.email,
      displayName: displayName ?? this.displayName,
      photoURL: photoURL ?? this.photoURL,
      isOnline: isOnline ?? this.isOnline,
      lastSeen: lastSeen ?? this.lastSeen,
      createdAt: createdAt ?? this.createdAt,
      accountType: accountType ?? this.accountType,
      universityName: universityName ?? this.universityName,
      faculty: faculty ?? this.faculty,
      department: department ?? this.department,
      organizationName: organizationName ?? this.organizationName,
      isEmailVerified: isEmailVerified ?? this.isEmailVerified,
      role: role ?? this.role,
      theme: theme ?? this.theme,
      notificationsEnabled: notificationsEnabled ?? this.notificationsEnabled,
      bio: bio ?? this.bio,
      interests: interests ?? this.interests,      
    );
  }
}