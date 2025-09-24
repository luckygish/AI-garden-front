import 'dart:async';
import 'package:flutter/material.dart';
import 'pending_plants_service.dart';
import '../api/api_service.dart';

class PlantNotificationService {
  static Timer? _checkTimer;
  static bool _isChecking = false;
  
  /// Запускает периодическую проверку ожидающих растений
  static void startPeriodicCheck(BuildContext context) {
    // Проверяем каждые 30 секунд
    _checkTimer = Timer.periodic(const Duration(seconds: 30), (timer) {
      _checkPendingPlants(context);
    });
    
    // Первая проверка через 10 секунд
    Timer(const Duration(seconds: 10), () {
      _checkPendingPlants(context);
    });
  }
  
  /// Останавливает периодическую проверку
  static void stopPeriodicCheck() {
    _checkTimer?.cancel();
    _checkTimer = null;
  }
  
  /// Проверяет ожидающие растения
  static Future<void> _checkPendingPlants(BuildContext context) async {
    if (_isChecking) return;
    
    _isChecking = true;
    
    try {
      final appearedPlants = await PendingPlantsService.checkPendingPlants();
      
      if (appearedPlants.isNotEmpty && context.mounted) {
        for (final plant in appearedPlants) {
          _showPlantAppearedNotification(context, plant);
        }
      }
    } catch (e) {
      print('Ошибка проверки ожидающих растений: $e');
    } finally {
      _isChecking = false;
    }
  }
  
  /// Показывает уведомление о появившемся растении
  static void _showPlantAppearedNotification(BuildContext context, Map<String, dynamic> plant) {
    final plantName = plant['plantName'] as String;
    
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.check_circle, color: Colors.white),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                'Растение "$plantName" добавлено в ваш сад!',
                style: const TextStyle(fontSize: 14),
              ),
            ),
          ],
        ),
        backgroundColor: Colors.green,
        duration: const Duration(seconds: 5),
        behavior: SnackBarBehavior.floating,
        action: SnackBarAction(
          label: 'Открыть',
          textColor: Colors.white,
          onPressed: () {
            // Можно добавить навигацию к растению
            ScaffoldMessenger.of(context).hideCurrentSnackBar();
          },
        ),
      ),
    );
  }
  
  /// Ручная проверка ожидающих растений
  static Future<void> checkNow(BuildContext context) async {
    await _checkPendingPlants(context);
  }
}
