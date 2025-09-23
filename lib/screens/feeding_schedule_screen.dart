import 'package:flutter/material.dart';
import 'dart:async';
import '../models/plant.dart';
import '../models/user.dart';
import '../api/api_service.dart';

class FeedingScheduleScreen extends StatefulWidget {
  final Plant plant;
  final User user;

  const FeedingScheduleScreen({super.key, required this.plant, required this.user});

  @override
  State<FeedingScheduleScreen> createState() => _FeedingScheduleScreenState();
}

class _FeedingScheduleScreenState extends State<FeedingScheduleScreen> {
  bool _loading = true;
  String? _error;
  List<Map<String, dynamic>> _schedule = [];

  final List<String> _months = [
    'АПРЕЛЬ', 'МАЙ', 'ИЮНЬ', 'ИЮЛЬ', 
    'АВГУСТ', 'СЕНТЯБРЬ', 'ОКТЯБРЬ', 'НОЯБРЬ'
  ];

  @override
  void initState() {
    super.initState();
    _loadSchedule();
  }

  Future<void> _loadSchedule() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      // Получаем план ухода из БД по параметрам пользователя
      final plan = await ApiService.getCarePlanByParams(
        culture: widget.plant.culture ?? widget.plant.name,
        region: widget.user.region,
        gardenType: widget.user.gardenType,
      );
      
      if (plan == null) {
        throw Exception('План ухода не найден');
      }
      
      // Извлекаем операции из плана (поддерживаем оба формата)
      final operations = (plan['operations'] as List<dynamic>? ?? 
                         plan['schedule'] as List<dynamic>? ?? []);
      final mapped = operations.map<Map<String, dynamic>>((e) {
        final map = (e as Map).cast<String, dynamic>();
        return {
          'type': (map['type'] ?? '').toString(),
          'fase': (map['fase'] ?? map['phase'] ?? '').toString(),
          'description': (map['description'] ?? '').toString(),
          'period': (map['period'] ?? '').toString(),
          'trigger': (map['trigger'] ?? '').toString(),
          'application_condition': (map['application_condition'] ?? '').toString(),
          'materials': (map['materials'] as List<dynamic>? ?? []),
          'source': (map['source'] ?? '').toString(),
          // Совместимость со старым форматом
          'fertilizer': (map['fertilizer'] ?? '').toString(),
          'method': (map['method'] ?? '').toString(),
        };
      }).toList();
      
