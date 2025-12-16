import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter/foundation.dart';

class FirestoreSeedService {
  static const _seedKey = 'firestore_seeded';
  static final _db = FirebaseFirestore.instance;

  static Future<void> seedIfNeeded() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final seeded = prefs.getBool(_seedKey) ?? false;
      if (!seeded) {
        // Add timeout to prevent hanging
        await _seedAll().timeout(
          const Duration(seconds: 10),
          onTimeout: () {
            throw Exception('Firestore seeding timed out - may not have internet connection');
          },
        );
        await prefs.setBool(_seedKey, true);
      }
    } catch (e) {
      // Don't block app startup if seeding fails
      debugPrint('Firestore seeding failed: $e');
      rethrow;
    }
  }

  static Future<void> _seedAll() async {
    await _seedUsers();
    await _seedForumThreads();
    await _seedEvents();
  }

  static Future<void> _seedUsers() async {
    final users = [
      {
        'id': 'u1_mock',
        'email': 'john@example.com',
        'displayName': 'John Doe',
        'premiumStatus': false,
      },
      {
        'id': 'user_2',
        'email': 'alice@example.com',
        'displayName': 'Alice Johnson',
        'premiumStatus': true,
      },
      {
        'id': 'user_3',
        'email': 'bob@example.com',
        'displayName': 'Bob Smith',
        'premiumStatus': false,
      },
    ];

    for (final user in users) {
      await _db.collection('users').doc(user['id'] as String).set(user);
    }
  }

  static Future<void> _seedForumThreads() async {
    // Global threads
    final globalThreads = [
      {
        'id': 'global_thread_1',
        'title': 'Welcome to UniBridge Forum!',
        'content':
            'This is the global forum where you can discuss topics that interest the entire UniBridge community.',
        'ownerId': 'u1_mock',
        'ownerName': 'John Doe',
        'scope': 'global',
        'scopeId': 'global',
        'replies': [
          {
            'id': 'reply_1',
            'content': 'Great initiative! Looking forward to connecting with peers.',
            'senderId': 'user_2',
            'senderName': 'Alice Johnson',
            'nestedReplies': [
              {
                'id': 'nested_1',
                'content': 'Same here! The cross-university perspective is invaluable.',
                'senderId': 'user_3',
                'senderName': 'Bob Smith',
              }
            ]
          },
        ]
      },
      {
        'id': 'global_thread_2',
        'title': 'Best Online Learning Resources for CS',
        'content':
            'Looking for high-quality online courses. What platforms do you recommend? Interested in algorithms, web dev, AI/ML.',
        'ownerId': 'user_2',
        'ownerName': 'Alice Johnson',
        'scope': 'global',
        'scopeId': 'global',
        'replies': [
          {
            'id': 'reply_2',
            'content': 'I highly recommend Coursera for CS specializations.',
            'senderId': 'user_3',
            'senderName': 'Bob Smith',
            'nestedReplies': []
          },
        ]
      },
    ];

    for (final thread in globalThreads) {
      await _seedThread('global', 'global', thread);
    }

    // University threads
    final uniThreads = [
      {
        'id': 'uni_thread_1',
        'title': 'Campus Housing Advice',
        'content': 'Recommendations for on-campus housing options',
        'ownerId': 'user_3',
        'ownerName': 'Bob Smith',
        'scope': 'university',
        'scopeId': 'moratuwa',
        'replies': [
          {
            'id': 'reply_3',
            'content': 'I recommend Colombo Hall, great community!',
            'senderId': 'u1_mock',
            'senderName': 'John Doe',
            'nestedReplies': []
          },
        ]
      },
    ];

    for (final thread in uniThreads) {
      await _seedThread('university', 'moratuwa', thread);
    }

    // Faculty threads
    final facThreads = [
      {
        'id': 'fac_thread_1',
        'title': 'Engineering Projects Showcase',
        'content': 'Share your best engineering projects and get feedback',
        'ownerId': 'user_2',
        'ownerName': 'Alice Johnson',
        'scope': 'faculty',
        'scopeId': 'engineering',
        'replies': [
          {
            'id': 'reply_4',
            'content': 'Amazing project on structural design!',
            'senderId': 'user_3',
            'senderName': 'Bob Smith',
            'nestedReplies': []
          },
        ]
      },
    ];

    for (final thread in facThreads) {
      await _seedThread('faculty', 'engineering', thread);
    }

    // Department threads
    final deptThreads = [
      {
        'id': 'dept_thread_1',
        'title': 'Civil Engineering Internships',
        'content': 'Discussing internship opportunities in civil engineering',
        'ownerId': 'user_3',
        'ownerName': 'Bob Smith',
        'scope': 'department',
        'scopeId': 'civil',
        'replies': [
          {
            'id': 'reply_5',
            'content': 'Great opportunities at major construction companies',
            'senderId': 'u1_mock',
            'senderName': 'John Doe',
            'nestedReplies': []
          },
        ]
      },
    ];

    for (final thread in deptThreads) {
      await _seedThread('department', 'civil', thread);
    }
  }

  static Future<void> _seedThread(String scope, String scopeId, Map<String, dynamic> thread) async {
    final threadId = thread['id'] as String;
    final threadData = {
      'id': threadId,
      'title': thread['title'],
      'content': thread['content'],
      'ownerId': thread['ownerId'],
      'ownerName': thread['ownerName'],
      'scope': scope,
      'scopeId': scopeId,
      'timestamp': Timestamp.now(),
      'likeCount': 0,
      'replyCount': (thread['replies'] as List?)?.length ?? 0,
    };

    final docRef = _db
        .collection('forums')
        .doc(scope)
        .collection(scopeId)
        .doc(threadId);

    await docRef.set(threadData);

    // Seed replies
    final replies = (thread['replies'] as List?) ?? [];
    for (var i = 0; i < replies.length; i++) {
      final reply = replies[i];
      final replyId = reply['id'] as String;
      final replyData = {
        'id': replyId,
        'content': reply['content'],
        'senderId': reply['senderId'],
        'senderName': reply['senderName'],
        'timestamp': Timestamp.now(),
        'nestedReplies': (reply['nestedReplies'] as List?)?.isNotEmpty ?? false ? 1 : 0,
      };

      await docRef
          .collection('replies')
          .doc(replyId)
          .set(replyData);

      // Seed nested replies if present
      final nestedReplies = (reply['nestedReplies'] as List?) ?? [];
      for (final nestedReply in nestedReplies) {
        await docRef
            .collection('replies')
            .doc(replyId)
            .collection('nested')
            .doc(nestedReply['id'])
            .set({
              'id': nestedReply['id'],
              'content': nestedReply['content'],
              'senderId': nestedReply['senderId'],
              'senderName': nestedReply['senderName'],
              'timestamp': Timestamp.now(),
            });
      }
    }
  }

  static Future<void> _seedEvents() async {
    final events = [
      {
        'id': 'event_1',
        'title': 'Tech Meetup 2024',
        'description': 'Annual tech meetup featuring industry experts',
        'date': Timestamp.fromDate(DateTime.now().add(const Duration(days: 7))),
        'location': 'University Auditorium',
        'attendeeCount': 45,
        'eventCategory': 'Technology',
      },
      {
        'id': 'event_2',
        'title': 'Career Fair',
        'description': 'Connect with top companies for internships and job opportunities',
        'date': Timestamp.fromDate(DateTime.now().add(const Duration(days: 14))),
        'location': 'Main Campus',
        'attendeeCount': 120,
        'eventCategory': 'Career',
      },
      {
        'id': 'event_3',
        'title': 'Sports Day',
        'description': 'Inter-faculty sports competition',
        'date': Timestamp.fromDate(DateTime.now().add(const Duration(days: 21))),
        'location': 'Sports Complex',
        'attendeeCount': 80,
        'eventCategory': 'Sports',
      },
    ];

    for (final event in events) {
      await _db.collection('events').doc(event['id'] as String).set(event);
    }
  }
}

