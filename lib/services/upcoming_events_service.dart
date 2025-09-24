import '../api/api_service.dart';
import '../models/care_event.dart';
import '../models/plant.dart';
import '../models/user.dart';

class UpcomingEventsService {
  // Получить ближайшие мероприятия из плана ухода
  static Future<List<CareEvent>> getUpcomingEvents(User user, List<Plant> plants) async {
    final List<CareEvent> upcomingEvents = [];
    
    print('🔍 Поиск предстоящих мероприятий для ${plants.length} растений');
    
    try {
      // Получаем план ухода для каждого растения
      for (final plant in plants) {
        print('🌱 Обрабатываем растение: ${plant.name} (${plant.culture ?? plant.name})');
        
        final carePlan = await ApiService.getCarePlanByParams(
          culture: plant.culture ?? plant.name, // Используем culture если есть, иначе name
          region: user.region,
          gardenType: user.gardenType,
        );
        
        if (carePlan != null && carePlan['operations'] != null) {
          final operations = carePlan['operations'] as List<dynamic>;
          print('📋 Найдено ${operations.length} операций для ${plant.name}');
          
          // Обрабатываем операции и создаем события
          for (final operation in operations) {
            final operationMap = operation as Map<String, dynamic>;
            final type = (operationMap['type'] ?? '').toString();
            final fase = (operationMap['fase'] ?? '').toString();
            final period = (operationMap['period'] ?? '').toString();
            final description = (operationMap['description'] ?? '').toString();
            
            print('🔍 Операция: $type - $fase - $period');
            
            // Парсим период для определения месяца
            final eventMonth = _parseMonthFromPeriod(period);
            if (eventMonth != null && _isEventInCurrentOrNextMonth(eventMonth)) {
              print('✅ Событие в текущем/следующем месяце: $eventMonth');
              
              // Создаем событие для всего месяца
              final event = CareEvent(
                id: '${plant.id}_${type}_${fase}',
                plantId: plant.id,
                title: fase.isNotEmpty ? fase : type,
                description: description,
                date: DateTime(DateTime.now().year, eventMonth, 1), // Первое число месяца
                options: _createCareOptions(operationMap),
              );
              
              upcomingEvents.add(event);
            } else {
              print('❌ Событие не в текущем/следующем месяце: $eventMonth');
            }
          }
        } else {
          print('❌ План ухода не найден для ${plant.name}');
        }
      }
      
      print('📅 Итого найдено ${upcomingEvents.length} предстоящих событий');
      
      // Сортируем по дате и возвращаем все события текущего и следующего месяца
      upcomingEvents.sort((a, b) => a.date.compareTo(b.date));
      return upcomingEvents;
      
    } catch (e) {
      print('❌ Ошибка получения предстоящих мероприятий: $e');
      return [];
    }
  }
  
  // Парсим месяц из периода
  static int? _parseMonthFromPeriod(String period) {
    if (period.isEmpty) return null;
    
    try {
      final periodLower = period.toLowerCase();
      
      // Ищем упоминания месяцев (расширенный список)
      if (periodLower.contains('январ') || periodLower.contains('янв')) {
        return 1;
      } else if (periodLower.contains('феврал') || periodLower.contains('фев')) {
        return 2;
      } else if (periodLower.contains('март') || periodLower.contains('мар')) {
        return 3;
      } else if (periodLower.contains('апрел') || periodLower.contains('апр')) {
        return 4;
      } else if (periodLower.contains('май') || periodLower.contains('мая')) {
        return 5;
      } else if (periodLower.contains('июн') || periodLower.contains('июня')) {
        return 6;
      } else if (periodLower.contains('июл') || periodLower.contains('июля')) {
        return 7;
      } else if (periodLower.contains('август') || periodLower.contains('авг')) {
        return 8;
      } else if (periodLower.contains('сентябр') || periodLower.contains('сен') || periodLower.contains('сент')) {
        return 9;
      } else if (periodLower.contains('октябр') || periodLower.contains('окт')) {
        return 10;
      } else if (periodLower.contains('ноябр') || periodLower.contains('ноя')) {
        return 11;
      } else if (periodLower.contains('декабр') || periodLower.contains('дек')) {
        return 12;
      }
      
      // Если не найден месяц, возвращаем null
      return null;
      
    } catch (e) {
      return null;
    }
  }

  // Проверяем, находится ли событие в текущем или следующем месяце
  static bool _isEventInCurrentOrNextMonth(int eventMonth) {
    final now = DateTime.now();
    final currentMonth = now.month;
    final nextMonth = (currentMonth % 12) + 1;
    
    // Событие должно быть в текущем или следующем месяце
    return eventMonth == currentMonth || eventMonth == nextMonth;
  }
  
  // Создаем опции ухода из операции
  static List<CareOption> _createCareOptions(Map<String, dynamic> operation) {
    final List<CareOption> options = [];
    final materials = operation['materials'] as List<dynamic>? ?? [];
    
    if (materials.isNotEmpty) {
      final products = <String>[];
      final alternatives = <String>[];
      
      for (final material in materials) {
        final materialMap = material as Map<String, dynamic>;
        final name = (materialMap['name'] ?? '').toString();
        final alts = materialMap['alternatives'] as List<dynamic>? ?? [];
        
        if (name.isNotEmpty) {
          products.add(name);
        }
        
        for (final alt in alts) {
          final altMap = alt as Map<String, dynamic>;
          final altName = (altMap['name'] ?? '').toString();
          if (altName.isNotEmpty) {
            alternatives.add(altName);
          }
        }
      }
      
      if (products.isNotEmpty || alternatives.isNotEmpty) {
        options.add(CareOption(
          type: (operation['type'] ?? '').toString(),
          title: (operation['fase'] ?? operation['type'] ?? '').toString(),
          instructions: (operation['description'] ?? '').toString(),
          products: products,
          alternatives: alternatives,
        ));
      }
    }
    
    return options;
  }
}
