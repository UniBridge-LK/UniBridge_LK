import 'dart:convert';

import 'package:chat_with_aks/models/message_model.dart';
import 'package:chat_with_aks/services/firestore_service.dart';
import 'package:chat_with_aks/controllers/auth_controller.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:uuid/uuid.dart';

class ChatController extends GetxController {
  final FirestoreService _fs = FirestoreService();
  final AuthController _auth = Get.find<AuthController>();
  final RxList<MessageModel> pending = <MessageModel>[].obs;
  final Uuid _uuid = Uuid();
  late SharedPreferences _prefs;
  final String _prefsKey = 'pending_messages';

  @override
  void onInit() {
    super.onInit();
    _initPrefs();
    Connectivity().onConnectivityChanged.listen((status) {
      if (status != ConnectivityResult.none) {
        _flushQueue();
      }
    });
  }

  Future<void> _initPrefs() async {
    _prefs = await SharedPreferences.getInstance();
    final raw = _prefs.getStringList(_prefsKey) ?? [];
    pending.assignAll(raw.map((r) => MessageModel.fromMap(json.decode(r) as Map<String, dynamic>)));
  }

  Future<void> _savePrefs() async {
    final raw = pending.map((m) => json.encode(m.toMap())).toList();
    await _prefs.setStringList(_prefsKey, raw);
  }

  Future<void> sendMessage(String receiverId, String content) async {
    final senderId = _auth.user?.uid ?? 'u1_mock';
    final id = _uuid.v4();
    final message = MessageModel(
      id: id,
      senderId: senderId,
      receiverId: receiverId,
      content: content,
      timestamp: DateTime.now(),
    );

    // Try sending immediately
    try {
      final connectivity = await Connectivity().checkConnectivity();
      if (connectivity == ConnectivityResult.none) {
        // queue locally
        pending.add(message);
        await _savePrefs();
        Get.snackbar('Offline', 'Message queued and will be sent when online');
        return;
      }

      await _fs.sendMessage(message);
    } catch (e) {
      // queue on failure
      pending.add(message);
      await _savePrefs();
      Get.snackbar('Queued', 'Message queued due to send failure');
    }
  }

  Future<void> _flushQueue() async {
    if (pending.isEmpty) return;
    final toSend = List<MessageModel>.from(pending);
    for (var m in toSend) {
      try {
        await _fs.sendMessage(m);
        pending.removeWhere((p) => p.id == m.id);
        await _savePrefs();
      } catch (e) {
        // stop trying further if a send fails repeatedly
        break;
      }
    }
  }
}
