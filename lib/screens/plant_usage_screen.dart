import 'package:flutter/material.dart';
import '../models/plant.dart';

class PlantUsageScreen extends StatelessWidget {
  final Plant plant;

  const PlantUsageScreen({super.key, required this.plant});

  @override
  Widget build(BuildContext context) {
    final usageData = _getUsageData(plant.name);

    return Scaffold(
      appBar: AppBar(
        title: Text('Использование ${plant.name}'),
        backgroundColor: Colors.green,
        foregroundColor: Colors.white,
      ),
      body: ListView.builder(
        itemCount: usageData.length,
        itemBuilder: (context, index) {
          final item = usageData[index];
          return Card(
            margin: const EdgeInsets.all(8.0),
            child: ExpansionTile(
              leading: Icon(_getIconForType(item['type']!)),
              title: Text(item['title']!),
              subtitle: Text(item['subtitle']!),
              children: [
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Text(
                    item['description']!,
                    style: const TextStyle(fontSize: 14),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  List<Map<String, String>> _getUsageData(String plantName) {
    if (plantName.toLowerCase().contains('томат')) {
      return [
        {
          'type': 'recipe',
          'title': 'Салат из свежих томатов',
          'subtitle': 'Лёгкий летний салат',
          'description': 'Нарежьте помидоры кольцами, добавьте лук, зелень, заправьте оливковым маслом и бальзамическим уксусом.'
        },
        {
          'type': 'preservation',
          'title': 'Консервированные томаты',
          'subtitle': 'Заготовка на зиму',
          'description': 'Стерилизуйте банки, уложите помидоры, добавьте специи, залейте маринадом из воды, соли, сахара и уксуса.'
        },
      ];
    }

    return [
      {
        'type': 'general',
        'title': 'Сбор и хранение урожая',
        'subtitle': 'Основные рекомендации',
        'description': 'Собирайте урожай в сухую погоду. Храните в прохладном месте с хорошей вентиляцией.'
      },
      {
        'type': 'recipe',
        'title': 'Базовые рецепты',
        'subtitle': 'Просто и вкусно',
        'description': 'Используйте свежим в салатах, добавляйте в горячие блюда или консервируйте.'
      },
    ];
  }

  IconData _getIconForType(String type) {
    switch (type) {
      case 'recipe':
        return Icons.restaurant;
      case 'preservation':
        return Icons.kitchen;
      default:
        return Icons.info;
    }
  }
}