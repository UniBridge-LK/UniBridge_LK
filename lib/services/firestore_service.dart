import 'package:chat_with_aks/models/friend_request_model.dart';
import 'package:chat_with_aks/models/friendship_model.dart';
import 'package:chat_with_aks/models/notification_model.dart';
import 'package:chat_with_aks/models/user_model.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';

class FirestoreService {
  // Firestore related methods would be here
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<void> createUser(UserModel user) async {
    try {
      await _firestore.collection('users').doc(user.id).set(user.toMap());
    } catch (e) {
      throw Exception('Failed to create user: ${e.toString()}');
    }
  }

  Future<UserModel?> getUser(String userId) async {
    try {
      DocumentSnapshot doc = await _firestore.collection('users').doc(userId).get();
      if (doc.exists) {
        return UserModel.fromMap(doc.data() as Map<String, dynamic>);
      }
      return null;
    } catch (e) {
      throw Exception('Failed to get user: ${e.toString()}');
    }
  }

  Future<void> updateUserOnlineStatus(String userId, bool isOnline) async {
    try {
      DocumentSnapshot doc = await _firestore.collection('users').doc(userId).get();
      if (doc.exists) {
        await _firestore.collection('users').doc(userId).update({
          'isOnline': isOnline,
          'lastSeen': DateTime.now().microsecondsSinceEpoch,
        });
      }
    } catch (e) {
      throw Exception('Failed to update user online status: ${e.toString()}');
    }
  }

  Future<void> deleteUser(String userId) async {
    try {
      await _firestore.collection('users').doc(userId).delete();
    } on FirebaseException catch (e) {
      if (e.code == 'permission-denied') {
        // Fallback to soft-delete when rules disallow hard delete
        await _firestore.collection('users').doc(userId).set({
          'isDeleted': true,
          'deletedAt': FieldValue.serverTimestamp(),
        }, SetOptions(merge: true));
      } else {
        throw Exception('Failed to delete user: ${e.code} ${e.message}');
      }
    } catch (e) {
      throw Exception('Failed to delete user: ${e.toString()}');
    }
  }

  Stream<UserModel?> getUserStream(String userId) {
    return _firestore.collection('users')
    .doc(userId).snapshots()
    .map((doc) => doc.exists ? UserModel.fromMap(doc.data()!) : null);
  }

  Future<void> UpdateUser(UserModel user) async {
    try {
      await _firestore.collection('users').doc(user.id).update(user.toMap());
    } catch (e) {
      throw Exception('Failed to update user');
    }
  }

  Stream<List<UserModel>> getUsersStream() {
    return _firestore.collection('users').snapshots().map((snapshot) =>
      snapshot.docs.map((doc) => UserModel.fromMap(doc.data())).toList()
    );
  }

  // friend Request Collection
  Future<void> sendFriendRequest(FriendRequestModel request) async {
    try {
      await _firestore
      .collection('friend_requests').doc(request.id).set(request.toMap());

      String notificationId = 'friend_request_${request.senderId}_${request.receiverId}_${DateTime.now().millisecondsSinceEpoch}';

      await createNotification(
        NotificationModel(
          id: notificationId,
          userId: request.receiverId,
          title: 'New Friend Request',
          body: 'You have a new friend request from ${request.senderId}',
          type: NotificationType.friendRequests,
          data: {
            'senderId': request.senderId,
            'receiverId': request.receiverId,
            'requestId': request.id,
          },
          createdAt: DateTime.now(),
        )
      );
    } catch (e) {
      throw Exception('Failed to send friend request: ${e.toString()}');
    }

    
  }

  Future<void> cancelFriendRequest(String requestId) async {
    try {
      DocumentSnapshot requestDoc = await _firestore
      .collection('friend_requests').doc(requestId).get();

      if (requestDoc.exists) {
        FriendRequestModel request = FriendRequestModel.fromMap(
          requestDoc.data() as Map<String, dynamic>);

        await _firestore.collection('friend_requests').doc(requestId).delete();

        await deleteNotificationByTypeAndUser(
          request.receiverId,
          NotificationType.friendRequests,
          request.senderId
        );        
        
      }
      
    } catch (e) {
      throw Exception('Failed to cancel friend request: ${e.toString()}');
    }
  }

