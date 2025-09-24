import 'package:flutter/material.dart';
import '../models/user.dart';
import '../models/plant.dart';
import '../utils/plant_icons.dart';
import 'add_plant_screen.dart';

class CatalogScreen extends StatefulWidget {
  final User user;

  const CatalogScreen({super.key, required this.user});

  @override
  State<CatalogScreen> createState() => _CatalogScreenState();
}

class _CatalogScreenState extends State<CatalogScreen> {
  final List<PlantCategory> _categories = [
    PlantCategory(name: 'Овощи', plants: [
      Plant(
        id: '1',
        name: 'Томат',
        description: 'Популярный овощ, требует много солнца и тепла. Нуждается в подвязке и пасынковании.',
        plantingDate: DateTime.now(),
        growthStage: 'Взрослое',
        imageUrl: '', category: '',
      ),
      Plant(
        id: '2',
        name: 'Огурец',
        description: 'Любит влагу и тепло. Требует регулярного полива и плодородной почвы.',
        plantingDate: DateTime.now(),
        growthStage: 'Взрослое',
        imageUrl: '', category: '',
      ),
      Plant(
        id: '3',
        name: 'Перец',
        description: 'Теплолюбивое растение. Нуждается в защите от ветра и регулярном удобрении.',
        plantingDate: DateTime.now(),
        growthStage: 'Взрослое',
        imageUrl: '', category: '',
      ),
      Plant(
        id: '4',
        name: 'Морковь',
        description: 'Корнеплод, предпочитает рыхлые почвы. Требует прореживания всходов.',
        plantingDate: DateTime.now(),
        growthStage: 'Взрослое',
        imageUrl: '', category: '',
      ),
    ]),
    PlantCategory(name: 'Фрукты', plants: [
      Plant(
        id: '5',
        name: 'Яблоня',
        description: 'Плодовое дерево. Требует ежегодной обрезки и защиты от вредителей.',
        plantingDate: DateTime.now(),
        growthStage: 'Взрослое',
        imageUrl: '', category: '',
      ),
      Plant(
        id: '6',
        name: 'Груша',
        description: 'Дерево с сочными плодами. Нуждается в солнечном месте и плодородной почве.',
        plantingDate: DateTime.now(),
        growthStage: 'Взрослое',
        imageUrl: '', category: '',
      ),
    ]),
    PlantCategory(name: 'Ягоды', plants: [
      Plant(
        id: '7',
        name: 'Клубника',
        description: 'Многолетнее растение. Требует обновления посадок каждые 3-4 года.',
        plantingDate: DateTime.now(),
        growthStage: 'Взрослое',
        imageUrl: '', category: '',
      ),
      Plant(
        id: '8',
        name: 'Малина',
        description: 'Кустарник с ароматными ягодами. Нуждается в опоре и регулярной обрезке.',
        plantingDate: DateTime.now(),
        growthStage: 'Взрослое',
        imageUrl: '', category: '',
      ),
    ]),
    PlantCategory(name: 'Зелень', plants: [
      Plant(
        id: '9',
        name: 'Петрушка',
        description: 'Ароматная зелень. Холодостойкое растение, можно выращивать круглый год.',
        plantingDate: DateTime.now(),
        growthStage: 'Взрослое',
        imageUrl: '', category: '',
      ),
      Plant(
        id: '10',
        name: 'Укроп',
        description: 'Пряная зелень. Быстро растет, можно сеять несколько раз за сезон.',
        plantingDate: DateTime.now(),
        growthStage: 'Взрослое',
        imageUrl: '', category: '',
      ),
    ]),
  ];

  final TextEditingController _searchController = TextEditingController();
  String _selectedCategory = 'Все';
  List<Plant> _filteredPlants = [];

  @override
  void initState() {
    super.initState();
    _filteredPlants = _getAllPlants();
  }

  List<Plant> _getAllPlants() {
    return _categories.expand((category) => category.plants).toList();
  }

