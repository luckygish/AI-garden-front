import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../api/api_service.dart';

class PendingPlantsService {
  static const String _pendingPlantsKey = 'pending_plants';
  
  /// Добавляет растение в список ожидающих
  static Future<void> addPendingPlant({
    required String plantId,
    required String plantName,
    required String culture,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    final pendingPlantsJson = prefs.getString(_pendingPlantsKey);
    
    List<Map<String, dynamic>> pendingPlants = [];
    if (pendingPlantsJson != null) {
      final List<dynamic> decoded = json.decode(pendingPlantsJson);
      pendingPlants = decoded.map((e) => Map<String, dynamic>.from(e)).toList();
    }
    
    // Проверяем, нет ли уже такого растения в списке
    if (!pendingPlants.any((p) => p['plantId'] == plantId)) {
      pendingPlants.add({
        'plantId': plantId,
        'plantName': plantName,
        'culture': culture,
        'addedAt': DateTime.now().toIso8601String(),
        'checkedAt': null,
      });
      
      await prefs.setString(_pendingPlantsKey, json.encode(pendingPlants));
    }
  }
  
  /// Удаляет растение из списка ожидающих
  static Future<void> removePendingPlant(String plantId) async {
    final prefs = await SharedPreferences.getInstance();
    final pendingPlantsJson = prefs.getString(_pendingPlantsKey);
    
    if (pendingPlantsJson != null) {
      final List<dynamic> decoded = json.decode(pendingPlantsJson);
      final List<Map<String, dynamic>> pendingPlants = decoded
          .map((e) => Map<String, dynamic>.from(e))
          .where((p) => p['plantId'] != plantId)
          .toList();
      
      await prefs.setString(_pendingPlantsKey, json.encode(pendingPlants));
    }
  }
  
  /// Получает список всех ожидающих растений
  static Future<List<Map<String, dynamic>>> getPendingPlants() async {
    final prefs = await SharedPreferences.getInstance();
    final pendingPlantsJson = prefs.getString(_pendingPlantsKey);
    
    if (pendingPlantsJson != null) {
      final List<dynamic> decoded = json.decode(pendingPlantsJson);
      return decoded.map((e) => Map<String, dynamic>.from(e)).toList();
    }
    
    return [];
  }
  
  /// Проверяет, появились ли ожидающие растения в базе данных
  static Future<List<Map<String, dynamic>>> checkPendingPlants() async {
    final pendingPlants = await getPendingPlants();
    final List<Map<String, dynamic>> appearedPlants = [];
    
    for (final plant in pendingPlants) {
      final plantId = plant['plantId'] as String;
      final exists = await ApiService.checkPlantExists(plantId);
      
      if (exists) {
        appearedPlants.add(plant);
        // Удаляем из списка ожидающих
        await removePendingPlant(plantId);
      }
    }
    
    return appearedPlants;
  }
  
  /// Очищает старые записи (старше 1 часа)
  static Future<void> cleanupOldPendingPlants() async {
    final pendingPlants = await getPendingPlants();
    final now = DateTime.now();
    final oneHourAgo = now.subtract(const Duration(hours: 1));
    
    for (final plant in pendingPlants) {
      final addedAt = DateTime.parse(plant['addedAt'] as String);
      if (addedAt.isBefore(oneHourAgo)) {
        await removePendingPlant(plant['plantId'] as String);
      }
    }
  }
  
  /// Инициализация сервиса при запуске приложения
  static Future<void> initialize() async {
    // Очищаем старые записи
    await cleanupOldPendingPlants();
  }
}
