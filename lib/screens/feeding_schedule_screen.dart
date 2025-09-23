import 'package:flutter/material.dart';
import 'dart:async';
import '../models/plant.dart';
import '../api/api_service.dart';

class FeedingScheduleScreen extends StatefulWidget {
  final Plant plant;

  const FeedingScheduleScreen({super.key, required this.plant});

  @override
  State<FeedingScheduleScreen> createState() => _FeedingScheduleScreenState();
}

class _FeedingScheduleScreenState extends State<FeedingScheduleScreen> {
  bool _loading = true;
  String? _error;
  List<Map<String, String>> _schedule = const [];

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
      final data = await ApiService.getPlantCarePlan(widget.plant.id);
      final List<dynamic> items = (data['schedule'] as List<dynamic>? ?? []);
      final mapped = items.map<Map<String, String>>((e) {
        final map = (e as Map).cast<String, dynamic>();
        return {
          'period': (map['period'] ?? '').toString(),
          'phase': (map['phase'] ?? '').toString(),
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

    if (_schedule.isEmpty) {
      return const Center(
        child: Text('Нет данных по графику подкормок'),
      );
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.all(20.0),
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
          const SizedBox(height: 12),

          const Text(
            'График формируется на основе ваших параметров и плана ухода для культуры.',
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey,
              height: 1.4,
            ),
          ),
          const SizedBox(height: 24),

          _buildScheduleTable(),
          const SizedBox(height: 24),
          const Divider(height: 1, color: Color(0xFFEEEEEE)),
          const SizedBox(height: 16),
        ],
      ),
    );
  }

  Widget _buildScheduleTable() {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: const Color(0xFFEEEEEE)),
      ),
      child: Table(
        border: TableBorder.all(
          color: const Color(0xFFEEEEEE),
          width: 1,
        ),
        columnWidths: const {
          0: FlexColumnWidth(1.2),
          1: FlexColumnWidth(1.5),
          2: FlexColumnWidth(1.3),
        },
        children: [
          TableRow(
            decoration: const BoxDecoration(color: Color(0xFFF5F5F5)),
            children: [
              _buildTableHeader('СРОК / ФЕНОФАЗА'),
              _buildTableHeader('УДОБРЕНИЕ /ПРЕПАРАТ'),
              _buildTableHeader('СПОСОБ ВНЕСЕНИЯ'),
            ],
          ),
          ..._schedule.map((item) => _buildTableRow(
                _joinPeriodPhase(item['period'] ?? '', item['phase'] ?? ''),
                item['fertilizer'] ?? '',
                item['method'] ?? '',
              )),
        ],
      ),
    );
  }

  String _joinPeriodPhase(String period, String phase) {
    if (period.isNotEmpty && phase.isNotEmpty) return '$period\n$phase';
    return period.isNotEmpty ? period : phase;
  }

  Widget _buildTableHeader(String text) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
      child: Text(
        text,
        style: const TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.bold,
          color: Colors.black87,
        ),
        textAlign: TextAlign.center,
      ),
    );
  }

  TableRow _buildTableRow(String period, String fertilizer, String method) {
    return TableRow(
      decoration: const BoxDecoration(color: Colors.white),
      children: [
        _buildTableCell(period, isPeriod: true),
        _buildTableCell(fertilizer),
        _buildTableCell(method),
      ],
    );
  }

  Widget _buildTableCell(String text, {bool isPeriod = false}) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
      child: Text(
        text,
        style: TextStyle(
          fontSize: 12,
          fontWeight: isPeriod ? FontWeight.bold : FontWeight.normal,
          color: Colors.black87,
          height: 1.4,
        ),
        textAlign: TextAlign.center,
      ),
    );
  }
}