  void _filterPlants(String query) {
    setState(() {
      _filteredPlants = _getAllPlants().where((plant) {
        final nameMatch = plant.name.toLowerCase().contains(query.toLowerCase());
        final categoryMatch = _selectedCategory == 'Все' || _getPlantCategory(plant.name) == _selectedCategory;
        return nameMatch && categoryMatch;
      }).toList();
    });
  }

  String _getPlantCategory(String plantName) {
    final name = plantName.toLowerCase();
    if (name.contains('томат') || name.contains('огурец') || name.contains('перец') || name.contains('морков')) {
      return 'Овощи';
    } else if (name.contains('яблон') || name.contains('груш')) {
      return 'Фрукты';
    } else if (name.contains('клубник') || name.contains('малин')) {
      return 'Ягоды';
    } else if (name.contains('петруш') || name.contains('укроп')) {
      return 'Зелень';
    }
    return 'Другие';
  }

  void _showAddPlantDialog(Plant plant) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) {
        return Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Иконка растения из общего класса
              PlantIcons.getStyledIcon(plant.name, size: 60),
              const SizedBox(height: 16),

              Text(
                plant.name,
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),

              Text(
                plant.description,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 14,
                  color: Colors.grey,
                ),
              ),
              const SizedBox(height: 20),

              ElevatedButton(
                onPressed: () async {
                  Navigator.pop(context);
                  final result = await Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => AddPlantScreen(plant: plant, user: widget.user),
                    ),
                  );
                  
                  // Если растение было успешно добавлено, возвращаемся к списку сада
                  if (result != null && mounted) {
                    Navigator.pop(context, result);
                  }
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green,
                  foregroundColor: Colors.white,
                  minimumSize: const Size(double.infinity, 50),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: const Text('Добавить в мой сад'),
              ),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Каталог растений'),
        backgroundColor: Colors.green,
        foregroundColor: Colors.white,
      ),
      body: Column(
        children: [
          // Поисковая строка
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'Поиск растений...',
                prefixIcon: const Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                contentPadding: const EdgeInsets.symmetric(horizontal: 16),
              ),
              onChanged: _filterPlants,
            ),
          ),

          // Категории
          SizedBox(
            height: 50,
            child: ListView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              children: [
                _buildCategoryChip('Все'),
                ..._categories.map((category) => _buildCategoryChip(category.name)),
              ],
            ),
          ),

          const SizedBox(height: 16),

          // Список растений
          Expanded(
            child: _filteredPlants.isEmpty
                ? const Center(
              child: Text(
                'Растения не найдены',
                style: TextStyle(color: Colors.grey),
              ),
            )
                : ListView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              itemCount: _filteredPlants.length,
              itemBuilder: (context, index) {
                final plant = _filteredPlants[index];
                return _buildPlantCard(plant);
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCategoryChip(String category) {
    final isSelected = _selectedCategory == category;
    return Padding(
      padding: const EdgeInsets.only(right: 8.0),
      child: FilterChip(
        label: Text(category),
        selected: isSelected,
        onSelected: (selected) {
          setState(() {
            _selectedCategory = selected ? category : 'Все';
            _filterPlants(_searchController.text);
          });
        },
        backgroundColor: Colors.white,
        selectedColor: Colors.green,
        labelStyle: TextStyle(
          color: isSelected ? Colors.white : Colors.black,
        ),
        shape: StadiumBorder(
          side: BorderSide(
            color: isSelected ? Colors.green : Colors.grey[300]!,
          ),
        ),
      ),
    );
  }

  Widget _buildPlantCard(Plant plant) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: ListTile(
        leading: PlantIcons.getStyledIcon(plant.name), // Используем общий класс иконок
        title: Text(
          plant.name,
          style: const TextStyle(
            fontWeight: FontWeight.w500,
          ),
        ),
        subtitle: Text(
          _getPlantCategory(plant.name),
          style: const TextStyle(
            fontSize: 12,
            color: Colors.grey,
          ),
        ),
        trailing: const Icon(Icons.chevron_right, color: Colors.grey),
        onTap: () => _showAddPlantDialog(plant),
      ),
    );
  }
}

class PlantCategory {
  final String name;
  final List<Plant> plants;

  PlantCategory({required this.name, required this.plants});
}