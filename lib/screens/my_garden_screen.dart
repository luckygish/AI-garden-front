import 'package:flutter/material.dart';
import '../models/user.dart';
import '../models/plant.dart';
import '../models/care_event.dart';
import '../utils/plant_icons.dart';
import '../api/api_service.dart';
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
  List<Plant> plants = [];
  final List<CareEvent> careEvents = [];
  bool _loading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadPlants();
  }

  Future<void> _loadPlants() async {
    setState(() { _loading = true; _error = null; });
    try {
      final list = await ApiService.getUserPlants();
      final mapped = list.map((m) {
        final id = (m['id'] ?? m['plantId']).toString();
        return Plant(
          id: id,
          name: (m['name'] ?? '').toString(),
          variety: (m['variety'] as String?),
          description: (m['description'] ?? 'Описание растения').toString(),
          plantingDate: DateTime.tryParse((m['plantingDate'] ?? '').toString()) ?? DateTime.now(),
          growthStage: (m['growthStage'] ?? '').toString(),
          imageUrl: 'lib/assets/images/plant_placeholder.svg',
          category: '',
          culture: (m['culture'] as String?), // Получаем culture из бэкенда
        );
      }).toList();
      if (!mounted) return;
      setState(() { plants = mapped; _loading = false; });
    } catch (e) {
      if (!mounted) return;
      setState(() { _error = e.toString(); _loading = false; });
    }
  }

  Future<void> _deletePlantServer(Plant plant) async {
    try {
      await ApiService.deletePlant(plant.id);
      setState(() { plants.removeWhere((p) => p.id == plant.id); });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('${plant.name} удален из сада')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Ошибка удаления: $e'), backgroundColor: Colors.red),
      );
    }
  }

  void _confirmDeletePlant(Plant plant) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Удалить растение?'),
          content: Text('Вы уверены, что хотите удалить "${plant.name}" из своего сада?'),
          actions: [
            TextButton(onPressed: () => Navigator.of(context).pop(), child: const Text('Отмена')),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                _deletePlantServer(plant);
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
          IconButton(icon: const Icon(Icons.refresh), onPressed: _loading ? null : _loadPlants),
        ],
      ),
      body: _buildBody(context),
      floatingActionButton: Column(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
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

  Widget _buildBody(BuildContext context) {
    if (_loading) return const Center(child: CircularProgressIndicator());
    if (_error != null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.error_outline, color: Colors.red, size: 40),
              const SizedBox(height: 8),
              Text(_error!, style: const TextStyle(color: Colors.red)),
              const SizedBox(height: 8),
              ElevatedButton(onPressed: _loadPlants, child: const Text('Повторить')),
            ],
          ),
        ),
      );
    }
    return plants.isEmpty ? _buildEmptyState(context) : _buildPlantsList(context);
  }

  Widget _buildEmptyState(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.eco, size: 64, color: Colors.grey),
          const SizedBox(height: 20),
          const Text('Ваш сад пуст', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
          const SizedBox(height: 10),
          const Text('Добавьте первое растение, чтобы начать', textAlign: TextAlign.center, style: TextStyle(color: Colors.grey)),
          const SizedBox(height: 20),
          ElevatedButton(onPressed: () => _navigateToCatalog(context), child: const Text('Добавить растение')),
        ],
      ),
    );
  }

  Widget _buildPlantsList(BuildContext context) {
    return RefreshIndicator(
      onRefresh: _loadPlants,
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
              _confirmDeletePlant(plant);
              return false;
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
                        user: widget.user,
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
    );
  }

  void _navigateToCatalog(BuildContext context) async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => CatalogScreen(user: widget.user),
      ),
    );
    
    // Если растение было добавлено, добавляем его в локальный список
    if (result != null && result is Plant) {
      setState(() {
        plants.add(result);
      });
    } else {
      // Иначе перезагружаем весь список
      _loadPlants();
    }
  }
}