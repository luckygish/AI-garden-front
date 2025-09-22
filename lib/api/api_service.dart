import 'dart:async';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class ApiService {
  static const String baseUrl = 'http://10.0.2.2:8080/api'; // Для эмулятора Android
  // static const String baseUrl = 'http://localhost:8080/api'; // Для iOS
  static String? authToken;
  static String? userId;

  // Инициализация при запуске
  static Future<void> initialize() async {
    final prefs = await SharedPreferences.getInstance();
    authToken = prefs.getString('auth_token');
    userId = prefs.getString('user_id');
  }

  // Сохранить auth данные
  static Future<void> _saveAuthData(String token, String id) async {
    authToken = token;
    userId = id;

    final prefs = await c.getInstance();
    await prefs.setString('auth_token', token);
    await prefs.setString('user_id', id);
  }

  // Общий метод для запросов с обработкой ошибок
  static Future<http.Response> _request(
      String method,
      String endpoint, {
        Map<String, dynamic>? body,
        bool requireAuth = true,
      }) async {
    final url = Uri.parse('$baseUrl$endpoint');
    final headers = {
      'Content-Type': 'application/json',
      if (requireAuth && authToken != null) 'Authorization': 'Bearer $authToken',
    };

    try {
      final response = await http.post(
        url,
        headers: headers,
        body: body != null ? json.encode(body) : null,
      ).timeout(const Duration(seconds: 30));

      // Обработка ошибок авторизации
      if (response.statusCode == 401 || response.statusCode == 403) {
        await _clearAuthData();
        throw Exception('Сессия истекла. Пожалуйста, войдите снова.');
      }

      // Обработка других ошибок
      if (response.statusCode >= 400) {
        final errorData = json.decode(response.body);
        throw Exception(errorData['message'] ?? 'Ошибка сервера');
      }

      return response;

    } on http.ClientException catch (e) {
      throw Exception('Ошибка подключения: ${e.message}');
    } on TimeoutException catch (e) {
      throw Exception('Таймаут запроса');
    }
  }

  // Очистка auth данных
  static Future<void> _clearAuthData() async {
    authToken = null;
    userId = null;

    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('auth_token');
    await prefs.remove('user_id');
  }

  // Регистрация
  static Future<Map<String, dynamic>> register({
    required String email,
    required String password,
    required String name,
    required String region,
    required String gardenType,
  }) async {
    final response = await _request(
      'POST',
      '/auth/register',
      body: {
        'email': email,
        'password': password,
        'name': name,
        'region': region,
        'gardenType': gardenType,
      },
      requireAuth: false,
    );

    final data = json.decode(response.body);
    await _saveAuthData(data['token'], data['userId']);
    return data;
  }

  // Логин
  static Future<Map<String, dynamic>> login({
    required String email,
    required String password,
  }) async {
    final response = await _request(
      'POST',
      '/auth/login',
      body: {
        'email': email,
        'password': password,
      },
      requireAuth: false,
    );

    final data = json.decode(response.body);
    await _saveAuthData(data['token'], data['userId']);
    return data;
  }

  // Выход
  static Future<void> logout() async {
    await _clearAuthData();
  }

  // Проверить авторизацию
  static bool isLoggedIn() {
    return authToken != null && userId != null;
  }

  // Получить растения пользователя
  static Future<List<dynamic>> getUserPlants() async {
    final response = await _request('GET', '/garden');
    return json.decode(response.body);
  }

}