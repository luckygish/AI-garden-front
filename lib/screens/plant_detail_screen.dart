import 'package:flutter/material.dart';
import '../models/plant.dart';
import '../models/care_event.dart';
import 'feeding_schedule_screen.dart';
import 'care_guide_screen.dart';
import 'plant_usage_screen.dart';

class PlantDetailScreen extends StatelessWidget {
  final Plant plant;
  final List<CareEvent> careEvents;

  const PlantDetailScreen({
    super.key,
    required this.plant,
    required this.careEvents,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text(
          'Краткая информация',
          style: TextStyle(
            color: Colors.black,
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0,
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Герой-секция
            _buildHeroSection(),
            const SizedBox(height: 20),

            // Ближайшие мероприятия
            _buildNextCareEvent(context),
            const SizedBox(height: 24),

            // Описание и особенности
            _buildDescriptionSection(),
            const SizedBox(height: 24),

            // Полезные ссылки
            _buildUsefulLinksSection(context),
            const SizedBox(height: 24),

            // История ухода
            _buildCareHistory(),
          ],
        ),
      ),
    );
  }

  Widget _buildHeroSection() {
    return Card(
      elevation: 0,
      color: const Color(0xFFF5F5F5),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Row(
          children: [
            CircleAvatar(
              radius: 30,
              backgroundImage: NetworkImage(plant.imageUrl),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    plant.name,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  if (plant.variety != null)
                    Text(
                      plant.variety!,
                      style: const TextStyle(
                        fontSize: 14,
                        color: Colors.grey,
                      ),
                    ),
                  const SizedBox(height: 4),
                  Text(
                    'Посажено: ${plant.plantingDate.day}.${plant.plantingDate.month}.${plant.plantingDate.year}',
                    style: const TextStyle(
                      fontSize: 12,
                      color: Colors.grey,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Стадия: ${plant.growthStage}',
                    style: const TextStyle(
                      fontSize: 12,
                      color: Colors.green,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNextCareEvent(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Ближайшие мероприятия',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 12),

        if (careEvents.isEmpty)
          _buildEmptyCareEvent()
        else
          ...careEvents.map((event) => _buildCareEventCard(context, event)),
      ],
    );
  }

  Widget _buildEmptyCareEvent() {
    return Card(
      elevation: 0,
      color: const Color(0xFFF5F5F5),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: const Padding(
        padding: EdgeInsets.all(16.0),
        child: Text(
          'Ближайших мероприятий нет',
          style: TextStyle(color: Colors.grey),
        ),
      ),
    );
  }

  Widget _buildCareEventCard(BuildContext context, CareEvent event) {
    return Card(
      elevation: 0,
      margin: const EdgeInsets.only(bottom: 12),
      color: const Color(0xFFE8F5E9),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '${event.date.day}.${event.date.month}.${event.date.year} - ${event.title}',
              style: const TextStyle(
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              event.description,
              style: const TextStyle(
                fontSize: 12,
                color: Colors.grey,
              ),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => CareGuideScreen(event: event),
                        ),
                      );
                    },
                    style: OutlinedButton.styleFrom(
                      foregroundColor: Colors.green,
                      side: const BorderSide(color: Colors.green),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    child: const Text('Подробнее'),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () {
                      // Логика отметки выполнения
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    child: const Text('Отметить'),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDescriptionSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Описание и особенности',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 12),
        Card(
          elevation: 0,
          color: const Color(0xFFF5F5F5),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Text(
              plant.description,
              style: const TextStyle(
                fontSize: 14,
                height: 1.4,
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildUsefulLinksSection(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Полезные ссылки',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 12),

        // Карточка магазина
        Card(
          elevation: 0,
          margin: const EdgeInsets.only(bottom: 12),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
            side: const BorderSide(color: Color(0xFFEEEEEE)),
          ),
          child: ListTile(
            leading: const Icon(Icons.shopping_cart, color: Colors.green),
            title: const Text('Семена и саженцы'),
            subtitle: const Text('100 ₽'),
            trailing: const Icon(Icons.arrow_forward_ios, size: 16),
            onTap: () {
              // Открыть внешнюю ссылку
            },
          ),
        ),

        // Карточка использования урожая
        Card(
          elevation: 0,
          margin: const EdgeInsets.only(bottom: 12),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
            side: const BorderSide(color: Color(0xFFEEEEEE)),
          ),
          child: ListTile(
            leading: const Icon(Icons.restaurant, color: Colors.green),
            title: const Text('Использование культуры'),
            subtitle: const Text('Рецепты и советы'),
            trailing: const Icon(Icons.arrow_forward_ios, size: 16),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => PlantUsageScreen(plant: plant),
                ),
              );
            },
          ),
        ),

        // Карточка графика подкормок
        Card(
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
            side: const BorderSide(color: Color(0xFFEEEEEE)),
          ),
          child: ListTile(
            leading: const Icon(Icons.calendar_today, color: Colors.green),
            title: const Text('График подкормок'),
            subtitle: const Text('Годовой план ухода'),
            trailing: const Icon(Icons.arrow_forward_ios, size: 16),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => FeedingScheduleScreen(plant: plant),
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildCareHistory() {
    // Временные данные для истории ухода
    final careHistory = [
      {'date': '1.01.2024', 'action': 'Обработка', 'status': 'Выполнено'},
      {'date': '15.12.2023', 'action': 'Подкормка', 'status': 'Выполнено'},
      {'date': '1.11.2023', 'action': 'Полив', 'status': 'Выполнено'},
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'История ухода',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 12),
        ...careHistory.map((history) => _buildHistoryItem(history)),
      ],
    );
  }

  Widget _buildHistoryItem(Map<String, String> history) {
    return Card(
      elevation: 0,
      margin: const EdgeInsets.only(bottom: 8),
      color: const Color(0xFFF5F5F5),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8),
      ),
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              history['date']!,
              style: const TextStyle(
                fontSize: 12,
                color: Colors.grey,
              ),
            ),
            Text(
              history['action']!,
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
              ),
            ),
            Text(
              history['status']!,
              style: const TextStyle(
                fontSize: 12,
                color: Colors.green,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }
}