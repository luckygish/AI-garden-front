import 'package:flutter/material.dart';
import '../models/user.dart';
import '../models/plant.dart';
import '../models/care_event.dart';
import '../utils/plant_icons.dart';
import 'catalog_screen.dart';
import 'plant_detail_screen.dart';
import 'feeding_schedule_screen.dart';
import 'care_guide_screen.dart';
import 'plant_usage_screen.dart';
import 'calendar_screen.dart';
import 'notifications_screen.dart';

class MyGardenScreen extends StatefulWidget {
  final User user;

  MyGardenScreen({super.key, required this.user});

  @override
  State<MyGardenScreen> createState() => _MyGardenScreenState();
}

class _MyGardenScreenState extends State<MyGardenScreen> {
  // Временные данные для тестирования (теперь в состоянии)
  List<Plant> plants = [
    Plant(
      id: '1',
      name: 'Томат',
      variety: 'Бычье сердце',
      description: 'Популярный овощ, требует много солнца',
      plantingDate: DateTime(2024, 5, 15),
      growthStage: 'Цветение',
      imageUrl: 'https://via.placeholder.com/150?text=Tomato', category: '',
    ),
    Plant(
      id: '2',
      name: 'Огурец',
      variety: 'Зозуля',
      description: 'Любит влагу и тепло',
      plantingDate: DateTime(2024, 6, 1),
      growthStage: 'Росток',
      imageUrl: 'https://via.placeholder.com/150?text=Cucumber', category: '',
    ),
  ];

  final List<CareEvent> careEvents = [
    CareEvent(
      id: '1',
      plantId: '1',
      title: 'Подкормка калийным удобрением',
      description: 'Внекорневая подкормка для улучшения плодоношения',
      date: DateTime.now().add(const Duration(days: 3)),
      options: [
        CareOption(
          type: 'Минеральные',
          title: 'Калий сернокислый',
          instructions: '20-30 г на 10 л воды, полив под корень',
          products: ['Калий сернокислый', 'Суперфосфат'],
          alternatives: ['Калимагнезия', 'Древесная зола'],
        ),
      ],
    ),
  ];

  // Метод для удаления растения
  void _deletePlant(String plantId) {
    setState(() {
      plants.removeWhere((plant) => plant.id == plantId);
    });
  }

