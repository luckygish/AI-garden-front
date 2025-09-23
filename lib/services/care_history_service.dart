class CareHistoryService {
  static final Set<String> _completedOperations = <String>{};
  static final Map<String, Map<String, dynamic>> _operationDetails = <String, Map<String, dynamic>>{};

  // Добавить выполненную операцию с деталями
  static void addCompletedOperation(String operationId, {Map<String, dynamic>? details}) {
    _completedOperations.add(operationId);
    if (details != null) {
      _operationDetails[operationId] = details;
    }
  }

  // Удалить выполненную операцию
  static void removeCompletedOperation(String operationId) {
    _completedOperations.remove(operationId);
    _operationDetails.remove(operationId);
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
  static void clearAllOperations() {
    _completedOperations.clear();
    _operationDetails.clear();
  }
}
