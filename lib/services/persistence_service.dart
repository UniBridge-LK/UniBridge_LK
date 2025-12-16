import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

class PersistenceService {
  static const _userDataKey = 'user_data';
  static const _navStateKey = 'nav_state';
  static const _lastTabKey = 'last_tab';
  static const _uniPathKey = 'uni_path';
  static const _facPathKey = 'fac_path';
  static const _deptPathKey = 'dept_path';

  static late SharedPreferences _prefs;

  static Future<void> init() async {
    _prefs = await SharedPreferences.getInstance();
  }

  // User data persistence
  static Future<void> saveUserData({
    required String id,
    required String email,
    required String? displayName,
    required bool premiumStatus,
  }) async {
    final userData = {
      'id': id,
      'email': email,
      'displayName': displayName,
      'premiumStatus': premiumStatus,
    };
    await _prefs.setString(_userDataKey, jsonEncode(userData));
  }

  static Map<String, dynamic>? getUserData() {
    final raw = _prefs.getString(_userDataKey);
    if (raw == null) return null;
    return jsonDecode(raw) as Map<String, dynamic>;
  }

  static Future<void> clearUserData() async {
    await _prefs.remove(_userDataKey);
    await _prefs.remove(_navStateKey);
    await _prefs.remove(_lastTabKey);
    await _prefs.remove(_uniPathKey);
    await _prefs.remove(_facPathKey);
    await _prefs.remove(_deptPathKey);
  }

  // Navigation state persistence
  static Future<void> saveNavState({
    required int tabIndex,
    String? universityPath,
    String? facultyPath,
    String? departmentPath,
  }) async {
    await _prefs.setInt(_lastTabKey, tabIndex);
    if (universityPath != null) {
      await _prefs.setString(_uniPathKey, universityPath);
    }
    if (facultyPath != null) {
      await _prefs.setString(_facPathKey, facultyPath);
    }
    if (departmentPath != null) {
      await _prefs.setString(_deptPathKey, departmentPath);
    }
  }

  static int getLastTabIndex() {
    return _prefs.getInt(_lastTabKey) ?? 0;
  }

  static String? getLastUniversityPath() {
    return _prefs.getString(_uniPathKey);
  }

  static String? getLastFacultyPath() {
    return _prefs.getString(_facPathKey);
  }

  static String? getLastDepartmentPath() {
    return _prefs.getString(_deptPathKey);
  }

  static Future<void> clearNavState() async {
    await _prefs.remove(_lastTabKey);
    await _prefs.remove(_uniPathKey);
    await _prefs.remove(_facPathKey);
    await _prefs.remove(_deptPathKey);
  }
}
