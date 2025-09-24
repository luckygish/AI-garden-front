import 'package:flutter/material.dart';
import '../models/user.dart';
import '../models/care_event.dart';
import '../models/plant.dart';
import '../services/upcoming_events_service.dart';
import '../api/api_service.dart';
import 'care_guide_screen.dart';
import 'care_plan_details_screen.dart';

class NotificationsScreen extends StatefulWidget {
  final User user;

  const NotificationsScreen({super.key, required this.user});

  @override
  State<NotificationsScreen> createState() => _NotificationsScreenState();
}

class _NotificationsScreenState extends State<NotificationsScreen> {
  bool _notificationsEnabled = true;
  TimeOfDay _notificationTime = const TimeOfDay(hour: 9, minute: 0);
  List<CareEvent> _upcomingEvents = [];
  List<Plant> _plants = []; // Добавляем список растений
  bool _loadingEvents = true;

  @override
  void initState() {
    super.initState();
    _notificationsEnabled = widget.user.notificationsEnabled;
    _loadUpcomingEvents();
  }

  Future<void> _loadUpcomingEvents() async {
    setState(() {
      _loadingEvents = true;
    });

    try {
      // Получаем реальный список растений пользователя из API
      final plantsData = await ApiService.getUserPlants();
      
      // Преобразуем данные в объекты Plant
      final plants = plantsData.map((data) => Plant(
        id: (data['id'] ?? '').toString(),
        name: (data['name'] ?? '').toString(),
        variety: data['variety'] as String?,
        plantingDate: DateTime.parse(data['plantingDate'] ?? DateTime.now().toIso8601String()),
        growthStage: (data['growthStage'] ?? '').toString(),
        imageUrl: (data['imageUrl'] ?? '').toString(),
        description: (data['description'] ?? '').toString(),
        category: (data['category'] ?? '').toString(),
        culture: (data['culture'] ?? '').toString(),
      )).toList();
      
      if (plants.isNotEmpty) {
        final events = await UpcomingEventsService.getUpcomingEvents(widget.user, plants);
        setState(() {
          _upcomingEvents = events;
          _plants = plants; // Сохраняем растения для навигации
          _loadingEvents = false;
        });
      } else {
        setState(() {
          _upcomingEvents = [];
          _plants = [];
          _loadingEvents = false;
        });
      }
    } catch (e) {
      setState(() {
        _upcomingEvents = [];
        _loadingEvents = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Уведомления'),
        backgroundColor: Colors.green,
        foregroundColor: Colors.white,
      ),
      body: ListView(
        padding: const EdgeInsets.all(16.0),
        children: [
          // Настройки уведомлений
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Настройки уведомлений',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 16),

                  SwitchListTile(
                    title: const Text('Разрешить уведомления'),
                    value: _notificationsEnabled,
                    onChanged: (value) {
                      setState(() {
                        _notificationsEnabled = value;
                      });
                    },
                  ),

                  ListTile(
                    title: const Text('Время напоминаний'),
                    subtitle: Text(_notificationTime.format(context)),
                    trailing: const Icon(Icons.access_time),
                    onTap: _notificationsEnabled ? _selectTime : null,
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(height: 24),

          // Предстоящие уведомления
          const Text(
            'Предстоящие мероприятия',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 12),

          _loadingEvents
              ? const Card(
            child: Padding(
              padding: EdgeInsets.all(16.0),
              child: Center(
                child: CircularProgressIndicator(),
              ),
            ),
          )
              : _upcomingEvents.isEmpty
              ? const Card(
            child: Padding(
              padding: EdgeInsets.all(16.0),
              child: Text('Предстоящих мероприятий нет'),
            ),
          )
              : Column(
            children: _upcomingEvents.map((event) {
              return Card(
                margin: const EdgeInsets.only(bottom: 8),
                child: ListTile(
                  leading: _getEventIcon(event.title),
                  title: Text(event.title),
                  subtitle: Text(
                      '${_formatEventDate(event.date)} '
                          'в ${_notificationTime.format(context)}'
                  ),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () {
                    // Находим растение по ID из события
                    final plant = _plants.firstWhere(
                      (p) => p.id == event.plantId,
                      orElse: () => Plant(
                        id: event.plantId,
                        name: 'Неизвестное растение',
                        variety: null,
                        plantingDate: DateTime.now(),
                        growthStage: '',
                        imageUrl: '',
                        description: '',
                        category: '',
                        culture: '',
                      ),
                    );
                    
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => CarePlanDetailsScreen(
                          plant: plant,
                          user: widget.user,
                        ),
                      ),
                    );
                  },
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  Future<void> _selectTime() async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: _notificationTime,
    );

    if (picked != null && picked != _notificationTime) {
      setState(() {
        _notificationTime = picked;
      });
    }
  }

  Icon _getEventIcon(String title) {
    if (title.toLowerCase().contains('подкормка')) {
      return const Icon(Icons.eco, color: Colors.green);
    } else if (title.toLowerCase().contains('обработка')) {
      return const Icon(Icons.medical_services, color: Colors.blue);
    }
    return const Icon(Icons.calendar_today);
  }

  String _formatEventDate(DateTime date) {
    final now = DateTime.now();
    final currentMonth = now.month;
    final eventMonth = date.month;
    
    // Если событие в текущем месяце
    if (eventMonth == currentMonth) {
      return '${_getMonthName(date.month)} (текущий месяц)';
    }
    // Если событие в следующем месяце
    else if (eventMonth == (currentMonth % 12) + 1) {
      return '${_getMonthName(date.month)} (следующий месяц)';
    }
    // Для других случаев
    else {
      return '${_getMonthName(date.month)} ${date.year}';
    }
  }

  String _getMonthName(int month) {
    const months = [
      'января', 'февраля', 'марта', 'апреля', 'мая', 'июня',
      'июля', 'августа', 'сентября', 'октября', 'ноября', 'декабря'
    ];
    return months[month - 1];
  }
}