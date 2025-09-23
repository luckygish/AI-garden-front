import 'dart:async';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class ApiService {
  static const String baseUrl = 'http://10.0.2.2:8080/api'; // Для эмулятора Android
  // static const String baseUrl = 'http://localhost:8080/api'; // Для iOS
  static String? authToken;
  static String? userId;

  static Future<void> initialize() async {
    final prefs = await SharedPreferences.getInstance();
    authToken = prefs.getString('auth_token');
    userId = prefs.getString('user_id');
  }

  static Future<void> _saveAuthData(String token, String id) async {
    authToken = token;
    userId = id;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('auth_token', token);
    await prefs.setString('user_id', id);
  }

  static Future<http.Response> _request(
    String method,
    String endpoint, {
    Map<String, dynamic>? body,
    bool requireAuth = true,
  }) async {
    final url = Uri.parse('$baseUrl$endpoint');
    final headers = <String, String>{
      'Content-Type': 'application/json',
      if (requireAuth && authToken != null) 'Authorization': 'Bearer $authToken',
    };
    try {
      late http.Response response;
      switch (method.toUpperCase()) {
        case 'GET':
          response = await http.get(url, headers: headers).timeout(const Duration(seconds: 30));
          break;
        case 'DELETE':
          response = await http.delete(url, headers: headers).timeout(const Duration(seconds: 30));
          break;
        case 'POST':
        default:
          response = await http
              .post(url, headers: headers, body: body != null ? json.encode(body) : null)
              .timeout(const Duration(seconds: 30));
      }
      if (response.statusCode == 401 || response.statusCode == 403) {
        await _clearAuthData();
        throw Exception('Сессия истекла. Пожалуйста, войдите снова.');
      }
      if (response.statusCode >= 400) {
        String message = 'Ошибка сервера';
        try {
          final parsed = response.body.isNotEmpty ? json.decode(response.body) : null;
          if (parsed is Map && parsed['message'] != null) message = parsed['message'];
        } catch (_) {}
        throw Exception(message);
      }
      return response;
    } on http.ClientException catch (e) {
      throw Exception('Ошибка подключения: ${e.message}');
    } on TimeoutException catch (_) {
      throw Exception('Таймаут запроса');
    }
  }

  static Future<void> _clearAuthData() async {
    authToken = null;
    userId = null;
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('auth_token');
    await prefs.remove('user_id');
  }

  static Future<Map<String, dynamic>> register({
    required String email,
    required String password,
    required String name,
    required String region,
    required String gardenType,
  }) async {
    final response = await _request('POST', '/auth/register', body: {
      'email': email,
      'password': password,
      'name': name,
      'region': region,
      'gardenType': gardenType,
    }, requireAuth: false);
    final data = json.decode(response.body) as Map<String, dynamic>;
    await _saveAuthData(data['token'] as String, data['userId'] as String);
    // Дублируем в SharedPrefsService для совместимости со стартовой логикой
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('auth_token', data['token'] as String);
      await prefs.setString('user_id', data['userId'] as String);
    } catch (_) {}
    return data;
  }

  static Future<Map<String, dynamic>> login({
    required String email,
    required String password,
  }) async {
    final response = await _request('POST', '/auth/login', body: {
      'email': email,
      'password': password,
    }, requireAuth: false);
    final data = json.decode(response.body) as Map<String, dynamic>;
    await _saveAuthData(data['token'] as String, data['userId'] as String);
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('auth_token', data['token'] as String);
      await prefs.setString('user_id', data['userId'] as String);
    } catch (_) {}
    return data;
  }

  static Future<void> logout() async {
    await _clearAuthData();
  }

  static bool isLoggedIn() {
    return authToken != null && userId != null;
  }

  static Future<List<Map<String, dynamic>>> getUserPlants() async {
    final response = await _request('GET', '/plants');
    final list = json.decode(response.body) as List<dynamic>;
    return list.map((e) => (e as Map).cast<String, dynamic>()).toList();
  }

  static Future<void> deletePlant(String plantId) async {
    await _request('DELETE', '/plants/$plantId');
  }

  static Future<Map<String, dynamic>> addPlant({
    required String culture,
    required String name,
    String? variety,
    required DateTime plantingDate,
    String? growthStage,
  }) async {
    final response = await _request('POST', '/plants', body: {
      'culture': culture,
      'name': name,
      'variety': variety,
      'plantingDate': plantingDate.toIso8601String().substring(0, 10),
      'growthStage': growthStage ?? '',
    }, requireAuth: true);
    return json.decode(response.body) as Map<String, dynamic>;
  }

  static Future<Map<String, dynamic>> getPlantCarePlan(String plantId) async {
    final response = await _request('GET', '/plants/$plantId/care-plan');
    return json.decode(response.body) as Map<String, dynamic>;
  }

  static Future<Map<String, dynamic>?> getCarePlanByParams({
    required String culture,
    required String region,
    required String gardenType,
  }) async {
    final q = Uri(queryParameters: {
      'culture': culture,
      'region': region,
      'gardenType': gardenType, // Бэкенд ожидает gardenType, не garden_type
    }).query;
    final response = await _request('GET', '/care-plans/by-params?$q', requireAuth: false);
    return json.decode(response.body) as Map<String, dynamic>;
  }

  static Future<Map<String, dynamic>?> getCarePlanByHash(String hash) async {
    final q = Uri(queryParameters: {'hash': hash}).query;
    final response = await _request('GET', '/care-plans/by-hash?$q', requireAuth: false);
    return json.decode(response.body) as Map<String, dynamic>;
  }

  static Future<String> resetRequest({required String email}) async {
    final response = await _request('POST', '/auth/password/reset-request', body: {'email': email}, requireAuth: false);
    return response.body;
  }

  static Future<void> resetConfirm({required String token, required String newPassword}) async {
    await _request('POST', '/auth/password/reset-confirm', body: {'token': token, 'newPassword': newPassword}, requireAuth: false);
  }
}