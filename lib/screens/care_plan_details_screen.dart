import 'dart:async';
import 'package:flutter/material.dart';
import '../api/api_service.dart';
import '../models/plant.dart';
import '../models/user.dart';
import '../services/care_history_service.dart';

class CarePlanDetailsScreen extends StatefulWidget {
  final Plant plant;
  final User user;

  const CarePlanDetailsScreen({super.key, required this.plant, required this.user});

  @override
  State<CarePlanDetailsScreen> createState() => _CarePlanDetailsScreenState();
}

class _CarePlanDetailsScreenState extends State<CarePlanDetailsScreen> {
  bool _loading = true;
  String? _error;
  List<Map<String, dynamic>> _operations = const [];
  Set<String> _completedOperations = <String>{};

  @override
  void initState() {
    super.initState();
    _loadPlan();
    _loadCompletedOperations();
  }

  Future<void> _loadCompletedOperations() async {
    final completedOps = CareHistoryService.getCompletedOperations();
    setState(() {
      _completedOperations = completedOps.toSet();
    });
  }

  Future<void> _loadPlan() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final plan = await ApiService.getCarePlanByParams(
        culture: widget.plant.culture ?? widget.plant.name, // Используем culture если есть, иначе name
        region: widget.user.region,
        gardenType: widget.user.gardenType,
      );
      final ops = (plan?['operations'] as List<dynamic>? ?? [])
          .map<Map<String, dynamic>>((e) => (e as Map).cast<String, dynamic>())
          .toList();
      if (!mounted) return;
      setState(() {
        _operations = ops;
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
          'План ухода (подробно)',
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
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh, color: Colors.black),
            onPressed: _loading ? null : _loadPlan,
          ),
        ],
      ),
      body: _buildBody(),
    );
  }

  Widget _buildBody() {
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
              Text(_error!, style: const TextStyle(color: Colors.red), textAlign: TextAlign.center),
              const SizedBox(height: 12),
              ElevatedButton(onPressed: _loadPlan, child: const Text('Повторить')),
            ],
          ),
        ),
      );
    }
    if (_operations.isEmpty) {
      return const Center(child: Text('План не найден'));
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Заголовок
          _buildTitle(),
          const SizedBox(height: 20),
          
          // Операции по типам
          ..._buildOperationsByType(),
        ],
      ),
    );
  }

  Widget _buildTitle() {
    return Text(
      'План ухода для ${widget.plant.name}',
      style: const TextStyle(
        fontSize: 20,
        fontWeight: FontWeight.bold,
        color: Colors.black87,
      ),
    );
  }

  List<Widget> _buildOperationsByType() {
    // Группируем операции по типам
    final Map<String, List<Map<String, dynamic>>> operationsByType = {};
    for (final op in _operations) {
      final type = (op['type'] ?? '').toString();
      if (type.isNotEmpty) {
        operationsByType.putIfAbsent(type, () => []).add(op);
      }
    }

    final List<Widget> widgets = [];
    operationsByType.forEach((type, operations) {
      widgets.add(
        _buildExpandableSection(
          title: _getTypeTitle(type),
          operations: operations,
        ),
      );
      widgets.add(const SizedBox(height: 16));
    });

    return widgets;
  }

  String _getTypeTitle(String type) {
    switch (type.toLowerCase()) {
      case 'подкормка':
        return 'Подкормка';
      case 'обработка':
        return 'Обработка';
      case 'полив':
        return 'Полив';
      case 'обрезка':
        return 'Обрезка';
      default:
        return type;
    }
  }

  Widget _buildExpandableSection({
    required String title,
    required List<Map<String, dynamic>> operations,
  }) {
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: const BorderSide(color: Color(0xFFEEEEEE)),
      ),
      child: ExpansionTile(
        title: Text(
          title,
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Colors.black87,
          ),
        ),
        initiallyExpanded: false,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
            child: Column(
              children: operations.map((op) => _buildOperationCard(op)).toList(),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildOperationCard(Map<String, dynamic> op) {
    final String type = (op['type'] ?? '').toString();
    final String fase = (op['fase'] ?? '').toString();
    final String period = (op['period'] ?? '').toString();
    final String desc = (op['description'] ?? '').toString();
    final List<dynamic> materials = (op['materials'] as List<dynamic>? ?? []);
    
    // Создаем уникальный ID для операции
    final String operationId = _generateOperationId(op);
    final bool isCompleted = _completedOperations.contains(operationId);

    return Card(
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
            // Заголовок с чекбоксом
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      if (fase.isNotEmpty)
                        Text(
                          fase,
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Colors.black87,
                          ),
                        ),
                      if (period.isNotEmpty) ...[
                        const SizedBox(height: 4),
                        Text(
                          period,
                          style: const TextStyle(
                            fontSize: 14,
                            color: Colors.green,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
                // Чекбокс увеличенный на 15%
                Transform.scale(
                  scale: 1.15,
                  child: Checkbox(
                    value: isCompleted,
                        onChanged: (bool? value) async {
                          setState(() {
                            if (value == true) {
                              _completedOperations.add(operationId);
                              // Сохраняем детали операции для перехода
                              CareHistoryService.addCompletedOperation(
                                operationId,
                                details: {
                                  'type': type,
                                  'fase': fase,
                                  'period': period,
                                  'description': desc,
                                  'materials': materials,
                                },
                              );
                            } else {
                              _completedOperations.remove(operationId);
                              CareHistoryService.removeCompletedOperation(operationId);
                            }
                          });
                        },
                    activeColor: Colors.green,
                  ),
                ),
              ],
            ),
            
            // Описание
            if (desc.isNotEmpty) ...[
              const SizedBox(height: 8),
              Text(
                desc,
                style: const TextStyle(
                  fontSize: 14,
                  color: Colors.black87,
                  height: 1.4,
                ),
              ),
            ],
            
            // Материалы
            if (materials.isNotEmpty) ...[
              const SizedBox(height: 12),
              ...materials.map((m) => _buildMaterialCard((m as Map).cast<String, dynamic>())),
            ],
          ],
        ),
      ),
    );
  }

  String _generateOperationId(Map<String, dynamic> op) {
    // Создаем уникальный ID на основе plant.id и полей операции
    // Это гарантирует, что операции разных растений будут иметь разные ID
    final String type = (op['type'] ?? '').toString();
    final String fase = (op['fase'] ?? '').toString();
    final String period = (op['period'] ?? '').toString();
    
    // Используем формат совместимый с UpcomingEventsService
    return '${widget.plant.id}_${type}_${fase}';
  }


  Widget _buildMaterialCard(Map<String, dynamic> m) {
    final String name = (m['name'] ?? '').toString();
    final String type = (m['type'] ?? '').toString();
    final String norm = (m['norm'] ?? '').toString();
    final String method = (m['method'] ?? '').toString();
    final String frequency = (m['frequency'] ?? '').toString();
    final String warning = (m['warning'] ?? '').toString();
    final List<dynamic> alts = (m['alternatives'] as List<dynamic>? ?? []);

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(color: const Color(0xFFF8F9FA), borderRadius: BorderRadius.circular(8), border: Border.all(color: const Color(0xFFEEEEEE))),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(child: Text(name, style: const TextStyle(fontWeight: FontWeight.bold))),
              if (type.isNotEmpty) Text(type, style: const TextStyle(color: Colors.grey)),
            ],
          ),
          if (norm.isNotEmpty) ...[
            const SizedBox(height: 6),
            Text('Норма: $norm'),
          ],
          if (method.isNotEmpty) ...[
            const SizedBox(height: 6),
            Text('Способ: $method'),
          ],
          if (frequency.isNotEmpty) ...[
            const SizedBox(height: 6),
            Text('Частота: $frequency'),
          ],
          if (warning.isNotEmpty) ...[
            const SizedBox(height: 6),
            Text('Внимание: $warning', style: const TextStyle(color: Colors.red)),
          ],
          if (alts.isNotEmpty) ...[
            const SizedBox(height: 8),
            const Text('Аналоги:', style: TextStyle(fontWeight: FontWeight.w600)),
            const SizedBox(height: 4),
            ...alts.map((a) {
              final altMap = a as Map<String, dynamic>;
              final altName = (altMap['name'] ?? '').toString();
              final altComment = (altMap['comment'] ?? '').toString();
              final altNorm = (altMap['norm'] ?? '').toString();
              
              return Padding(
                padding: const EdgeInsets.only(bottom: 4),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('- $altName: $altComment'),
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
    );
  }
}
