import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

class CareHistoryService {
  static const String _completedOperationsKey = 'completed_operations';
  static const String _operationDetailsKey = 'operation_details';
  
  static final Set<String> _completedOperations = <String>{};
  static final Map<String, Map<String, dynamic>> _operationDetails = <String, Map<String, dynamic>>{};

  // Инициализация при запуске приложения
  static Future<void> initialize() async {
    final prefs = await SharedPreferences.getInstance();
    
    // Загружаем выполненные операции
    final completedOpsJson = prefs.getString(_completedOperationsKey);
    if (completedOpsJson != null) {
      final List<dynamic> completedOps = json.decode(completedOpsJson);
      _completedOperations.addAll(completedOps.cast<String>());
    }
    
    // Загружаем детали операций
    final detailsJson = prefs.getString(_operationDetailsKey);
    if (detailsJson != null) {
      final Map<String, dynamic> details = json.decode(detailsJson);
      _operationDetails.addAll(details.map((key, value) => MapEntry(key, Map<String, dynamic>.from(value))));
    }
  }

  // Сохранение в SharedPreferences
  static Future<void> _saveToPrefs() async {
    final prefs = await SharedPreferences.getInstance();
    
    // Сохраняем выполненные операции
    await prefs.setString(_completedOperationsKey, json.encode(_completedOperations.toList()));
    
    // Сохраняем детали операций
    await prefs.setString(_operationDetailsKey, json.encode(_operationDetails));
  }

  // Добавить выполненную операцию с деталями
  static Future<void> addCompletedOperation(String operationId, {Map<String, dynamic>? details}) async {
    _completedOperations.add(operationId);
    if (details != null) {
      _operationDetails[operationId] = details;
    }
    await _saveToPrefs();
  }

  // Удалить выполненную операцию
  static Future<void> removeCompletedOperation(String operationId) async {
    _completedOperations.remove(operationId);
    _operationDetails.remove(operationId);
    await _saveToPrefs();
  }

  // Получить все выполненные операции
  static List<String> getCompletedOperations() {
    return _completedOperations.toList();
  }

  // Проверить, выполнена ли операция
  static bool isOperationCompleted(String operationId) {
    return _completedOperations.contains(operationId);
  }

  // Получить детали операции
  static Map<String, dynamic>? getOperationDetails(String operationId) {
    return _operationDetails[operationId];
  }

  // Очистить все выполненные операции
  static Future<void> clearAllOperations() async {
    _completedOperations.clear();
    _operationDetails.clear();
    await _saveToPrefs();
  }
}
