// lib/utils/plant_icons.dart
import 'package:flutter/material.dart';

class PlantIcons {
  // Метод для получения иконки по названию растения
  static IconData getIcon(String plantName) {
    final name = plantName.toLowerCase();

    if (name.contains('томат')) return Icons.local_pizza;
    if (name.contains('огурец')) return Icons.water_drop;
    if (name.contains('перец')) return Icons.local_fire_department;
    if (name.contains('морков')) return Icons.grass;
    if (name.contains('яблон')) return Icons.park;
    if (name.contains('груш')) return Icons.nature;
    if (name.contains('клубник')) return Icons.bakery_dining;
    if (name.contains('малин')) return Icons.forest;
    if (name.contains('петруш')) return Icons.spa;
    if (name.contains('укроп')) return Icons.air;

    return Icons.eco; // Иконка по умолчанию
  }

  // Метод для получения цвета по названию растения
  static Color getColor(String plantName) {
    final name = plantName.toLowerCase();

    if (name.contains('томат')) return Colors.red;
    if (name.contains('огурец')) return Colors.green;
    if (name.contains('перец')) return Colors.orange;
    if (name.contains('морков')) return Colors.orangeAccent;
    if (name.contains('яблон')) return Colors.greenAccent;
    if (name.contains('груш')) return Colors.lightGreen;
    if (name.contains('клубник')) return Colors.pink;
    if (name.contains('малин')) return Colors.purple;
    if (name.contains('петруш')) return Colors.lightGreenAccent;
    if (name.contains('укроп')) return Colors.green;

    return Colors.green; // Цвет по умолчанию
  }

  // Метод для создания стилизованной иконки
  static Widget getStyledIcon(String plantName, {double size = 40}) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: getColor(plantName).withOpacity(0.2),
        shape: BoxShape.circle,
      ),
      child: Icon(
        getIcon(plantName),
        size: size * 0.6,
        color: getColor(plantName),
      ),
    );
  }
}