  // Подтверждение удаления
  void _confirmDeletePlant(Plant plant) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Удалить растение?'),
          content: Text('Вы уверены, что хотите удалить "${plant.name}" из своего сада?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Отмена'),
            ),
            TextButton(
              onPressed: () {
                _deletePlant(plant.id);
                Navigator.of(context).pop();
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('${plant.name} удален из сада'),
                    duration: const Duration(seconds: 2),
                  ),
                );
              },
              child: const Text('Удалить', style: TextStyle(color: Colors.red)),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Мой сад'),
        backgroundColor: Colors.green,
        foregroundColor: Colors.white,
        actions: [
          // Иконка для быстрой навигации по всем экранам
          PopupMenuButton<String>(
            onSelected: (value) => _navigateToScreen(context, value),
            itemBuilder: (BuildContext context) {
              return [
                const PopupMenuItem<String>(
                  value: 'calendar',
                  child: ListTile(
                    leading: Icon(Icons.calendar_today),
                    title: Text('Календарь'),
                  ),
                ),
                const PopupMenuItem<String>(
                  value: 'notifications',
                  child: ListTile(
                    leading: Icon(Icons.notifications),
                    title: Text('Уведомления'),
                  ),
                ),
                const PopupMenuItem<String>(
                  value: 'feeding_schedule',
                  child: ListTile(
                    leading: Icon(Icons.schedule),
                    title: Text('График подкормок'),
                  ),
                ),
                const PopupMenuItem<String>(
                  value: 'care_guide',
                  child: ListTile(
                    leading: Icon(Icons.medical_services),
                    title: Text('Рекомендации по уходу'),
                  ),
                ),
                const PopupMenuItem<String>(
                  value: 'plant_usage',
                  child: ListTile(
                    leading: Icon(Icons.restaurant),
                    title: Text('Использование урожая'),
                  ),
                ),
              ];
            },
          ),
        ],
      ),
      body: plants.isEmpty
          ? _buildEmptyState(context)
          : _buildPlantsList(context),
      floatingActionButton: Column(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          // Кнопка для быстрого тестирования уведомлений
          FloatingActionButton.small(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => NotificationsScreen(user: widget.user),
                ),
              );
            },
            backgroundColor: Colors.blue,
            child: const Icon(Icons.notifications, color: Colors.white),
          ),
          const SizedBox(height: 8),
          // Основная кнопка добавления
          FloatingActionButton(
            onPressed: () {
              _navigateToCatalog(context);
            },
            backgroundColor: Colors.green,
            child: const Icon(Icons.add, color: Colors.white),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.eco, size: 64, color: Colors.grey),
          const SizedBox(height: 20),
          const Text(
            'Ваш сад пуст',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 10),
          const Text(
            'Добавьте первое растение, чтобы начать',
            textAlign: TextAlign.center,
            style: TextStyle(color: Colors.grey),
          ),
          const SizedBox(height: 20),
          ElevatedButton(
            onPressed: () {
              _navigateToCatalog(context);
            },
            child: const Text('Добавить растение'),
          ),
          const SizedBox(height: 20),
          // Кнопки для тестирования всех экранов
          _buildTestButtons(context),
        ],
      ),
    );
  }

  Widget _buildTestButtons(BuildContext context) {
    return Column(
      children: [
        const Text(
          'Тестовые экраны:',
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 10),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            ElevatedButton(
              onPressed: () => _navigateToScreen(context, 'calendar'),
              child: const Text('Календарь'),
            ),
            ElevatedButton(
              onPressed: () => _navigateToScreen(context, 'notifications'),
              child: const Text('Уведомления'),
            ),
            ElevatedButton(
              onPressed: () => _navigateToScreen(context, 'feeding_schedule'),
              child: const Text('График'),
            ),
            ElevatedButton(
              onPressed: () => _navigateToScreen(context, 'care_guide'),
              child: const Text('Уход'),
            ),
            ElevatedButton(
              onPressed: () => _navigateToScreen(context, 'plant_usage'),
              child: const Text('Урожай'),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildPlantsList(BuildContext context) {
    return Column(
      children: [
        // Кнопки для тестирования при наличии растений
        if (plants.isNotEmpty) _buildTestButtons(context),

        Expanded(
          child: ListView.builder(
            itemCount: plants.length,
            itemBuilder: (context, index) {
              final plant = plants[index];
              final plantEvents = careEvents.where((e) => e.plantId == plant.id).toList();

              return Dismissible(
                key: Key(plant.id),
                direction: DismissDirection.endToStart,
                background: Container(
                  color: Colors.red,
                  alignment: Alignment.centerRight,
                  padding: const EdgeInsets.only(right: 20),
                  child: const Icon(Icons.delete, color: Colors.white, size: 30),
                ),
                confirmDismiss: (direction) async {
                  return await showDialog(
                    context: context,
                    builder: (BuildContext context) {
                      return AlertDialog(
                        title: const Text('Удалить растение?'),
                        content: Text('Вы уверены, что хотите удалить "${plant.name}" из своего сада?'),
                        actions: [
                          TextButton(
                            onPressed: () => Navigator.of(context).pop(false),
                            child: const Text('Отмена'),
                          ),
                          TextButton(
                            onPressed: () => Navigator.of(context).pop(true),
                            child: const Text('Удалить', style: TextStyle(color: Colors.red)),
                          ),
                        ],
                      );
                    },
                  );
                },
                onDismissed: (direction) {
                  _deletePlant(plant.id);
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('${plant.name} удален из сада'),
                      duration: const Duration(seconds: 2),
                    ),
                  );
                },
                child: Card(
                  margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  child: ListTile(
                    leading: CircleAvatar(
                      backgroundColor: Colors.transparent,
                      child: PlantIcons.getStyledIcon(plant.name, size: 36),
                    ),
                    title: Text(plant.name),
                    subtitle: plant.variety != null ? Text(plant.variety!) : null,
                    trailing: IconButton(
                      icon: const Icon(Icons.delete_outline, color: Colors.grey),
                      onPressed: () => _confirmDeletePlant(plant),
                    ),
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => PlantDetailScreen(
                            plant: plant,
                            careEvents: plantEvents,
                          ),
                        ),
                      );
                    },
                    onLongPress: () => _confirmDeletePlant(plant),
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  void _navigateToCatalog(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => CatalogScreen(user: widget.user),
      ),
    );
  }

  void _navigateToScreen(BuildContext context, String screen) {
    switch (screen) {
      case 'calendar':
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => CalendarScreen(user: widget.user),
          ),
        );
        break;
      case 'notifications':
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => NotificationsScreen(user: widget.user),
          ),
        );
        break;
      case 'feeding_schedule':
        if (plants.isNotEmpty) {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => FeedingScheduleScreen(plant: plants.first),
            ),
          );
        }
        break;
      case 'care_guide':
        if (careEvents.isNotEmpty) {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => CareGuideScreen(event: careEvents.first),
            ),
          );
        }
        break;
      case 'plant_usage':
        if (plants.isNotEmpty) {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => PlantUsageScreen(plant: plants.first),
            ),
          );
        }
        break;
    }
  }
}