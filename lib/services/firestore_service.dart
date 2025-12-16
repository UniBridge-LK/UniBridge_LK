import 'package:chat_with_aks/models/chat_models.dart';
import 'package:chat_with_aks/models/friend_request_model.dart';
import 'package:chat_with_aks/models/friendship_model.dart';
import 'package:chat_with_aks/models/message_model.dart';
import 'package:chat_with_aks/models/notification_model.dart';
import 'package:chat_with_aks/models/university_model.dart';
import 'package:chat_with_aks/models/user_model.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:chat_with_aks/models/thread_model.dart';
import 'package:chat_with_aks/models/reply_model.dart';
// firebase_core import removed (not required here)

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

  // Silent delete - removes request without notifying sender (for receiver's Delete action)
  Future<void> deleteFriendRequest(String requestId) async {
    try {
      DocumentSnapshot requestDoc = await _firestore
      .collection('friend_requests').doc(requestId).get();

      if (requestDoc.exists) {
        FriendRequestModel request = FriendRequestModel.fromMap(
          requestDoc.data() as Map<String, dynamic>);

        // Simply delete the request without notifications
        await _firestore.collection('friend_requests').doc(requestId).delete();

        // Remove the notification from receiver's notifications
        await deleteNotificationByTypeAndUser(
          request.receiverId,
          NotificationType.friendRequests,
          request.senderId
        );
      }
      
    } catch (e) {
      throw Exception('Failed to delete friend request: ${e.toString()}');
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
        // Create friendship first
        await createFriendship(request.senderId, request.receiverId);

        // Get accepter's name for notification
        final accepterUser = await getUser(request.receiverId);
        final accepterName = accepterUser?.displayName ?? 'Someone';

        // Send notification to the person who sent the request
        await createNotification(
          NotificationModel(
            id: DateTime.now().millisecondsSinceEpoch.toString(),
            userId: request.senderId,
            title: 'Friend Request Accepted',
            body: '$accepterName has accepted your friend request',
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
    return _firestore
        .collection('friend_requests')
        .where('receiverId', isEqualTo: userId)
        .where('status', isEqualTo: 'pending')
        // Avoid composite index requirement by sorting client-side
        .snapshots()
        .map((snapshot) {
          final list = snapshot.docs
              .map((doc) => FriendRequestModel.fromMap(doc.data()))
              .toList();
          list.sort((a, b) => b.createdAt.compareTo(a.createdAt));
          return list;
        });
  }

  Stream<List<FriendRequestModel>> getSentFriendRequestsStream(String userId) {
    return _firestore
        .collection('friend_requests')
        .where('senderId', isEqualTo: userId)
        .where('status', isEqualTo: 'pending')
        .snapshots()
        .map((snapshot) {
          final list = snapshot.docs
              .map((doc) => FriendRequestModel.fromMap(doc.data()))
              .toList();
          list.sort((a, b) => b.createdAt.compareTo(a.createdAt));
          return list;
        });
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

  // Check connection status between two users
  // Returns: 'none', 'pending_sent', 'pending_received', or 'connected'
  Future<String> getConnectionStatus(String currentUserId, String otherUserId) async {
    try {
      // Check if they are friends
      final friendship = await getFriendship(currentUserId, otherUserId);
      if (friendship != null && !friendship.isBlocked) {
        return 'connected';
      }

      // Check if current user sent a pending request
      QuerySnapshot sentRequest = await _firestore.collection('friend_requests')
          .where('senderId', isEqualTo: currentUserId)
          .where('receiverId', isEqualTo: otherUserId)
          .where('status', isEqualTo: 'pending')
          .get();

      if (sentRequest.docs.isNotEmpty) {
        return 'pending_sent';
      }

      // Check if current user received a pending request
      QuerySnapshot receivedRequest = await _firestore.collection('friend_requests')
          .where('senderId', isEqualTo: otherUserId)
          .where('receiverId', isEqualTo: currentUserId)
          .where('status', isEqualTo: 'pending')
          .get();

      if (receivedRequest.docs.isNotEmpty) {
        return 'pending_received';
      }

      return 'none';
    } catch (e) {
      return 'none';
    }
  }

  // Stream version for real-time updates - watches both collections
  Stream<String> getConnectionStatusStream(String currentUserId, String otherUserId) async* {
    // Initial check
    yield await getConnectionStatus(currentUserId, otherUserId);
    
    // Watch for changes in both friendships AND friend_requests for real-time updates
    final List<String> userIds = [currentUserId, otherUserId]..sort();
    final friendshipId = '${userIds[0]}_${userIds[1]}';
    
    // Watch friendship changes
    await for (final _ in _firestore.collection('friendships').doc(friendshipId).snapshots()) {
      yield await getConnectionStatus(currentUserId, otherUserId);
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
          body: '$userId1 has removed you from their friends list',
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

  Future<void> unblockUser(String userId1, String userId2) async {
    // Implementation for unblocking a user
    try{
      List<String> userIds = [userId1, userId2]..sort();
      String friendshipId = '${userIds[0]}_${userIds[1]}';

      await _firestore.collection('friendships').doc(friendshipId).update({
        'isBlocked': false,
        'blockedBy': null,
      });
    } catch (e) {
      throw Exception('Failed to unblock user: ${e.toString()}');
    }
  }

  Stream<List<FriendshipModel>> getFriendsStream(String userId) {
    return _firestore.collection('friendships')
    .where('isBlocked', isEqualTo: false)
    .where('user1Id', isEqualTo: userId)
    .snapshots()
    .asyncMap((snapshot1) async {
      QuerySnapshot snapshot2 = await _firestore.collection('friendships')
      .where('isBlocked', isEqualTo: false)
      .where('user2Id', isEqualTo: userId)
      .get();

      List<FriendshipModel> friendships = [];

      for (var doc in snapshot1.docs) {
        friendships.add(FriendshipModel.fromMap(doc.data()));
      }
      for (var doc in snapshot2.docs) {
        friendships.add(FriendshipModel.fromMap(doc.data() as Map<String, dynamic>));
      }

      return friendships.where((f)=> !f.isBlocked).toList();
    });
  }

  Future<FriendshipModel?> getFriendship(String userId1, String userId2) async {
    try {
      List<String> userIds = [userId1, userId2]..sort();
      String friendshipId = '${userIds[0]}_${userIds[1]}';

      DocumentSnapshot doc = await _firestore.collection('friendships').doc(friendshipId).get();

      if (doc.exists) {
        return FriendshipModel.fromMap(doc.data() as Map<String, dynamic>);
      }
      return null;
    } catch (e) {
      throw Exception('Failed to get friendship: ${e.toString()}');
    }
  }

  Future<bool> isUserBlocked(String userId1, String userId2) async {
    try {
      List<String> userIds = [userId1, userId2]..sort();
      String friendshipId = '${userIds[0]}_${userIds[1]}';

      DocumentSnapshot doc = await _firestore.collection('friendships').doc(friendshipId).get();

      if (doc.exists) {
        FriendshipModel friendship = FriendshipModel.fromMap(doc.data() as Map<String, dynamic>);
        return friendship.isBlocked;
      }
      return false;
    } catch (e) {
      throw Exception('Failed to check if user is blocked: ${e.toString()}');
    }
  }

  Future<bool> isUnfriended(String userId1, String userId2) async {
    try {
      List<String> userIds = [userId1, userId2]..sort();
      String friendshipId = '${userIds[0]}_${userIds[1]}';

      DocumentSnapshot doc = await _firestore.collection('friendships').doc(friendshipId).get();

      return !doc.exists ||(doc.exists && doc.data() == null);
    } catch (e) {
      throw Exception('Failed to check if users are unfriended: ${e.toString()}');
    }
  }

  Future<String> createOrGetChat(String  userId1, String userId2) async {
    try {
      List<String> participants = [userId1, userId2]..sort();
      String chatId = '${participants[0]}_${participants[1]}';

      DocumentReference chatRef = _firestore.collection('chats').doc(chatId);
      DocumentSnapshot chatDoc = await chatRef.get();

      if (!chatDoc.exists) {
        ChatModel newChat = ChatModel(
          id: chatId,
          participants: participants,
          unreadCount: {
            userId1: 0,
            userId2: 0,
          },
          deletedBy: {userId1: false, userId2: false},
          deletedAt: {userId1: null, userId2: null},
          lastSeenBy: {userId1: DateTime.now(), userId2: DateTime.now()},
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        );
        await chatRef.set(newChat.toMap());
      }
      else{
        ChatModel existingChat = ChatModel.fromMap(chatDoc.data() as Map<String, dynamic>);
        if(existingChat.deletedBy[userId1] == true){
          await restoreChatForUser(chatId, userId1);
        }
        if(existingChat.deletedBy[userId2] == true){
          await restoreChatForUser(chatId, userId2);
        }
      }

      return chatId;
    } catch (e) {
      throw Exception('Failed to create or get chat: ${e.toString()}');
    }
  }

  Stream<List<ChatModel>> getUserChatsStream(String userId) {
    return _firestore.collection('chats')
    .where('participants', arrayContains: userId)
    .orderBy('updatedAt', descending: true)
    .snapshots()
    .map((snapshot) => snapshot.docs
      .map((doc) => ChatModel.fromMap(doc.data()))
      .where((chat) => chat.deletedBy[userId] != true)
      .toList()
    );
  }  

  Future<String> createThread(ThreadModel thread, {required String appId}) async {
    try {
      final data = thread.toMap();
      data.remove('id');
      final docRef = await _firestore
        .collection('artifacts')
        .doc(appId)
        .collection('public')
        .doc('data')
        .collection('forumPosts')
        .add(data);
      await docRef.update({'id': docRef.id});
      return docRef.id;
    } catch (e) {
      throw Exception('Failed to create thread: ${e.toString()}');
    }
  }

  Future<void> editThread(String threadId, Map<String, dynamic> updates, {required String appId}) async {
    try {
      await _firestore
        .collection('artifacts')
        .doc(appId)
        .collection('public')
        .doc('data')
        .collection('forumPosts')
        .doc(threadId)
        .update(updates);
    } catch (e) {
      throw Exception('Failed to edit thread: ${e.toString()}');
    }
  }

  Future<void> deleteThread(String threadId, {required String appId}) async {
    try {
      await _firestore
        .collection('artifacts')
        .doc(appId)
        .collection('public')
        .doc('data')
        .collection('forumPosts')
        .doc(threadId)
        .delete();
    } catch (e) {
      throw Exception('Failed to delete thread: ${e.toString()}');
    }
  }

  Future<String> addReply(String threadId, ReplyModel reply, {required String appId}) async {
    try {
      final data = reply.toMap();
      data.remove('id');

      final docRef = await _firestore
          .collection('artifacts')
          .doc(appId)
          .collection('public')
          .doc('data')
          .collection('forumPosts')
          .doc(threadId)
          .collection('replies')
          .add(data);

      await docRef.update({'id': docRef.id, 'threadId': threadId});

      await _firestore
          .collection('artifacts')
          .doc(appId)
          .collection('public')
          .doc('data')
          .collection('forumPosts')
          .doc(threadId)
          .update({
            'replyCount': FieldValue.increment(1),
            'lastActivity': DateTime.now().millisecondsSinceEpoch,
          });

      return docRef.id;
    } catch (e) {
      throw Exception('Failed to add reply: ${e.toString()}');
    }
  }

  Stream<List<ReplyModel>> getRepliesStream(String threadId, {required String appId}) {
    return _firestore
        .collection('artifacts')
        .doc(appId)
        .collection('public')
        .doc('data')
        .collection('forumPosts')
        .doc(threadId)
        .collection('replies')
        .orderBy('timestamp', descending: false)
        .snapshots()
        .map((snapshot) => snapshot.docs.map((doc) => ReplyModel.fromMap(doc.data())).toList());
  }

  Future<void> likeReply(String threadId, String replyId, String userId, {required String appId}) async {
    try {
      await _firestore
          .collection('artifacts')
          .doc(appId)
          .collection('public')
          .doc('data')
          .collection('forumPosts')
          .doc(threadId)
          .collection('replies')
          .doc(replyId)
          .update({
            'likes': FieldValue.arrayUnion([userId]),
          });
    } catch (e) {
      throw Exception('Failed to like reply: ${e.toString()}');
    }
  }

  Future<void> unlikeReply(String threadId, String replyId, String userId, {required String appId}) async {
    try {
      await _firestore
          .collection('artifacts')
          .doc(appId)
          .collection('public')
          .doc('data')
          .collection('forumPosts')
          .doc(threadId)
          .collection('replies')
          .doc(replyId)
          .update({
            'likes': FieldValue.arrayRemove([userId]),
          });
    } catch (e) {
      throw Exception('Failed to unlike reply: ${e.toString()}');
    }
  }

  Future<void> editReply(String threadId, String replyId, String newContent, {required String appId}) async {
    try {
      await _firestore
          .collection('artifacts')
          .doc(appId)
          .collection('public')
          .doc('data')
          .collection('forumPosts')
          .doc(threadId)
          .collection('replies')
          .doc(replyId)
          .update({
            'content': newContent,
          });
    } catch (e) {
      throw Exception('Failed to edit reply: ${e.toString()}');
    }
  }

  Future<void> deleteReply(String threadId, String replyId, {required String appId}) async {
    try {
      await _firestore
          .collection('artifacts')
          .doc(appId)
          .collection('public')
          .doc('data')
          .collection('forumPosts')
          .doc(threadId)
          .collection('replies')
          .doc(replyId)
          .delete();
    } catch (e) {
      throw Exception('Failed to delete reply: ${e.toString()}');
    }
  }

  Future<void> likeThread(String threadId, String userId, {required String appId}) async {
    try {
      await _firestore
          .collection('artifacts')
          .doc(appId)
          .collection('public')
          .doc('data')
          .collection('forumPosts')
          .doc(threadId)
          .update({
            'likes': FieldValue.arrayUnion([userId]),
          });
    } catch (e) {
      throw Exception('Failed to like thread: ${e.toString()}');
    }
  }

  Future<void> unlikeThread(String threadId, String userId, {required String appId}) async {
    try {
      await _firestore
          .collection('artifacts')
          .doc(appId)
          .collection('public')
          .doc('data')
          .collection('forumPosts')
          .doc(threadId)
          .update({
            'likes': FieldValue.arrayRemove([userId]),
          });
    } catch (e) {
      throw Exception('Failed to unlike thread: ${e.toString()}');
    }
  }

  Stream<List<ThreadModel>> getThreadsStream({required String appId}) {
    return _firestore
      .collection('artifacts')
      .doc(appId)
      .collection('public')
      .doc('data')
      .collection('forumPosts')
      .snapshots()
      .map((snapshot) => snapshot.docs.map((doc) {
            final data = doc.data();
            if ((data['id'] == null) || (data['id'] is String && (data['id'] as String).isEmpty)) {
              data['id'] = doc.id;
            }
            return ThreadModel.fromMap(data);
          }).toList());
  }

  Future<void> updateChatLastMessage(String chatId, MessageModel message) async {
    try {
      await _firestore.collection('chats').doc(chatId).update({
        'lastMessage': message.content,
        'lastMessageTime': message.timestamp.millisecondsSinceEpoch,
        'lastMessageSenderId': message.senderId,
        'updatedAt': DateTime.now().millisecondsSinceEpoch,
      });
    } catch (e) {
      throw Exception('Failed to update chat last message: ${e.toString()}');
    }
  }

  Future<void> updateUserLastseen(String chatId, String userId) async {
    try {
      DocumentSnapshot chatDoc = await _firestore.collection('chats').doc(chatId).get();

      if (chatDoc.exists) {
        ChatModel chat = ChatModel.fromMap(chatDoc.data() as Map<String, dynamic>);

        chat.lastSeenBy[userId] = DateTime.now();

        await _firestore.collection('chats').doc(chatId).update({
          'lastSeenBy': chat.lastSeenBy.map((key, value) => MapEntry(key, value?.millisecondsSinceEpoch)),
        });
      }
    } catch (e) {
      throw Exception('Failed to update user last seen: ${e.toString()}');
    }
  }

  Future<void> deleteChatForUser(String chatId, String userId) async {
    try {
      DocumentSnapshot chatDoc = await _firestore.collection('chats').doc(chatId).get();

      if (chatDoc.exists) {
        ChatModel chat = ChatModel.fromMap(chatDoc.data() as Map<String, dynamic>);

        chat.deletedBy[userId] = true;
        chat.deletedAt[userId] = DateTime.now();

        await _firestore.collection('chats').doc(chatId).update({
          'deletedBy': chat.deletedBy,
          'deletedAt': chat.deletedAt.map((key, value) => MapEntry(key, value?.millisecondsSinceEpoch)),
        });
      }
    } catch (e) {
      throw Exception('Failed to delete chat for user: ${e.toString()}');
    }
  }

  Future<void> restoreChatForUser(String chatId, String userId) async {
    try {
      DocumentSnapshot chatDoc = await _firestore.collection('chats').doc(chatId).get();

      if (chatDoc.exists) {
        ChatModel chat = ChatModel.fromMap(chatDoc.data() as Map<String, dynamic>);

        chat.deletedBy[userId] = false;
        chat.deletedAt[userId] = null;

        await _firestore.collection('chats').doc(chatId).update({
          'deletedBy': chat.deletedBy,
          'deletedAt': chat.deletedAt.map((key, value) => MapEntry(key, value?.millisecondsSinceEpoch)),
        });
      }
    } catch (e) {
      throw Exception('Failed to restore chat for user: ${e.toString()}');
    }
  }

  Future<void> updateUnreadCount(String chatId, String userId, int count) async {
    try {
      DocumentSnapshot chatDoc = await _firestore.collection('chats').doc(chatId).get();

      if (chatDoc.exists) {
        ChatModel chat = ChatModel.fromMap(chatDoc.data() as Map<String, dynamic>);

        int currentCount = chat.unreadCount[userId] ?? 0;
        chat.unreadCount[userId] = currentCount + count;

        if (chat.unreadCount[userId]! < 0) {
          chat.unreadCount[userId] = 0;
        }

        await _firestore.collection('chats').doc(chatId).update({
          'unreadCount': chat.unreadCount,
        });
      }
    } catch (e) {
      throw Exception('Failed to update unread count: ${e.toString()}');
    }
  }

  Future<void> restoreUnreadCount(String chatId, String userId) async {
    try {
      DocumentSnapshot chatDoc = await _firestore.collection('chats').doc(chatId).get();

      if (chatDoc.exists) {
        ChatModel chat = ChatModel.fromMap(chatDoc.data() as Map<String, dynamic>);

        chat.unreadCount[userId] = 0;

        await _firestore.collection('chats').doc(chatId).update({
          'unreadCount': chat.unreadCount,
        });
      }
    } catch (e) {
      throw Exception('Failed to restore unread count: ${e.toString()}');
    }
  }

  // Message Collection Methods would be here

  Future<void> sendMessage(MessageModel message) async {
    try {
      await _firestore.collection('messages').doc(message.id).set(message.toMap());
      String chatId = await createOrGetChat(message.senderId, message.receiverId);
      await updateChatLastMessage(chatId, message);
      await updateUserLastseen(chatId, message.senderId);
      DocumentSnapshot chatDoc = await _firestore.collection('chats').doc(chatId).get();
      if (chatDoc.exists) {
        ChatModel chat = ChatModel.fromMap(chatDoc.data() as Map<String, dynamic>);

        int currentUnread = chat.getUnreadCount( message.receiverId);

        await updateUnreadCount(chatId, message.receiverId, 1 + currentUnread);
        
        
      }

    } catch (e) {
      throw Exception('Failed to send message: ${e.toString()}');
    }
  }

  Stream<List<MessageModel>> getMessagesStream(String userId1, String userId2) {
    return _firestore.collection('messages')
    .where('senderId', whereIn: [userId1, userId2])
    .where('receiverId', whereIn: [userId1, userId2])
    .orderBy('timestamp', descending: true)
    .snapshots()
    .asyncMap((snapshot) async {
      List<String> participants = [userId1, userId2]..sort();
      String chatId = '${participants[0]}_${participants[1]}';

      DocumentSnapshot chatDoc = await _firestore.collection('chats').doc(chatId).get();
      ChatModel? chat;
      if (chatDoc.exists) {
        chat = ChatModel.fromMap(chatDoc.data() as Map<String, dynamic>);
      }
      List<MessageModel> messages = [];

      for(var doc in snapshot.docs) {
        MessageModel message = MessageModel.fromMap(doc.data());
        if((message.senderId == userId1 && message.receiverId == userId2) ||
           (message.senderId == userId2 && message.receiverId == userId1)) {
          // Check if the message is deleted for the user
          bool includeMessage = true;
          if (chat != null) {
            DateTime? currentUserDeletedAt = chat.getDeletedAt(userId1);
            if (currentUserDeletedAt != null && message.timestamp.isBefore(currentUserDeletedAt)){
              includeMessage = false;
            }
          }
          if(includeMessage){
            messages.add(message);
          }
        }
        
      }
      messages.sort((a,b) => a.timestamp.compareTo(b.timestamp));
      return messages;
    });
  }

  Future<void> markMessageAsRead(String messageId) async{
    try{
      await _firestore.collection('messages').doc(messageId).update({
        'isRead': true,
      });
    } catch(e){
      throw Exception('Failed to mark message as read');
    }
  }

  Future<void> deleteMessage(String messageId) async{
    try{
      await _firestore.collection('messages').doc(messageId).delete();
    } catch(e){
      throw Exception('Failed to delete message: ${e.toString()}');
    }
  }

  Future<void> editMessage(String messageId, String newContent) async{
    try{
      await _firestore.collection('messages').doc(messageId).update({
        'content': newContent,
        'isEdited': true,
        'editedAt': DateTime.now().millisecondsSinceEpoch,
      });
    } catch(e){
      throw Exception('Failed to edit message: ${e.toString()}');
    }
  }

  // Notification Collection Methods would be here
    
  Future<void> createNotification(NotificationModel notificationModel) async {
    try {
      await _firestore
      .collection('notifications')
      .doc(notificationModel.id)
      .set(notificationModel.toMap());
    } catch (e) {
      throw Exception('Failed to create notification: ${e.toString()}');
    }
  }

  Stream<List<NotificationModel>> getNotificationsStream(String userId) {
    return _firestore.collection('notifications')
    .where('userId', isEqualTo: userId)
    .orderBy('createdAt', descending: true)
    .snapshots()
    .map((snapshot) => snapshot.docs
      .map((doc) => NotificationModel.fromMap(doc.data()))
      .toList()
    );
  }

  Future<void> markNotificationAsRead(String notificationId) async {
    try {
      await _firestore.collection('notifications').doc(notificationId).update({
        'isRead': true,
      });
    } catch (e) {
      throw Exception('Failed to mark notification as read: ${e.toString()}');
    }
  }

  Future<void> markAllNotificationsAsRead(String userId) async {
    try {
      QuerySnapshot notifications = await _firestore.collection('notifications')
      .where('userId', isEqualTo: userId)
      .where('isRead', isEqualTo: false)
      .get();

      WriteBatch batch = _firestore.batch();

      for (var doc in notifications.docs) {
        batch.update(doc.reference, {'isRead': true});
      }
      await batch.commit();
    } catch (e) {
      throw Exception('Failed to mark all notifications as read: ${e.toString()}');
    }
  }

  Future<void> deleteNotification(String notificationId) async {
    try {
      await _firestore.collection('notifications').doc(notificationId).delete();
    } catch (e) {
      throw Exception('Failed to delete notification: ${e.toString()}');
    }
  }
  
  Future<void> _removeNotificationForCancelledRequest(String receiverId, String senderId) async {
    try {      
      QuerySnapshot notifications = await _firestore.collection('notifications')
      .where('userId', isEqualTo: receiverId)
      .where('type', isEqualTo: NotificationType.friendRequests.name)
      .where('data.senderId', isEqualTo: senderId)
      .get();

      WriteBatch batch = _firestore.batch();

      for (var doc in notifications.docs) {
        batch.delete(doc.reference);
      }
      await batch.commit();
    } catch (e) {
      throw Exception('Failed to remove notification for cancelled request: ${e.toString()}');
    }
  }
  
  Future<void> deleteNotificationByTypeAndUser(String userId, NotificationType type, String relatedUserId) async {
    try {      
      QuerySnapshot notifications = await _firestore.collection('notifications')
      .where('userId', isEqualTo: userId)
      .where('type', isEqualTo: type.name)
      .where('data.senderId', isEqualTo: relatedUserId)
      .get();

      WriteBatch batch = _firestore.batch();

      for (var doc in notifications.docs) {
        batch.delete(doc.reference);
      }
      await batch.commit();
    } catch (e) {
      throw Exception('Failed to delete notification by type and user: ${e.toString()}');
    }
  }

  Future<String> addUniversity(String universityName) async {
  try {
    // 1. Create a reference to the 'universities' collection
    final CollectionReference universities = _firestore.collection('universities');

    // 2. Prepare the data
    final University newUniversity = University(
      id: '', // ID is temporary, Firestore will generate one
      name: universityName,
    );

    // 3. Add the document to Firestore
    DocumentReference docRef = await universities.add(newUniversity.toFirestore());

    print('University added with ID: ${docRef.id}');
    return docRef.id; // Return the generated ID for later use
  } catch (e) {
    print('Error adding university: $e');
    rethrow;
  }
  }

  Future<String> addFaculty(String facultyName, String universityId) async {
  try {
    final CollectionReference faculties = _firestore.collection('faculties');

    final Faculty newFaculty = Faculty(
      id: '',
      name: facultyName,
      universityId: universityId, // <-- The crucial linkage
    );

    DocumentReference docRef = await faculties.add(newFaculty.toFirestore());

    print('Faculty added with ID: ${docRef.id}');
    return docRef.id;
  } catch (e) {
    print('Error adding faculty: $e');
    rethrow;
  }
}
Future<void> addDepartment(String departmentName, String facultyId) async {
  try {
    final CollectionReference departments = _firestore.collection('departments');

    final Department newDepartment = Department(
      id: '',
      name: departmentName,
      facultyId: facultyId, // <-- The crucial linkage
    );

    await departments.add(newDepartment.toFirestore());
    print('Department added successfully.');
  } catch (e) {
    print('Error adding department: $e');
    rethrow;
  }
}

  Future<List<Map<String, dynamic>>> getUniversities() async {
    try {
      final snapshot = await _firestore.collection('universities').get();
      return snapshot.docs.map((doc) {
        final data = doc.data();
        return {
          'id': doc.id,
          'name': data['name'] ?? '',
        };
      }).toList();
    } catch (e) {
      print('Error fetching universities: $e');
      rethrow;
    }
  }

  Future<List<Map<String, dynamic>>> getFacultiesByUniversity(String universityId) async {
    try {
      final snapshot = await _firestore
          .collection('faculties')
          .where('universityId', isEqualTo: universityId)
          .get();
      return snapshot.docs.map((doc) {
        final data = doc.data();
        return {
          'id': doc.id,
          'name': data['name'] ?? '',
          'universityId': data['universityId'] ?? '',
        };
      }).toList();
    } catch (e) {
      print('Error fetching faculties: $e');
      rethrow;
    }
  }

  Future<List<Map<String, dynamic>>> getDepartmentsByFaculty(String facultyId) async {
    try {
      final snapshot = await _firestore
          .collection('departments')
          .where('facultyId', isEqualTo: facultyId)
          .get();
      return snapshot.docs.map((doc) {
        final data = doc.data();
        return {
          'id': doc.id,
          'name': data['name'] ?? '',
          'facultyId': data['facultyId'] ?? '',
        };
      }).toList();
    } catch (e) {
      print('Error fetching departments: $e');
      rethrow;
    }
  }
}