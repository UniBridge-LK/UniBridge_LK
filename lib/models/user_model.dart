import 'package:cloud_firestore/cloud_firestore.dart' show Timestamp;
import 'package:firebase_auth/firebase_auth.dart';

class UserModel {
  final String id;
  final String email;
  final String displayName;
  final String photoURL;
  final bool isOnline;
  final DateTime lastSeen;
  final DateTime createdAt;
  final String accountType; // 'individual' or 'organization'
  final String universityName;
  final String faculty;
  final String department;
  final String organizationName;
  final bool isEmailVerified;

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
    );
  }
}