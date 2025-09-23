import 'dart:async';
import 'package:flutter/material.dart';
import '../api/api_service.dart';
import '../models/plant.dart';
import '../models/user.dart';

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

  @override
  void initState() {
    super.initState();
    _loadPlan();
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
        title: const Text('План ухода (подробно)', style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold, fontSize: 18)),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0,
        centerTitle: true,
        actions: [
          IconButton(icon: const Icon(Icons.refresh, color: Colors.black), onPressed: _loading ? null : _loadPlan),
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

    return ListView.separated(
      padding: const EdgeInsets.all(16),
      itemCount: _operations.length,
      separatorBuilder: (_, __) => const SizedBox(height: 12),
      itemBuilder: (context, index) {
        final op = _operations[index];
        return _buildOperationCard(op);
      },
    );
  }

  Widget _buildOperationCard(Map<String, dynamic> op) {
    final String type = (op['type'] ?? '').toString();
    final String fase = (op['fase'] ?? '').toString();
    final String period = (op['period'] ?? '').toString();
    final String desc = (op['description'] ?? '').toString();
    final List<dynamic> materials = (op['materials'] as List<dynamic>? ?? []);

    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: const BorderSide(color: Color(0xFFEEEEEE)),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                _typeChip(type),
                const SizedBox(width: 8),
                if (period.isNotEmpty) Text(period, style: const TextStyle(color: Colors.green, fontWeight: FontWeight.w600)),
              ],
            ),
            if (fase.isNotEmpty) ...[
              const SizedBox(height: 8),
              Text(fase, style: const TextStyle(fontWeight: FontWeight.bold)),
            ],
            if (desc.isNotEmpty) ...[
              const SizedBox(height: 8),
              Text(desc, style: const TextStyle(fontSize: 14, height: 1.4)),
            ],
            const SizedBox(height: 12),
            ...materials.map((m) => _buildMaterialCard((m as Map).cast<String, dynamic>())),
          ],
        ),
      ),
    );
  }

  Widget _typeChip(String type) {
    Color color;
    switch (type) {
      case 'подкормка':
        color = Colors.orange;
        break;
      case 'обработка':
        color = Colors.blue;
        break;
      case 'полив':
        color = Colors.teal;
        break;
      default:
        color = Colors.grey;
    }
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(color: color.withOpacity(0.1), borderRadius: BorderRadius.circular(20), border: Border.all(color: color.withOpacity(0.3))),
      child: Text(type, style: TextStyle(color: color, fontWeight: FontWeight.w600)),
    );
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
            ...alts.map((a) => Padding(
                  padding: const EdgeInsets.only(bottom: 4),
                  child: Text('- ${(a as Map)['name']}: ${(a as Map)['comment'] ?? ''}')),
                ),
          ],
        ],
      ),
    );
  }
}
