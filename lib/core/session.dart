import 'package:shared_preferences/shared_preferences.dart';

class Session {
  static String? token;
  static int userId = 0;
  static String fullName = '';
  static String phone = '';
  static bool isAdmin = false;

  static const _kToken = 'admin_token';
  static const _kId = 'admin_id';
  static const _kName = 'admin_name';
  static const _kPhone = 'admin_phone';
  static const _kIsAdmin = 'admin_is_admin';

  static Future<void> save() async {
    final prefs = await SharedPreferences.getInstance();
    if (token == null) {
      await prefs.remove(_kToken);
    } else {
      await prefs.setString(_kToken, token!);
    }
    await prefs.setInt(_kId, userId);
    await prefs.setString(_kName, fullName);
    await prefs.setString(_kPhone, phone);
    await prefs.setBool(_kIsAdmin, isAdmin);
  }

  static Future<void> load() async {
    final prefs = await SharedPreferences.getInstance();
    token = prefs.getString(_kToken);
    userId = prefs.getInt(_kId) ?? 0;
    fullName = prefs.getString(_kName) ?? '';
    phone = prefs.getString(_kPhone) ?? '';
    isAdmin = prefs.getBool(_kIsAdmin) ?? false;
  }

  static Future<void> clear() async {
    token = null;
    userId = 0;
    fullName = '';
    phone = '';
    isAdmin = false;

    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_kToken);
    await prefs.remove(_kId);
    await prefs.remove(_kName);
    await prefs.remove(_kPhone);
    await prefs.remove(_kIsAdmin);
  }

  static String get initials {
    final parts = fullName.trim().split(' ').where((p) => p.isNotEmpty).toList();
    if (parts.isEmpty) return 'A';
    if (parts.length == 1) return parts.first.substring(0, 1).toUpperCase();
    return (parts[0].substring(0, 1) + parts[1].substring(0, 1)).toUpperCase();
  }
}
