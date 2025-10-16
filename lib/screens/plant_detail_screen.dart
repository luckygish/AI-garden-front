import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/plant.dart';
import '../models/care_event.dart';
import '../models/user.dart';
import '../services/care_history_service.dart';
import '../utils/plant_icons.dart';
import '../api/api_service.dart';
import 'feeding_schedule_screen.dart';
import 'care_guide_screen.dart';
import 'plant_usage_screen.dart';
import 'care_plan_details_screen.dart';

class PlantDetailScreen extends StatefulWidget {
  final Plant plant;
  final List<CareEvent> careEvents;
  final User user;

  const PlantDetailScreen({
    super.key,
    required this.plant,
    required this.careEvents,
    required this.user,
  });

  @override
  State<PlantDetailScreen> createState() => _PlantDetailScreenState();
}

class _PlantDetailScreenState extends State<PlantDetailScreen> {
  List<String> _completedOperations = [];
  bool _historyLoaded = false;
  bool _loadingDescription = false;
  String? _plantDescription;
  Map<String, dynamic>? _varietyData;

  @override
  void initState() {
    super.initState();
    _loadCareHistory();
    _loadSavedVarietyData();
  }

  Future<void> _loadCareHistory() async {
    final completedOps = await CareHistoryService.getCompletedOperations();
    setState(() {
      _completedOperations = completedOps;
      _historyLoaded = true;
    });
  }

