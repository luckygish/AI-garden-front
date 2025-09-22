import 'package:shared_preferences/shared_preferences.dart';

class SharedPrefsService {
  static const _authTokenKey = 'auth_token';
  static const _userIdKey = 'user_id';

  // Сохранить токен
  static Future<void> saveAuthData(String token, String userId) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_authTokenKey, token);
    await prefs.setString(_userIdKey, userId);
  }

  // Получить токен
  static Future<String?> getAuthToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_authTokenKey);
  }

  // Получить ID пользователя
  static Future<String?> getUserId() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_userIdKey);
  }

  // Удалить данные (выход)
  static Future<void> clearAuthData() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_authTokenKey);
    await prefs.remove(_userIdKey);
  }
}