      if (!mounted) return;
      setState(() {
        _schedule = mapped;
        _loading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _error = e.toString();
        _loading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text(
          'График подкормок',
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
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh, color: Colors.black),
            onPressed: _loading ? null : _loadSchedule,
          ),
        ],
      ),
      body: _buildBody(),
    );
  }

  Widget _buildBody() {
    if (_loading) {
      return const Center(child: CircularProgressIndicator());
    }
    if (_error != null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.error_outline, color: Colors.red, size: 40),
              const SizedBox(height: 12),
              Text(
                _error!,
                style: const TextStyle(color: Colors.red),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 12),
              ElevatedButton(
                onPressed: _loadSchedule,
                child: const Text('Повторить'),
              )
            ],
          ),
        ),
      );
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Название растения
          Text(
            widget.plant.name,
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'График формируется на основе ваших параметров и плана ухода для культуры.',
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey,
              height: 1.4,
            ),
          ),
          const SizedBox(height: 20),

          // Таблица подкормок
          _buildFertilizerTable(),
          
          const SizedBox(height: 20),
          
        ],
      ),
    );
  }

  Widget _buildFertilizerTable() {
    if (_schedule.isEmpty) {
      return const Center(
        child: Text(
          'Нет данных для отображения',
          style: TextStyle(fontSize: 16, color: Colors.grey),
        ),
      );
    }

    // Получаем уникальные типы операций
    final uniqueTypes = _schedule
        .map((item) => item['type']?.toString() ?? '')
        .where((type) => type.isNotEmpty)
        .toSet()
        .toList();

    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: const Color(0xFFE0E0E0)),
        color: Colors.white,
      ),
      child: Column(
        children: [
          // Заголовок таблицы
          Container(
            decoration: const BoxDecoration(
              color: Color(0xFFF5F5F5),
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(8),
                topRight: Radius.circular(8),
              ),
            ),
            child: Row(
              children: [
                // Левая колонка с типом операции
                Expanded(
                  flex: 2,
                  child: Container(
                    padding: const EdgeInsets.all(12),
                    decoration: const BoxDecoration(
                      border: Border(
                        right: BorderSide(color: Color(0xFFE0E0E0)),
                      ),
                    ),
                    child: const Text(
                      'ТИП ОПЕРАЦИИ',
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                        color: Colors.black87,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ),
                // Месяцы
                Expanded(
                  flex: 8,
                  child: Row(
                    children: _months.map((month) => 
                      Expanded(
                        child: Container(
                          padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 4),
                          decoration: const BoxDecoration(
                            border: Border(
                              right: BorderSide(color: Color(0xFFE0E0E0)),
                            ),
                          ),
                          child: Text(
                            month,
                            style: const TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                              color: Colors.black87,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ),
                      ),
                    ).toList(),
                  ),
                ),
              ],
            ),
          ),
          // Строки с типами операций
          ...uniqueTypes.map((type) => _buildTypeRow(type)),
        ],
      ),
    );
  }

  Widget _buildTypeRow(String type) {
    // Получаем все записи для данного типа
    final typeItems = _schedule.where((item) => item['type']?.toString() == type).toList();
    
    // Определяем месяцы, когда выполняется этот тип операции
    final months = <int>[];
    for (final item in typeItems) {
      final period = item['period']?.toString() ?? '';
      final fase = item['fase']?.toString() ?? '';
      
      // Простая логика определения месяца по периоду/фазе
      if (period.toLowerCase().contains('апрель') || fase.toLowerCase().contains('апрель')) months.add(3);
      if (period.toLowerCase().contains('май') || fase.toLowerCase().contains('май')) months.add(4);
      if (period.toLowerCase().contains('июнь') || fase.toLowerCase().contains('июнь')) months.add(5);
      if (period.toLowerCase().contains('июль') || fase.toLowerCase().contains('июль')) months.add(6);
      if (period.toLowerCase().contains('август') || fase.toLowerCase().contains('август')) months.add(7);
      if (period.toLowerCase().contains('сентябрь') || fase.toLowerCase().contains('сентябрь')) months.add(8);
      if (period.toLowerCase().contains('октябрь') || fase.toLowerCase().contains('октябрь')) months.add(9);
      if (period.toLowerCase().contains('ноябрь') || fase.toLowerCase().contains('ноябрь')) months.add(10);
    }

    return Container(
      decoration: const BoxDecoration(
        border: Border(
          top: BorderSide(color: Color(0xFFE0E0E0)),
        ),
      ),
      child: Row(
        children: [
          // Тип операции
          Expanded(
            flex: 2,
            child: Container(
              padding: const EdgeInsets.all(8),
              decoration: const BoxDecoration(
                border: Border(
                  right: BorderSide(color: Color(0xFFE0E0E0)),
                ),
              ),
              child: Text(
                type,
                style: const TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w500,
                  color: Colors.black87,
                  height: 1.2,
                ),
              ),
            ),
          ),
          // Месяцы с цветными блоками
          Expanded(
            flex: 8,
            child: Row(
              children: List.generate(8, (index) => 
                Expanded(
                  child: Container(
                    height: 40,
                    decoration: BoxDecoration(
                      border: const Border(
                        right: BorderSide(color: Color(0xFFE0E0E0)),
                      ),
                      color: months.contains(index + 3) 
                          ? Colors.green.withOpacity(0.7)
                          : Colors.white,
                    ),
                    child: months.contains(index + 3)
                        ? Container(
                            margin: const EdgeInsets.all(2),
                            decoration: BoxDecoration(
                              color: Colors.green,
                              borderRadius: BorderRadius.circular(4),
                            ),
                          )
                        : null,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }


  String _joinPeriodPhase(String period, String phase) {
    if (period.isNotEmpty && phase.isNotEmpty) return '$period - $phase';
    return period.isNotEmpty ? period : phase;
  }
}
