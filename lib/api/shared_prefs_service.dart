import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import '../models/user.dart';

class SharedPrefsService {
  static const _authTokenKey = 'auth_token';
  static const _userIdKey = 'user_id';
  static const _userDataKey = 'user_data';
  static const _onboardingCompletedKey = 'onboarding_completed';

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

  // Сохранить полные данные пользователя
  static Future<void> saveUserData(User user) async {
    final prefs = await SharedPreferences.getInstance();
    final userJson = json.encode({
      'id': user.id,
      'name': user.name,
      'region': user.region,
      'gardenType': user.gardenType,
      'notificationsEnabled': user.notificationsEnabled,
    });
    await prefs.setString(_userDataKey, userJson);
  }

  // Получить данные пользователя
  static Future<User?> getUserData() async {
    final prefs = await SharedPreferences.getInstance();
    final userJson = prefs.getString(_userDataKey);
    if (userJson != null) {
      try {
        final userMap = json.decode(userJson) as Map<String, dynamic>;
        return User(
          id: userMap['id'] as String,
          name: userMap['name'] as String?,
          region: userMap['region'] as String,
          gardenType: userMap['gardenType'] as String,
          notificationsEnabled: userMap['notificationsEnabled'] as bool? ?? true,
        );
      } catch (e) {
        return null;
      }
    }
    return null;
  }

  // Проверить, завершен ли онбординг
  static Future<bool> isOnboardingCompleted() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_onboardingCompletedKey) ?? false;
  }

  // Отметить онбординг как завершенный
  static Future<void> setOnboardingCompleted() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_onboardingCompletedKey, true);
  }

  // Удалить данные (выход)
  static Future<void> clearAuthData() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_authTokenKey);
    await prefs.remove(_userIdKey);
    await prefs.remove(_userDataKey);
  }
}