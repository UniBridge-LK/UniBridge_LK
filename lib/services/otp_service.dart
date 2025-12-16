import 'dart:math';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cloud_functions/cloud_functions.dart';

class OtpService {
  final _firestore = FirebaseFirestore.instance;
  final _functions = FirebaseFunctions.instance;

  String _generateCode(int length) {
    final rand = Random.secure();
    final code = List.generate(length, (_) => rand.nextInt(10).toString()).join();
    return code;
  }

  Future<void> sendEmailOtp({
    required String userId,
    required String email,
    int codeLength = 6,
    Duration ttl = const Duration(minutes: 10),
  }) async {
    final code = _generateCode(codeLength);
    final now = DateTime.now();
    final expiresAt = now.add(ttl);

    await _firestore.collection('emailOtps').doc(userId).set({
      'email': email,
      'code': code,
      'attempts': 0,
      'createdAt': now.millisecondsSinceEpoch,
      'expiresAt': expiresAt.millisecondsSinceEpoch,
    });

    final callable = _functions.httpsCallable('sendOtpEmail');
    await callable.call({
      'email': email,
      'code': code,
    });
  }

  Future<bool> verifyEmailOtp({
    required String userId,
    required String code,
  }) async {
    final ref = _firestore.collection('emailOtps').doc(userId);
    final snap = await ref.get();
    if (!snap.exists) return false;
    final data = snap.data() as Map<String, dynamic>;

    final expiresAtMs = data['expiresAt'] as int? ?? 0;
    final attempts = data['attempts'] as int? ?? 0;
    if (attempts >= 5) return false;
    final isExpired = DateTime.now().millisecondsSinceEpoch > expiresAtMs;
    if (isExpired) return false;

    final storedCode = data['code']?.toString() ?? '';
    final ok = storedCode == code.trim();

    if (ok) {
      await ref.delete();
    } else {
      await ref.update({'attempts': attempts + 1});
    }
    return ok;
  }
}