  Future<void> _loadPlantDescription() async {
    String? variety = widget.plant.variety;
    
    // Проверяем, заполнен ли сорт
    if (variety == null || variety.isEmpty) {
      final result = await _showVarietyDialog();
      if (result == null) return;
      variety = result;
    }

    setState(() {
      _loadingDescription = true;
    });

    try {
      // Вызываем API для получения описания сорта
      final descriptionData = await ApiService.getOrCreateVarietyDescription(
        culture: widget.plant.name,
        variety: variety!, // variety не может быть null здесь, так как мы проверили выше
      );
      
      // Отладочная информация
      print('📊 Получены данные сорта: $descriptionData');
      
      // Сохраняем данные в SharedPreferences
      await _saveVarietyData(descriptionData);
      
      setState(() {
        _varietyData = descriptionData; // Сохраняем полные данные для структурированного отображения
        _loadingDescription = false;
      });
      
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Описание сорта загружено'),
          backgroundColor: Colors.green,
        ),
      );
    } catch (e) {
      setState(() {
        _loadingDescription = false;
      });
      
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Ошибка загрузки описания: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Future<String?> _showVarietyDialog() async {
    final TextEditingController varietyController = TextEditingController();
    
    final result = await showDialog<String>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Укажите сорт'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('Для загрузки подробного описания необходимо указать сорт растения.'),
            const SizedBox(height: 16),
            TextField(
              controller: varietyController,
              decoration: const InputDecoration(
                labelText: 'Сорт растения',
                hintText: 'Например, Титан',
                border: OutlineInputBorder(),
              ),
              autofocus: true,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Отмена'),
          ),
          ElevatedButton(
            onPressed: () {
              if (varietyController.text.trim().isNotEmpty) {
                Navigator.pop(context, varietyController.text.trim());
              }
            },
            child: const Text('Загрузить'),
          ),
        ],
      ),
    );

    return result;
  }

  /// Загружает сохраненные данные сорта из SharedPreferences
  Future<void> _loadSavedVarietyData() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final plantId = widget.plant.id;
      final savedDataJson = prefs.getString('variety_data_$plantId');
      
      if (savedDataJson != null) {
        final savedData = json.decode(savedDataJson) as Map<String, dynamic>;
        setState(() {
          _varietyData = savedData;
        });
        print('💾 Загружены сохраненные данные сорта для растения $plantId');
      }
    } catch (e) {
      print('❌ Ошибка загрузки сохраненных данных сорта: $e');
    }
  }

  /// Сохраняет данные сорта в SharedPreferences
  Future<void> _saveVarietyData(Map<String, dynamic> data) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final plantId = widget.plant.id;
      final dataJson = json.encode(data);
      await prefs.setString('variety_data_$plantId', dataJson);
      print('💾 Данные сорта сохранены для растения $plantId');
    } catch (e) {
      print('❌ Ошибка сохранения данных сорта: $e');
    }
  }


  String? _formatDiseaseResistance(dynamic diseaseResistance) {
    if (diseaseResistance == null) return null;
    
    if (diseaseResistance is List && diseaseResistance.isNotEmpty) {
      return diseaseResistance.join(', ');
    }
    
    return diseaseResistance.toString();
  }

  Widget _buildVarietyInfoCard() {
    print('🎯 _buildVarietyInfoCard вызван, _varietyData = $_varietyData');
    if (_varietyData == null) {
      print('❌ _varietyData is null, возвращаем SizedBox.shrink()');
      return const SizedBox.shrink();
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Заголовок с названием культуры и сорта
        if (_varietyData!['culture'] != null || _varietyData!['variety'] != null) ...[
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: Colors.green[100],
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              '${_varietyData!['culture'] ?? ''} ${_varietyData!['variety'] ?? ''}'.trim(),
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Colors.green,
              ),
            ),
          ),
          const SizedBox(height: 12),
        ],

        // Основное описание
        if (_varietyData!['description'] != null && _varietyData!['description'] != 'Описание сорта недоступно') ...[
          Text(
            _varietyData!['description'],
            style: const TextStyle(
              fontSize: 14,
              height: 1.4,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 16),
        ],

        // Характеристики сорта
        _buildInfoRow('Срок созревания', _varietyData!['ripeningPeriod'], Icons.schedule),
        _buildInfoRow('Высота растения', _varietyData!['plantHeight'], Icons.height),
        _buildInfoRow('Масса плода', _varietyData!['fruitWeight'], Icons.scale),
        _buildInfoRow('Урожайность', _varietyData!['yield'], Icons.eco),
        _buildInfoRow('Устойчивость к болезням', _formatDiseaseResistance(_varietyData!['diseaseResistance']), Icons.shield),
        _buildInfoRow('Условия выращивания', _varietyData!['growingConditions'], Icons.agriculture),
      ],
    );
  }

  Widget _buildInfoRow(String label, dynamic value, IconData icon) {
    // Отладочная информация
    print('🔍 _buildInfoRow: $label = $value (${value.runtimeType})');
    
    if (value == null || value.toString().trim().isEmpty || 
        value.toString().contains('Не указан') || 
        value.toString().contains('Не указана')) {
      print('❌ Поле $label скрыто: значение = $value');
      return const SizedBox.shrink();
    }

    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 16, color: Colors.green),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '$label:',
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: Colors.black87,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  value.toString(),
                  style: const TextStyle(fontSize: 13, color: Colors.black87),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

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
            _buildHeroSection(),
            const SizedBox(height: 20),
            _buildDescriptionSection(),
            const SizedBox(height: 24),
            _buildUsefulLinksSection(context),
            const SizedBox(height: 24),
            _buildCareHistory(),
          ],
        ),
      ),
    );
  }

  Widget _buildHeroSection() {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Colors.green[50]!,
            Colors.green[100]!,
          ],
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.green[200]!),
        boxShadow: [
          BoxShadow(
            color: Colors.green.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          // Изображение растения с анимацией
          Hero(
            tag: 'plant-${widget.plant.id}',
            child: Container(
              width: 60,
              height: 60,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(30),
                color: Colors.white,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: PlantIcons.getStyledIcon(widget.plant.name, size: 50),
            ),
          ),
          const SizedBox(width: 16),
          // Информация о растении
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  widget.plant.name,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
                const SizedBox(height: 4),
                if (widget.plant.variety != null)
                  Text(
                    widget.plant.variety!,
                    style: const TextStyle(
                      fontSize: 14,
                      color: Colors.grey,
                    ),
                  ),
                const SizedBox(height: 4),
                Text(
                  'Посажено: ${widget.plant.plantingDate.day}.${widget.plant.plantingDate.month}.${widget.plant.plantingDate.year}',
                  style: const TextStyle(
                    fontSize: 12,
                    color: Colors.grey,
                  ),
                ),
                // const SizedBox(height: 4),
                // Container(
                //   padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                //   decoration: BoxDecoration(
                //     color: Colors.green[100],
                //     borderRadius: BorderRadius.circular(12),
                //   ),
                //   child: Text(
                //     'Стадия: ${widget.plant.growthStage}',
                //     style: const TextStyle(
                //       fontSize: 12,
                //       color: Colors.green,
                //       fontWeight: FontWeight.w500,
                //     ),
                //   ),
                // ),
              ],
            ),
          ),
        ],
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
        if (widget.careEvents.isEmpty)
          _buildEmptyCareEvent()
        else
          ...widget.careEvents.map((event) => _buildCareEventCard(context, event)),
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
                    onPressed: () {},
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
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (_varietyData != null) ...[
                  // Структурированное отображение данных сорта
                  _buildVarietyInfoCard(),
                ] else ...[
                  // Стандартное описание растения
                  Text(
                    widget.plant.description,
                    style: const TextStyle(
                      fontSize: 14,
                      height: 1.4,
                    ),
                  ),
                ],
                const SizedBox(height: 12),
                ElevatedButton.icon(
                  onPressed: (_loadingDescription || _varietyData != null) ? null : _loadPlantDescription,
                  icon: _loadingDescription 
                    ? const SizedBox(
                        width: 16,
                        height: 16,
                        child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                      )
                    : const Icon(Icons.cloud_download, size: 16),
                  label: const Text('Загрузить описание'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                ),
              ],
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
        // График подкормок
        Card(
          elevation: 0,
          margin: const EdgeInsets.only(bottom: 12),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
            side: const BorderSide(color: Color(0xFFEEEEEE)),
          ),
          child: ListTile(
            leading: const Icon(Icons.calendar_today, color: Colors.green),
            title: const Text('График подкормок'),
            subtitle: const Text('Годовой план ухода (сводный)'),
            trailing: const Icon(Icons.arrow_forward_ios, size: 16),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => FeedingScheduleScreen(plant: widget.plant, user: widget.user),
                ),
              );
            },
          ),
        ),
        
        // План ухода подробно
        Card(
          elevation: 0,
          margin: const EdgeInsets.only(bottom: 12),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
            side: const BorderSide(color: Color(0xFFEEEEEE)),
          ),
          child: ListTile(
            leading: const Icon(Icons.list_alt, color: Colors.green),
            title: const Text('План ухода подробно'),
            subtitle: const Text('Все операции и материалы'),
            trailing: const Icon(Icons.arrow_forward_ios, size: 16),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => CarePlanDetailsScreen(plant: widget.plant, user: widget.user),
                ),
              );
            },
          ),
        ),
        // Семена и саженцы - не кликабельный с надписью "Скоро"
        Card(
          elevation: 0,
          margin: const EdgeInsets.only(bottom: 12),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
            side: const BorderSide(color: Color(0xFFEEEEEE)),
          ),
          child: ListTile(
            leading: const Icon(Icons.shopping_cart, color: Colors.grey),
            title: const Text('Семена и саженцы'),
            subtitle: const Text('Скоро'),
            trailing: const Text(
              'Скоро',
              style: TextStyle(
                color: Colors.grey,
                fontSize: 12,
                fontWeight: FontWeight.w500,
              ),
            ),
            onTap: null, // Не кликабельный
          ),
        ),
        // Использование культуры
        Card(
          elevation: 0,
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
                  builder: (context) => PlantUsageScreen(plant: widget.plant),
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildCareHistory() {
    if (!_historyLoaded) {
      return const Center(child: CircularProgressIndicator());
    }

    // Фильтруем операции только для текущего растения
    final plantOperations = _completedOperations
        .where((operationId) => operationId.startsWith('${widget.plant.id}_'))
        .toList();

    if (plantOperations.isEmpty) {
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
          const Center(
            child: Text(
              'Пока нет выполненных операций',
              style: TextStyle(
                color: Colors.grey,
                fontSize: 14,
              ),
            ),
          ),
        ],
      );
    }

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
        ...plantOperations.map((operationId) => _buildHistoryItem(operationId, context)),
      ],
    );
  }

  Widget _buildHistoryItem(String operationId, BuildContext context) {
    // Получаем детали операции
    final operationDetails = CareHistoryService.getOperationDetails(operationId);
    final now = DateTime.now();
    final dateStr = '${now.day}.${now.month}.${now.year}';
    
    // Определяем название операции
    String operationTitle = 'Операция выполнена';
    if (operationDetails != null) {
      final fase = operationDetails['fase']?.toString() ?? '';
      final type = operationDetails['type']?.toString() ?? '';
      if (fase.isNotEmpty) {
        operationTitle = fase;
      } else if (type.isNotEmpty) {
        operationTitle = type;
      }
    }
    
    return Card(
      elevation: 0,
      margin: const EdgeInsets.only(bottom: 8),
      color: const Color(0xFFF5F5F5),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8),
      ),
      child: InkWell(
        onTap: () {
          // Переход к деталям операции
          _navigateToOperationDetails(context, operationId, operationDetails);
        },
        borderRadius: BorderRadius.circular(8),
        child: Padding(
          padding: const EdgeInsets.all(12.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                dateStr,
                style: const TextStyle(
                  fontSize: 12,
                  color: Colors.grey,
                ),
              ),
              Expanded(
                child: Text(
                  operationTitle,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
              Row(
                children: [
                  Text(
                    'Выполнено',
                    style: const TextStyle(
                      fontSize: 12,
                      color: Colors.green,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(width: 4),
                  const Icon(
                    Icons.arrow_forward_ios,
                    size: 12,
                    color: Colors.grey,
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _navigateToOperationDetails(BuildContext context, String operationId, Map<String, dynamic>? operationDetails) {
    if (operationDetails == null) return;
    
    // Создаем экран с деталями операции
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => _OperationDetailsScreen(
          operationId: operationId,
          operationDetails: operationDetails,
          plant: widget.plant,
        ),
      ),
    );
  }
}

// Экран с деталями выполненной операции
class _OperationDetailsScreen extends StatelessWidget {
  final String operationId;
  final Map<String, dynamic> operationDetails;
  final Plant plant;

  const _OperationDetailsScreen({
    required this.operationId,
    required this.operationDetails,
    required this.plant,
  });

  @override
  Widget build(BuildContext context) {
    final String type = operationDetails['type']?.toString() ?? '';
    final String fase = operationDetails['fase']?.toString() ?? '';
    final String period = operationDetails['period']?.toString() ?? '';
    final String description = operationDetails['description']?.toString() ?? '';
    final List<dynamic> materials = operationDetails['materials'] as List<dynamic>? ?? [];

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text(
          'Детали операции',
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
            // Заголовок
            Text(
              'Операция для ${plant.name}',
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),
            const SizedBox(height: 20),

            // Основная информация
            Card(
              elevation: 0,
              color: const Color(0xFFF8F9FA),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
                side: const BorderSide(color: Color(0xFFEEEEEE)),
              ),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (fase.isNotEmpty) ...[
                      Text(
                        'Фаза: $fase',
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.black87,
                        ),
                      ),
                      const SizedBox(height: 8),
                    ],
                    if (type.isNotEmpty) ...[
                      Text(
                        'Тип операции: $type',
                        style: const TextStyle(
                          fontSize: 14,
                          color: Colors.black87,
                        ),
                      ),
                      const SizedBox(height: 8),
                    ],
                    if (period.isNotEmpty) ...[
                      Text(
                        'Период: $period',
                        style: const TextStyle(
                          fontSize: 14,
                          color: Colors.green,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 8),
                    ],
                    if (description.isNotEmpty) ...[
                      Text(
                        'Описание:',
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          color: Colors.black87,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        description,
                        style: const TextStyle(
                          fontSize: 14,
                          color: Colors.black87,
                          height: 1.4,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ),

            // Материалы
            if (materials.isNotEmpty) ...[
              const SizedBox(height: 16),
              const Text(
                'Использованные материалы:',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
              const SizedBox(height: 12),
              ...materials.map((material) => _buildMaterialCard(material as Map<String, dynamic>)),
            ],

            // Статус выполнения
            const SizedBox(height: 16),
            Card(
              elevation: 0,
              color: Colors.green.withOpacity(0.1),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
                side: const BorderSide(color: Colors.green),
              ),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Row(
                  children: [
                    const Icon(
                      Icons.check_circle,
                      color: Colors.green,
                      size: 24,
                    ),
                    const SizedBox(width: 12),
                    const Expanded(
                      child: Text(
                        'Операция выполнена',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.green,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMaterialCard(Map<String, dynamic> material) {
    final String name = (material['name'] ?? '').toString();
    final String type = (material['type'] ?? '').toString();
    final String norm = (material['norm'] ?? '').toString();
    final String method = (material['method'] ?? '').toString();
    final String frequency = (material['frequency'] ?? '').toString();
    final String warning = (material['warning'] ?? '').toString();
    final List<dynamic> alternatives = (material['alternatives'] as List<dynamic>? ?? []);

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 0,
      color: const Color(0xFFF8F9FA),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8),
        side: const BorderSide(color: Color(0xFFEEEEEE)),
      ),
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(
                    name,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                      color: Colors.black87,
                    ),
                  ),
                ),
                if (type.isNotEmpty)
                  Text(
                    type,
                    style: const TextStyle(
                      color: Colors.grey,
                      fontSize: 12,
                    ),
                  ),
              ],
            ),
            if (norm.isNotEmpty) ...[
              const SizedBox(height: 6),
              Text(
                'Норма: $norm',
                style: const TextStyle(
                  fontSize: 14,
                  color: Colors.black87,
                ),
              ),
            ],
            if (method.isNotEmpty) ...[
              const SizedBox(height: 6),
              Text(
                'Способ: $method',
                style: const TextStyle(
                  fontSize: 14,
                  color: Colors.black87,
                ),
              ),
            ],
            if (frequency.isNotEmpty) ...[
              const SizedBox(height: 6),
              Text(
                'Частота: $frequency',
                style: const TextStyle(
                  fontSize: 14,
                  color: Colors.black87,
                ),
              ),
            ],
            if (warning.isNotEmpty) ...[
              const SizedBox(height: 6),
              Text(
                'Внимание: $warning',
                style: const TextStyle(
                  color: Colors.red,
                  fontSize: 14,
                ),
              ),
            ],
            if (alternatives.isNotEmpty) ...[
              const SizedBox(height: 8),
              const Text(
                'Аналоги:',
                style: TextStyle(
                  fontWeight: FontWeight.w600,
                  fontSize: 14,
                  color: Colors.black87,
                ),
              ),
              const SizedBox(height: 4),
              ...alternatives.map((alt) {
                final altMap = alt as Map<String, dynamic>;
                final altName = (altMap['name'] ?? '').toString();
                final altComment = (altMap['comment'] ?? '').toString();
                final altNorm = (altMap['norm'] ?? '').toString();
                
                return Padding(
                  padding: const EdgeInsets.only(bottom: 4),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '- $altName: $altComment',
                        style: const TextStyle(
                          fontSize: 14,
                          color: Colors.black87,
                        ),
                      ),
                      if (altNorm.isNotEmpty) ...[
                        const SizedBox(height: 2),
                        Text(
                          '  Норма: $altNorm',
                          style: const TextStyle(
                            fontSize: 12,
                            color: Colors.grey,
                            fontStyle: FontStyle.italic,
                          ),
                        ),
                      ],
                    ],
                  ),
                );
              }),
            ],
          ],
        ),
      ),
    );
  }
}