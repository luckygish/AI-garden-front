import 'dart:async';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../config/app_config.dart';

class ApiService {
  // Базовый URL из конфигурации
  static String get baseUrl => AppConfig.baseUrl;
  
  static String? authToken;
  static String? userId;

  static Future<void> initialize() async {
    final prefs = await SharedPreferences.getInstance();
    authToken = prefs.getString('auth_token');
    userId = prefs.getString('user_id');
    
    // Логируем полную конфигурацию в режиме отладки
    AppConfig.logFullConfig();
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
    
    // Детальное логирование
    print('🌐 API Request: $method $url');
    print('📋 Headers: $headers');
    if (body != null) {
      print('📦 Body: ${json.encode(body)}');
    }
    
    try {
      late http.Response response;
      switch (method.toUpperCase()) {
        case 'GET':
          response = await http.get(url, headers: headers).timeout(AppConfig.requestTimeout);
          break;
        case 'DELETE':
          response = await http.delete(url, headers: headers).timeout(AppConfig.requestTimeout);
          break;
        case 'POST':
        default:
          response = await http
              .post(url, headers: headers, body: body != null ? json.encode(body) : null)
              .timeout(AppConfig.requestTimeout);
      }
      
      // Логирование ответа
      print('📡 Response Status: ${response.statusCode}');
      print('📄 Response Body: ${response.body}');
      
      if ((response.statusCode == 401 || response.statusCode == 403) && requireAuth) {
        await _clearAuthData();
        throw Exception('Сессия истекла. Пожалуйста, войдите снова.');
      }
      if (response.statusCode >= 400) {
        String message = 'Ошибка сервера';
        try {
          // Для простых строковых ответов (как "Invalid credentials")
          if (response.body.isNotEmpty && !response.body.startsWith('{')) {
            message = response.body;
          } else if (response.body.isNotEmpty) {
            // Для JSON ответов
            final parsed = json.decode(response.body);
            if (parsed is Map && parsed['message'] != null) {
              message = parsed['message'];
            }
          }
        } catch (_) {}
        throw Exception(message);
      }
      return response;
    } on http.ClientException catch (e) {
      print('❌ Client Exception: ${e.message}');
      print('🔗 URL: $url');
      throw Exception('Ошибка подключения: ${e.message}');
    } on TimeoutException catch (e) {
      print('⏰ Timeout Exception: ${e.message}');
      print('🔗 URL: $url');
      throw Exception('Таймаут запроса');
    } catch (e) {
      print('💥 Unexpected Exception: $e');
      print('🔗 URL: $url');
      rethrow;
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
    try {
      final response = await _request('GET', '/plants');
      final list = json.decode(response.body) as List<dynamic>;
      return list.map((e) => (e as Map).cast<String, dynamic>()).toList();
    } catch (e) {
      // Если ошибка аутентификации, возвращаем пустой список
      if (e.toString().contains('Сессия истекла') || e.toString().contains('User not authenticated')) {
        return [];
      }
      rethrow;
    }
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

  static Future<Map<String, dynamic>?> getPlantById(String plantId) async {
    try {
      final response = await _request('GET', '/plants/$plantId');
      return json.decode(response.body) as Map<String, dynamic>;
    } catch (e) {
      return null; // Растение не найдено
    }
  }

  static Future<bool> checkPlantExists(String plantId) async {
    final plant = await getPlantById(plantId);
    return plant != null;
  }

  // Методы для работы с описаниями сортов растений
  static Future<Map<String, dynamic>> getOrCreateVarietyDescription({
    required String culture,
    required String variety,
  }) async {
    final response = await _request('POST', '/plant-variety/description', body: {
      'culture': culture,
      'variety': variety,
    }, requireAuth: false);
    return json.decode(response.body) as Map<String, dynamic>;
  }

  static Future<bool> checkVarietyDescriptionExists({
    required String culture,
    required String variety,
  }) async {
    try {
      final q = Uri(queryParameters: {
        'culture': culture,
        'variety': variety,
      }).query;
      final response = await _request('GET', '/plant-variety/description/exists?$q', requireAuth: false);
      return json.decode(response.body) as bool;
    } catch (e) {
      return false;
    }
  }

  static Future<Map<String, dynamic>?> getVarietyDescription({
    required String culture,
    required String variety,
  }) async {
    try {
      final q = Uri(queryParameters: {
        'culture': culture,
        'variety': variety,
      }).query;
      final response = await _request('GET', '/plant-variety/description?$q', requireAuth: false);
      return json.decode(response.body) as Map<String, dynamic>;
    } catch (e) {
      return null;
    }
  }

}