  Future<void> responseToFriendRequest(String requestId, FriendRequestStatus status) async {
    try {
      await _firestore.collection('friend_requests').doc(requestId).update({
          'status': status.name,
          'respondedAt': DateTime.now().millisecondsSinceEpoch,
        });

      DocumentSnapshot requestDoc = await _firestore
      .collection('friend_requests')
      .doc(requestId)
      .get();

      if (requestDoc.exists) {
        FriendRequestModel request = FriendRequestModel.fromMap(
          requestDoc.data() as Map<String, dynamic>);

        if (status == FriendRequestStatus.accepted) {
        await createFriendship(request.senderId, request.receiverId);

        await createNotification(
          NotificationModel(
            id: DateTime.now().millisecondsSinceEpoch.toString(),
            userId: request.senderId,
            title: 'Friend Request Accepted',
            body: '${request.receiverId} has accepted your friend request',
            type: NotificationType.friendRequestAccepted,
            data: {
              'senderId': request.receiverId,
              'receiverId': request.senderId,
              'requestId': request.id,
            },
            createdAt: DateTime.now(),
          )
        );

        await _removeNotificationForCancelledRequest(
          request.receiverId,          
          request.senderId
        );        
      }
      else if (status == FriendRequestStatus.declined) {
        await createNotification(
          NotificationModel(
            id: DateTime.now().millisecondsSinceEpoch.toString(),
            userId: request.senderId,
            title: 'Friend Request Declined',
            body: '${request.receiverId} has declined your friend request',
            type: NotificationType.friendRequestRejected,
            data: {
              'senderId': request.receiverId,
              'receiverId': request.senderId,
              'requestId': request.id,
            },
            createdAt: DateTime.now(),
          )
        );

        await _removeNotificationForCancelledRequest(
          request.receiverId,          
          request.senderId
        );               
      }
      }
      
      
    } catch (e) {
      throw Exception('Failed to respond to friend request: ${e.toString()}');
    }
  }

  Stream<List<FriendRequestModel>> getFriendRequestsStream(String userId) {
    return _firestore.collection('friend_requests')
    .where('receiverId', isEqualTo: userId)
    .where('status', isEqualTo: 'pending')
    .orderBy('createdAt', descending: true)
    .snapshots()
    .map((snapshot) => snapshot.docs
      .map((doc) => FriendRequestModel.fromMap(doc.data()))
      .toList()
    );
  }

  Stream<List<FriendRequestModel>> getSentFriendRequestsStream(String userId) {
    return _firestore.collection('friend_requests')
    .where('senderId', isEqualTo: userId)
    .where('status', isEqualTo: 'pending')
    .orderBy('createdAt', descending: true)
    .snapshots()
    .map((snapshot) => snapshot.docs
      .map((doc) => FriendRequestModel.fromMap(doc.data()))
      .toList()
    );
  }

  Future<FriendRequestModel> getFriendRequest(String senderId, String receiverId) async {
    try {
      QuerySnapshot query = await _firestore.collection('friend_requests')
      .where('senderId', isEqualTo: senderId)
      .where('receiverId', isEqualTo: receiverId)
      .where('status', isEqualTo: 'pending')
      .get();

      if (query.docs.isNotEmpty) {
        return FriendRequestModel.fromMap(
          query.docs.first.data() as Map<String, dynamic>);
      } else {
        throw Exception('No pending friend request found');
      }
    } catch (e) {
      throw Exception('Failed to get friend request: ${e.toString()}');
    }
  }

  Future<void> createFriendship(String userId1, String userId2) async {
    // Implementation for creating friendship between two users
    try{
      List<String> userIds = [userId1, userId2]..sort();
      String friendshipId = '${userIds[0]}_${userIds[1]}';

      FriendshipModel friendship = FriendshipModel(
        id: friendshipId,
        user1Id: userIds[0],
        user2Id: userIds[1],
        createdAt: DateTime.now(),
      );
      await _firestore.collection('friendships').doc(friendshipId).set(friendship.toMap());
    } catch (e) {
      throw Exception('Failed to create friendship: ${e.toString()}');
    }
  }

  Future<void> removeFriendship(String userId1, String userId2) async {
    // Implementation for removing friendship between two users
    try{
      List<String> userIds = [userId1, userId2]..sort();
      String friendshipId = '${userIds[0]}_${userIds[1]}';

      await _firestore.collection('friendships').doc(friendshipId).delete();
      await createNotification(
        NotificationModel(
          id: DateTime.now().millisecondsSinceEpoch.toString(),
          userId: userId2,
          title: 'Friend Removed',
          body: '${userId1} has removed you from their friends list',
          type: NotificationType.friendRemoved,
          data: {
            'userId1': userId1,
            'userId2': userId2,
          },
          createdAt: DateTime.now(),
        )
      );
    } catch (e) {
      throw Exception('Failed to remove friendship: ${e.toString()}');
    }
  }

  Future<void> blockUser(String userId1, String userId2, String blockedBy) async {
    // Implementation for blocking a user
    try{
      List<String> userIds = [userId1, userId2]..sort();
      String friendshipId = '${userIds[0]}_${userIds[1]}';

      await _firestore.collection('friendships').doc(friendshipId).update({
        'isBlocked': true,
        'blockedBy': blockedBy,
      });
    } catch (e) {
      throw Exception('Failed to block user: ${e.toString()}');
    }
  }
  
  Future<void> createNotification(NotificationModel notificationModel) async {}
  
  Future<void> _removeNotificationForCancelledRequest(String receiverId, String senderId) async {}
  
  Future<void> deleteNotificationByTypeAndUser(String receiverId, NotificationType friendRequests, String senderId) async {}
}