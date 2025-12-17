import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SettingsController extends GetxController {
  final Rx<bool> notificationsEnabled = true.obs;
  final Rx<bool> pushNotificationsEnabled = true.obs;
  final Rx<bool> darkThemeEnabled = false.obs;

  @override
  void onInit() {
    super.onInit();
    _loadSettings();
  }

  Future<void> _loadSettings() async {
    final prefs = await SharedPreferences.getInstance();
    notificationsEnabled.value = prefs.getBool('notifications_enabled') ?? true;
    pushNotificationsEnabled.value = prefs.getBool('push_notifications_enabled') ?? true;
    darkThemeEnabled.value = prefs.getBool('dark_theme_enabled') ?? false;
  }

  Future<void> setNotifications(bool value) async {
    notificationsEnabled.value = value;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('notifications_enabled', value);
  }

  Future<void> setPushNotifications(bool value) async {
    pushNotificationsEnabled.value = value;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('push_notifications_enabled', value);
  }

  Future<void> setDarkTheme(bool value) async {
    darkThemeEnabled.value = value;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('dark_theme_enabled', value);
  }
}
