import 'package:chat_with_aks/models/user_model.dart';
import 'package:chat_with_aks/services/firestore_service.dart';
import 'package:firebase_auth/firebase_auth.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirestoreService _firestoreService = FirestoreService();

  User? get currentUser => _auth.currentUser;
  String? get currentUserId => _auth.currentUser?.uid;

  Stream<User?> get authStateChanges => _auth.authStateChanges();

  Future<UserModel?> signInWithEmailAndPassword(
    String email, 
    String password
    ) async {
      try {
        UserCredential result = await _auth.signInWithEmailAndPassword(
          email: email, 
          password: password
          );
        User? user = result.user;
        if (user != null) {
          await _firestoreService.updateUserOnlineStatus(user.uid, true);
          return await _firestoreService.getUser(user.uid);
        }
        return null; 
      } catch (e) {
        throw Exception('Failed To Sign In: ${e.toString()}');
      }    
  }

  Future<UserModel?> registerWithEmailAndPassword(
    String email, 
    String password, 
    String displayName,
    {
      required String accountType,
      String universityName = '',
      String faculty = '',
      String department = '',
      String organizationName = '',
    }
    
    ) async {
      try {
        UserCredential result = await _auth.createUserWithEmailAndPassword(
          email: email, 
          password: password
          );
        User? user = result.user;
        if (user != null) {
          await user.updateDisplayName(displayName);
          final userModel = UserModel(
            id: user.uid,
            email: email,
            displayName: displayName,
            photoURL: '',
            isOnline: true,
            createdAt: DateTime.now(),
            lastSeen: DateTime.now(),
            accountType: accountType,
            universityName: universityName,
            faculty: faculty,
            department: department,
            organizationName: organizationName,
          );
          // Do NOT save to Firestore yet - wait for OTP verification          
          await _firestoreService.createUser(userModel);
          return userModel;
        }
        return null; 
      } catch (e) {
        throw Exception('Failed To Register: ${e.toString()}');
      }    
  }

  Future<void> sendPasswordResetEmail(String email) async {
    try {
      await _auth.sendPasswordResetEmail(email: email);
    } catch (e) {
      throw Exception('Failed To Send Password Reset Email: ${e.toString()}');
    }
  }

  Future<void> signOut() async {
    try {
      if (currentUser != null) {
        await _firestoreService.updateUserOnlineStatus(currentUserId!, false);
      }
      await _auth.signOut();
    } catch (e) {
      throw Exception('Failed To Sign Out: ${e.toString()}');
    }
  }

  Future<void> deleteAccount() async {
    try {
      User? user = _auth.currentUser;
      if (user != null) {
        await _firestoreService.deleteUser(user.uid);
        await user.delete();
      }
    } catch (e) {
      throw Exception('Failed To Delete Account: ${e.toString()}');
    }
  }

  Future<void> saveUserProfileAfterOtpVerification(UserModel userModel) async {
    try {
      await _firestoreService.createUser(userModel);
    } catch (e) {
      throw Exception('Failed To Save User Profile: ${e.toString()}');
    }
  }
}